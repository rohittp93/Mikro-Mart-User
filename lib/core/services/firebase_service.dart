import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/address_model.dart';
import 'package:userapp/core/models/categories.dart';
import 'package:userapp/core/models/firebase_user_model.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/core/models/orders.dart';
import 'package:userapp/core/models/user.dart';
import 'package:userapp/core/notifiers/categories_notifier.dart';
import 'package:userapp/core/notifiers/item_notifier.dart';
import 'package:userapp/core/services/database.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/views/address_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String PREF_PHONE_AUTHENTICATED = "phone_authenticated";
  final String PREF_IS_SIGNED_IN = "signed_in";

  final String PREF_USER_ID = "user_id";
  final String PREF_USER_NAME = "user_name";
  final String PREF_USER_EMAIL = "user_email";
  final String PREF_USER_PHONE = "user_phone";
  final String PREF_USER_LAT = "user_lat";
  final String PREF_USER_LNG = "user_lng";
  final String PREF_USER_HOUSE_NAME = "user_house_name";

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final String CART_VALID = "cart_valid";

  final int ORDER_PLACED = 1;

  //final AppDatabase appDatabase = AppDatabase();

  // create user object based on FirebaseUser
  FirebaseUserModel _userFromFirebaseUser(
      FirebaseUser user, bool isSignedIn, bool isPhoneVerified) {
    return user != null
        ? FirebaseUserModel(
            uid: user.uid,
            isSignedIn: isSignedIn,
            isPhoneVerified: isPhoneVerified)
        : null;
  }

  // auth change user stream
  Stream<FirebaseUserModel> get user {
    return _auth.onAuthStateChanged.map((user) {
      return _userFromFirebaseUser(user, user != null, false);
    });
  }

  addCartItem(CartItem cartItem, AppDatabase db) {
    db.insertCartItem(cartItem);
  }

  updateCartItem(CartItem cartItem, AppDatabase db) {
    db.updateCartItem(cartItem);
  }

  deleteCartItem(CartItem cartItem, AppDatabase db) {
    db.deleteCartItem(cartItem);
  }

  // sign in anonymously
  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();

      return _userFromFirebaseUser(result.user, true, false);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }



// register with email & pw
  Future registerWithEmailAndPassword(String name, String email,
      String password, AddressModel userAddress, AppDatabase db) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final prefs = await SharedPreferences.getInstance();

      prefs.setString(PREF_USER_NAME, name);

      FirebaseUser user = result.user;
      // create a new document with uid & twofactorenabled as false
      String fcmToken = await _fcm.getToken();
      GeoPoint addressLocation = new GeoPoint(
          userAddress.location.latitude, userAddress.location.longitude);

      await DatabaseService(uid: user.uid).updateUserData(
          name,
          email,
          false,
          '',
          user.uid,
          fcmToken,
          addressLocation,
          userAddress.appartmentName,
          false);
      prefs.setBool(PREF_IS_SIGNED_IN, true);

      saveUserCreds(
          id: user.uid,
          name: name,
          email: email,
          phone: null,
          lat: addressLocation.latitude,
          lng: addressLocation.longitude,
          house_name: userAddress.appartmentName);

      return _userFromFirebaseUser(user, true, false);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
  
  updateAddressInFirestore(AddressModel userAddress) async {
    final prefs = await SharedPreferences.getInstance();

    String uId = prefs.getString(PREF_USER_ID);

    GeoPoint addressLocation = new GeoPoint(
        userAddress.location.latitude, userAddress.location.longitude);

    await DatabaseService(uid: uId).updateUserAddress(addressLocation, userAddress.appartmentName);
  }

  Future<void> updateUserAddressInSharedPrefs(AddressModel addressModel) async {
    final prefs = await SharedPreferences.getInstance();

    if (addressModel.location.latitude != null) {
      prefs.setDouble(PREF_USER_LAT, addressModel.location.latitude);
    }
    if (addressModel.location.longitude != null) {
      prefs.setDouble(PREF_USER_LNG, addressModel.location.longitude);
    }
    if (addressModel.appartmentName != null) {
      prefs.setString(PREF_USER_HOUSE_NAME, addressModel.appartmentName);
    }
  }


  Future<GeoPoint> getUserAddress() async {
    final prefs = await SharedPreferences.getInstance();

    double lat =  prefs.getDouble(PREF_USER_LAT);
    double lng = prefs.getDouble(PREF_USER_LNG);

    return new GeoPoint(
        lat, lng);
  }

// signout
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  final _codeController = TextEditingController();

  // sign in with phone
  Future signInWithPhone(
      String phone, BuildContext context, AppDatabase db) async {
    //await _auth.signOut();
    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          final result =
              await registerPhoneWithSignedInUser(phone, credential, context);

          if (result != null) {
            savePhoneAndCheckAddress(phone, context);
          } else {
            // error
          }

          // This only gets called when autoRetrieval is true
        },
        verificationFailed: (AuthException authException) {
          print(authException.message);
          return null;
        },
        codeSent: (String verificationId, [int forcedResendingToken]) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                String _descriptionText =
                    'Trying to automatically read the OTP';
                bool _isLoading = true;

                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: Text(
                          "Enter the OTP sent to the registered phone number"),
                      titleTextStyle: TextStyle(
                          fontSize: 16.0,
                          color: MikroMartColors.colorPrimary,
                          fontStyle: FontStyle.normal),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            keyboardType: TextInputType.number,
                            controller: _codeController,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                _descriptionText,
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: _isLoading
                                        ? MikroMartColors.purple
                                        : MikroMartColors.errorRed,
                                    fontStyle: FontStyle.normal),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  child: _isLoading
                                      ? CircularProgressIndicator(
                                          backgroundColor:
                                              MikroMartColors.white,
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  MikroMartColors.purple),
                                          strokeWidth: 1,
                                        )
                                      : Container(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FlatButton(
                              child: Text('Confirm'),
                              textColor: MikroMartColors.colorPrimary,
                              onPressed: () async {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                setState(() {
                                  _isLoading = true;
                                });
                                final code = _codeController.text.trim();
                                AuthCredential credential =
                                    PhoneAuthProvider.getCredential(
                                        verificationId: verificationId,
                                        smsCode: code);

                                final result =
                                    await registerPhoneWithSignedInUser(
                                        phone, credential, context);

                                if (result != null) {
                                  savePhoneAndCheckAddress(phone, context);
                                } else {
                                  setState(() {
                                    _isLoading = false;
                                    _descriptionText =
                                        "OTP did not match. Please try again";
                                  });
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    );
                  },
                );
              });
        },
        codeAutoRetrievalTimeout: null);
  }

  validateCartItems(List<CartItem> cartItems) async {
    String cartMessage = CART_VALID;

    for (CartItem cartItem in cartItems) {
      DocumentReference snapshot = await Firestore.instance
          .collection('items')
          .document(cartItem.itemId);

      DocumentSnapshot datasnapshot = await snapshot.get();

      if (datasnapshot.exists) {
        Item item = Item.fromMap(datasnapshot.data, datasnapshot.documentID);

        if (item.item_stock_quantity == 0) {
          cartMessage = '${item.item_name} is out of stock';
          break;
        } else if (cartItem.cartQuantity <= item.item_stock_quantity) {
          cartMessage = CART_VALID;
        } else {
          cartMessage =
              'There are currently on ${item.item_stock_quantity}  ${item.item_name}s in stock';
          break;
        }
      } else {
        cartMessage = '${cartItem.itemName} is no longer available';
        break;
      }
    }

    return cartMessage;
  }

  Future<String> placeOrder(
      List<CartItem> cartItems, double totalAmount, AppDatabase db) async {
    FirebaseUser user = await _auth.currentUser();
    List<Map<String, dynamic>> orderItems = new List();
    final prefs = await SharedPreferences.getInstance();

    for (CartItem cartItem in cartItems) {
      orderItems.add({
        'cart_item_id': cartItem.itemId,
        'cart_item_name': cartItem.itemName,
        'cart_item_quantity': cartItem.cartQuantity,
        'item_price': cartItem.itemPrice,
        'item_image': cartItem.itemImage
      });
    }

    String userPhone = prefs.getString(PREF_USER_PHONE);

    OrderModel orderModel = new OrderModel(
        order_status: ORDER_PLACED,
        cart_items: orderItems,
        total_amount: totalAmount,
        outlet_name: cartItems[0].outletId,
        user_name: prefs.getString(PREF_USER_NAME),
        user_house_name: prefs.getString(PREF_USER_HOUSE_NAME),
        user_location: new GeoPoint(
            prefs.getDouble(PREF_USER_LAT), prefs.getDouble(PREF_USER_LNG)));

    String orderId =
        await DatabaseService(uid: user.uid).addOrder(user.uid, orderModel, userPhone);

    return orderId;
  }

  saveUserCreds(
      {@required String id,
      @required String name,
      @required String email,
      @required String phone,
      @required double lat,
      @required double lng,
      @required String house_name}) async {
    final prefs = await SharedPreferences.getInstance();

    if (id != null) {
      prefs.setString(PREF_USER_ID, id);
    }
    if (name != null) {
      prefs.setString(PREF_USER_NAME, name);
    }
    if (email != null) {
      prefs.setString(PREF_USER_EMAIL, email);
    }
    if (phone != null) {
      prefs.setString(PREF_USER_PHONE, phone);
    }
    if (lat != null) {
      prefs.setDouble(PREF_USER_LAT, lat);
    }
    if (lng != null) {
      prefs.setDouble(PREF_USER_LNG, lng);
    }
    if (house_name != null) {
      prefs.setString(PREF_USER_HOUSE_NAME, house_name);
    }
  }

  Future<User> fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();

    return User(
      id: prefs.getString(PREF_USER_ID),
      name: prefs.getString(PREF_USER_NAME),
      email: prefs.getString(PREF_USER_EMAIL),
      phone: prefs.getString(PREF_USER_PHONE),
      lat: prefs.getDouble(PREF_USER_LAT),
      lng: prefs.getDouble(PREF_USER_LNG),
      houseName: prefs.getString(PREF_USER_HOUSE_NAME),
    );
  }

  Future<String> registerPhoneWithSignedInUser(
      String phone, AuthCredential credential, context) async {
    final prefs = await SharedPreferences.getInstance();
    FirebaseUser user = await _auth.currentUser();
    if (user != null) {
      // successfully verified
      AuthResult authResult =
          await user.linkWithCredential(credential).catchError((error) {
        return null;
      });

      if (authResult != null) {
        String fcmToken = await _fcm.getToken();

        prefs.setBool(PREF_PHONE_AUTHENTICATED, true);
        DatabaseService(uid: user.uid).updateUserData(
            prefs.getString(PREF_USER_NAME),
            user.email,
            true,
            phone,
            user.uid,
            fcmToken,
            null,
            null,
            false);
        return 'success';
      } else {
        return null;
      }
    } else {
      print('Error');
      return null;
    }
  }

  // sign in with email & pw
  Future<bool> signInWithEmailAndPassword(
      String email, String password, AppDatabase db) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      FirebaseUser firebaseUser = result.user;
      if (firebaseUser != null) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool(PREF_IS_SIGNED_IN, true);

        DocumentSnapshot userDoc = await DatabaseService(uid: firebaseUser.uid)
            .fetchUserData(result.user.uid);

        bool phoneValidated = userDoc.data["two_factor_enabled"];

        if (phoneValidated) {
          prefs.setBool(PREF_PHONE_AUTHENTICATED, true);
        } else {
          prefs.setBool(PREF_PHONE_AUTHENTICATED, false);
        }

        GeoPoint location = userDoc.data["location"];

        saveUserCreds(
            id: firebaseUser.uid,
            name: userDoc.data["name"],
            email: userDoc.data["email"],
            phone: userDoc.data["phone_number"],
            lat: location.latitude,
            lng: location.longitude,
            house_name: userDoc.data['building_name']);

        return phoneValidated;
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with google
  Future<FirebaseUserModel> signInWithGoogle(AppDatabase db) async {
    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final AuthResult authResult =
          await _auth.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool(PREF_IS_SIGNED_IN, true);

      DocumentSnapshot userDoc =
          await DatabaseService(uid: user.uid).fetchUserData(user.uid);

      if (userDoc.exists) {
        bool phoneValidated = userDoc.data["two_factor_enabled"];
        GeoPoint location = userDoc.data["location"];

        saveUserCreds(
            id: user.uid,
            name: userDoc.data["name"],
            email: userDoc.data["email"],
            phone: userDoc.data["phone_number"],
            lat: location!=null ? location.latitude : null,
            lng: location!=null ? location.longitude : null,
            house_name: userDoc.data['building_name']);

        if (phoneValidated) {
          prefs.setBool(PREF_PHONE_AUTHENTICATED, true);
        } else {
          prefs.setBool(PREF_PHONE_AUTHENTICATED, false);
        }

        // db.insertUser(userModel);

        return _userFromFirebaseUser(user, true, phoneValidated);
      } else {
        String fcmToken = await _fcm.getToken();
        await DatabaseService(uid: user.uid).updateUserData(user.email,
            user.email, false, '', user.uid, fcmToken, null, null, true);
        prefs.setBool(PREF_IS_SIGNED_IN, true);

        saveUserCreds(
            id: user.uid,
            name: user.email,
            email: user.email,
            phone: null,
            lat: null,
            lng: null,
            house_name: null);

        return _userFromFirebaseUser(user, true, false);
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> updateFCMToken(String userId, String fcmToken) async {
    await DatabaseService(uid: userId).updateFCMToken(userId, fcmToken);
  }

  Future<void> savePhoneAndCheckAddress(
      String phone, BuildContext context) async {
    saveUserCreds(
        id: null,
        name: null,
        email: null,
        phone: phone,
        lat: null,
        lng: null,
        house_name: null);

    User user = await fetchUserDetails();
    if (user.houseName == null || user.houseName.isEmpty) {
      AddressModel addressModel = await Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (BuildContext context) => new AddressScreen(
              isDismissable: false,
            ),
            fullscreenDialog: true,
          ));

      GeoPoint addressLocation = new GeoPoint(
          addressModel.location.latitude, addressModel.location.longitude);

      await DatabaseService(uid: user.id).updateUserAddress(addressLocation, addressModel.appartmentName);
      await updateUserAddressInSharedPrefs(addressModel);
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/mainHome', (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/mainHome', (Route<dynamic> route) => false);
    }
    /*Navigator.of(context).pushNamedAndRemoveUntil(
        '/mainHome', (Route<dynamic> route) => false);*/
  }

  Future<void> logoutUser(AppDatabase db) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _auth.signOut();
    var logoutResult =  db.deleteAllCartItems();
    return logoutResult;
  }
}

getItemOffers(ItemNotifier notifier) async {
  QuerySnapshot snapshot = await Firestore.instance
      .collection('items')
      .where('category_id', isEqualTo: 'OFFERS')
      .getDocuments();

  List<Item> _itemList = [];

  snapshot.documents.forEach((document) {
    Item item = Item.fromMap(document.data, document.documentID);
    _itemList.add(item);
  });

  notifier.offerList = _itemList;
}

getCategories(CategoriesNotifier notifier) async {
  QuerySnapshot snapshot =
      await Firestore.instance.collection('categories').getDocuments();

  List<Category> _categories = [];

  snapshot.documents.forEach((document) {
    Category category = Category.fromMap(document.data, document.documentID);
    _categories.add(category);
  });

  notifier.categoryList = _categories;
}

final int ORDER_STATUS_QUEUED = 1;
final int ORDER_STATUS_REJECTED = 2;
final int ORDER_STATUS_PROCESSING = 3;
final int ORDER_STATUS_PROCESSED = 4;
final int ORDER_STATUS_COMPLETED = 5;

String showOrderStatus(int order) {
  switch (order) {
    case 1:
      return 'Order queued';
    case 2:
      return 'Order rejected';
    case 3:
      return 'Order processing';
    case 4:
      return 'Order processed';
    case 5:
      return 'Order completed';
    default:
  }
}

Future<List<DocumentSnapshot>> getItems(
    String categoryId, int _per_page) async {
  QuerySnapshot snapshot;
  try {
    snapshot = await Firestore.instance
        .collection('items')
        .orderBy('item_name')
        .limit(_per_page)
        .where('category_id', isEqualTo: categoryId)
        .getDocuments();
  } catch (e) {
    return null;
  }

  return snapshot.documents;
}

Future<List<DocumentSnapshot>> getOrders(int _per_page) async {
  final prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString("user_id");

  QuerySnapshot snapshot;
  try {
    snapshot = await Firestore.instance
        .collection('orders')
        .orderBy('created_time')
        .limit(_per_page)
        .where('user_id', isEqualTo: uid)
        .getDocuments();
  } catch (e) {
    return null;
  }

  return snapshot.documents;
}

Future<List<DocumentSnapshot>> getMoreOrders(
    int _per_page, DocumentSnapshot lastDocument) async {
  final prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString("user_id");

  QuerySnapshot snapshot;
  try {
    snapshot = await Firestore.instance
        .collection('orders')
        .orderBy('created_time')
        .where('user_id', isEqualTo: uid)
        .startAfterDocument(lastDocument)
        .limit(_per_page)
        .getDocuments();
  } catch (e) {
    return null;
  }
}

Future<List<DocumentSnapshot>> getMoreItems(
    String categoryId, int _per_page, DocumentSnapshot lastDocument) async {
  QuerySnapshot snapshot;
  try {
    snapshot = await Firestore.instance
        .collection('items')
        .orderBy('item_name')
        .startAfterDocument(lastDocument)
        .limit(_per_page)
        .where('category_id', isEqualTo: categoryId)
        .getDocuments();
  } catch (e) {
    return null;
  }

  return snapshot.documents;
}

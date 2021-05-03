import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/address_model.dart';
import 'package:userapp/core/models/banner.dart';
import 'package:userapp/core/models/cart_validation_response.dart';
import 'package:userapp/core/models/outlet_type.dart';
import 'package:userapp/core/models/razorpay_order.dart';
import 'package:userapp/core/models/store.dart';
import 'package:userapp/core/models/firebase_user_model.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/core/models/orders.dart';
import 'package:userapp/core/models/user.dart';
import 'package:userapp/core/models/version_check.dart';
import 'package:userapp/core/notifiers/categories_notifier.dart';
import 'package:userapp/core/notifiers/item_notifier.dart';
import 'package:userapp/core/services/database.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/views/address_screen_new.dart';

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
  final String PHONE_SAVED_ADDRESS_INVALID = "phone_saved_address_invalid";
  final String PHONE_SAVED_ADDRESS_VALID = "phone_saved_address_valid";
  final String PHONE_VERIFICATION_FAILED = "phone_verification_failed";
  final String PHONE_CODE_SENT = "phone_verification_code_sent";
  final String PHONE_VERIFICATION_COMPLETE = "phone_verification_code_sent";

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
  Future registerWithEmailAndPassword(
      BuildContext context,
      String name,
      String email,
      String password,
      AddressModel userAddress,
      AppDatabase db) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(PREF_USER_NAME, name);

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
      await prefs.setBool(PREF_IS_SIGNED_IN, true);

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
      print('ERROR SIGNING IN WITH EMAIL PW : ${e.toString()}');

      showErrorBottomSheet(context, e.message);
      return null;
    }
  }

  showErrorBottomSheet(BuildContext context, String message) {
    new Flushbar<List<String>>(
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeOutCubic,
      animationDuration: Duration(milliseconds: 600),
      duration: Duration(seconds: 10),
      backgroundColor: MikroMartColors.purpleStart,
      userInputForm: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Text(
                  message,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )),
          ],
        ),
      ),
      boxShadows: [
        BoxShadow(color: Colors.blue, offset: Offset(0.0, 0.2), blurRadius: 3.0)
      ],
      backgroundGradient: LinearGradient(colors: [
        MikroMartColors.colorPrimaryDark,
        MikroMartColors.colorPrimary
      ]),
      isDismissible: true,
      icon: Icon(
        Icons.check,
        color: Colors.white,
      ),
    )..show(context);
  }

  updateAddressInFirestore(AddressModel userAddress) async {
    final prefs = await SharedPreferences.getInstance();

    String uId = prefs.getString(PREF_USER_ID);

    GeoPoint addressLocation = new GeoPoint(
        userAddress.location.latitude, userAddress.location.longitude);
    /*await*/
    DatabaseService(uid: uId)
        .updateUserAddress(addressLocation, userAddress.appartmentName);

    await updateUserAddressInSharedPrefs(userAddress);
  }

  Future<void> updateUserAddressInSharedPrefs(AddressModel addressModel) async {
    final prefs = await SharedPreferences.getInstance();

    if (addressModel.location.latitude != null) {
      await prefs.setDouble(PREF_USER_LAT, addressModel.location.latitude);
    }
    if (addressModel.location.longitude != null) {
      await prefs.setDouble(PREF_USER_LNG, addressModel.location.longitude);
    }
    if (addressModel.appartmentName != null) {
      await prefs.setString(PREF_USER_HOUSE_NAME, addressModel.appartmentName);
    }
  }

  Future<GeoPoint> getUserAddress() async {
    final prefs = await SharedPreferences.getInstance();

    double lat = prefs.getDouble(PREF_USER_LAT);
    double lng = prefs.getDouble(PREF_USER_LNG);

    return new GeoPoint(lat, lng);
  }

  Future<LatLng> getOutletLocation(String outletId) async {
    FirebaseUser user = await _auth.currentUser();

    DocumentSnapshot outletDoc =
        await DatabaseService(uid: user.uid).fetchOutletLocation(outletId);

    Map<String, dynamic> address = outletDoc.data["address"];
    GeoPoint location = address['location'];

    print(
        'LOCATION OF OUTLET : Lat : ${location.latitude}, Longi ${location.longitude}');

    return new LatLng(location.latitude, location.longitude);
  }

  Future<String> getUserBuildingName() async {
    final prefs = await SharedPreferences.getInstance();

    String houseName = prefs.getString(PREF_USER_HOUSE_NAME);

    return houseName;
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  validateCartItems(List<CartItem> cartItems, AppDatabase db) async {
    //String cartMessage = CART_VALID;
    CartValidationResponse response = CartValidationResponse(
        status: CartResponseEnum.UNAVAILABLE,
        cartItem: null,
        currentItem: null);

    for (CartItem cartItem in cartItems) {
      DocumentReference snapshot = await Firestore.instance
          .collection('items')
          .document(cartItem.itemId);

      DocumentSnapshot datasnapshot = await snapshot.get();

      if (datasnapshot.exists) {
        Item item = Item.fromMap(datasnapshot.data, datasnapshot.documentID);

        if (item.show_item) {
          for (var i = 0; i < item.item_quantity_list.length; i++) {
            for (var j = 0; j < cartItems.length; j++) {
              if (item.item_quantity_list[i].item_quantity ==
                  cartItems[j].itemQuantity) {
                //item.item_quantity_list[i].item_price = 56;

                if (item.item_quantity_list[i].item_stock_quantity == 0) {
                  //cartMessage = '${item.item_name} is out of stock';
                  response = CartValidationResponse(
                      status: CartResponseEnum.OUT_OF_STOCK,
                      cartItem: cartItem,
                      currentItem: item);
                  break;
                } else if (cartItem.cartQuantity <=
                    item.item_quantity_list[i].item_stock_quantity) {


                  if (cartItem.itemPrice ==
                      item.item_quantity_list[i].item_price) {
                    response = CartValidationResponse(
                        status: CartResponseEnum.VALID,
                        cartItem: cartItem,
                        currentItem: item);

                  } else {
                    final newCartItem = cartItem.copyWith(
                        itemPrice: item.item_quantity_list[i].item_price,
                        cartPrice: (item.item_quantity_list[i].item_price) *
                            cartItem.cartQuantity);

                    await updateCartItem(newCartItem, db);

                    response = CartValidationResponse(
                        status: CartResponseEnum.PRICE_UPDATED,
                        cartItem: cartItem,
                        currentItem: item);

                    break;
                  }
                } else {
                  //cartMessage =
                  //    'There are currently on ${item.item_quantity_list[i].item_stock_quantity}  ${item.item_name}s in stock';

                  response = CartValidationResponse(
                      status: CartResponseEnum.OUT_OF_STOCK,
                      cartItem: cartItem,
                      currentItem: item);

                  break;
                }
              }
            }
          }

          //Check other item to see if price was updated
          if (response.status == CartResponseEnum.PRICE_UPDATED) {
            for (var i = 0; i < item.item_quantity_list.length; i++) {
              for (var j = 0; j < cartItems.length; j++) {
                if (item.item_quantity_list[i].item_quantity ==
                    cartItems[j].itemQuantity) {
                  if (cartItem.cartPrice !=
                      item.item_quantity_list[i].item_price) {
                    final newCartItem = cartItem.copyWith(
                        itemPrice: item.item_quantity_list[i].item_price,
                        cartPrice: (item.item_quantity_list[i].item_price) *
                            cartItem.cartQuantity);

                    await updateCartItem(newCartItem, db);
                  }
                }
              }
            }
          }
        } else {
          //cartMessage =
          //    '${item.item_name} is currently unavailable. Please check after some time';
          response = CartValidationResponse(
              status: CartResponseEnum.UNAVAILABLE,
              cartItem: cartItem,
              currentItem: item);
          break;
        }
      } else {
        //cartMessage = '${cartItem.itemName} is no longer available';
        break;
      }
    }

    return response;
  }

  Future<RazorPayOrderResponse> createRazorpayOrder(double amount) async {
    var client = Client();

    amount = num.parse(amount.toStringAsFixed(2)) * 100;

    Map<String, dynamic> requestBody = <String,dynamic>{
      'amount':amount
    };

     final response = await client.post(
      Uri.parse('https://us-central1-mikromart-e69ba.cloudfunctions.net/app'),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
      body: '''{\n  "amount": $amount\n}''',
    );

    print('RazorPayOrderResponse : ${response.statusCode}');

    if (response.statusCode == 200) {
      return RazorPayOrderResponse.fromMap(json.decode(response.body));
    } else {
      return null;
    }
  }

  Future<String> placeOrder(

      List<CartItem> cartItems,
      double totalAmount,
      AppDatabase db,
      String moreItemsStr,
      double deliveryCharge,
      bool paymentGatewaySelected,
      String payment_id) async {
    FirebaseUser user = await _auth.currentUser();
    List<Map<String, dynamic>> orderItems = new List();
    final prefs = await SharedPreferences.getInstance();

    for (CartItem cartItem in cartItems) {
      orderItems.add({
        'cart_item_id': cartItem.itemId,
        'cart_item_name': cartItem.itemName,
        'cart_item_quantity': cartItem.cartQuantity,
        'item_quantity': cartItem.itemQuantity,
        'item_price': cartItem.itemPrice,
        'item_image': cartItem.itemImage,
      });
    }

    String userPhone = prefs.getString(PREF_USER_PHONE);
    String userName = prefs.getString(PREF_USER_NAME);
    //moreItemsStr.isNotEmpty ? 'item_extra' : moreItemsStr: null
    String orderId = '';

    if (userName != null && userName.isNotEmpty) {
      OrderModel orderModel = new OrderModel(
          delivery_charge: deliveryCharge,
          already_paid: paymentGatewaySelected,
          order_status: ORDER_PLACED,
          cart_items: orderItems,
          total_amount: totalAmount,
          outlet_name: cartItems[0].outletId,
          user_name: userName,
          payment_id: payment_id,
          user_house_name: prefs.getString(PREF_USER_HOUSE_NAME),
          extra_item: moreItemsStr.isNotEmpty ? moreItemsStr : null,
          user_location: new GeoPoint(
              prefs.getDouble(PREF_USER_LAT), prefs.getDouble(PREF_USER_LNG)));

      orderId = await DatabaseService(uid: user.uid)
          .addOrder(user.uid, orderModel, userPhone);
    } else {
      return null;
    }

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
      await prefs.setString(PREF_USER_ID, id);
    }
    if (name != null) {
      await prefs.setString(PREF_USER_NAME, name);
    }
    if (email != null) {
      await prefs.setString(PREF_USER_EMAIL, email);
    }
    if (phone != null) {
      await prefs.setString(PREF_USER_PHONE, phone);
    }
    if (lat != null) {
      await prefs.setDouble(PREF_USER_LAT, lat);
    }
    if (lng != null) {
      await prefs.setDouble(PREF_USER_LNG, lng);
    }
    if (house_name != null) {
      await prefs.setString(PREF_USER_HOUSE_NAME, house_name);
    }
  }

  Future<MikromartUser> fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();

    return MikromartUser(
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
      String phone, AuthCredential credential) async {
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

        await prefs.setBool(PREF_PHONE_AUTHENTICATED, true);
        await DatabaseService(uid: user.uid).updateUserData(
            prefs.getString(PREF_USER_NAME),
            user.email,
            true,
            phone,
            user.uid,
            fcmToken,
            null,
            null,
            false);
        return Future.value(PHONE_VERIFICATION_COMPLETE);
      } else {
        return Future.value(PHONE_VERIFICATION_FAILED);
      }
    } else {
      print('Error');
      return Future.value(PHONE_VERIFICATION_FAILED);
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
        await prefs.setBool(PREF_IS_SIGNED_IN, true);

        DocumentSnapshot userDoc = await DatabaseService(uid: firebaseUser.uid)
            .fetchUserData(result.user.uid);

        bool phoneValidated = userDoc.data["two_factor_enabled"];

        if (phoneValidated) {
          await prefs.setBool(PREF_PHONE_AUTHENTICATED, true);
        } else {
          await prefs.setBool(PREF_PHONE_AUTHENTICATED, false);
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

        String fcmToken = await _fcm.getToken();
        await updateFCMToken(firebaseUser.uid, fcmToken);

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
      print('GOOGLESIGNIN : initiated');
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('GOOGLESIGNIN : before AuthResult');
      final AuthResult authResult =
          await _auth.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PREF_IS_SIGNED_IN, true);

      print('GOOGLESIGNIN : before Fetching userData');

      DocumentSnapshot userDoc =
          await DatabaseService(uid: user.uid).fetchUserData(user.uid);

      if (userDoc.exists) {
        print('GOOGLESIGNIN : user Exists');

        bool phoneValidated = userDoc.data["two_factor_enabled"];
        GeoPoint location = userDoc.data["location"];

        saveUserCreds(
            id: user.uid,
            name: userDoc.data["name"],
            email: userDoc.data["email"],
            phone: userDoc.data["phone_number"],
            lat: location != null ? location.latitude : null,
            lng: location != null ? location.longitude : null,
            house_name: userDoc.data['building_name']);

        if (phoneValidated) {
          await prefs.setBool(PREF_PHONE_AUTHENTICATED, true);
        } else {
          await prefs.setBool(PREF_PHONE_AUTHENTICATED, false);
        }

        // db.insertUser(userModel);
        String fcmToken = await _fcm.getToken();
        await updateFCMToken(user.uid, fcmToken);

        return _userFromFirebaseUser(user, true, phoneValidated);
      } else {
        print('GOOGLESIGNIN : before saving user');

        String fcmToken = await _fcm.getToken();
        await DatabaseService(uid: user.uid).updateUserData(user.email,
            user.email, false, '', user.uid, fcmToken, null, null, true);
        await prefs.setBool(PREF_IS_SIGNED_IN, true);

        await saveUserCreds(
            id: user.uid,
            name: user.email,
            email: user.email,
            phone: null,
            lat: null,
            lng: null,
            house_name: null);
        print('GOOGLESIGNIN : user SAved');

        return _userFromFirebaseUser(user, true, false);
      }
    } catch (e) {
      print('GOOGLESIGNIN : ERROR ' + e.toString());

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

    MikromartUser user = await fetchUserDetails();
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

      await DatabaseService(uid: user.id)
          .updateUserAddress(addressLocation, addressModel.appartmentName);
      await updateUserAddressInSharedPrefs(addressModel);
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/mainHome', (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/mainHome', (Route<dynamic> route) => false);
    }
  }

  Future<MikromartUser> savePhoneAndCheckAddr(String phone) async {
    saveUserCreds(
        id: null,
        name: null,
        email: null,
        phone: phone,
        lat: null,
        lng: null,
        house_name: null);

    MikromartUser user = await fetchUserDetails();

    return user;
  }

  Future<void> logoutUser(AppDatabase db) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _auth.signOut();
    var logoutResult = await db.deleteAllCartItems();
    return logoutResult;
  }
}

getItemOffers(ItemNotifier notifier) async {
  QuerySnapshot snapshot = await Firestore.instance
      .collection('items')
      .where('category_id', isEqualTo: 'OFFERS')
      //.where('category_id', isEqualTo: 'Oy86pXdMJeCMyuR46JRW')
      .getDocuments();

  List<Item> _itemList = [];

  snapshot.documents.forEach((document) {
    Item item = Item.fromMap(document.data, document.documentID);
    _itemList.add(item);
  });

  notifier.offerList = _itemList;
  //notifier.offerList = [];
}

checkAppVersion() async {
  DocumentSnapshot versionDatasnapshot = await Firestore.instance
      .collection('app_details')
      .document('VERSION')
      .get();

  if (versionDatasnapshot.exists) {
    Version version = Version.fromMap(versionDatasnapshot.data);

    return version;
  } else {
    return null;
  }
}

Future<List<BannerImage>> getBanners() async {
  QuerySnapshot snapshot =
      await Firestore.instance.collection('banners').getDocuments();

  List<BannerImage> _bannerList = [];

  snapshot.documents.forEach((document) {
    BannerImage banner = BannerImage.fromMap(document.data);
    _bannerList.add(banner);
  });

  return _bannerList;
}

getCategories() async {
  QuerySnapshot snapshot =
      await Firestore.instance.collection('outlet_types').getDocuments();

  List<OutletType> _categories = [];

  snapshot.documents.forEach((document) {
    OutletType outletType = OutletType.fromMap(document.data, document.documentID);
    _categories.add(outletType);
  });

  return _categories;
}

getStores(StoresNotifier notifier) async {
  QuerySnapshot snapshot =
      await Firestore.instance.collection('categories').getDocuments();

  List<Store> _categories = [];

  snapshot.documents.forEach((document) {
    Store category = Store.fromMap(document.data, document.documentID);
    _categories.add(category);
  });

  _categories.removeWhere((store) => store.category_name == 'OFFERS');

  _categories.removeWhere((store) => store.outlet_open == false);

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
  //String uid = prefs.getString("oOXmYoSP5Lg7mkHyUMlSZfa6rQQ2");

  QuerySnapshot snapshot;
  try {
    snapshot = await Firestore.instance
        .collection('orders')
        .orderBy('created_time', descending: true)
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
    String categoryId, int perPage, DocumentSnapshot lastDocument) async {
  QuerySnapshot snapshot;
  try {
    snapshot = await Firestore.instance
        .collection('items')
        .orderBy('item_name')
        .startAfterDocument(lastDocument)
        .limit(perPage)
        .where('category_id', isEqualTo: categoryId)
        .getDocuments();
  } catch (e) {
    return null;
  }

  return snapshot.documents;
}

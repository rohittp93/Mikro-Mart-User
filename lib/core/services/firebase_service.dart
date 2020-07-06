import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/categories.dart';
import 'package:userapp/core/models/firebase_user_model.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/core/notifiers/categories_notifier.dart';
import 'package:userapp/core/notifiers/item_notifier.dart';
import 'package:userapp/core/services/database.dart';
import 'package:userapp/ui/shared/colors.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String PREF_PHONE_AUTHENTICATED = "phone_authenticated";
  final String PREF_IS_SIGNED_IN = "signed_in";
  final String PREF_USER_NAME = "user_name";
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final FirebaseMessaging _fcm = FirebaseMessaging();
  final AppDatabase appDatabase = AppDatabase();

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
      String name, String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final prefs = await SharedPreferences.getInstance();

      prefs.setString(PREF_USER_NAME, name);

      FirebaseUser user = result.user;
      // create a new document with uid & twofactorenabled as false
      String fcmToken = await _fcm.getToken();
      await DatabaseService(uid: user.uid)
          .updateUserData(name, email, false, '', user.uid, fcmToken);
      prefs.setBool(PREF_IS_SIGNED_IN, true);

      return _userFromFirebaseUser(user, true, false);
    } catch (e) {
      print(e.toString());
      return null;
    }
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
  Future signInWithPhone(String phone, BuildContext context) async {
    //await _auth.signOut();
    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          //Navigator.of(context).pop();
          //registerPhoneWithSignedInUser(phone, credential, context);

          final result =
              await registerPhoneWithSignedInUser(phone, credential, context);

          if (result != null) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/mainHome', (Route<dynamic> route) => false);
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
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/mainHome',
                                      (Route<dynamic> route) => false);
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
            fcmToken);
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
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      FirebaseUser firebaseUser = result.user;
      if (firebaseUser != null) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool(PREF_IS_SIGNED_IN, true);

        DocumentSnapshot userDoc = await DatabaseService(uid: firebaseUser.uid)
            .fetchUserData(result.user.uid);

        User user = new User(
            uid: firebaseUser.uid,
            name: userDoc.data["name"],
            email: userDoc.data["email"],
            phoneValidated: userDoc.data["two_factor_enabled"],
            phone: userDoc.data["phone_number"]);

        if (user.phoneValidated) {
          prefs.setBool(PREF_PHONE_AUTHENTICATED, true);
        } else {
          prefs.setBool(PREF_PHONE_AUTHENTICATED, false);
        }

        appDatabase.insertUser(user);

        return user;
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with google
  Future<FirebaseUserModel> signInWithGoogle() async {
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
        User userModel = new User(
            uid: user.uid,
            name: userDoc.data["name"],
            email: userDoc.data["email"],
            phoneValidated: userDoc.data["two_factor_enabled"],
            phone: userDoc.data["phone_number"]);

        if (userModel.phoneValidated) {
          prefs.setBool(PREF_PHONE_AUTHENTICATED, true);
        } else {
          prefs.setBool(PREF_PHONE_AUTHENTICATED, false);
        }

        appDatabase.insertUser(userModel);

        return _userFromFirebaseUser(user, true, userModel.phoneValidated);
      } else {
        String fcmToken = await _fcm.getToken();
        await DatabaseService(uid: user.uid).updateUserData(
            user.email, user.email, false, '', user.uid, fcmToken);
        prefs.setBool(PREF_IS_SIGNED_IN, true);

        return _userFromFirebaseUser(user, true, false);
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> updateFCMToken(String userId, String fcmToken) async {
    await DatabaseService(uid: userId).updateFCMToken(userId, fcmToken);
  }
}

getItemOffers(ItemNotifier notifier) async {
  QuerySnapshot snapshot = await Firestore.instance
      .collection('items')
      .where('category_id', isEqualTo: 'KtAXEw9SFk1jtMUtNRON')
      .getDocuments();

  List<Item> _itemList = [];

  snapshot.documents.forEach((document) {
    Item item = Item.fromMap(document.data);
    _itemList.add(item);
  });

  notifier.offerList = _itemList;
}

getCategories(CategoriesNotifier notifier) async {
  QuerySnapshot snapshot = await Firestore.instance
      .collection('categories')
      .getDocuments();

  List<Category> _categories = [];

  snapshot.documents.forEach((document) {
    Category category = Category.fromMap(document.data, document.documentID);
    _categories.add(category);
  });

  notifier.categoryList = _categories;
}



Future<List<Item>> getItems(String categoryId) async {
  QuerySnapshot snapshot = await Firestore.instance
      .collection('items')
      .where('category_id', isEqualTo: categoryId)
      .getDocuments();

  List<Item> _itemList = [];

  snapshot.documents.forEach((document) {
    Item item = Item.fromMap(document.data);
    _itemList.add(item);
  });

  return _itemList;
}

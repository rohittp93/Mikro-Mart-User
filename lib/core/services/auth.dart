import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/firebase_user_model.dart';
import 'package:userapp/core/services/database.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/views/Login_staggeredAnimation/FadeContainer.dart';
import 'package:userapp/ui/views/mainHome.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String PREF_PHONE_AUTHENTICATED = "phone_authenticated";
  final String PREF_IS_SIGNED_IN = "signed_in";
  final String PREF_USER_NAME = "user_name";

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

  // sign in with google

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
  Future registerWithEmailAndPassword(String name, String email, String password) async {
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
          registerPhoneWithSignedInUser(phone, credential, context);
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
                return AlertDialog(
                  title:
                      Text("Enter the OTP sent to the registered phone number"),
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
                            "Trying to automatically read the OTP",
                            style: TextStyle(
                                fontSize: 12.0,
                                color: MikroMartColors.purple,
                                fontStyle: FontStyle.normal),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                            child: Container(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                backgroundColor: MikroMartColors.white,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    MikroMartColors.purple),
                                strokeWidth: 1,
                              ),
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
                            final code = _codeController.text.trim();
                            AuthCredential credential =
                                PhoneAuthProvider.getCredential(
                                    verificationId: verificationId,
                                    smsCode: code);

                            registerPhoneWithSignedInUser(
                                phone, credential, context);
                          },
                        ),
                      ),
                    )
                  ],
                );
              });
        },
        codeAutoRetrievalTimeout: null);
  }

  Future<void> registerPhoneWithSignedInUser(
      String phone, AuthCredential credential, context) async {
    final prefs = await SharedPreferences.getInstance();
    FirebaseUser user = await _auth.currentUser();
    if (user != null) {
      // successfully verified
      user.linkWithCredential(credential).then((AuthResult value) async {
        String fcmToken = await _fcm.getToken();

        await DatabaseService(uid: user.uid)
            .updateUserData(prefs.getString(PREF_USER_NAME), user.email, true, phone, user.uid, fcmToken);
        prefs.setBool(PREF_PHONE_AUTHENTICATED, true);

        Navigator.of(context)
            .pushNamedAndRemoveUntil('/mainHome', (Route<dynamic> route) => false);
      });
    } else {
      print('Error');
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
            name: "name",
            email: "dummy_email",
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

  Future<void> updateFCMToken(String userId, String fcmToken) async {
    await DatabaseService(uid: userId).updateFCMToken(userId, fcmToken);
  }
}

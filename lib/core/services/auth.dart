import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:userapp/core/models/otp_model.dart';
import 'package:userapp/core/models/user.dart';
import 'package:userapp/core/services/database.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/views/Login_staggeredAnimation/FadeContainer.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String PREF_PHONE_AUTHENTICATED = 'phone_authenticated';

  // create user object based on FirebaseUser
  User _userFromFirebaseUser(
      FirebaseUser user, bool isSignedIn, bool isPhoneVerified) {
    return user != null
        ? User(
            uid: user.uid,
            isSignedIn: isSignedIn,
            isPhoneVerified: isPhoneVerified)
        : null;
  }

  // sign in with google

  // auth change user stream
  Stream<User> get user {
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
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      // create a new document with uid & twofactorenabled as false
      await DatabaseService(uid: user.uid).updateUserData(false, '');
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
        await DatabaseService(uid: user.uid).updateUserData(true, phone);
        prefs.setBool(PREF_PHONE_AUTHENTICATED, true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FadeBox(
              primaryColor: Theme.of(context).primaryColor,
            ),
          ),
        );
      });
    } else {
      print('Error');
    }
  }

  // sign in with email & pw
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // Before returning the user, query the user doc from firestore to check if he is phone verified. If not, redirect
      // to phone verification screen
      await DatabaseService(uid: result.user.uid).fetchUserData();
      return _userFromFirebaseUser(result.user, true, false);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}

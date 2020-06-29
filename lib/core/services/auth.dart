import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:userapp/core/models/user.dart';
import 'package:userapp/core/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user object based on FirebaseUser
  User _userFromFirebaseUser(FirebaseUser user, bool isSignedIn,
      bool isPhoneVerified) {
    return user != null
        ? User(
        uid: user.uid,
        isSignedIn: isSignedIn,
        isPhoneVerified: isPhoneVerified)
        : null;
  }

  // sign in with email & pw

  // sign in with google
  Future SignInWithEmail(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Before returning the user, query the user doc from firestore to check if he is phone verified. Of not, redirect
      // to phone verification screen
      return _userFromFirebaseUser(result.user, true, false);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged
        .map((user) => _userFromFirebaseUser(user, user != null, false));
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
    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          Navigator.of(context).pop();
          AuthResult authResult = await _auth.signInWithCredential(credential);

          completeSignInFlow(authResult, credential, phone);

          // This only gets called when autoRetrieval is true
        },
        verificationFailed: (AuthException authException) {
          print(authException);
        },
        codeSent: (String verificationId, [int forcedResendingToken]) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text("Give the code?"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: _codeController,
                      )
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Confirm'),
                      textColor: Colors.white,
                      color: Colors.blue,
                      onPressed: () async {
                        final code = _codeController.text.trim();
                        AuthCredential credential =
                        PhoneAuthProvider.getCredential(
                            verificationId: verificationId, smsCode: code);

                        AuthResult result =
                        await _auth.signInWithCredential(credential);

                        completeSignInFlow(result, credential, phone);
                      },
                    )
                  ],
                );
              });
        },
        codeAutoRetrievalTimeout: null);
  }

  void completeSignInFlow(AuthResult result, AuthCredential credential, String phone) {
    FirebaseUser user = result.user;

    if (user != null) {
      // successfully verified

      user.linkWithCredential(credential).then((AuthResult value) async {
        await DatabaseService(uid: user.uid).updateUserData(true, phone);
      });
    } else {
      print('Error');
    }
  }
}
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/models/firebase_user_model.dart';
import 'package:userapp/core/services/auth.dart';
import 'package:userapp/ui/shared/colors.dart';
import '../shared/theme.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback onLoginClicked;

  @override
  _SignUpPageState createState() => _SignUpPageState();

  const SignUpPage({Key key, this.onLoginClicked}) : super(key: key);
}

class _SignUpPageState extends State<SignUpPage> {
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    //final theme = Provider.of<ThemeChanger>(context);
    //final user = Provider.of<User>(context);
    return Scaffold(
      key: _scaffoldkey,
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.transparent,
        child: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Container(
              child: Image.asset(
                "assets/logo.png",
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.width * 0.6,
              ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Text(
                    "Name",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: MikroMartColors.colorPrimary,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 0.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: MikroMartColors.colorPrimary,
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: const EdgeInsets.only(left: 0.0, right: 0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      obscureText: false,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Name',
                        hintStyle:
                            TextStyle(color: Theme.of(context).hintColor),
                      ),
                      onChanged: (val) {
                        setState(() => name = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: MediaQuery.of(context).size.height * 0.03,
              color: Colors.transparent,
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Text(
                    "Email",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: MikroMartColors.colorPrimary,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 0.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: MikroMartColors.colorPrimary,
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: const EdgeInsets.only(left: 0.0, right: 0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      obscureText: false,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Email',
                        hintStyle:
                            TextStyle(color: Theme.of(context).hintColor),
                      ),
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: MediaQuery.of(context).size.height * 0.03,
              color: Colors.transparent,
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Text(
                    "Password",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: MikroMartColors.colorPrimary,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 0.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: MikroMartColors.colorPrimary,
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: const EdgeInsets.only(left: 0.0, right: 0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      obscureText: true,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '*********',
                        hintStyle:
                            TextStyle(color: Theme.of(context).hintColor),
                      ),
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: MediaQuery.of(context).size.height * 0.03,
              color: Colors.transparent,
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Text(
                    "Confirm Password",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: MikroMartColors.colorPrimary,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 0.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: MikroMartColors.colorPrimary,
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: const EdgeInsets.only(left: 0.0, right: 0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      obscureText: true,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '*********',
                        hintStyle:
                            TextStyle(color: Theme.of(context).hintColor),
                      ),
                      onChanged: (val) {
                        setState(() => confirmPassword = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: MediaQuery.of(context).size.height * 0.03,
              color: Colors.transparent,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: FlatButton(
                    child: Text(
                      "Already have an account?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: MikroMartColors.colorPrimary,
                        fontSize: 15.0,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    onPressed: () => widget.onLoginClicked(),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(
                  left: 30.0,
                  right: 30.0,
                  top: MediaQuery.of(context).size.height * 0.05),
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      color: MikroMartColors.colorPrimary,
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(FocusNode());

                        if (this.name.length != 0) {
                          if (this.email.length != 0 ||
                              validateEmail(this.email)) {
                            if (this.password.length != 0 &&
                                this.password.length > 6) {
                              if (this.password == this.confirmPassword) {
                                // Perform sign up with email & pw
                                // On success, create firestore entry with twoFactorEnabled = false
                                // Redirect to phone screen by uncommenting below line

                                dynamic result =
                                    await _auth.registerWithEmailAndPassword(
                                        this.name, this.email, this.password);

                                if (result == null) {
                                  showSnackBar(
                                      'Something has gone wrong. Please try again');
                                } else {
                                  //routeWhenUserUpdates(result);
                                  routeWhenUserUpdates(
                                      dartz.cast<FirebaseUserModel>(result));
                                }
                              } else {
                                showSnackBar('Passwords don\'t match');
                              }
                            } else {
                              showSnackBar(
                                  'Password must be 6+ characters long');
                            }
                          } else {
                            showSnackBar('Email ID is invalid');
                          }
                        } else {
                          showSnackBar('Enter a valid name');
                        }
                      },
                      child: Container(
                        height: 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "SIGN UP",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }

  void showSnackBar(String message) {
    _scaffoldkey.currentState.showSnackBar(SnackBar(
      content: new Text(message),
      duration: new Duration(seconds: 3),
    ));
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  void routeWhenUserUpdates(FirebaseUserModel user) {
    if (user == null) {
    } else {
      if (user.isPhoneVerified) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/mainHome');
        });
      } else {
        Navigator.of(context).pushReplacementNamed('/phoneNumberRegister');
      }
    }
  }
}

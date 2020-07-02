import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/models/firebase_user_model.dart';
import 'package:userapp/core/services/auth.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/reveal_progress.dart';
import 'package:userapp/ui/views/PhonenumberRegister.dart';
import 'package:userapp/ui/views/mainHome.dart';
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
  bool isRegistrationFormValid = false;
  bool _isSnackbarActive = false;
  String _intentWidget = '/phoneNumberRegister';
  int _buttonAnimationState = 0;

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
                        setState(() {
                          name = val;
                          isRegistrationFormValid = validateEmail(email) &&
                              validatePassword(password) &&
                              validateUserName(val);
                        });
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
                        setState(() {
                          email = val;

                          isRegistrationFormValid = validateEmail(val) &&
                              validatePassword(password) &&
                              validateUserName(name);
                        });
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
                        setState(() {
                          password = val;

                          isRegistrationFormValid = validateEmail(email) &&
                              validatePassword(val) &&
                              validateUserName(name);
                        });
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
            Divider(
              height: MediaQuery.of(context).size.height * 0.03,
              color: Colors.transparent,
            ),
            Container(
              margin: const EdgeInsets.only(
                  left: 40.0, right: 40.0, top: 0.0, bottom: 160.0),
              child: RevealProgressButton(
                  keepStack: false,
                  isValid: this.isRegistrationFormValid,
                  intentWidgetRoute: this._intentWidget,
                  buttonAnimationState: this._buttonAnimationState,
                  buttonText: 'REGISTER',
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode());

                    if (this.name.length != 0) {
                      if (this.email.length != 0 || validateEmail(this.email)) {
                        if (this.password.length != 0 &&
                            this.password.length > 6) {
                          if (this.password == this.confirmPassword) {
                            setState(() {
                              _buttonAnimationState = 1;
                            });

                            dynamic result =
                                await _auth.registerWithEmailAndPassword(
                                    this.name, this.email, this.password);

                            if (result == null) {
                              showSnackBar(
                                  'Something has gone wrong. Please try again');
                              setState(() {
                                _buttonAnimationState = 0;
                              });
                            } else {
                              //routeWhenUserUpdates(result);
                              setState(() {
                                _buttonAnimationState = 2;
                                _intentWidget = routeWhenUserUpdates(
                                    dartz.cast<FirebaseUserModel>(result));
                              });
                            }
                          } else {
                            showSnackBar('Passwords don\'t match');
                          }
                        } else {
                          showSnackBar('Password must be 6+ characters long');
                        }
                      } else {
                        showSnackBar('Email ID is invalid');
                      }
                    } else {
                      showSnackBar('Enter a valid name');
                    }
                  }),
            )
          ],
        )),
      ),
    );
  }

  void showSnackBar(String message) {
    if (!_isSnackbarActive) {
      _isSnackbarActive = true;
      _scaffoldkey.currentState
          .showSnackBar(SnackBar(
            content: new Text(message),
            duration: new Duration(seconds: 3),
          ))
          .closed
          .then((value) => _isSnackbarActive = false);
    }
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  bool validatePassword(String text) {
    if (password.length != 0 && password.length > 6) {
      return true;
    } else {
      return false;
    }
  }

  bool validateUserName(String text) {
    if (name.length != 0) {
      return true;
    } else {
      return false;
    }
  }

  String routeWhenUserUpdates(FirebaseUserModel user) {
    if (user == null) {
      return null;
    } else {
      if (user.isPhoneVerified) {
        return '/mainHome';
      } else {
        return '/phoneNumberRegister';
      }
    }
  }
}

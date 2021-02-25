import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/address_model.dart';
import 'package:userapp/core/models/firebase_user_model.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/reveal_progress.dart';

import 'address_screen_new.dart';
import 'curvedpainter.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback onLoginClicked, onBackClicked;

  @override
  _SignUpPageState createState() => _SignUpPageState();

  const SignUpPage({Key key, this.onLoginClicked, this.onBackClicked})
      : super(key: key);
}

class _SignUpPageState extends State<SignUpPage> {
  String name = '';
  String email = '';
  AddressModel _userAddress;
  String password = '';
  String confirmPassword = '';
  bool isRegistrationFormValid = false;
  bool _isSnackbarActive = false;
  String _intentWidget = '/phoneNumberRegister';
  int _buttonAnimationState = 0;

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmForcus = FocusNode();

  @override
  Widget build(BuildContext context) {
    //final theme = Provider.of<ThemeChanger>(context);
    AppDatabase db = Provider.of<AppDatabase>(context);
    return WillPopScope(
      onWillPop: () {
        widget.onBackClicked();
        return Future.value(false);
      },
      child: Scaffold(
        key: _scaffoldkey,
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
        body: Container(
          color: Colors.transparent,
          child: SingleChildScrollView(
              child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: CurvePainter(type: 1),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24.0, bottom: 80),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Getting Started",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: MikroMartColors.white
                              , fontFamily: 'Mulish',
                              fontSize: 26.0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Create an account to continue!",
                              style: TextStyle(
                                fontWeight: FontWeight.normal
                                , fontFamily: 'Mulish',
                                color: MikroMartColors.white,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height: 142,
                        child: Image(
                          image: AssetImage('assets/dot_big.png'),
                        ),

                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 0.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: MikroMartColors.backgroundGray,
                  ),
                  borderRadius: BorderRadius.circular(100.0),
                  color: MikroMartColors.backgroundGray,
                ),
                padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                child: TextField(
                  obscureText: false,
                  textAlign: TextAlign.left,
                  style: TextStyle( fontFamily: 'Mulish',),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (v) {
                    FocusScope.of(context).requestFocus(emailFocus);
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Full Name',
                    hintStyle: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'Mulish',),
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
              SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 0.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: MikroMartColors.backgroundGray,
                  ),
                  borderRadius: BorderRadius.circular(100.0),
                  color: MikroMartColors.backgroundGray,
                ),
                padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                child: TextField(
                  obscureText: false,
                  textInputAction: TextInputAction.next,
                  style: TextStyle( fontFamily: 'Mulish',),
                  focusNode: emailFocus,
                  onSubmitted: (v) {
                    FocusScope.of(context).requestFocus(passwordFocus);
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'E-mail Address',
                    hintStyle: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'Mulish',),
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
              SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 0.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: MikroMartColors.backgroundGray,
                  ),
                  borderRadius: BorderRadius.circular(100.0),
                  color: MikroMartColors.backgroundGray,
                ),
                padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                child: TextField(
                  obscureText: true,
                  focusNode: passwordFocus,
                  textAlign: TextAlign.left,
                  style: TextStyle( fontFamily: 'Mulish',),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (v) {
                    FocusScope.of(context).requestFocus(confirmForcus);
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'Mulish',),
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
              SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 0.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: MikroMartColors.backgroundGray,
                  ),
                  borderRadius: BorderRadius.circular(100.0),
                  color: MikroMartColors.backgroundGray,
                ),
                padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                child: TextField(
                  textInputAction: TextInputAction.next,
                  style: TextStyle( fontFamily: 'Mulish',),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Confirm Password',
                    hintStyle: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'Mulish',),
                  ),
                  obscureText: true,
                  textAlign: TextAlign.left,
                  focusNode: confirmForcus,
                  onChanged: (val) {
                    setState(() => confirmPassword = val);
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () async {
                  //AddressModel result = await Navigator.pushNamed(context,'/addressScreen');

                  var result = await Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (BuildContext context) => new AddressScreen(
                          isDismissable: true,
                        ),
                        fullscreenDialog: true,
                      ));

                  setState(() {
                    _userAddress = result;
                  });
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  margin:
                      const EdgeInsets.only(left: 30.0, right: 30.0, top: 0.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: MikroMartColors.backgroundGray,
                    ),
                    borderRadius: BorderRadius.circular(100.0),
                    color: MikroMartColors.backgroundGray,
                  ),
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _userAddress != null
                          ? _userAddress.appartmentName
                          : 'Address',
                      style: _userAddress == null
                          ? TextStyle(
                              color: MikroMartColors.subtitleGray
                          , fontFamily: 'Mulish',
                              fontSize: 16.0)
                          : TextStyle(color: Colors.black, fontSize: 16.0, fontFamily: 'Mulish',),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                margin: const EdgeInsets.only(
                  left: 40.0,
                  right: 40.0,
                  top: 0.0,
                ),
                child: RevealProgressButton(
                    keepStack: false,
                    isValid: this.isRegistrationFormValid,
                    intentWidgetRoute: this._intentWidget,
                    buttonAnimationState: this._buttonAnimationState,
                    buttonText: 'SIGN UP',
                    onPressed: () async {
                      FocusScope.of(context).requestFocus(FocusNode());

                      if (this.name.length != 0) {
                        if (this.email.length != 0 ||
                            validateEmail(this.email)) {
                          if (this.password.length != 0 &&
                              this.password.length > 6) {
                            if (this.password == this.confirmPassword) {
                              if (_userAddress != null &&
                                  _userAddress.location != null) {
                                setState(() {
                                  _buttonAnimationState = 1;
                                });

                                dynamic result =
                                    await _auth.registerWithEmailAndPassword(
                                        context,
                                        this.name,
                                        this.email,
                                        this.password,
                                        this._userAddress,
                                        db);

                                if (result == null) {
                                  /* showSnackBar(
                                      'Something has gone wrong. Please try again');*/
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
                                showSnackBar('Select addreess');
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
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0, top:8, bottom: 30),
                    child: FlatButton(
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Already have an account?",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: MikroMartColors.subtitleGray
                              , fontFamily: 'Mulish',
                              fontSize: 15.0,
                            ),
                            textAlign: TextAlign.end,
                          ),
                          Text(
                            " SIGN IN",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: MikroMartColors.colorPrimary
                              , fontFamily: 'Mulish',
                              fontSize: 15.0,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                      onPressed: () => widget.onLoginClicked(),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  height: 110,
                  child: Image(
                    image: AssetImage('assets/dot_small.png'),
                  ),
                ),
              ),
            ],
          )),
        ),
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

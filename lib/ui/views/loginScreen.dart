import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/firebase_user_model.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/reveal_progress.dart';

import 'curvedpainter.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSignUpClicked, onBackClicked;

  const LoginScreen({Key key, this.onSignUpClicked, this.onBackClicked})
      : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  AnimationController _loginButtonController;
  var animationStatus = 0;
  String email = '';
  bool isLoginCredsValid = false;
  String password = '';
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();
  final GlobalKey _passwordInputKey = GlobalKey();
  final passwordFocus = FocusNode();
  bool isLoginFormValid = false;
  String _intentWidget = '/phoneNumberRegister';
  bool _isSnackbarActive = false;
  bool _signingWithGoogle = false;
  int _buttonAnimationState = 0;

  @override
  void initState() {
    _loginButtonController = AnimationController(
        duration: Duration(milliseconds: 3000), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: CurvePainter(type: 3),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 24.0, bottom: 80),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Let's Sign In",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Mulish',
                                    color: MikroMartColors.white,
                                    fontSize: 26.0,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    "Welcome back, you've been missed!",
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: MikroMartColors.white,
                                      fontFamily: 'Mulish',
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
                      margin: const EdgeInsets.only(
                          left: 30.0, right: 30.0, top: 0.0),
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
                        style: TextStyle(
                          fontFamily: 'Mulish',
                        ),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (v) {
                          FocusScope.of(context).requestFocus(passwordFocus);
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'E-mail Address',
                          hintStyle: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontFamily: 'Mulish',
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            email = val;
                            isLoginCredsValid = validateEmail(val) &&
                                validatePassword(password);
                          });
                        },
                      ),
                    ),
                    /*   Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          left: 40.0, right: 40.0, top: 10.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: MikroMartColors.colorPrimary,
                              width: 0.5,
                              style: BorderStyle.solid),
                        ),
                      ),
                      padding: const EdgeInsets.only(left: 0.0, right: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              obscureText: false,
                              textAlign: TextAlign.left,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (v) {
                                FocusScope.of(context)
                                    .requestFocus(passwordFocus);
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Email',
                                hintStyle:
                                    TextStyle(color: Theme.of(context).hintColor),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  email = val;
                                  isLoginCredsValid = validateEmail(val) &&
                                      validatePassword(password);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),*/
                    Divider(
                      height: MediaQuery.of(context).size.height * 0.03,
                      color: Colors.transparent,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          left: 30.0, right: 30.0, top: 0.0),
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
                        style: TextStyle(
                          fontFamily: 'Mulish',
                        ),
                        focusNode: passwordFocus,
                        textAlign: TextAlign.left,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontFamily: 'Mulish',
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            password = val;
                            isLoginCredsValid =
                                validateEmail(email) && validatePassword(val);
                          });
                        },
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          child: RevealProgressButton(
                            isValid: this.isLoginCredsValid,
                            keepStack: false,
                            intentWidgetRoute: this._intentWidget,
                            buttonAnimationState: this._buttonAnimationState,
                            buttonText: 'SIGN IN',
                            onPressed: () async {
                              FocusScope.of(context).requestFocus(FocusNode());

                              if (this.email.length != 0 ||
                                  validateEmail(this.email)) {
                                if (this.password.length != 0 &&
                                    this.password.length > 6) {
                                  setState(() {
                                    _buttonAnimationState = 1;
                                  });

                                  bool phoneValidated =
                                      await _auth.signInWithEmailAndPassword(
                                          this.email, this.password, db);

                                  if (phoneValidated != null) {
                                    setState(() {
                                      _buttonAnimationState = 2;
                                      _intentWidget = phoneValidated
                                          ? '/mainHome'
                                          : '/phoneNumberRegister';
                                    });
                                  } else {
                                    setState(() {
                                      _buttonAnimationState = 0;
                                    });

                                    showSnackBar(
                                        'Email & passwords don\'t match');
                                  }
                                } else {
                                  showSnackBar(
                                      'Password must be 6+ characters long');
                                }
                              } else {
                                showSnackBar('Email ID is invalid');
                              }
                            },
                          ),
                          margin: const EdgeInsets.only(
                              left: 30.0, right: 30.0, top: 40.0),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only(
                              left: 30.0, right: 30.0, top: 20.0),
                          alignment: Alignment.center,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 0.25)),
                                ),
                              ),
                              Text(
                                "OR",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Mulish',
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 0.25)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0),
                          child: OutlineButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            color: MikroMartColors.transparentGray,
                            highlightedBorderColor:
                                MikroMartColors.transparentGray,
                            textColor: MikroMartColors.colorPrimary,
                            borderSide: BorderSide(
                              color: MikroMartColors.colorPrimary,
                              //Color of the border
                              style: BorderStyle.solid,
                              //Style of the border
                              width: 2.5, //width of the border
                            ),
                            onPressed: () async {
                              setState(() {
                                _signingWithGoogle = true;
                              });
                              FirebaseUserModel user =
                                  await _auth.signInWithGoogle(db);

                              setState(() {
                                _signingWithGoogle = false;
                              });

                              if (user == null) {
                                _scaffoldkey.currentState.showSnackBar(SnackBar(
                                  content: new Text(
                                      'There was a problem signing in. Please check your credentials'),
                                  duration: new Duration(seconds: 3),
                                ));
                              } else {
                                if (user.isPhoneVerified) {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/mainHome',
                                      (Route<dynamic> route) => false);
                                } else {
                                  Navigator.of(context).pushReplacementNamed(
                                      '/phoneNumberRegister');
                                }
                              }
                            },
                            child: Container(
                              height: 50,
                              child: Center(
                                child: Text(
                                  "SIGN IN WITH GOOGLE",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: MikroMartColors.colorPrimary,
                                      fontFamily: 'Mulish',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 20.0, top: 8, bottom: 30),
                              child: FlatButton(
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      "Don't have an account ?",
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: MikroMartColors.subtitleGray,
                                        fontFamily: 'Mulish',
                                        fontSize: 15.0,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    Text(
                                      " SIGN UP",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: MikroMartColors.colorPrimary,
                                        fontFamily: 'Mulish',
                                        fontSize: 15.0,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ],
                                ),
                                onPressed: () => widget.onSignUpClicked(),
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
                    ),
                  ],
                ),
                _signingWithGoogle
                    ? Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: MikroMartColors.textGray.withOpacity(0.6),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Signing in with Google',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Mulish',
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )),
                            ],
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
    ;
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
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

  bool validatePassword(String text) {
    if (password.length != 0 && password.length > 6) {
      return true;
    } else {
      return false;
    }
  }
}

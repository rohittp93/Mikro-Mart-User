import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/firebase_user_model.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/reveal_progress.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSignUpClicked, onBackClicked;

  const LoginScreen({Key key, this.onSignUpClicked, this.onBackClicked}) : super(key: key);


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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: Text(
                              "EMAIL",
                              style: TextStyle(
                                color: MikroMartColors.colorPrimary,
                                fontWeight: FontWeight.w400,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
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
                    ),
                    Divider(
                      height: MediaQuery.of(context).size.height * 0.03,
                      color: Colors.transparent,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: Text(
                              "PASSWORD",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: MikroMartColors.colorPrimary,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
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
                              key: _passwordInputKey,
                              obscureText: true,
                              focusNode: passwordFocus,
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
                                  isLoginCredsValid = validateEmail(email) &&
                                      validatePassword(val);
                                });
                              },
                            ),
                          ),
                        ],
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
                            buttonText: 'LOGIN',
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
                     /*   Container(
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
                        ),*/
                        SizedBox(
                          height: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 48,
                              color: MikroMartColors.colorPrimary,
                              child: InkWell(
                                onTap: () async {
                                  setState(() {
                                    _signingWithGoogle = true;
                                  });
                                  FirebaseUserModel user =
                                      await _auth.signInWithGoogle(db);

                                  setState(() {
                                    _signingWithGoogle = false;
                                  });

                                  if (user == null) {
                                    _scaffoldkey.currentState
                                        .showSnackBar(SnackBar(
                                      content: new Text(
                                          'There was a problem signing in. Please check your credentials'),
                                      duration: new Duration(seconds: 3),
                                    ));
                                  } else {
                                    if (user.isPhoneVerified) {
                                      Navigator.of(context).pushNamedAndRemoveUntil(
                                          '/mainHome', (Route<dynamic> route) => false);
                                    } else {
                                      Navigator.of(context).pushReplacementNamed(
                                          '/phoneNumberRegister');
                                    }
                                  }
                                },
                                child: Center(
                                  child: Container(
                                    child: Text(
                                      "SIGN IN WITH GOOGLE",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),   Container(
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
                          padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 48,
                              color: MikroMartColors.colorPrimary,
                              child: InkWell(
                                onTap: () {
                                  widget.onSignUpClicked();
                                 /* setState(() {
                                    _signingWithGoogle = true;
                                  });
                                  FirebaseUserModel user =
                                      await _auth.signInWithGoogle(db);

                                  setState(() {
                                    _signingWithGoogle = false;
                                  });

                                  if (user == null) {
                                    _scaffoldkey.currentState
                                        .showSnackBar(SnackBar(
                                      content: new Text(
                                          'There was a problem signing in. Please check your credentials'),
                                      duration: new Duration(seconds: 3),
                                    ));
                                  } else {
                                    if (user.isPhoneVerified) {
                                      Navigator.of(context).pushNamedAndRemoveUntil(
                                          '/mainHome', (Route<dynamic> route) => false);
                                    } else {
                                      Navigator.of(context).pushReplacementNamed(
                                          '/phoneNumberRegister');
                                    }
                                  }*/
                                },
                                child: Center(
                                  child: Container(
                                    child: Text(
                                      "SIGN UP",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        )
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
                                style: TextStyle(color: Colors.white),
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

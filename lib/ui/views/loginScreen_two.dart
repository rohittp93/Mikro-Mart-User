import 'package:flutter/material.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/firebase_user_model.dart';
import 'package:userapp/core/services/auth.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/reveal_progress.dart';

class LoginScreen extends StatefulWidget {
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
 /* Size pwFieldSize;
  Offset pwFieldPosition;*/
  //FocusNode _textFocus = new FocusNode();
  bool isLoginFormValid = false;
  String _intentWidget = '/phoneNumberRegister';
  bool _isSnackbarActive = false;
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
    return Scaffold(
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
                          padding: const EdgeInsets.only(left: 40.0, top: 20),
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

                            if (this.email.length != 0 || validateEmail(this.email)) {
                              if (this.password.length != 0 &&
                                  this.password.length > 6) {
                                setState(() {
                                  _buttonAnimationState = 1;
                                });

                                User user = await   _auth.signInWithEmailAndPassword(
                                    this.email, this.password);

                                if (user != null) {
                                  setState(() {
                                    _buttonAnimationState = 2;
                                    _intentWidget = user.phoneValidated ? '/mainHome' : '/phoneNumberRegister';
                                  });
                                } else {
                                  setState(() {
                                    _buttonAnimationState = 0;
                                  });

                                  showSnackBar('Email & passwords don\'t match');
                                }
                              } else {
                                showSnackBar('Password must be 6+ characters long');
                              }
                            } else {
                              showSnackBar('Email ID is invalid');
                            }

                          },
                        ),
                        margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 80.0),
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
                        padding: const EdgeInsets.fromLTRB(30.0,20.0,30.0,0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 48,
                            color: MikroMartColors.colorPrimary,
                            child: InkWell(
                              onTap: () async {
                                FirebaseUserModel user =
                                    await _auth.signInWithGoogle();

                                if (user == null) {
                                  _scaffoldkey.currentState
                                      .showSnackBar(SnackBar(
                                    content: new Text(
                                        'There was a problem signing in. Please check your credentials'),
                                    duration: new Duration(seconds: 3),
                                  ));
                                } else {
                                  if (user.isPhoneVerified) {
                                    Navigator.of(context)
                                        .pushReplacementNamed('/mainHome');
                                  } else {
                                    Navigator.of(context)
                                        .pushReplacementNamed(
                                        '/phoneNumberRegister');
                                  }
                                }
                              },
                              child: Center(
                                child: Container(
                                  child: Text(
                                    "SIGN IN WITH GOOGLE",
                                    textAlign:
                                    TextAlign.center,
                                    style: TextStyle(
                                        color:
                                        Colors.white,
                                        fontWeight:
                                        FontWeight
                                            .bold),
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
            ],
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

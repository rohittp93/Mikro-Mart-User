import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/firebase_user_model.dart';
import 'package:userapp/core/services/auth.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/views/Login_staggeredAnimation/staggeredAnimation.dart';
import '../shared/custom_social_icons.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  AnimationController _loginButtonController;
  var animationStatus = 0;
  String email = '';
  String password = '';
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();

  @override
  void initState() {
    _loginButtonController = AnimationController(
        duration: Duration(milliseconds: 3000), vsync: this);

    super.initState();
  }

  Future<Null> _playAnimation() async {
    await _loginButtonController.reset();
    try {
      await _loginButtonController.forward().whenComplete(() {
        animationStatus = 0;
      });
      //await _loginButtonController.reverse();
    } on TickerCanceled {}
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
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            image: DecorationImage(
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.05), BlendMode.dstATop),
              image: AssetImage('assets/home_background.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Image.asset(
                      "assets/logo.png",
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.width * 0.7,
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
                              fontWeight: FontWeight.bold,
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40.0),
                          child: Text(
                            "PASSWORD",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: FlatButton(
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: MikroMartColors.colorPrimary,
                              fontSize: 15.0,
                            ),
                            textAlign: TextAlign.end,
                          ),
                          onPressed: () => {},
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Column(
                    children: <Widget>[
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
                              "OR CONNECT WITH",
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
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(
                            left: 30.0, right: 30.0, top: 20.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 8.0),
                                alignment: Alignment.center,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: FlatButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        color: Color(0Xffdb3236),
                                        onPressed: () async {
                                          //adjsgh
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
                                        child: Container(
                                          height: 48,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Expanded(
                                                child: FlatButton(
                                                  onPressed: () => {},
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Center(
                                                            child: Icon(
                                                              CustomSocial
                                                                  .google,
                                                              color:
                                                                  Colors.white,
                                                              size: 15.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Center(
                                                        child: Text(
                                                          "GOOGLE",
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
                                                    ],
                                                  ),
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
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      )
                    ],
                  ),
                ],
              ),
              animationStatus == 0
                  ? Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.95 - 180),
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                      //alignment: Alignment.center,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            color: MikroMartColors.colorPrimary,
                            onPressed: () async {
                              // TODO : Validate if Email & PW are entered & then proceed if valid.
                              // Use the auth object to invoke sign in with email & pw here
                              FocusScope.of(context).requestFocus(FocusNode());

                              if (this.email.length != 0 ||
                                  validateEmail(this.email)) {
                                if (this.password.length != 0 &&
                                    this.password.length > 6) {
                                  User user =
                                      await _auth.signInWithEmailAndPassword(
                                          this.email, this.password);

                                  if (user == null) {
                                    _scaffoldkey.currentState
                                        .showSnackBar(SnackBar(
                                      content: new Text(
                                          'There was a problem signing in. Please check your credentials'),
                                      duration: new Duration(seconds: 3),
                                    ));
                                  } else {
                                    if (user.phoneValidated) {
                                      Navigator.of(context)
                                          .pushReplacementNamed('/mainHome');
                                    } else {
                                      Navigator.of(context)
                                          .pushReplacementNamed(
                                              '/phoneNumberRegister');
                                    }
                                  }
                                } else {
                                  _scaffoldkey.currentState
                                      .showSnackBar(SnackBar(
                                    content: new Text(
                                        'Password must be 6+ characters long'),
                                    duration: new Duration(seconds: 3),
                                  ));
                                }
                              } else {
                                _scaffoldkey.currentState.showSnackBar(SnackBar(
                                  content: new Text('Email ID is invalid'),
                                  duration: new Duration(seconds: 3),
                                ));
                              }

                              /* setState(() {
                                animationStatus = 1;
                              });
                              _playAnimation();*/
                            },
                            child: Container(
                              height: 48,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "LOGIN",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],
                      ),
                    )
                  : StaggerAnimation(
                      buttonController: _loginButtonController.view,
                      //screenSize: MediaQuery.of(context).size,
                    )
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
}

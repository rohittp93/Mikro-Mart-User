import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/models/user.dart';
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
  String email = '';
  String password = '';
  String confirmPassword = '';
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    //final user = Provider.of<User>(context);

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
          child: Column(
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
                margin:
                    const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
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
                margin:
                    const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
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
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Text(
                        "CONFIRM PASSWORD",
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
                margin:
                    const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
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

                          if (this.email.length != 0 ||
                              validateEmail(this.email)) {
                            if (this.password.length != 0 &&
                                this.password.length > 6) {
                              if (this.password == this.confirmPassword) {
                                // Perform sign up with email & pw
                                // On success, create firestore entry with twoFactorEnabled = false
                                // Redirect to phone screen by uncommenting below line
                                /*
                                  Navigator.pushNamed(context, '/phoneNumberRegister');
                                */
                                dynamic result = await
                                    _auth.registerWithEmailAndPassword(
                                        this.email, this.password);


                                if (result == null) {
                                  _scaffoldkey.currentState
                                      .showSnackBar(SnackBar(
                                    content: new Text(
                                        'Something has gone wrong. Please try again'),
                                    duration: new Duration(seconds: 3),
                                  ));
                                } else {
                                  //routeWhenUserUpdates(result);
                                  routeWhenUserUpdates(dartz.cast<User>(result));

                                }
                              } else {
                                _scaffoldkey.currentState.showSnackBar(SnackBar(
                                  content: new Text('Passwords don\'t match'),
                                  duration: new Duration(seconds: 3),
                                ));
                              }
                            } else {
                              _scaffoldkey.currentState.showSnackBar(SnackBar(
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
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20.0,
                            horizontal: 20.0,
                          ),
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
          ),
        ),
      ),
    );
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  void routeWhenUserUpdates(User user) {

    if (user == null) {

    } else {
      if (user.isPhoneVerified) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/mainHome');
        });
      } else {
          Navigator.of(context).pushReplacementNamed('/phoneNumberRegister');
       /* SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/phoneNumberRegister');
        });*/
      }
    }
  }
}

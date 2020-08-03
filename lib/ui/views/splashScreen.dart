import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:userapp/core/models/address_model.dart';
import 'package:userapp/core/models/firebase_user_model.dart';
import 'package:userapp/core/models/user.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';

import 'address_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //final FirebaseMessaging _fcm = FirebaseMessaging();
  final AuthService _auth = AuthService();
  bool isAddressPageVisible = false;

  startTime() async {
    final prefs = await SharedPreferences.getInstance();
    //var _duration = new Duration(seconds: 2);
    /*return new Timer(_duration, () {
      navigationPage(prefs.getBool("signed_in") ?? false,
          prefs.getBool("phone_authenticated") ?? false);
    });*/
    print('SplashTag : startTimer CAlled');

    Future.delayed(Duration(seconds: 2), () {
      print('SplashTag : FutureDelayed Called');
      navigationPage(prefs.getBool("signed_in") ?? false,
          prefs.getBool("phone_authenticated") ?? false);
    });
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  Future<void> navigationPage(bool is_signed_in,
      bool isPhoneAuthenticated) async {
    print('SplashTag : NavigateToPage CAlled');

    if (!is_signed_in) {
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      if (isPhoneAuthenticated) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/mainHome', (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pushReplacementNamed('/phoneNumberRegister');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('SplashTag : WidgetBuild CAlled');
    return new Scaffold(
      backgroundColor: MikroMartColors.colorPrimary,
      body: new Center(
        child: Container(
          height: 150,
          width: 150,
          child: new Image.asset(
            'assets/logo.png',
            color: Colors.white,
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .height,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

/*@override
Widget build(BuildContext context) {
  //  startTime();
  return new Scaffold(
    backgroundColor: MikroMartColors.colorPrimary,
    body: new Center(
      child: Container(
        height: 150,
        width: 150,
        child: new Image.asset(
          'assets/logo.png',
          color: Colors.white,
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: MediaQuery
              .of(context)
              .size
              .height,
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}}*/

class Message {
  final String title;
  final String body;
  final String message;

  Message(this.title, this.body, this.message);
}

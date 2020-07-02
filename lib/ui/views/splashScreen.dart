import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:userapp/core/models/firebase_user_model.dart';
import 'package:userapp/core/services/auth.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final AuthService _auth = AuthService();

  startTime() async {
    final prefs = await SharedPreferences.getInstance();
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, () {
      navigationPage(
          prefs.getBool("signed_in") ?? false , prefs.getBool("phone_authenticated") ?? false);
    });
  }

  @override
  void initState() {
    super.initState();

    _fcm.configure(onMessage: (Map<String, dynamic> message) async {
      print('onMessage: $message');
      final snackBar = SnackBar(
        content: Text(message['notification']['title']),
        action: SnackBarAction(
          label: 'Go',
          onPressed: () => null,
        ),
      );

      Scaffold.of(context).showSnackBar(snackBar);
    }, onResume: (Map<String, dynamic> message) async {
      print('onResume: $message');
    }, onLaunch: (Map<String, dynamic> message) async {
      print('onLaunch: $message');
    });
  }

  void navigationPage(bool is_signed_in, bool isPhoneAuthenticated) {
      if(!is_signed_in) {
        Navigator.of(context).pushReplacementNamed('/');
      }else{
        if (isPhoneAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/mainHome');
        } else {
          Navigator.of(context).pushReplacementNamed('/phoneNumberRegister');
        }
      }
  }

  _saveDeviceToken(String userId) async {
    String fcmToken = await _fcm.getToken();
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('fcm_token', fcmToken);
    if (fcmToken != null && _auth.user != null) {
      _auth.updateFCMToken(userId, fcmToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    startTime();
    return new Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: new Center(
        child: new Image.asset(
          Theme.of(context).brightness == Brightness.light
              ? 'assets/icons&splashs/splash_day.png'
              : 'assets/icons&splashs/splash_night.png',
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

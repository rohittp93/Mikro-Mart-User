import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:userapp/core/models/user.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime(User user) async {
    final prefs = await SharedPreferences.getInstance();
    var _duration = new Duration(seconds: 3);
    print(user);
    return new Timer(_duration, () {
      navigationPage(user, prefs.getBool('phone_authenticated'));
    });
  }

  void navigationPage(User user, bool isPhoneAuthenticated) {
    if (user == null) {
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      if (isPhoneAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/mainHome');
      } else {
        Navigator.of(context).pushReplacementNamed('/phoneNumberRegister');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    //startTime();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    startTime(user);
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

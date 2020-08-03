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
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, () {
      navigationPage(prefs.getBool("signed_in") ?? false,
          prefs.getBool("phone_authenticated") ?? false);
    });
  }

  @override
  void initState() {
    super.initState();

    /*_fcm.configure(onMessage: (Map<String, dynamic> message) async {
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
    });*/
  }

  Future<void> navigationPage(
      bool is_signed_in, bool isPhoneAuthenticated) async {
    if (!is_signed_in) {
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      if (isPhoneAuthenticated) {
        //Check Address
        print('TAG 1');
       /* User user = await _auth.fetchUserDetails();
        print('TAG 2');
        if (user.houseName == null ||
            user.houseName.isEmpty && !isAddressPageVisible) {
          isAddressPageVisible = true;
          AddressModel addressModel = await Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (BuildContext context) => new AddressScreen(
                  isDismissable: false,
                ),
                fullscreenDialog: true,
              ));
          isAddressPageVisible = false;
          await _auth.updateUserAddressInSharedPrefs(addressModel);
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/mainHome', (Route<dynamic> route) => false);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/mainHome', (Route<dynamic> route) => false);
        }*/


        Navigator.of(context).pushNamedAndRemoveUntil(
            '/mainHome', (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pushReplacementNamed('/phoneNumberRegister');
      }
    }
  }

  _saveDeviceToken(String userId) async {
    /*String fcmToken = await _fcm.getToken();
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('fcm_token', fcmToken);
    if (fcmToken != null && _auth.user != null) {
      _auth.updateFCMToken(userId, fcmToken);
    }*/
  }

  @override
  Widget build(BuildContext context) {
    startTime();
    return new Scaffold(
      backgroundColor: MikroMartColors.colorPrimary,
      body: new Center(
        child: Container(
          height: 150,
          width: 150,
          child: new Image.asset(
            'assets/logo.png',
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class Message {
  final String title;
  final String body;
  final String message;

  Message(this.title, this.body, this.message);
}

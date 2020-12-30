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
import 'package:userapp/ui/views/CurvedPage.dart';

import 'address_screen.dart';
import 'curvedpainter.dart';

class SplashScreen extends StatelessWidget {
  final AuthService _auth = AuthService();
  bool isAddressPageVisible = false;

  startTime(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    Future.delayed(Duration(seconds: 2), () {
      print('SplashTag : FutureDelayed Called');
      navigationPage(prefs.getBool("signed_in") ?? false,
          prefs.getBool("phone_authenticated") ?? false, context);
    });
  }

  Future<void> navigationPage(bool is_signed_in, bool isPhoneAuthenticated,
      BuildContext context) async {
    print('SplashTag : NavigateToPage CAlled');

    if (!is_signed_in) {
      Navigator.of(context).pushReplacementNamed('/home');
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
    startTime(context);

    print('SplashTag : WidgetBuild CAlled');
    return new Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              color: MikroMartColors.colorPrimary,
              height: 80,
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: CurvePainter(type: 1),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: Center(
                      child: Container(
                        height: 180,
                        width: 180,
                        child: new Image.asset(
                          'assets/white_logo.png',
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          fit: BoxFit.cover,
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
    );
  }
}

class Message {
  final String title;
  final String body;
  final String message;

  Message(this.title, this.body, this.message);
}

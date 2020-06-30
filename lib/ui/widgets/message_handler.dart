import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:userapp/core/models/firebase_user_model.dart';
import 'package:userapp/core/services/auth.dart';

class MessageHandler extends StatefulWidget {
  @override
  _MessageHandlerState createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<FirebaseUserModel>(context);

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


    _saveDeviceToken(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return null;
  }

  _saveDeviceToken(String userId) async {
    String fcmToken = await _fcm.getToken();
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('fcm_token', fcmToken);
    if (fcmToken != null && _auth.user != null) {
      _auth.updateFCMToken(userId, fcmToken);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/models/user.dart';
import 'package:userapp/ui/views/HomePage.dart';
import 'package:userapp/ui/views/PhonenumberRegister.dart';
import 'package:userapp/ui/views/mainHome.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //return either home or login
    final user = Provider.of<User>(context);

    if (user == null) {
      return HomePage();
    } else {
      if (user.isPhoneVerified) {
        return MainHome();
      } else {
       return PhoneNumberRegister();
      }
    }
  }
}
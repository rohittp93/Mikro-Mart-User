import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/address_model.dart';
import 'package:userapp/core/models/user.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/tab_navigator.dart';
import 'package:userapp/ui/views/appspush.dart';
import 'package:userapp/ui/views/shoppingCart.dart';
import '../widgets/CusTomAppBar.dart';
import 'LandingPage.dart';
import './searchScreen.dart';
import './ProfilePage.dart';
import 'address_screen.dart';
import 'curvedpainter.dart';
import 'favoritePage.dart';

class CurvedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomPaint(
        painter: CurvePainter(type: 4),
      ),
    );
  }
}


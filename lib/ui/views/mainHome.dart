import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:userapp/ui/shared/colors.dart';
import '../widgets/CusTomAppBar.dart';
import 'LandingPage.dart';
import './searchScreen.dart';
import './ProfilePage.dart';
import 'favoritePage.dart';

class MainHome extends StatefulWidget {
  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> with TickerProviderStateMixin {
  int currentPage = 0;
  Color primaryColor;

  PageController _pageController;

  @override
  void initState() {
    super.initState();
  }

  Widget current_page(position) {
    if (position == 0) {
      return LandingPage();
    }
    if (position == 1) {
      return Center(child: SearchPanel());
    }
    if (position == 2) {
      return FavoriteList();
    }
    if (position == 3) {
      return ProfilePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    primaryColor = MikroMartColors.colorPrimary;
    return Scaffold(
      bottomNavigationBar: FancyBottomNavigation(
        textColor: MikroMartColors.colorPrimaryDark,
        activeIconColor: Colors.white,
        circleColor: primaryColor,
        inactiveIconColor: primaryColor,
        initialSelection: 0,
        tabs: [
          TabData(iconData: Icons.home, title: "Home"),
          TabData(iconData: Icons.search, title: "Search"),
          TabData(iconData: Icons.favorite, title: "Favorite"),
          TabData(iconData: Icons.person, title: "Profile"),
        ],
        onTabChangedListener: (position) {
          setState(() {
            currentPage = position;
          });
        },
      ),
      body: current_page(currentPage),
      appBar: CustomAppBar(),
    );
  }
}

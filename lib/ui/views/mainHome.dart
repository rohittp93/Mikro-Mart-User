import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/tab_navigator.dart';
import 'package:userapp/ui/views/shoppingCart.dart';
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
  //int currentPage = 0;
  String _currentPage = "Home";
  List<String> pageKeys = ["Home", "Search", "Cart", "Profile"];

  Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "Home": GlobalKey<NavigatorState>(),
    "Search": GlobalKey<NavigatorState>(),
    "Cart": GlobalKey<NavigatorState>(),
    "Profile": GlobalKey<NavigatorState>(),
  };
  //int _selectedIndex = 0;

  PageController _pageController;

  void _selectTab(String tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem].currentState.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = pageKeys[index];
        //_selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

 /* Widget current_page(position) {
    if (position == 0) {
      return LandingPage();
    }
    if (position == 1) {
      return Center(child: SearchPanel());
    }
    if (position == 2) {
      return ShoppingCart();
    }
    if (position == 3) {
      return ProfilePage();
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
        !await _navigatorKeys[_currentPage].currentState.maybePop();
       /* if (isFirstRouteInCurrentTab) {
          if (_currentPage != "Home") {
            _selectTab("Home", 1);

            return false;
          }
        }*/
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        bottomNavigationBar: FancyBottomNavigation(
          textColor: MikroMartColors.colorPrimaryDark,
          activeIconColor: Colors.white,
          circleColor: MikroMartColors.colorPrimary,
          inactiveIconColor: MikroMartColors.colorPrimary,
          initialSelection: 0,
          tabs: [
            TabData(iconData: Icons.home, title: "Home"),
            TabData(iconData: Icons.search, title: "Search"),
            TabData(iconData: Icons.shopping_cart, title: "Cart"),
            TabData(iconData: Icons.person, title: "Profile"),
          ],
          onTabChangedListener: (position) {
            /*setState(() {
              _selectedIndex = position;
              print('Tab position changed : $position');
            });*/
            _selectTab(pageKeys[position], position);
          },
        ),
        body: Stack(
          children: <Widget>[
            _buildOffstageNavigator("Home"),
            _buildOffstageNavigator("Search"),
            _buildOffstageNavigator("Cart"),
            _buildOffstageNavigator("Profile"),
          ],
        ),
        //appBar: CustomAppBar(),
      ),
    );
  }


  Widget _buildOffstageNavigator(String tabItem) {
    return Offstage(
      offstage: _currentPage != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }

/*
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
          TabData(iconData: Icons.shopping_cart, title: "Cart"),
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
  }*/
}

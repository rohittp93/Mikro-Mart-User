import 'package:flutter/material.dart';
import 'package:userapp/ui/views/LandingPage.dart';
import 'package:userapp/ui/views/ProfilePage.dart';
import 'package:userapp/ui/views/searchScreen.dart';
import 'package:userapp/ui/views/shoppingCart.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;

  @override
  Widget build(BuildContext context) {

    Widget child ;
    if(tabItem == "Home")
      child = LandingPage();
    else if(tabItem == "Search")
      child = SearchPanel();
    else if(tabItem == "Cart")
      child = ShoppingCart();
    else if(tabItem == "Profile")
      child = ProfilePage();
    
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => child
        );
      },
    );
  }
}

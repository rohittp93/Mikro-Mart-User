import 'package:flutter/material.dart';
import 'package:userapp/ui/views/LandingPage.dart';
import 'package:userapp/ui/views/profile_screen_new.dart';
import 'package:userapp/ui/views/searchScreen.dart';
import 'package:userapp/ui/views/shopping_cart_new.dart';

class TabNavigatorRoutes {
  static const String detail = '/detail';
}

class TabNavigator extends StatelessWidget {
  final Function onViewMoreClicked;
  TabNavigator({this.navigatorKey, this.tabItem, this.onViewMoreClicked});
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;

  @override
  Widget build(BuildContext context) {

    Widget child ;
    if(tabItem == "Home")
      child = LandingPage(onViewMoreClicked: onViewMoreClicked);
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

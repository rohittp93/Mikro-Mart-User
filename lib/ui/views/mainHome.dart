import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/address_model.dart';
import 'package:userapp/core/models/user.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/tab_navigator.dart';
import 'package:userapp/ui/views/address_screen_new.dart';
import 'package:userapp/ui/views/appspush.dart';
import 'package:userapp/ui/views/shoppingCart.dart';
import '../widgets/CusTomAppBar.dart';
import 'LandingPage.dart';
import './searchScreen.dart';
import 'favoritePage.dart';

class MainHome extends StatefulWidget {
  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> with TickerProviderStateMixin {
  //int currentPage = 0;
  String _currentPage = "Home";
  List<String> pageKeys = ["Home", "Search", "Cart", "Profile"];
  final AuthService _auth = AuthService();
  GlobalKey _bottomNavigationKey = GlobalKey();

  Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "Home": GlobalKey<NavigatorState>(),
    "Search": GlobalKey<NavigatorState>(),
    "Cart": GlobalKey<NavigatorState>(),
    "Profile": GlobalKey<NavigatorState>(),
  };

  int _selectedIndex = 0;

  List<CartItem> _cartItems;

  void _selectTab(String tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem].currentState.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = pageKeys[index];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfAddressAdded();
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  checkIfAddressAdded() async {
    String userHouseName = await _auth.getUserBuildingName();

    if (userHouseName == null || userHouseName.isEmpty) {
      MikromartUser user = await _auth.fetchUserDetails();
      if (user.houseName == null || user.houseName.isEmpty) {
        AddressModel addressModel = await Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (BuildContext context) => new AddressScreen(
                isDismissable: false,
              ),
              fullscreenDialog: true,
            ));
        /*await _auth.updateAddressInFirestore(
            addressModel);*/
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _cartItems = Provider.of<List<CartItem>>(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return WillPopScope(
        onWillPop: () async {
          final isFirstRouteInCurrentTab =
              !await _navigatorKeys[_currentPage].currentState.maybePop();
          return isFirstRouteInCurrentTab;
        },
        child: AppPushs(
          child: Stack(
            children: <Widget>[
              Scaffold(
                body: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: _buildOffstageNavigator("Home"),
                    ),
                    _buildOffstageNavigator("Search"),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: _buildOffstageNavigator("Cart"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 75.0),
                      child: _buildOffstageNavigator("Profile"),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Theme(
                              data: Theme.of(context)
                                  .copyWith(canvasColor: Colors.transparent),
                              child: CurvedNavigationBar(
                                height: 50.0,
                                buttonBackgroundColor:
                                    MikroMartColors.colorPrimary,
                                key: _bottomNavigationKey,
                                color: MikroMartColors.white,
                                backgroundColor: Colors.transparent,
                                index: 0,
                                animationCurve: Curves.fastLinearToSlowEaseIn,
                                animationDuration: Duration(milliseconds: 400),
                                items: <Widget>[
                                  Icon(
                                    Icons.home,
                                    size: 30,
                                    color: _selectedIndex == 0
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  Icon(
                                    Icons.search,
                                    size: 30,
                                    color: _selectedIndex == 1
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  Icon(
                                    Icons.shopping_cart,
                                    size: 30,
                                    color: _selectedIndex == 2
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  Icon(
                                    Icons.person,
                                    size: 30,
                                    color: _selectedIndex == 3
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ],
                                onTap: (position) {
                                  setState(() {
                                    _selectedIndex = position;
                                  });
                                  _selectTab(pageKeys[position], position);
                                },
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(32, 0, 32, 0),
                              color: MikroMartColors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: (){
                                        final CurvedNavigationBarState navBarState =
                                            _bottomNavigationKey.currentState;
                                        navBarState.setPage(0);

                                        setState(() {
                                          _selectedIndex = 0;
                                        });
                                        _selectTab(pageKeys[0], 0);
                                      },
                                      child: Text(
                                        'Home',
                                        style: TextStyle(
                                            fontSize: 13
                                            , fontFamily: 'Mulish',
                                            color: _selectedIndex == 0
                                                ? MikroMartColors.colorPrimary
                                                : MikroMartColors.dividerGray),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        final CurvedNavigationBarState navBarState =
                                            _bottomNavigationKey.currentState;
                                        navBarState.setPage(1);
                                        setState(() {
                                          _selectedIndex = 1;
                                        });
                                        _selectTab(pageKeys[1], 1);
                                      },
                                      child: Text(
                                        'Search',
                                        style: TextStyle(
                                            fontSize: 13
                                            , fontFamily: 'Mulish',
                                            color: _selectedIndex == 1
                                                ? MikroMartColors.colorPrimary
                                                : MikroMartColors.dividerGray),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        final CurvedNavigationBarState navBarState =
                                            _bottomNavigationKey.currentState;
                                        navBarState.setPage(2);
                                        setState(() {
                                          _selectedIndex = 2;
                                        });
                                        _selectTab(pageKeys[2], 2);
                                      },
                                      child: Text(
                                        'Cart',
                                        style: TextStyle(
                                            fontSize: 13
                                            , fontFamily: 'Mulish',
                                            color: _selectedIndex == 2
                                                ? MikroMartColors.colorPrimary
                                                : MikroMartColors.dividerGray),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        final CurvedNavigationBarState navBarState =
                                            _bottomNavigationKey.currentState;
                                        navBarState.setPage(3);
                                        setState(() {
                                          _selectedIndex = 3;
                                        });
                                        _selectTab(pageKeys[3], 3);
                                      },
                                      child: Text(
                                        'Profile',
                                        style: TextStyle(
                                            fontSize: 13
                                            , fontFamily: 'Mulish',
                                            color: _selectedIndex == 3
                                                ? MikroMartColors.colorPrimary
                                                : MikroMartColors.dividerGray),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )),
                  ],
                ),
              ),
              (_selectedIndex != 2 &&
                      _cartItems != null &&
                      _cartItems.length != 0)
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(
                          (MediaQuery.of(context).size.width -
                                  MediaQuery.of(context).size.width / 4) -
                              50,
                          0,
                          0,
                          40),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          height: 15,
                          width: 15,
                          decoration: BoxDecoration(
                              color: Colors.green, shape: BoxShape.circle),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ));
  }

  Widget _buildOffstageNavigator(String tabItem) {
    return Offstage(
      offstage: _currentPage != tabItem,
      child: TabNavigator(
        onViewMoreClicked: () {
          setState(() {
            _selectedIndex = 1;
          });
          _selectTab(pageKeys[1], 1);
        },
        navigatorKey: _navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }
}

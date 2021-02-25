import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/address_model.dart';
import 'package:userapp/core/models/user.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/dottedline.dart';
import 'package:userapp/ui/shared/theme.dart';
import 'package:userapp/ui/views/address_screen_new.dart';
import 'package:userapp/ui/views/delivery_addresses.dart.dart';
import 'package:userapp/ui/views/orders_list.dart';
import '../shared/text_styles.dart' as style;
import 'package:flare_flutter/flare_actor.dart';

import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _auth = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool shouldLogout = false;

  @override
  Future<void> initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppDatabase db = Provider.of<AppDatabase>(context);

    /*if(shouldLogout){
     logoutUser(db);
    }*/
    return FutureBuilder(
      future: _auth.fetchUserDetails(),
      builder: (BuildContext context, AsyncSnapshot<MikromartUser> snapshot) {
        print('ProfileTAG Rebuilt');

        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return new Text('');
          case ConnectionState.waiting:
            return new Text('Awaiting result...', style: TextStyle(fontFamily: 'Mulish',),);
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else {
              MikromartUser _user = snapshot.data;
              print('ProfileTAG User: ${_user.houseName}');
              return Scaffold(
                key: _scaffoldKey,
                body: SafeArea(
                  child: Container(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          height: 50,
                          color: MikroMartColors.colorPrimary,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'My Profile',
                                style: style.mediumTextTitle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 80, 20, 0),
                          child: Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.6),
                                    offset: Offset(0.0, 1.4), //(x,y)
                                    blurRadius: 8.0,
                                  ),
                                ],
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                                color: MikroMartColors.cardBackground),
                            child: Column(
                              children: <Widget>[
                                /*Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                                  child: Container(
                                    width: 83,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: MikroMartColors
                                          .itemDetailSwipeIndicatorColor,
                                    ),
                                  ),
                                ),*/
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                                  child: Text(
                                    (_user != null && _user.email != null)
                                        ? _user.email
                                        : '',
                                    style: TextStyle(
                                        fontSize: 19.0
                                        , fontFamily: 'Mulish',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                                  child: Text(
                                    (_user != null && _user.phone != null)
                                        ? _user.phone
                                        : '',
                                    style: TextStyle(
                                        fontSize: 15.0, fontFamily: 'Mulish',
                                        color: MikroMartColors.colorPrimary),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: MySeparator(color: Colors.grey),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                OrderList()));
                                  },
                                  child: Container(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 5, 20, 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Order History',
                                            style: TextStyle(
                                                fontSize: 16.0
                                                , fontFamily: 'Mulish',
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            child: Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.black,
                                              size: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: MySeparator(color: Colors.grey),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                DeliveryAddressScreen()));
                                  },
                                  child: Container(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 5, 20, 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Delivery Address',
                                            style: TextStyle(
                                                fontSize: 16.0
                                                , fontFamily: 'Mulish',
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            child: Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.black,
                                              size: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: MySeparator(color: Colors.grey),
                                ),
                                InkWell(
                                  onTap: () {
                                    print('TnC tapped');
                                  },
                                  child: Container(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 5, 20, 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Terms & Conditions',
                                            style: TextStyle(
                                                fontSize: 16.0
                                                , fontFamily: 'Mulish',
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            child: Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.black,
                                              size: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: MySeparator(color: Colors.grey),
                                ),
                                InkWell(
                                  onTap: () {
                                    showHelp(db);
                                  },
                                  child: Container(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 5, 20, 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Help',
                                            style: TextStyle(
                                                fontSize: 16.0
                                                , fontFamily: 'Mulish',
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            child: Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.black,
                                              size: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: MySeparator(color: Colors.grey),
                                ),
                                InkWell(
                                  onTap: () {
                                    showLogout(db);
                                  },
                                  child: Container(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 5, 20, 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Logout',
                                            style: TextStyle(
                                                fontSize: 16.0
                                                , fontFamily: 'Mulish',
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            child: Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.black,
                                              size: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: MySeparator(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
        }
      },
    );
  }

  final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'mikromarts@gmail.com',
      queryParameters: {'subject': 'Mikro Mart App'});

  showHelp(AppDatabase db) async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: MikroMartColors.colorPrimaryDarkOverlay));
    await showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: false,
      useRootNavigator: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 280),
      context: context,
      pageBuilder: (_, __, ___) {
        return Material(
          type: MaterialType.transparency,
          child: Align(
            alignment: Alignment.center,
            child: Wrap(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width - 50,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      21.0,
                      41,
                      21.0,
                      41,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Help ?',
                          style: style.mediumTextTitle.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: MySeparator(color: Colors.grey),
                        ),
                        InkWell(
                          onTap: () async {
                            String url = _emailLaunchUri.toString();
                            if (await canLaunch(url)) {
                              await launch(url);
                              Navigator.of(context, rootNavigator: true)
                                  .pop();
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Email',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Container(
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                      size: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: MySeparator(color: Colors.grey),
                        ),
                        InkWell(
                          onTap: () async {
                            const url = "tel:+9090080858";
                            if (await canLaunch(url) != null) {
                              await launch(url);
                              Navigator.of(context, rootNavigator: true)
                                  .pop();
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Phone',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Container(
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                      size: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: MySeparator(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  margin: EdgeInsets.only(bottom: 50, left: 12, right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    ).then((val) {
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: MikroMartColors.colorPrimaryDark));
      // Navigator.pop(context);
    }); //Navigator.of(context).push(TutorialOverlay());
  }

  showLogout(AppDatabase db) async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: MikroMartColors.colorPrimaryDarkOverlay));

    await showGeneralDialog(
      context: _scaffoldKey.currentContext,
      barrierLabel: "Barrier",
      barrierDismissible: false,
      useRootNavigator: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) {
        return Material(
          type: MaterialType.transparency,
          child: Align(
            alignment: Alignment.center,
            child: Wrap(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(_scaffoldKey.currentContext).size.width - 50,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      21.0,
                      41,
                      21.0,
                      41,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Logout ?',
                          style: style.mediumTextTitle.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            'Are you sure want to log out?',
                            style: style.mediumTextTitle.copyWith(
                                color: MikroMartColors.disabledPriceColor,
                                fontWeight: FontWeight.normal,
                                fontSize: 13),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40.0),
                                    side: BorderSide(
                                        color: MikroMartColors.colorPrimary)),
                                onPressed: () {
                                  shouldLogout = false;
                                  Navigator.of(_scaffoldKey.currentContext, rootNavigator: true)
                                      .pop();
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 11, 24, 11),
                                  child: Text(
                                    'CANCEL',
                                    style: style.mediumTextTitle.copyWith(
                                        color: MikroMartColors.colorPrimary,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                              FlatButton(
                                color: MikroMartColors.colorPrimary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40.0),
                                    side: BorderSide(
                                        color: MikroMartColors.colorPrimary)),
                                onPressed: () async {
                                  FocusScope.of(_scaffoldKey.currentContext)
                                      .requestFocus(FocusNode());
                                  shouldLogout = true;
                                  Navigator.of(_scaffoldKey.currentContext, rootNavigator: true)
                                      .pop();
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 11, 24, 11),
                                  child: Text(
                                    'LOGOUT',
                                    style: style.mediumTextTitle.copyWith(
                                        color: MikroMartColors.white,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  margin: EdgeInsets.only(bottom: 50, left: 12, right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    ).then((val) async {
      print('returned value ' + shouldLogout.toString());
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: MikroMartColors.colorPrimaryDark));
      if(shouldLogout){
        await _auth.logoutUser(db);
        Navigator.of(_scaffoldKey.currentContext, rootNavigator: true).pushNamedAndRemoveUntil("/", (Route<dynamic> route) => false);
      }
    }); //Navigator.of(context).push(TutorialOverlay());
  }

/*  Future<void> logoutUser(AppDatabase db) async {
    await _auth.logoutUser(db);
    WidgetsBinding.instance
        .addPostFrameCallback((_) =>  Navigator.pushNamedAndRemoveUntil(
        context, "/", (r) => false));
   // Navigator.of(context).pushNamedAndRemoveUntil("/", (Route<dynamic> route) => false);
  }*/
}

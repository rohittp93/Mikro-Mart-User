import 'package:flutter/material.dart';
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

  var _userAddress = '';

  @override
  Future<void> initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppDatabase db = Provider.of<AppDatabase>(context);

    return FutureBuilder(
      future: _auth.fetchUserDetails(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        print('ProfileTAG Rebuilt');

        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return new Text('');
          case ConnectionState.waiting:
            return new Text('Awaiting result...');
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else {
              User _user = snapshot.data;
              print('ProfileTAG User: ${_user.houseName}');
              return Scaffold(
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
                                        fontSize: 19.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                                  child: Text(
                                    (_user != null && _user.phone != null)
                                        ? _user.phone
                                        : '',
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500,
                                        color: MikroMartColors.colorPrimary),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: MySeparator(color: Colors.grey),
                                ),
                                InkWell(
                                  onTap: () {
                                    print('Order history tapped');
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
                                  onTap: () {
                                    print('Address tapped');
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
                                            'Terms & Cditions',
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
                                  onTap: () {
                                    print('Help tapped');
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
                                  onTap: () {
                                    print('Logout tapped');
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

  showLogoutAlert(AppDatabase db) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text("Are you sure you want to logout?"),
              titleTextStyle: TextStyle(
                  fontSize: 16.0,
                  color: MikroMartColors.purple,
                  fontStyle: FontStyle.normal),
              actions: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                      child: Text('Cancel'),
                      textColor: MikroMartColors.colorPrimary,
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                      child: Text('Confirm'),
                      textColor: MikroMartColors.colorPrimary,
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        await _auth.logoutUser(db);
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/", (r) => false);
                      },
                    ),
                  ),
                )
              ],
            );
          });
        });
  }
}

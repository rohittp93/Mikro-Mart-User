import 'package:flutter/material.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/address_model.dart';
import 'package:userapp/core/models/user.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/theme.dart';
import 'package:userapp/ui/views/orders_list.dart';
import '../shared/text_styles.dart' as style;
import 'package:flare_flutter/flare_actor.dart';

import 'address_screen.dart';
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
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return new Text('Press button to start');
          case ConnectionState.waiting:
            return new Text('Awaiting result...');
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else {
              User _user = snapshot.data;
              return Scaffold(
                body: SafeArea(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          child: Stack(
                            children: <Widget>[
                              //forground
                              Container(
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Container(
                                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Text(
                                            'PROFILE',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 24,
                                                color: MikroMartColors
                                                    .colorPrimary,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.45,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text('Email',
                                                    style: style.mediumTextTitle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800),
                                                    textAlign:
                                                        TextAlign.center),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    (_user != null &&
                                                            _user.email != null)
                                                        ? _user.email
                                                        : '',
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                    ),
                                                    textAlign:
                                                        TextAlign.center),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            width: 1.0,
                                            height: 40.0,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.45,
                                            child: Column(
                                              children: <Widget>[
                                                Text('Phone',
                                                    style: style.mediumTextTitle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800),
                                                    textAlign:
                                                        TextAlign.center),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  (_user != null &&
                                                          _user.phone != null)
                                                      ? _user.phone
                                                      : '',
                                                  style: TextStyle(
                                                    fontSize: 15.0,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    ListView(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () {},
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 25),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      'Username',
                                                      style:
                                                          style.mediumTextTitle,
                                                    ),
                                                    SizedBox(
                                                      height: 4,
                                                    ),
                                                    Text(
                                                      (_user != null &&
                                                              _user.name !=
                                                                  null)
                                                          ? _user.name
                                                          : '',
                                                      style: style
                                                          .mediumTextSubtitle,
                                                    )
                                                  ],
                                                ),
                                                //Icon(Icons.edit)
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            var result = await Navigator.push(
                                                context,
                                                new MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          new AddressScreen(
                                                    isDismissable: true,
                                                  ),
                                                  fullscreenDialog: true,
                                                ));

                                            AddressModel addressModel = result;
                                            _auth.updateAddressInFirestore(
                                                addressModel);

                                            setState(() {});
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 25),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      'Address',
                                                      style:
                                                          style.mediumTextTitle,
                                                    ),
                                                    SizedBox(
                                                      height: 4,
                                                    ),
                                                    Text(
                                                      (_user != null &&
                                                              _user.houseName !=
                                                                  null)
                                                          ? _user.houseName
                                                          : '',
                                                      style: style
                                                          .mediumTextSubtitle,
                                                    )
                                                  ],
                                                ),
                                                Icon(
                                                  Icons.edit,
                                                  color: Colors.grey,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 0, 12, 0),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          OrderList()));
                                            },
                                            child: Card(
                                              elevation: 2,
                                              child: Container(
                                                height: 50,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 25),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Center(
                                                      child: Text(
                                                        'View Order History',
                                                        style: style
                                                            .mediumTextTitle,
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Icon(
                                                        Icons.arrow_forward_ios,
                                                        color: Colors.grey,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 180,
                                        ),
                                       Align(
                                         alignment: Alignment.bottomLeft,
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: <Widget>[
                                             Container(
                                               padding: EdgeInsets.symmetric(
                                                   horizontal: 20),
                                               child: Text(
                                                 'Contact support :',
                                                 style: style.mediumTextTitle.copyWith(fontSize: 15),
                                               ),
                                             ),
                                             GestureDetector(
                                               onTap: () async{
                                                 const url = "tel:+9090080858";
                                                 if (await canLaunch(url) != null) {
                                                   await launch(url);
                                                 } else {
                                                   throw 'Could not launch $url';
                                                 }
                                               },
                                               child: Container(
                                                 padding: EdgeInsets.fromLTRB(
                                                     20, 20, 20, 0),
                                                 child: Text(
                                                   'Phone : 9090080858',
                                                   style: style.lightTextSubtitle,
                                                 ),
                                               ),
                                             ),
                                             GestureDetector(
                                               onTap: () async {
                                                 String url =
                                                 _emailLaunchUri.toString();
                                                 if (await canLaunch(url)) {
                                                   await launch(url);
                                                 } else {
                                                   throw 'Could not launch $url';
                                                 }
                                               },
                                               child: Container(
                                                 padding: EdgeInsets.fromLTRB(
                                                     20, 20, 20, 20),
                                                 child: Text(
                                                   'Email : mikromarts@gmail.com',
                                                   style: style.lightTextSubtitle,
                                                 ),
                                               ),
                                             ),
                                             SizedBox(
                                               height: 20,
                                             ),
                                             Align(
                                               alignment: Alignment.bottomCenter,
                                               child: Padding(
                                                 padding: EdgeInsets.fromLTRB(
                                                     12, 0, 12, 0),
                                                 child: FlatButton(
                                                   onPressed: () async {
                                                     showLogoutAlert(db);
                                                   },
                                                   color:
                                                   MikroMartColors.colorPrimary,
                                                   child: Container(
                                                     height: 40,
                                                     alignment: Alignment.center,
                                                     child: Text(
                                                       'LOGOUT',
                                                       style: TextStyle(
                                                           color: Colors.white,
                                                           fontSize: 16),
                                                     ),
                                                   ),
                                                 ),
                                               ),
                                             )
                                           ],
                                         ),
                                       )
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
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
                            context, "/splashScreen", (r) => false);
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

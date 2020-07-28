import 'package:flutter/material.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:userapp/core/models/address_model.dart';
import 'package:userapp/core/models/user.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/theme.dart';
import '../shared/text_styles.dart' as style;
import 'package:flare_flutter/flare_actor.dart';

import 'address_screen.dart';

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
    return FutureBuilder(
      future: _auth.fetchUserDetails(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none: return new Text('Press button to start');
          case ConnectionState.waiting: return new Text('Awaiting result...');
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
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceAround,
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
                                      height: 80.0,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceEvenly,
                                        children: <Widget>[
                                          Container(
                                            width:
                                            MediaQuery
                                                .of(context)
                                                .size
                                                .width * 0.45,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: <Widget>[
                                                Text('Email',
                                                    style: style.mediumTextTitle
                                                        .copyWith(
                                                        fontWeight: FontWeight
                                                            .w800),
                                                    textAlign: TextAlign
                                                        .center),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    (_user != null && _user.email!=null)
                                                    ? _user.email
                                                    : '',
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                    ),
                                                    textAlign: TextAlign
                                                        .center),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            color: Colors.white.withOpacity(
                                                0.5),
                                            width: 1.0,
                                            height: 40.0,
                                          ),
                                          Container(
                                            width:
                                            MediaQuery
                                                .of(context)
                                                .size
                                                .width * 0.45,
                                            child: Column(
                                              children: <Widget>[
                                                Text('Phone',
                                                    style: style.mediumTextTitle
                                                        .copyWith(
                                                        fontWeight: FontWeight
                                                            .w800),
                                                    textAlign: TextAlign
                                                        .center),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  (_user != null && _user.phone!=null)
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
                                            height:
                                            MediaQuery
                                                .of(context)
                                                .size
                                                .height * 0.08,
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width,
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      'Username',
                                                      style: style.mediumTextTitle,
                                                    ),
                                                    SizedBox(
                                                      height: 4,
                                                    ),
                                                    Text(
                                                      (_user != null && _user.name!=null)
                                                          ? _user.name
                                                          : '',
                                                      style: style.mediumTextSubtitle,
                                                    )
                                                  ],
                                                ),
                                                //Icon(Icons.edit)
                                              ],
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            var result = await Navigator.push(
                                                context,
                                                new MaterialPageRoute(
                                                  builder: (BuildContext context) =>
                                                  new AddressScreen(isDismissable: true,),
                                                  fullscreenDialog: true,
                                                ));

                                            AddressModel addressModel = result;
                                            _auth.updateUserAddress(addressModel);

                                            setState(() {

                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 25),
                                            height:
                                            MediaQuery
                                                .of(context)
                                                .size
                                                .height * 0.08,
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width,
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      'Address',
                                                      style: style.mediumTextTitle,
                                                    ),
                                                    SizedBox(
                                                      height: 4,
                                                    ),
                                                    Text(
                                                      (_user != null && _user.houseName!=null) ? _user
                                                          .houseName : '',
                                                      style: style.mediumTextSubtitle,
                                                    )
                                                  ],
                                                ),
                                                Icon(Icons.edit)
                                              ],
                                            ),
                                          ),
                                        ),
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
}

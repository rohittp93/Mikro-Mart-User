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

class DeliveryAddressScreen extends StatefulWidget {
  @override
  _DeliveryAddressScreenState createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  final AuthService _auth = AuthService();


  @override
  Future<void> initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppDatabase db = Provider.of<AppDatabase>(context);

    return FutureBuilder(
      future: _auth.fetchUserDetails(),
      builder: (BuildContext context, AsyncSnapshot<MikromartUser> snapshot) {
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
              MikromartUser _user = snapshot.data;
              print('ProfileTAG User: ${_user.houseName}');
              return Scaffold(
                body: SafeArea(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: MikroMartColors.colorPrimary,

                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 50,
                                child: FlatButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              Container(
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Delivery Address',
                                      style: style.mediumTextTitle.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.6),
                                  offset: Offset(0.0, 1.4), //(x,y)
                                  blurRadius: 3.0,
                                ),
                              ],
                              color: MikroMartColors.cardBackground,
                            ),
                            child:  Container(
                              padding: const EdgeInsets.only(left: 16.0, right:16, top: 24, bottom: 24),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                 Padding(
                                   padding: const EdgeInsets.only( top: 4,),
                                   child: Container(
                                     height: 20,
                                        child:
                                        Image.asset(
                                          'assets/map.png',
                                          color: MikroMartColors.subtitleGray,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                 ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12.0,),
                                        child: Text(
                                            _user.houseName
                                                ,style: style.mediumTextSubtitle.copyWith(fontWeight: FontWeight.bold, fontSize: 15,  color: Colors.black),
                                        ),
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


                                          setState(() {});
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 12.0, top: 22),
                                          child: Text(
                                            'Edit'
                                            ,style: style.itemnNameText.copyWith(fontStyle: FontStyle.normal, fontSize: 13, color: Colors.black),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),

                                ],
                              ),
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
}

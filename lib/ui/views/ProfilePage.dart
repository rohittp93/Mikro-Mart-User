import 'package:flutter/material.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:userapp/ui/shared/theme.dart';
import '../shared/text_styles.dart' as style;
import 'package:flare_flutter/flare_actor.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
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
                    //background
                    Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height * 0.45,
                            color: Colors.transparent,
                            child: ClipPath(
                              clipper: BackClipper(),
                              child: Container(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //forground
                    Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Center(
                              child: Container(
                                height: 90.0,
                                width: 90.0,
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(100.0)),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      AssetImage('assets/profil.jpg'),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: (){
                                    theme.toggleTheme() ;
                                  },
                                  child: Container(
                                      width: 90.0,
                                      height: 45.0,
                                      child: FlareActor("assets/switcher.flr",
                                          alignment: Alignment.center,
                                          animation: theme.getSwitcherAnim().toString().substring(14))),
                                ),
                                Container(
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        'Joe Hattab',
                                        style: style.headerStyle3,
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 3.0, horizontal: 10.0),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            color: Colors.black12),
                                        child: Text(
                                          'Male',
                                          style: style.textTheme.copyWith(
                                              fontWeight: FontWeight.w300),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: (){
                                    Navigator.pushReplacementNamed(context, '/splashScreen') ;
                                  },
                                  child: Container(
                                    width: 90.0,
                                    height: 45.0,
                                    child: Center(
                                      child: Icon(Icons.power_settings_new,size: 35,),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.45,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text('Email',
                                          style: style.headerStyle3.copyWith(
                                              fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.center),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text('joehattab@bestresto.com',
                                          style: TextStyle(
                                            fontSize: 15.0,
                                          ),
                                          textAlign: TextAlign.center),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1.0,
                                  height: 40.0,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.45,
                                  child: Column(
                                    children: <Widget>[
                                      Text('Phone',
                                          style: style.headerStyle3.copyWith(
                                              fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.center),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        '+1 833-6543-5672             ',
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
                          GridView.count(
                            crossAxisCount: 2,
                            primary: false,
                            crossAxisSpacing: 2.0,
                            mainAxisSpacing: 4.0,
                            shrinkWrap: true,
                            childAspectRatio: 2.0,
                            children: <Widget>[
                              _buildCard(
                                  'Reward point', '155', Icons.card_giftcard, 1),
                              _buildCard(
                                  'Active orders', '5', Icons.arrow_upward, 2),
                            ],
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
                                  padding: EdgeInsets.symmetric(horizontal: 25),
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Full Name',
                                            style: style.headerStyle3,
                                          ),
                                          Text(
                                            'Joe Hattab Youtuber',
                                            style: style.subHintTitle,
                                          )
                                        ],
                                      ),
                                      Icon(Icons.edit)
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 25),
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Address',
                                            style: style.headerStyle3,
                                          ),
                                          Text(
                                            '445 Mount Eden Road, Mount Eden, Auckland.',
                                            style: style.subHintTitle,
                                          )
                                        ],
                                      ),
                                      Icon(Icons.edit)
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 25),
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Date of Birth',
                                            style: style.headerStyle3,
                                          ),
                                          Text(
                                            'Juin 7 ,1996',
                                            style: style.subHintTitle,
                                          )
                                        ],
                                      ),
                                      Icon(Icons.edit)
                                    ],
                                  ),
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

  Widget _buildCard(String title, String value, icon, int cardIndex) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                  spreadRadius: 1.0, blurRadius: 5.0, color: Colors.black38)
            ]),
        child: Column(
          children: <Widget>[
            SizedBox(height: 15.0),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                    ),
                  ),
                  Icon(icon)
                ],
              ),
            ),
            Expanded(
                child: Container(
                    width: 175.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0)),
                    ),
                    child: Center(
                      child: Text(
                        value,
                        style: TextStyle(
                            fontSize: 25.0,
                            color: Theme.of(context).primaryColor),
                      ),
                    )))
          ],
        ),
        margin: cardIndex.isEven
            ? EdgeInsets.fromLTRB(10.0, 0.0, 25.0, 10.0)
            : EdgeInsets.fromLTRB(25.0, 0.0, 5.0, 10.0));
  }
}

class BackClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, size.height - size.height / 5);

    var firstControlPoint = new Offset(size.width / 2, size.height + 25);
    var firstEndPoint = new Offset(size.width, size.height - size.height / 5);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    path.lineTo(size.width, 0.0);

    var secondControlPoint = new Offset(size.width / 2, size.height / 5 + 25);
    var secondEndPoint = new Offset(0.0, 0.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

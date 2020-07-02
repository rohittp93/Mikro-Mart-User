import 'package:flutter/material.dart';
import 'package:userapp/ui/shared/colors.dart';
import './signupPage.dart';
import './loginScreen_two.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  Widget HomePage() {
    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height,
      decoration: BoxDecoration(
        color: MikroMartColors.transparentGray,
        image: DecorationImage(
          colorFilter: new ColorFilter.mode(
              Colors.deepPurple.withOpacity(0.1), BlendMode.dstATop),
          image: AssetImage('assets/home_background.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 40,
          ),
          Container(
            child: Image.asset(
              "assets/logo.png",
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.8,
              height: MediaQuery
                  .of(context)
                  .size
                  .width * 0.8,
            ),
          ),
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            margin: EdgeInsets.only(
                left: 30.0,
                right: 30.0,
                top: MediaQuery
                    .of(context)
                    .size
                    .height * 0.2),
            alignment: Alignment.center,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlineButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    color: MikroMartColors.transparentGray,
                    highlightedBorderColor: MikroMartColors.transparentGray,
                    textColor: MikroMartColors.colorPrimary,
                    borderSide: BorderSide(
                      color: MikroMartColors.colorPrimary, //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.9, //width of the border
                    ),
                    onPressed: () => gotoSignup(),
                    child: Container(
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "SIGN UP",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: MikroMartColors.colorPrimary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
            alignment: Alignment.center,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    color: MikroMartColors.colorPrimary,
                    splashColor: MikroMartColors.colorPrimary,
                    //highlightColor: Colors.blue,
                    highlightColor: MikroMartColors.colorPrimary,
                    onPressed: () => gotoLogin(),
                    child: Container(
                     height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "LOGIN",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: MikroMartColors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  gotoLogin() {
    _controller.animateToPage(
      0,
      duration: Duration(milliseconds: 800),
      curve: Curves.ease,
    );
  }

  gotoSignup() {
    _controller.animateToPage(
      2,
      duration: Duration(milliseconds: 800),
      curve: Curves.ease,
    );
  }

  PageController _controller =
  PageController(initialPage: 1, viewportFraction: 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: MediaQuery
              .of(context)
              .size
              .height,
          child: PageView(
            controller: _controller,
            physics: AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              LoginScreen(),
              HomePage(),
              SignUpPage(onLoginClicked: () {
                gotoLogin();
              },)
            ],
            scrollDirection: Axis.horizontal,
          )),
    );
  }
}

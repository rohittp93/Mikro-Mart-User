import 'package:flutter/material.dart';
import 'package:userapp/core/services/auth.dart';
import '../shared/text_styles.dart' as style;

class PhoneNumberRegister extends StatefulWidget {


/*  @override
  Widget build(BuildContext context) {

  }
*/




  @override
  _PhoneNumberRegisterState createState()=> _PhoneNumberRegisterState();


  /*@override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }*/
}


class _PhoneNumberRegisterState extends State<PhoneNumberRegister> {
  final GlobalKey<ScaffoldState> _scaffoldkey =
  new GlobalKey<ScaffoldState>();
  String phone = '';


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final AuthService _auth = AuthService();

    return Scaffold(
        key: _scaffoldkey,
        body: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            SizedBox(
              height: size.height * 0.15,
            ),
            Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, top: 20.0, right: 16.0),
                    child: Text(
                      "Verify your phone number",
                      style: style.textTheme
                          .copyWith(fontSize: 22, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Image(
                      image: AssetImage('assets/otp1.png'),
                      height: size.height * 0.25,
                      width: size.width * 0.8,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Container(),
                        flex: 1,
                      ),
                      Flexible(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          autofocus: false,
                          enabled: false,
                          initialValue: "+91",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                        flex: 3,
                      ),
                      Flexible(
                        child: new Container(),
                        flex: 1,
                      ),
                      Flexible(
                        child: TextFormField(
                          textAlign: TextAlign.start,
                          autofocus: false,
                          enabled: true,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          style: TextStyle(fontSize: 20.0),
                          onChanged: (val) {
                            setState(() => this.phone = val);
                          },
                        ),
                        flex: 9,
                      ),
                      Flexible(
                        child: Container(),
                        flex: 1,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(70),
                    child: Material(
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        splashColor: Colors.black,
                        onTap: () {
                          String validationMessage = validateMobile(this.phone);
                          if (validationMessage == null) {
                            //Navigator.pushNamed(context, '/otpPage');
                          } else {
                            _scaffoldkey.currentState.showSnackBar(SnackBar(
                              content: new Text(validationMessage),
                              duration: new Duration(seconds: 3),
                            ));
                          }
                        },
                        child: Container(
                          width: size.width * 0.85,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.8),
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.4),
                                  offset: Offset(8.0, 16.0),
                                  blurRadius: 16.0),
                            ],
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 12),
                            child: Text(
                              "SUBMIT",
                              style: style.headerStyle3
                                  .copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ])
          ],
        ));
  }



  String validateMobile(String value) {
    //String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    String pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }

}
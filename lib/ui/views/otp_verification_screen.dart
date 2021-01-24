import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/reveal_progress.dart';
import '../shared/text_styles.dart' as style;
import 'curvedpainter.dart';

class PhoneNumberRegister extends StatefulWidget {
  @override
  _PhoneNumberRegisterState createState() => _PhoneNumberRegisterState();
}

class _PhoneNumberRegisterState extends State<PhoneNumberRegister> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  String phone = '';
  bool isPhoneNumberValid = false;
  String _intentWidget = '/mainHome';
  int _buttonAnimationState = 0;
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    AppDatabase db = Provider.of<AppDatabase>(context);

    return Scaffold(
        key: _scaffoldkey,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 100.0),
                  child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    width: double.infinity,
                                    child: CustomPaint(
                                      painter: CurvePainter(type: 4),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: (){
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.only(left: 16, top: 24.0,),
                                      width: 50,
                                      child: Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),

                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 24.0, bottom: 100),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Your Phone Number",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: MikroMartColors.white,
                                              fontSize: 26.0,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              "Verify your mobile number",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: MikroMartColors.white,
                                                fontSize: 15.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    width: double.infinity,
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        height: 142,
                                        child: Image(
                                          image: AssetImage('assets/dot_big.png'),
                                        ),

                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.fromLTRB(30,0,30,50),
                              child: Text(
                                "A 4 digit OTP will be sent via SMS to verify your mobile number!",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: MikroMartColors.black,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin:
                              const EdgeInsets.only(left: 30.0, right: 30.0, top: 0.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: MikroMartColors.backgroundGray,
                                ),
                                borderRadius: BorderRadius.circular(100.0),
                                color: MikroMartColors.backgroundGray,
                              ),
                              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                              child: TextField(
                                obscureText: false,
                                textAlign: TextAlign.left,
                                textInputAction: TextInputAction.next,
                                onChanged: (val) {
                                  setState(() {
                                    this.phone = val;
                                    this.isPhoneNumberValid =
                                        validateMobile(this.phone) == null;
                                  });
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Mobile Number',
                                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                                ),
                              ),
                            ),
                           /* Row(
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
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.done,
                                    style: TextStyle(fontSize: 20.0),
                                    onChanged: (val) {
                                      setState(() {
                                        this.phone = val;
                                        this.isPhoneNumberValid =
                                            validateMobile(this.phone) == null;
                                      });
                                    },
                                  ),
                                  flex: 9,
                                ),
                                Flexible(
                                  child: Container(),
                                  flex: 1,
                                ),
                              ],
                            ),*/
                            SizedBox(
                              height: 50,
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0.0),
                              child: RevealProgressButton(
                                keepStack: false,
                                  isValid: this.isPhoneNumberValid,
                                  intentWidgetRoute: this._intentWidget,
                                  buttonAnimationState: this._buttonAnimationState,
                                  buttonText: 'CONTINUE',
                                  onPressed: () async {
                                    FocusScope.of(context).requestFocus(FocusNode());

                                    setState(() {
                                      _buttonAnimationState = 1;
                                    });

                                    String validationMessage = validateMobile(this.phone);
                                    if (validationMessage == null) {
                                      final result = await _auth.signInWithPhone('+91' + this.phone, context, db);

                                      if(result != null) {

                                      }
                                    } else {
                                      setState(() {
                                        _buttonAnimationState = 0;
                                      });

                                      _scaffoldkey.currentState.showSnackBar(SnackBar(
                                        content: new Text(validationMessage),
                                        duration: new Duration(seconds: 3),
                                      ));
                                    }

                                  }),
                            ),
                          ]),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    height: 110,
                    child: Image(
                      image: AssetImage('assets/dot_small.png'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
         );
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

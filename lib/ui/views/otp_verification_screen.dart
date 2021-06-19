import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/address_model.dart';
import 'package:userapp/core/models/user.dart';
import 'package:userapp/core/services/database.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/reveal_progress.dart';
import '../shared/text_styles.dart' as style;
import 'address_screen_new.dart';
import 'curvedpainter.dart';

class OTPScreen extends StatefulWidget {
  final String mobileNumber;

  const OTPScreen({Key key, this.mobileNumber});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  bool isPhoneNumberValid = false;
  String _intentWidget = '/mainHome';
  int _buttonAnimationState = 0;
  TextEditingController textEditingController = TextEditingController();
  var errorController;
  static const String PHONE_SAVED_ADDRESS_INVALID =
      "phone_saved_address_invalid";
  static const String PHONE_SAVED_ADDRESS_VALID = "phone_saved_address_valid";
  static const String PHONE_VERIFICATION_FAILED = "phone_verification_failed";
  static const String PHONE_CODE_SENT = "phone_verification_code_sent";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  var _verificationId;

  final String PHONE_VERIFICATION_COMPLETE = "phone_verification_code_sent";

  @override
  void initState() {
    super.initState();

    signInWithPhone(_auth, widget.mobileNumber);
  }

  @override
  Widget build(BuildContext context) {
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
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                width: double.infinity,
                                child: CustomPaint(
                                  painter: CurvePainter(type: 3),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 50,
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    top: 24.0,
                                  ),
                                  width: 50,
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 24.0, bottom: 100),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "OTP Verification",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: MikroMartColors.white,
                                          fontSize: 26.0,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          "Verify your account",
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
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
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
                          padding: const EdgeInsets.fromLTRB(30, 0, 30, 50),
                          child: Text(
                            "Enter the OTP you received to \n+91 " +
                                widget.mobileNumber.substring(0, 2) +
                                ' ' +
                                widget.mobileNumber.substring(2, 3) +
                                'X XX XX ' +
                                widget.mobileNumber.substring(8, 10),
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: MikroMartColors.black,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0, right: 30),
                          child: PinCodeTextField(
                            length: 6,
                            //obscureText: false,
                            animationType: AnimationType.fade,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(50),
                              fieldHeight: 50,
                              fieldWidth: 50,
                              selectedColor: MikroMartColors.colorPrimary,
                              disabledColor:
                                  MikroMartColors.itemDetailSwipeIndicatorColor,
                              activeColor:
                                  MikroMartColors.itemDetailSwipeIndicatorColor,
                              inactiveFillColor:
                                  MikroMartColors.itemDetailSwipeIndicatorColor,
                              selectedFillColor:
                                  MikroMartColors.itemDetailSwipeIndicatorColor,
                              inactiveColor:
                                  MikroMartColors.itemDetailSwipeIndicatorColor,
                              activeFillColor:
                                  MikroMartColors.itemDetailSwipeIndicatorColor,
                            ),
                            animationDuration: Duration(milliseconds: 300),
                            enableActiveFill: true,
                            errorAnimationController: errorController,
                            controller: textEditingController,
                            onCompleted: (v) {
                              print("Completed");
                            },
                            onChanged: (value) {
                              print(value);
                              /*setState(() {
                                    currentText = value;
                                  });*/
                            },
                            beforeTextPaste: (text) {
                              print("Allowing to paste $text");
                              //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                              //but you can show anything you want here, like your pop up saying wrong paste format or etc
                              return true;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 0.0),
                          child: RevealProgressButton(
                              keepStack: false,
                              isValid: this.isPhoneNumberValid,
                              intentWidgetRoute: this._intentWidget,
                              buttonAnimationState: this._buttonAnimationState,
                              buttonText: 'DONE',
                              onPressed: () async {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());

                                if (textEditingController.text.length == 6) {
                                    registerOTP(null);
                                } else {
                                  setState(() {
                                    _buttonAnimationState = 0;
                                  });
                                  _scaffoldkey.currentState
                                      .showSnackBar(SnackBar(
                                    content:
                                        new Text('Pleaste enter valid OTP'),
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
        ));
  }

  signInWithPhone(FirebaseAuth _auth, String mobileNumber) async {
    _auth.verifyPhoneNumber(
        phoneNumber: mobileNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          registerOTP(credential);
        },
        verificationFailed: (AuthException authException) {
          print(authException.message);
          _scaffoldkey.currentState.showSnackBar(SnackBar(
            content: new Text(authException.message),
            duration: new Duration(seconds: 3),
          ));
        },
        codeSent: (String verificationId, [int forcedResendingToken]) {
          this.setState(() {
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: null);
  }

  Future<void> phoneNumberVerified() async {
    MikromartUser user = await _authService
        .savePhoneAndCheckAddr(
        widget.mobileNumber);

    if (user.houseName == null || user.houseName.isEmpty) {
      AddressModel addressModel = await Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (BuildContext context) => new AddressScreen(
              isDismissable: false,
            ),
            fullscreenDialog: true,
          ));

      GeoPoint addressLocation = new GeoPoint(
          addressModel.location.latitude, addressModel.location.longitude);

      await DatabaseService(uid: user.id)
          .updateUserAddress(addressLocation, addressModel.appartmentName);
      await _authService.updateUserAddressInSharedPrefs(addressModel);
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/mainHome', (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/mainHome', (Route<dynamic> route) => false);
    }
  }

  Future<void> registerOTP(AuthCredential credential) async {
    setState(() {
      _buttonAnimationState = 1;
    });

    if(credential == null) {
      final code =
      textEditingController.text.trim();
      credential = PhoneAuthProvider.getCredential(
          verificationId: _verificationId,
          smsCode: code);
    }

    String result = await _authService
        .registerPhoneWithSignedInUser(
        widget.mobileNumber, credential);

    if (result == PHONE_VERIFICATION_COMPLETE) {
      phoneNumberVerified();
    } else {
      setState(() {
        _buttonAnimationState = 0;
      });
      _scaffoldkey.currentState
          .showSnackBar(SnackBar(
        content: new Text('OTP did not match'),
        duration: new Duration(seconds: 3),
      ));
    }
  }
}

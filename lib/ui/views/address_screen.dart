import 'dart:collection';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:userapp/core/helpers/great_circle_distance_base.dart';
import 'package:userapp/core/models/address_model.dart';
import 'package:userapp/ui/shared/colors.dart';
import '../shared/text_styles.dart' as style;

class AddressScreen extends StatefulWidget {
  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  Set<Marker> _markers = HashSet<Marker>();
  Set<Circle> _circles = HashSet<Circle>();
  GoogleMapController _mapController;
  Flushbar<List<String>> _addressNameFlushBar;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Form _userInputForm;
  TextEditingController _textEditingController = TextEditingController();
  bool _isSnackbarActive = false;
  var _controller;
  LatLng _locationAddress = null;

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  LatLng _outletLocation = LatLng(10.008746, 76.329626);

  //final ArgumentCallback<LatLng> onMapTap;

  void onMapCreated() {}

  void _setCircles() {
    _circles.add(
      Circle(
          circleId: CircleId("0"),
          center: LatLng(10.008746, 76.329626),
          radius: 5000,
          strokeWidth: 1,
          fillColor: Color.fromRGBO(219, 39, 47, 0.1)),
    );
  }

  @override
  void initState() {
    super.initState();
    _setCircles();
  }

  _handleTap(LatLng point) {
    setState(() {
      _locationAddress = point;
      if (_markers.length > 0) {
        _markers.clear();
      }

      if (_getDistanceBetween(point)) {
        _markers.add(Marker(
          markerId: MarkerId(point.toString()),
          position: point,
          infoWindow: InfoWindow(
            title: 'Address location',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ));
      } else {
        showErrorDialog();
      }
    });
  }

  bool _getDistanceBetween(LatLng addressLocation) {
    var gcd = new GreatCircleDistance.fromDegrees(
        latitude1: _outletLocation.latitude,
        longitude1: _outletLocation.longitude,
        latitude2: addressLocation.latitude,
        longitude2: addressLocation.longitude);
    /* print(
        'Distance from location 1 to 2 using the Haversine formula is: ${gcd.haversineDistance()}');
    print(
        'Distance from location 1 to 2 using the Spherical Law of Cosines is: ${gcd.sphericalLawOfCosinesDistance()}');
    print(
        'Distance from location 1 to 2 using the Vicenty`s formula is: ${gcd.vincentyDistance()}');*/

    return (gcd.haversineDistance() < 5000);
  }

  TextFormField textFormField() {
    return TextFormField(
        controller: _textEditingController,
        initialValue: null,
        style: TextStyle(color: Colors.white),
        maxLines: 1,
        maxLength: 100,
        decoration: InputDecoration(
          fillColor: Colors.white12,
          filled: true,
          /* icon: Icon(Icons.label, color: MikroMartColors.white),*/
          border: UnderlineInputBorder(),
          /*helperText: 'This location will be used by the delivery agent to deliver items to you.',
          helperStyle: TextStyle(color: Colors.white70),*/
          labelText: 'Enter your house name or appartment name',
          labelStyle: TextStyle(color: Colors.white70),
        ));
  }

  showFlatNameBottomSheet() {
    _addressNameFlushBar = Flushbar<List<String>>(
      title: 'Hello Rohit',
      message: 'How are you',
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      animationDuration: Duration(seconds: 1),
      backgroundColor: MikroMartColors.purpleStart,
      userInputForm: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            textFormField(),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: FlatButton(
                  child: Text('DONE'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.white,
                  textColor: MikroMartColors.purpleEnd,
                  padding: EdgeInsets.all(6),
                  onPressed: () {
                    if (_textEditingController.text.length > 0) {
                      _addressNameFlushBar
                          .dismiss([_textEditingController.text]);
                      FocusScope.of(context).unfocus();

                      AddressModel addressModel = AddressModel(
                          location: _locationAddress,
                          appartmentName: _textEditingController.text);

                      Navigator.pop(context, addressModel);
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
      boxShadows: [
        BoxShadow(color: Colors.blue, offset: Offset(0.0, 0.2), blurRadius: 3.0)
      ],
      backgroundGradient: LinearGradient(
          colors: [MikroMartColors.purpleEnd, MikroMartColors.purpleStart]),
      isDismissible: false,
      icon: Icon(
        Icons.check,
        color: Colors.white,
      ),
      /*mainButton: FlatButton(
        onPressed: () {
          _addressNameFlushBar.dismiss();
        },
        child: Text(
          'Done',
          style: TextStyle(color: MikroMartColors.white),
        ),
      ),*/
    )..show(context).then((result) {
        if (result != null) {
          String address = result[0];
          print('ADDRESS TYPED IS $address');
        } else {}
      });
  }

  showErrorDialog() {
    Dialog errorDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      //this right here
      child: Container(
        height: 200.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(15.0, 0, 15.0, 10),
                child: Text(
                  'We do not provide delivery to this location yet. Please select an area within the circular region',
                  style: TextStyle(color: MikroMartColors.purple),
                ),
              ),
            ),
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Reselect location',
                  style: TextStyle(
                      color: MikroMartColors.colorPrimary, fontSize: 18.0),
                ))
          ],
        ),
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => errorDialog);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        backgroundColor: MikroMartColors.colorPrimary,
        title: Text(
          "Tap to select your location",
          style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: MikroMartColors.white,
              decoration: TextDecoration.none),
          textAlign: TextAlign.center,
        ),
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 50.0),
            child: GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: _outletLocation, zoom: 12),
              circles: _circles,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: _handleTap,
              markers: _markers,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {
                if (_markers.length == 1) {
                  showFlatNameBottomSheet();
                } else {
                  showSnackBar('Select a location on map before continuing');
                }
              },
              child: Container(
                color: MikroMartColors.colorPrimary,
                height: 50.0,
                child: Center(
                    child: Text(
                  'DONE',
                  style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                      color: MikroMartColors.white,
                      decoration: TextDecoration.none),
                )),
              ),
            ),
          )
        ],
      ),
    );
  }

  void showSnackBar(String message) {
    if (!_isSnackbarActive) {
      _isSnackbarActive = true;
      _scaffoldkey.currentState
          .showSnackBar(SnackBar(
            content: new Text(message),
            duration: new Duration(seconds: 2),
          ))
          .closed
          .then((value) => _isSnackbarActive = false);
    }
  }
}

import 'dart:collection';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:userapp/core/helpers/great_circle_distance_base.dart';
import 'package:userapp/core/models/address_model.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';
import '../shared/text_styles.dart' as style;
import 'map_overlap.dart';

class AddressScreen extends StatefulWidget {
  final bool isDismissable;

  const AddressScreen({Key key, @required this.isDismissable})
      : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  Set<Marker> _markers = HashSet<Marker>();
  Set<Circle> _circles = HashSet<Circle>();
  var _mapController;
  final AuthService _auth = AuthService();

  Flushbar<List<String>> _addressNameFlushBar;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _textEditingController = TextEditingController();
  bool _isSnackbarActive = false;
  Flushbar _errorFlushBar;

  //var _controller;
  LatLng _locationAddress = null;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  LatLng _outletLocation = LatLng(10.065723, 76.495566);
  bool initStateCalled = false;

  LatLng _latlong;

  var _isFetchingCurrentLocation = true;

  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  Position _position;

  TextEditingController _floorController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _houseNameController = TextEditingController();

  void _setCircles() {
    _circles.add(
      Circle(
          circleId: CircleId("0"),
          center: LatLng(10.065723, 76.495566),
          radius: 8000,
          strokeWidth: 1,
          fillColor: Color.fromRGBO(219, 39, 47, 0.1)),
    );
  }

  Future getCurrentLocation() async {
    print('Initstate called');
    //Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;

    if (!(await Geolocator().isLocationServiceEnabled())) {
      PermissionStatus permissionRequestResult =
          await LocationPermissions().requestPermissions();
      setState(() {
        _permissionStatus = permissionRequestResult;
        print(_permissionStatus);
      });

      switch (_permissionStatus) {
        case PermissionStatus.denied:
          showSnackBar(
              'Location permission denied. Please enable device location');
          break;
        case PermissionStatus.granted:
          getCurrentLocationAndDrawMarker();
          break;
        default:
          break;
      }
    } else {
      getCurrentLocationAndDrawMarker();
    }
  }

  getCurrentLocationAndDrawMarker() async {
    try {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .timeout(new Duration(seconds: 15));

      print('Current location ${position.latitude}');
      setState(() {
        _position = position;
        _locationAddress = new LatLng(position.latitude, position.longitude);
      });
      displayMarker();
    } catch (e) {
      print('Error: ${e.toString()}');

      showSnackBar(
          'Could not fetch location. Please toggle your device location & try again');

      setState(() {
        _isFetchingCurrentLocation = false;
      });
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _position = position;
      });
      displayMarker();
    }
  }

  displayMarker() async {
    final geoLocator = Geolocator();

    GeolocationStatus geolocationStatus =
        await geoLocator.checkGeolocationPermissionStatus();

    if (geolocationStatus == GeolocationStatus.denied ||
        geolocationStatus == GeolocationStatus.disabled) {
      setState(() {
        _isFetchingCurrentLocation = false;
      });
    }

    await geoLocator.placemarkFromCoordinates(
        _position.latitude, _position.longitude);

    setState(() {
      _latlong = new LatLng(_position.latitude, _position.longitude);
      _isFetchingCurrentLocation = false;
    });
    var _cameraPosition = CameraPosition(target: _latlong, zoom: 18.0);
    _mapController
        .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));

    if (_markers.length > 0) {
      _markers.clear();
    }

    _markers.add(Marker(
      markerId: MarkerId(_latlong.toString()),
      position: _latlong,
      infoWindow: InfoWindow(
        title: 'Current location',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    ));
  }

  @override
  void initState() {
    super.initState();
    _setCircles();
    getCurrentLocation();
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

        setState(() {
          _latlong = point;
        });
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

    return (gcd.haversineDistance() < 8000);
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
          border: UnderlineInputBorder(),
          labelText: 'Enter your house name or appartment name',
          labelStyle: TextStyle(color: Colors.white70),
        ));
  }

  showErrorDialog() {
    _errorFlushBar = Flushbar<List<String>>(
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeOutCubic,
      animationDuration: Duration(milliseconds: 600),
      backgroundColor: MikroMartColors.purpleStart,
      userInputForm: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
              child: Text(
                'We do not provide delivery to this location yet. Please select an area within the circular region',
                style: TextStyle(color: MikroMartColors.white),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: FlatButton(
                    child: Text('Reselect Location'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    color: Colors.white,
                    textColor: MikroMartColors.purpleEnd,
                    padding: EdgeInsets.all(6),
                    onPressed: () {
                      _errorFlushBar.dismiss();
                      //onContinue.call();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      boxShadows: [
        BoxShadow(color: Colors.blue, offset: Offset(0.0, 0.2), blurRadius: 3.0)
      ],
      backgroundGradient: LinearGradient(colors: [
        MikroMartColors.colorPrimaryDark,
        MikroMartColors.colorPrimary
      ]),
      isDismissible: true,
      icon: Icon(
        Icons.check,
        color: Colors.white,
      ),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(widget.isDismissable),
      child: Scaffold(
        key: _scaffoldkey,
        appBar: AppBar(
          backgroundColor: MikroMartColors.colorPrimary,
          title: Text(
            "Tap to select your location",
            style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: MikroMartColors.white,
                fontFamily: 'Mulish',
                decoration: TextDecoration.none),
            textAlign: TextAlign.center,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    height: 400,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      child: GoogleMap(
                        initialCameraPosition:
                            CameraPosition(target: _outletLocation, zoom: 12),
                        gestureRecognizers:
                            <Factory<OneSequenceGestureRecognizer>>[
                          new Factory<OneSequenceGestureRecognizer>(
                            () => new EagerGestureRecognizer(),
                          ),
                        ].toSet(),
                        circles: _circles,
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = (controller);
                          _mapController.complete(controller);
                          //getCurrentLocation();
                        },
                        onTap: _handleTap,
                        markers: _markers,
                      ),
                    ),
                  ),
                  /* Container(
                    height: 400,
                    child: new IgnorePointer(
                      child: new ClipPath(
                        clipper: new InvertedCircleClipper(),
                        child: new Container(
                          color: new Color.fromRGBO(0, 0, 0, 0.5),
                        ),
                      ),
                    ),
                  ),*/

                  _isFetchingCurrentLocation
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: 40,
                          color: Colors.white.withOpacity(0.7),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                  child: Text(
                                'Fetching Current Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Mulish',
                                ),
                              )),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ))
                      : Container(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 38.0, left: 37),
                child: Text(
                  "Enter Email Details",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: MikroMartColors.black
                      , fontFamily: 'Mulish',
                      decoration: TextDecoration.none),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 25.0),
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
                  style: TextStyle(         fontFamily: 'Mulish',),
                  textAlign: TextAlign.left,
                  controller: _houseNameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'House/Appartment Name',
                    hintStyle: TextStyle(color: Theme.of(context).hintColor         , fontFamily: 'Mulish',),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 25.0),
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
                  style: TextStyle(         fontFamily: 'Mulish',),
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.text,
                  controller: _addressController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Complete Address',
                    hintStyle: TextStyle(color: Theme.of(context).hintColor         , fontFamily: 'Mulish',),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 25.0),
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
                  style: TextStyle(         fontFamily: 'Mulish',),
                  keyboardType: TextInputType.text,
                  controller: _floorController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Floor (Optional)',
                    hintStyle: TextStyle(color: Theme.of(context).hintColor         , fontFamily: 'Mulish',),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 80.0, top: 30),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () async {
                      if (_markers.length == 1) {
                        if (_getDistanceBetween(_latlong)) {
                          //showFlatNameBottomSheet();

                          if (_houseNameController.text.length != 0) {
                            if (_addressController.text.length != 0) {
                              FocusScope.of(context).unfocus();

                              String address = '';

                              if (_floorController.text.length != 0) {
                                address = _houseNameController.text +
                                    ', floor: ' +
                                    _floorController.text +
                                    '\n' +
                                    _addressController.text;
                              } else {
                                address = _houseNameController.text +
                                    ',' +
                                    '\n' +
                                    _addressController.text;
                              }

                              AddressModel addressModel = AddressModel(
                                  location: _locationAddress,
                                  appartmentName: address);

                              await _auth
                                  .updateAddressInFirestore(addressModel);

                              Navigator.pop(context, addressModel);
                            } else {
                              showSnackBar('Enter complete address');
                            }
                          } else {
                            showSnackBar('Enter House/Appartment name');
                          }
                        } else {
                          showErrorDialog();
                        }
                      } else {
                        showSnackBar(
                            'Select a location on map before continuing');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30),
                      child: Container(
                        decoration: BoxDecoration(
                          color: MikroMartColors.colorPrimary,
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        height: 50.0,
                        child: Center(
                            child: Text(
                          'SAVE ADDRESS',
                          style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold
                              , fontFamily: 'Mulish',
                              color: MikroMartColors.white,
                              decoration: TextDecoration.none),
                        )),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
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

class PermissionWidget extends StatefulWidget {
  const PermissionWidget(this._permissionLevel);

  final LocationPermissionLevel _permissionLevel;

  @override
  _PermissionState createState() => _PermissionState(_permissionLevel);
}

class _PermissionState extends State<PermissionWidget> {
  _PermissionState(this._permissionLevel);

  final LocationPermissionLevel _permissionLevel;
  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() {
    final Future<PermissionStatus> statusFuture =
        LocationPermissions().checkPermissionStatus();

    statusFuture.then((PermissionStatus status) {
      setState(() {
        _permissionStatus = status;
      });
    });
  }

  Color getPermissionColor() {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return Colors.red;
      case PermissionStatus.granted:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_permissionLevel.toString()),
      subtitle: Text(
        _permissionStatus.toString(),
        style: TextStyle(color: getPermissionColor()),
      ),
      trailing: IconButton(
          icon: const Icon(Icons.info),
          onPressed: () {
            checkServiceStatus(context, _permissionLevel);
          }),
      onTap: () {
        requestPermission(_permissionLevel);
      },
    );
  }

  void checkServiceStatus(
      BuildContext context, LocationPermissionLevel permissionLevel) {
    LocationPermissions()
        .checkServiceStatus()
        .then((ServiceStatus serviceStatus) {
      final SnackBar snackBar =
          SnackBar(content: Text(serviceStatus.toString()));

      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  Future<void> requestPermission(
      LocationPermissionLevel permissionLevel) async {
    final PermissionStatus permissionRequestResult = await LocationPermissions()
        .requestPermissions(permissionLevel: permissionLevel);

    setState(() {
      print(permissionRequestResult);
      _permissionStatus = permissionRequestResult;
      print(_permissionStatus);
    });
  }
}

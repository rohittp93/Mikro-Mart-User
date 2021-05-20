import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/helpers/great_circle_distance_base.dart';
import 'package:userapp/core/models/cart_validation_response.dart';
import 'package:userapp/core/models/razorpay_order.dart';
import 'package:userapp/core/models/user.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/dottedline.dart';
import '../shared/text_styles.dart' as style;
import 'package:provider/provider.dart';

class ShoppingCart extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  int NOT_ORDERING = -1;
  int PROCESSING_ORDER = 0;
  int ORDER_PLACED_SUCCESSFULLY = 1;
  int ORDER_FAILED = 2;
  GeoPoint _userAddress;

  //LatLng _outletLocation = LatLng(10.065723, 76.495566);
  Razorpay razorpay;
  LatLng _outletLocation;
  List<CartItem> _cartItems = [];
  final AuthService _auth = AuthService();
  var _orderingState = -1;

  Flushbar<List<String>> _addressNameFlushBar;
  double _itemTotalAmount = 0.0;
  double _deliveryCharge = 0.0;
  double _totalAmount = 0.0;
  TextEditingController _textEditingController = TextEditingController();
  bool paymentGatewaySelected = true;

  String _orderId = '';

  bool _bookingStarted = false;

  @override
  Future<void> initState() {
    super.initState();

    razorpay = new Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    //getDeliveryCharge();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      AppDatabase db = Provider.of<AppDatabase>(context, listen: false);
      placeOrder(db, response.paymentId);
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showMessage('Payment Error');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    showMessage('External Wallet');
  }

  showMessage(String message) {
    setState(() {
      _orderingState = ORDER_FAILED;
    });

    var _outletChangeFlushbar = Flushbar<List<String>>(
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeOutCubic,
      duration: Duration(seconds: 3),
      backgroundColor: MikroMartColors.errorRed,
      userInputForm: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                child: Text(
                  message,
                  style: style.mediumTextTitle
                      .copyWith(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      /*  boxShadows: [
        BoxShadow(color: Colors.blue, offset: Offset(0.0, 0.2), blurRadius: 3.0)
      ],*/

      isDismissible: true,
      icon: Icon(
        Icons.check,
        color: Colors.white,
      ),
    );

    if (!_outletChangeFlushbar.isShowing()) {
      _outletChangeFlushbar.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    _cartItems = Provider.of<List<CartItem>>(context);
    AppDatabase db = Provider.of<AppDatabase>(context);

    if (_cartItems != null &&
        _cartItems.length > 0 &&
        _outletLocation == null) {
      computeDeliveryCharge();
    }

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    height: 50,
                    color: MikroMartColors.colorPrimary,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'My Cart',
                          style: style.mediumTextTitle.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: _cartItems != null && _cartItems.length > 0
                          ? ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: _cartItems.length,
                              itemBuilder: _cartItemBuilder)
                          : Stack(
                              children: <Widget>[
                                Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.all(40),
                                  child: _orderingState ==
                                          ORDER_PLACED_SUCCESSFULLY
                                      ? Center(
                                          child: Container(
                                            width: 230,
                                            child: Image(
                                              image: AssetImage(
                                                  'assets/purchase_success.png'),
                                            ),
                                          ),
                                        )
                                      : FlareActor(
                                          "assets/empty.flr",
                                          alignment: Alignment.center,
                                          animation: 'empty',
                                        ),
                                ),
                                _orderingState == ORDER_PLACED_SUCCESSFULLY
                                    ? Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 120, 20, 0),
                                        child: Text(
                                          'Thank you for shopping with Mikro Mart',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: MikroMartColors.black,
                                              fontSize: 26,
                                              fontFamily: 'Mulish',
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : Container(),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        40, 0, 40, 200),
                                    child: Text(
                                      returnDisplayText(_orderingState),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: _orderingState == -1
                                              ? MikroMartColors.subtitleGray
                                              : MikroMartColors.black,
                                          fontFamily: 'Mulish',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                _orderingState == ORDER_PLACED_SUCCESSFULLY ||
                                        _orderingState == ORDER_FAILED
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 50.0, right: 24, left: 24),
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 0, 60),
                                              child: InkWell(
                                                onTap: () {
                                                  this.setState(() {
                                                    _orderingState = -1;
                                                  });
                                                },
                                                child: Container(
                                                  height: 50,
                                                  child: Center(
                                                    child: Text(
                                                      'CONTINUE SHOPPING',
                                                      style: TextStyle(
                                                          color: MikroMartColors
                                                              .white,
                                                          fontSize: 16,
                                                          fontFamily: 'Mulish',
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: MikroMartColors
                                                          .colorPrimary,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100.0),
                                                    color: MikroMartColors
                                                        .colorPrimary,
                                                  ),
                                                ),
                                              )),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            _cartItems != null && _cartItems.length > 0
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      height: 300,
                      child: Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                offset: Offset(0.0, 1.4), //(x,y)
                                blurRadius: 8.0,
                              ),
                            ],
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                            color: MikroMartColors.cardBackground),
                        //margin: const EdgeInsets.only(left: 8.0, right: 8.0),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 105),
                        child: Stack(
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 16.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              'Item Total',
                                              style:
                                                  style.cardTitleStyle.copyWith(
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              _calculateItemTotalPrice(
                                                  _cartItems),
                                              style: style.cardTitleStyle
                                                  .copyWith(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 12.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              'Delivery Charge',
                                              style: style.cardTitleStyle
                                                  .copyWith(
                                                      fontSize: 15,
                                                      color: MikroMartColors
                                                          .disabledPriceColor),
                                            ),
                                            Text(
                                              '\₹ ' +
                                                  _deliveryCharge
                                                      .toStringAsFixed(2),
                                              style: style.cardTitleStyle
                                                  .copyWith(
                                                      fontSize: 15,
                                                      color: MikroMartColors
                                                          .disabledPriceColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 20, 0, 20),
                                        child: MySeparator(color: Colors.grey),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 0.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              'Total',
                                              style: style.cardTitleStyle
                                                  .copyWith(
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            Text(
                                              _calculateTotalPrice(_cartItems),
                                              style: style.cardTitleStyle
                                                  .copyWith(
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.all(0.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40.0),
                                  child: RaisedButton(
                                    onPressed: () async {
                                      //showBottomSheetDialog();
                                      confirmOrderDialog(
                                        () {
                                          confirmOrder(db);
                                        },
                                      );
                                    },
                                    elevation: 0.5,
                                    color: MikroMartColors.colorPrimary,
                                    child: Row(
                                      children: <Widget>[
                                        Flexible(
                                          child: Center(
                                            child: Text(
                                              _orderingState == PROCESSING_ORDER
                                                  ? 'Please wait'
                                                  : 'PLACE ORDER',
                                              style: style.mediumTextTitle
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        _orderingState == PROCESSING_ORDER
                                            ? Flexible(
                                                child: Container(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            10, 0, 0, 0),
                                                    child: SpinKitCircle(
                                                        color: Colors.white)),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                    textColor: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  getDeliveryCharge() async {
    _userAddress = await _auth.getUserAddress();
    var gcd = new GreatCircleDistance.fromDegrees(
        latitude1: _outletLocation.latitude,
        longitude1: _outletLocation.longitude,
        latitude2: _userAddress.latitude,
        longitude2: _userAddress.longitude);
    double distance = gcd.haversineDistance();

    double kilometers = (distance / 1000);

    this.setState(() {
      _deliveryCharge = kilometers.ceilToDouble() * 6;
    });
  }

  Widget _cartItemBuilder(BuildContext context, int index) {
    AppDatabase db = Provider.of<AppDatabase>(context);

    return Wrap(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(12, index == 0 ? 12 : 0, 12,
              _cartItems.length - 1 == index ? 400 : 12),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.6),
                  offset: Offset(0.0, 1.4), //(x,y)
                  blurRadius: 3.0,
                ),
              ],
              color: MikroMartColors.cardBackground,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Image(
                        width: 101,
                        height: 95,
                        image: NetworkImage(_cartItems[index].itemImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _cartItems[index].itemName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: MikroMartColors.textGray,
                                fontFamily: 'Mulish',
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(_cartItems[index].itemQuantity,
                              style: TextStyle(
                                  color: MikroMartColors.textGray,
                                  fontSize: 12,
                                  fontFamily: 'Mulish',
                                  fontWeight: FontWeight.w400)),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            '\₹ ' +
                                _cartItems[index].cartPrice.toStringAsFixed(2),
                            style: TextStyle(
                                color: MikroMartColors.colorPrimary,
                                fontSize: 14,
                                fontFamily: 'Mulish',
                                fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    if (_cartItems[index].cartQuantity != 0) {
                                      int quantity =
                                          _cartItems[index].cartQuantity - 1;

                                      if (quantity == 0) {
                                        setState(() {
                                          _orderingState = NOT_ORDERING;
                                        });

                                        if (_cartItems.length == 1 &&
                                            quantity == 0) {
                                          deleteCartItem(_cartItems[index], db);
                                          _outletLocation = null;
                                          _cartItems.clear();
                                        } else {
                                          deleteCartItem(_cartItems[index], db);
                                        }
                                      } else {
                                        updateCartItemQuantity(
                                            _cartItems[index], quantity, db);
                                      }
                                    } else {}
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          color: MikroMartColors.cardBackground,
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          border: Border.all(
                                              width: 1,
                                              color:
                                                  MikroMartColors.colorPrimary),
                                        ),
                                      ),
                                      Text(
                                        '-',
                                        style: style.headerStyle.copyWith(
                                            color: MikroMartColors.colorPrimary,
                                            fontSize: 30,
                                            fontWeight: FontWeight.normal),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    _cartItems[index].cartQuantity.toString(),
                                    style: style.arialTheme.copyWith(
                                      color: MikroMartColors.colorPrimary,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (validateCartCount(_cartItems[index],
                                        _cartItems[index].cartQuantity)) {
                                      int quantity =
                                          _cartItems[index].cartQuantity + 1;
                                      updateCartItemQuantity(
                                          _cartItems[index], quantity, db);
                                    } else {
                                      showErrorBottomSheet(_cartItems[index],
                                          _cartItems[index].cartQuantity);
                                    }
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          color: MikroMartColors.cardBackground,
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          border: Border.all(
                                              width: 1,
                                              color:
                                                  MikroMartColors.colorPrimary),
                                        ),
                                      ),
                                      Text(
                                        '+',
                                        style: style.headerStyle.copyWith(
                                            color: MikroMartColors.colorPrimary,
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  showErrorBottomSheet(CartItem item, int itemQuantity) {
    _addressNameFlushBar = Flushbar<List<String>>(
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeOutCubic,
      animationDuration: Duration(milliseconds: 600),
      duration: Duration(seconds: 4),
      backgroundColor: MikroMartColors.purpleStart,
      userInputForm: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
              child: ((itemQuantity + 1) <= item.quantityInStock)
                  ? Text(
                      'You can add only upto ${item.maxQuantity} ${item.itemName} in a single order',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )
                  : Text(
                      'There are only ${item.quantityInStock} ${item.itemName}s in stock. Please add within this limit',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: FlatButton(
                  child: Text('OK'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.white,
                  textColor: MikroMartColors.purpleEnd,
                  padding: EdgeInsets.all(6),
                  onPressed: () {
                    _addressNameFlushBar.dismiss();
                  },
                ),
              ),
            )
          ],
        ),
      ),
      boxShadows: [
        BoxShadow(
            color: MikroMartColors.colorPrimaryDark,
            offset: Offset(0.0, 0.2),
            blurRadius: 3.0)
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
    )..show(context).then((result) {
        if (result != null) {
          String address = result[0];
          print('ADDRESS TYPED IS $address');
        } else {}
      });
  }

  confirmOrderDialog(Function action) async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: MikroMartColors.colorPrimaryDarkOverlay));
    await showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: false,
      useRootNavigator: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 280),
      context: context,
      pageBuilder: (_, __, ___) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Material(
              type: MaterialType.transparency,
              child: Align(
                alignment: Alignment.center,
                child: Wrap(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width - 50,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          21.0,
                          41,
                          21.0,
                          41,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Your order total is \₹ ' +
                                  _totalAmount.toStringAsFixed(2),
                              style: style.mediumTextTitle.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                'Once confirmed, we will process your order and deliver within 3 to 4 hours',
                                style: style.mediumTextTitle.copyWith(
                                    color: MikroMartColors.disabledPriceColor,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                'You could add items you didn\'t find on Mikro Mart & we will try to deliver it to you in this order',
                                style: style.mediumTextTitle.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: TextField(
                                  controller: _textEditingController,
                                  decoration: new InputDecoration(
                                      border: new OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                          //Color of the border
                                          style: BorderStyle.none,
                                          //Style of the border
                                          width: 0, //width of the border
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(60.0),
                                        ),
                                      ),
                                      filled: true,
                                      hintStyle: new TextStyle(
                                          color: Colors.grey[800]),
                                      hintText: "Add items",
                                      fillColor: MikroMartColors.dividerGray
                                          .withOpacity(0.1)),
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                'Pay Using',
                                style: style.mediumTextTitle.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                children: <Widget>[
                                  Flexible(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: OutlineButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0)),
                                        color: MikroMartColors.transparentGray,
                                        highlightedBorderColor:
                                            MikroMartColors.transparentGray,
                                        textColor: paymentGatewaySelected
                                            ? MikroMartColors.colorPrimary
                                            : MikroMartColors.disabledColor,
                                        borderSide: BorderSide(
                                          color: paymentGatewaySelected
                                              ? MikroMartColors.colorPrimary
                                              : MikroMartColors.disabledColor,
                                          //Color of the border
                                          style: BorderStyle.solid,
                                          //Style of the border
                                          width: 1, //width of the border
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            paymentGatewaySelected = true;
                                          });
                                        },
                                        child: Container(
                                          height: 60,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Pay via UPI or Card on Delivery",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: paymentGatewaySelected
                                                      ? MikroMartColors
                                                          .colorPrimary
                                                      : MikroMartColors
                                                          .disabledColor,
                                                  fontFamily: 'Mulish',
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: OutlineButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0)),
                                        color: MikroMartColors.transparentGray,
                                        highlightedBorderColor:
                                            MikroMartColors.transparentGray,
                                        textColor: !paymentGatewaySelected
                                            ? MikroMartColors.colorPrimary
                                            : MikroMartColors.disabledColor,
                                        borderSide: BorderSide(
                                          color: !paymentGatewaySelected
                                              ? MikroMartColors.colorPrimary
                                              : MikroMartColors.disabledColor,
                                          //Color of the border
                                          style: BorderStyle.solid,
                                          //Style of the border
                                          width: 1, //width of the border
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            paymentGatewaySelected = false;
                                          });
                                        },
                                        child: Container(
                                          height: 60,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Cash On Delivery",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: !paymentGatewaySelected
                                                      ? MikroMartColors
                                                          .colorPrimary
                                                      : MikroMartColors
                                                          .disabledColor,
                                                  fontFamily: 'Mulish',
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'You can cancel your order by calling MikroMart support number : +919090080858',
                                  style: style.mediumTextTitle.copyWith(
                                      color: MikroMartColors.colorPrimary,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  FlatButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                        side: BorderSide(
                                            color:
                                                MikroMartColors.colorPrimary)),
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          24, 11, 24, 11),
                                      child: Text(
                                        'CANCEL',
                                        style: style.mediumTextTitle.copyWith(
                                            color: MikroMartColors.colorPrimary,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  FlatButton(
                                    color: MikroMartColors.colorPrimary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                        side: BorderSide(
                                            color:
                                                MikroMartColors.colorPrimary)),
                                    onPressed: () {
                                      action.call();
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          24, 11, 24, 11),
                                      child: Text(
                                        'CONFIRM',
                                        style: style.mediumTextTitle.copyWith(
                                            color: MikroMartColors.white,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      margin: EdgeInsets.only(bottom: 50, left: 12, right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    ).then((val) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: MikroMartColors.colorPrimaryDark));
      // Navigator.pop(context);
    });
  }

  errorMessage(String error, Color color, bool dismissable, bool showCancel) {
    _addressNameFlushBar = Flushbar<List<String>>(
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeOutCubic,
      animationDuration: Duration(milliseconds: 600),
      duration: dismissable ? Duration(seconds: 6) : null,
      backgroundColor: MikroMartColors.purpleStart,
      userInputForm: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
              child: Text(
                error,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            !dismissable ? textFormField() : Container(),
            Container(
              alignment: Alignment.centerRight,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  showCancel
                      ? Padding(
                          padding: EdgeInsets.all(10.0),
                          child: FlatButton(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Mulish',
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            color: Colors.white,
                            textColor: MikroMartColors.purpleEnd,
                            padding: EdgeInsets.all(6),
                            onPressed: () {
                              _addressNameFlushBar.dismiss();
                            },
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text(
                        dismissable ? 'OK' : 'Confirm',
                        style: TextStyle(
                          fontFamily: 'Mulish',
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      textColor: MikroMartColors.purpleEnd,
                      padding: EdgeInsets.all(6),
                      onPressed: () {
                        _addressNameFlushBar.dismiss();
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
      boxShadows: [
        BoxShadow(
            color: MikroMartColors.subtitleGray,
            offset: Offset(0.0, 0.2),
            blurRadius: 5.0)
      ],
      borderRadius: 8.0,
      /* backgroundGradient:
      LinearGradient(colors: [color, color.withOpacity(0.7)]),*/
      isDismissible: true,
      icon: Icon(
        Icons.check,
        color: Colors.white,
      ),
    )..show(context);
  }

  textFormField() {
    return Container(
      padding: EdgeInsets.only(top: 20, left: 8.0, right: 8.0),
      child: Column(
        children: <Widget>[
          Text(
            'You could add items you did\'t find on Mikro Mart & we will try to deliver it to you in this order',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'Mulish',
            ),
          ),
          SizedBox(
            height: 8,
          ),
          TextFormField(
              controller: _textEditingController,
              initialValue: null,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Mulish',
              ),
              maxLines: 1,
              maxLength: 100,
              decoration: InputDecoration(
                fillColor: Colors.white12,
                filled: true,
                border: UnderlineInputBorder(),
                labelText: 'Add items',
                labelStyle: TextStyle(color: Colors.white70),
              )),
        ],
      ),
    );
  }

  bool validateCartCount(CartItem cartItem, int itemQuantity) {
    return (itemQuantity + 1) <= cartItem.maxQuantity;
  }

  void updateCartItemQuantity(CartItem cartItem, int quantity, AppDatabase db) {
    final item = cartItem.copyWith(
        cartQuantity: quantity, cartPrice: ((cartItem.itemPrice) * quantity));
    _auth.updateCartItem(item, db);
  }

  void deleteCartItem(CartItem cartItem, AppDatabase db) {
    _auth.deleteCartItem(cartItem, db);
  }

  String _calculateItemTotalPrice(List<CartItem> cartItems) {
    double total = 0;
    _cartItems.forEach((cartItem) {
      total += ((cartItem.itemPrice) * cartItem.cartQuantity);
    });

    this.setState(() {
      _itemTotalAmount = total;
    });

    return '\₹ ' + total.toStringAsFixed(2);
  }

  String _calculateTotalPrice(List<CartItem> cartItems) {
    double grandTotal = _itemTotalAmount + _deliveryCharge;

    this.setState(() {
      _totalAmount = grandTotal;
    });

    return '\₹ ' + grandTotal.toStringAsFixed(2);
  }

  String returnDisplayText(int orderingState) {
    switch (orderingState) {
      case -1:
        return 'Your cart is empty';

      case 0:
        return '';

      case 1:
        return 'Your order has been placed successfully.\nOrder Id: $_orderId';

      case 2:
        return 'There was an issue processing your order. Please contact mikromart support';
    }
  }

  Future<void> confirmOrder(AppDatabase db) async {
    if (_orderingState != PROCESSING_ORDER) {
      setState(() {
        _orderingState = PROCESSING_ORDER;
      });

      CartValidationResponse cartValidationResponse =
          await _auth.validateCartItems(_cartItems, db);

      switch (cartValidationResponse.status) {
        case CartResponseEnum.OUT_OF_STOCK:
          errorMessage(
              '${cartValidationResponse.currentItem.item_name} is out of stock',
              MikroMartColors.colorPrimary,
              true,
              false);

          setState(() {
            _orderingState = ORDER_FAILED;
          });
          break;

        case CartResponseEnum.PRICE_UPDATED:
          errorMessage(
              'Price of ${cartValidationResponse.currentItem.item_name} is updated and hence your cart total has changed. Please confirm before continuing',
              MikroMartColors.colorPrimary,
              true,
              false);

          setState(() {
            _orderingState = ORDER_FAILED;
          });
          break;

        case CartResponseEnum.CART_QUANTITY_MORE:
          var availableCount = 0;
          for (var i = 0;
              i < cartValidationResponse.currentItem.item_quantity_list.length;
              i++) {
            for (var j = 0; j < _cartItems.length; j++) {
              if (cartValidationResponse
                      .currentItem.item_quantity_list[i].item_quantity ==
                  _cartItems[j].itemQuantity) {
                availableCount = cartValidationResponse
                    .currentItem.item_quantity_list[i].item_stock_quantity;
              }
            }
          }

          errorMessage(
              'There are currently on $availableCount ${cartValidationResponse.currentItem.item_name}s in stock',
              MikroMartColors.colorPrimary,
              true,
              false);

          setState(() {
            _orderingState = ORDER_FAILED;
          });
          break;

        case CartResponseEnum.UNAVAILABLE:
          errorMessage(
              '${cartValidationResponse.currentItem.item_name} is currently unavailable. Please check after some time',
              MikroMartColors.colorPrimary,
              true,
              false);

          setState(() {
            _orderingState = ORDER_FAILED;
          });
          break;

        case CartResponseEnum.VALID:
          /*if (paymentGatewaySelected) {
            //openCheckout();
            //TODO : Perform orders api call. Get order Id and then open checkout with these details
            //(i.e : order id, etc)
            RazorPayOrderResponse razorPayOrderResponse =
                await _auth.createRazorpayOrder(_totalAmount);

            if(razorPayOrderResponse!=null) {
              print('SUCCESS CALLING RAZORPAY ORDERS API. ORDER ID ' + razorPayOrderResponse.id);
              openCheckout(razorPayOrderResponse);
            } else {
              errorMessage(
                  'Something went wrong. Please check after some time',
                  MikroMartColors.colorPrimary,
                  true,
                  false);

              setState(() {
                _orderingState = ORDER_FAILED;
              });
            }
          } else {*/
          placeOrder(db, "");
          // }

          /*setState(() {
            _orderId = 'TEST';
            db.deleteAllCartItems();
            _outletLocation = null;
            _cartItems.clear();
            _orderingState = ORDER_PLACED_SUCCESSFULLY;
          });*/

          break;
      }
    }
  }

  placeOrder(AppDatabase db, String paymentId) async {
    //print('MOCK ORDER PLACED!');
    String moreItemsStr = '';

    if (_textEditingController.text.length > 0) {
      moreItemsStr = _textEditingController.text;
    }

    String result = await _auth.placeOrder(_cartItems, _totalAmount, db,
        moreItemsStr, _deliveryCharge, paymentGatewaySelected, paymentId);
    if (result != null) {
      setState(() {
        _orderId = result;
        db.deleteAllCartItems();
        _outletLocation = null;
        _cartItems.clear();
        _orderingState = ORDER_PLACED_SUCCESSFULLY;
      });
    } else {
      setState(() {
        _orderingState = ORDER_FAILED;
      });

      errorMessage('Something went wrong. Please contact MikroMart team',
          MikroMartColors.colorPrimary, true, false);
    }
  }

  Future<void> openCheckout(RazorPayOrderResponse razorPayOrderResponse) async {
    setState(() {
      _bookingStarted = true;
    });

    MikromartUser user = await _auth.fetchUserDetails();

    var options = {
      "order_id": razorPayOrderResponse.id,
      "key": "rzp_test_qhNwyWy4d05HAz",
      //"amount": num.parse(_totalAmount.toStringAsFixed(2)) * 100,
      "amount": razorPayOrderResponse.amount,
      "name": "MikroMart",
      "timeout": 300,
      "description": "MikroMart Order",
      "prefill": {"contact": user.phone, "email": user.email},
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      _bookingStarted = false;
    });
  }

  Future<void> computeDeliveryCharge() async {
    print('COMPUTING OUTLET LOCATION');
    //_outletLocation = new LatLng(10.065723, 76.495566);
    _outletLocation = await _auth.getOutletLocation(_cartItems[0].outletId);
    getDeliveryCharge();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/helpers/great_circle_distance_base.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/widgets/CusTomAppBar.dart';
import '../widgets/cartItemCard.dart';
import '../../locator.dart';
import '../shared/text_styles.dart' as style;
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import '../../core/Dish_list.dart';

class ShoppingCart extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  int NOT_ORDERING = -1;
  int PROCESSING_ORDER = 0;
  int ORDER_PLACED_SUCCESSFULLY = 1;
  int ORDER_FAILED = 2;

  List<CartItem> _cartItems = [];
  final AuthService _auth = AuthService();
  var _orderingState = -1;

  Flushbar<List<String>> _addressNameFlushBar;
  double _totalAmount = 0.0;

  String _orderId = '';

  @override
  Widget build(BuildContext context) {
    _cartItems = Provider.of<List<CartItem>>(context);
    AppDatabase db = Provider.of<AppDatabase>(context);

    return Scaffold(
      bottomNavigationBar: _cartItems != null && _cartItems.length > 0
          ? Card(
              elevation: 10,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                height: 130,
                width: MediaQuery.of(context).size.width * 0.85,
                color: Theme.of(context).cardColor,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 6,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          fit: FlexFit.loose,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Total: ',
                                style: style.cardTitleStyle,
                              ),
                              Text(
                                _calculateTotalPrice(_cartItems),
                                style: style.cardTitleStyle.copyWith(
                                    color: MikroMartColors.colorPrimary),
                              ),
                              Text(
                                'Delivery charge of \₹6/Km will be added to your bill total',
                                style: TextStyle(fontSize: 13),
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Container(
                          height: 75,
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                            onPressed: () async {
                              //showOrderConfirmationDialog();
                              showFirestoreError(
                                  'Your order total is \₹ ${_totalAmount}\nOnce confirmed, we will process your order and deliver within 3 to 4 hours',
                                  MikroMartColors.greenEndColor, () {
                                /* print(
                              'Confirmed. Proceed with order');*/
                                confirmOrder(db);
                              }, false, true);
                            },
                            elevation: 0.5,
                            color: MikroMartColors.colorPrimary,
                            child: Row(
                              children: <Widget>[
                                Center(
                                  child: Text(
                                    _orderingState == PROCESSING_ORDER
                                        ? 'Processing order'
                                        : 'Place Order',
                                  ),
                                ),
                                _orderingState == PROCESSING_ORDER
                                    ? Container(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 0, 0, 0),
                                        child:
                                            SpinKitCircle(color: Colors.white))
                                    : Container(),
                              ],
                            ),
                            textColor: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            CustomAppBar(
              title: 'Shopping Cart',
            ),
            Container(
              child: Expanded(
                  child: _cartItems != null && _cartItems.length > 0
                      ? ListView.builder(
                          itemCount: _cartItems.length,
                          itemBuilder: _cartItemBuilder)
                      : Stack(
                          children: <Widget>[
                            Container(
                              color: Colors.white,
                              padding: EdgeInsets.all(40),
                              child: _orderingState == 1
                                  ? Center(
                                      child: Container(
                                        child: Image(
                                          image: AssetImage('assets/tick.png'),
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
                                          color:
                                              MikroMartColors.colorAccentDark,
                                          fontSize: 26,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  )
                                : Container(),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(40, 0, 40, 120),
                                child: Text(
                                  returnDisplayText(_orderingState),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: _orderingState == -1
                                          ? MikroMartColors.subtitleGray
                                          : MikroMartColors.greenEndColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            _orderingState == ORDER_PLACED_SUCCESSFULLY ||
                                    _orderingState == ORDER_FAILED
                                ? Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 0, 60),
                                      child: OutlineButton(
                                        borderSide: BorderSide(
                                          color: MikroMartColors.purple,
                                          //Color of the border
                                          style: BorderStyle.solid,
                                          //Style of the border
                                          width: 0.8, //width of the border
                                        ),
                                        onPressed: () {
                                          this.setState(() {
                                            _orderingState = -1;
                                          });
                                        },
                                        child: Text(
                                          'Continue shopping',
                                          style: TextStyle(
                                              color: MikroMartColors.purple,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        )),
            ),
          ],
        ),
      ),
    );
  }

  getDeliveryCharge(LatLng outletLocation) async {
    GeoPoint userAddress = await _auth.getUserAddress();
    var gcd = new GreatCircleDistance.fromDegrees(
        latitude1: outletLocation.latitude,
        longitude1: outletLocation.longitude,
        latitude2: userAddress.latitude,
        longitude2: userAddress.longitude);
    double distance = gcd.haversineDistance();

    double deliveryCharge = distance * 6;

    return deliveryCharge;
  }

  Widget _cartItemBuilder(BuildContext context, int index) {
    AppDatabase db = Provider.of<AppDatabase>(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Container(
        height: 80,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.6),
                offset: Offset(0.0, 1.4), //(x,y)
                blurRadius: 3.0,
              ),
            ],
            color: Colors.white.withOpacity(0.9)),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(4.0),
              width: 100,
              height: 80,
              child: Image(
                image: NetworkImage(_cartItems[index].itemImage),
                fit: BoxFit.cover,
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
                      style: TextStyle(
                          color: MikroMartColors.textGray,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(_cartItems[index].itemQuantity,
                        style: TextStyle(
                            color: MikroMartColors.textGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                    SizedBox(
                      height: 8,
                    ),
                    Text('\₹ ' + _cartItems[index].cartPrice.toString(),
                        style: TextStyle(
                            color: MikroMartColors.textGray,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ButtonTheme(
                      minWidth: 40,
                      height: 40,
                      child: OutlineButton(
                        child: Container(
                          width: 20,
                          child: new Icon(
                            Icons.remove,
                            color: MikroMartColors.colorPrimary,
                          ),
                        ),
                        borderSide: BorderSide(
                          color: MikroMartColors.colorPrimary,
                          style: BorderStyle.solid, //Style of the border
                          width: 0.8, //width of the border
                        ),
                        onPressed: () {
                          if (_cartItems[index].cartQuantity != 0) {
                            int quantity = _cartItems[index].cartQuantity - 1;

                            if (quantity == 0) {
                              setState(() {
                                _orderingState = NOT_ORDERING;
                              });

                              deleteCartItem(_cartItems[index], db);
                            } else {
                              updateCartItemQuantity(
                                  _cartItems[index], quantity, db);
                            }
                          } else {}
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: Text(
                        _cartItems[index].cartQuantity.toString(),
                        style: style.arialTheme.copyWith(
                          color: MikroMartColors.colorPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ButtonTheme(
                        minWidth: 40,
                        height: 40,
                        child: OutlineButton(
                          child: new Icon(
                            Icons.add,
                            color: MikroMartColors.colorPrimary,
                          ),
                          borderSide: BorderSide(
                            color: MikroMartColors.colorPrimary,
                            style: BorderStyle.solid, //Style of the border
                            width: 0.8, //width of the border
                          ),
                          onPressed: () {
                            if (validateCartCount(_cartItems[index],
                                _cartItems[index].cartQuantity)) {
                              int quantity = _cartItems[index].cartQuantity + 1;
                              updateCartItemQuantity(
                                  _cartItems[index], quantity, db);
                            } else {
                              showErrorBottomSheet(_cartItems[index],
                                  _cartItems[index].cartQuantity);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
    )..show(context).then((result) {
        if (result != null) {
          String address = result[0];
          print('ADDRESS TYPED IS $address');
        } else {}
      });
  }

  showFirestoreError(String error, Color color, Function action,
      bool dismissable, bool showCancel) {
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
              padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
              child: Text(
                error,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
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
                            child: Text('Cancel'),
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
                      child: Text(dismissable ? 'OK' : 'Confirm'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      textColor: MikroMartColors.purpleEnd,
                      padding: EdgeInsets.all(6),
                      onPressed: () {
                        _addressNameFlushBar.dismiss();
                        action.call();
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
            color: Colors.orange, offset: Offset(0.0, 0.2), blurRadius: 5.0)
      ],
      backgroundGradient:
          LinearGradient(colors: [color, color.withOpacity(0.7)]),
      isDismissible: true,
      icon: Icon(
        Icons.check,
        color: Colors.white,
      ),
    )..show(context);
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

  String _calculateTotalPrice(List<CartItem> cartItems) {
    double total = 0;
    _cartItems.forEach((cartItem) {
      total += ((cartItem.itemPrice) * cartItem.cartQuantity);
    });

    this.setState(() {
      _totalAmount = total;
    });

    return '\₹ ' + total.toString();
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

      String cartItemsValid = await _auth.validateCartItems(_cartItems);

      if (cartItemsValid == 'cart_valid') {
        print('CART ITEMS ARE VALID. PROCEED WITH CHECKOUT');
        String result = await _auth.placeOrder(_cartItems, _totalAmount, db);
        if (result != null) {
          setState(() {
            _orderId = result;
            db.deleteAllCartItems();
            _orderingState = ORDER_PLACED_SUCCESSFULLY;
          });
        } else {
          setState(() {
            _orderingState = ORDER_FAILED;
          });
          showFirestoreError('Something went wrong. Please try again later',
              MikroMartColors.colorPrimary, null, true, false);
        }
      } else {
        print('CART ITEMS ARE INVALID. CANNOT PROCEED');
        showFirestoreError(
            cartItemsValid, MikroMartColors.colorPrimary, null, true, false);
        setState(() {
          _orderingState = ORDER_FAILED;
        });
      }
    }
  }
}

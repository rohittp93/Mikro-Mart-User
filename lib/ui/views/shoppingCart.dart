import 'package:flare_flutter/flare_actor.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:userapp/core/data/moor_database.dart';
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
  List<CartItem> _cartItems = [];
  final AuthService _auth = AuthService();

  Flushbar<List<String>> _addressNameFlushBar;

  @override
  Widget build(BuildContext context) {
    _cartItems = Provider.of<List<CartItem>>(context);

    return Scaffold(
      bottomNavigationBar: _cartItems.length > 0
          ? Card(
        elevation: 10,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          height: 130,
          width: MediaQuery
              .of(context)
              .size
              .width * 0.85,
          color: Theme
              .of(context)
              .cardColor,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
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
                      Text('Delivery charges included')
                    ],
                  ),
                  SizedBox(width: 10.0),
                  Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.4,
                    height: 65,
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      onPressed: () async {
                        //Navigator.pushNamed(context, '/paymentPage') ;
                        //TODO: Validate each item from firestore DB & check if the items are in stock or not
                        String cartItemsValid = await
                        _auth.validateCartItems(_cartItems);

                        if (cartItemsValid == 'cart_valid') {
                          print(
                              'CART ITEMS ARE VALID. PROCEED WITH CHECKOUT');
                        } else {
                          print('CART ITEMS ARE INVALID. CANNOT PROCEED');
                          showFirestoreError(cartItemsValid);
                        }
                      },
                      elevation: 0.5,
                      color: MikroMartColors.colorPrimary,
                      child: Center(
                        child: Text(
                          'PLACE ORDER',
                        ),
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
                  child: _cartItems.length > 0
                      ? ListView.builder(
                      itemCount: _cartItems.length,
                      itemBuilder: _cartItemBuilder)
                      : Stack(
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(40),
                        child: FlareActor(
                          "assets/empty.flr",
                          alignment: Alignment.center,
                          animation: 'empty',
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding:
                          const EdgeInsets.fromLTRB(0, 0, 0, 120),
                          child: Text(
                            'Your cart is empty',
                            style: TextStyle(
                                color: MikroMartColors.subtitleGray,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartItemBuilder(BuildContext context, int index) {
    AppDatabase db = Provider.of<AppDatabase>(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Container(
        height: 80,
        width: MediaQuery
            .of(context)
            .size
            .width,
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
                        child: new Icon(
                          Icons.remove,
                          color: MikroMartColors.colorPrimary,
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
                    ButtonTheme(
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
                'You can add only upto ${item.maxQuantity} ${item
                    .itemName} in a single order',
                style: TextStyle(color: Colors.white, fontSize: 16),
              )
                  : Text(
                'There are only ${item.quantityInStock} ${item
                    .itemName}s in stock. Please add within this limit',
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
    )
      ..show(context).then((result) {
        if (result != null) {
          String address = result[0];
          print('ADDRESS TYPED IS $address');
        } else {}
      });
  }


  showFirestoreError(String error) {
    _addressNameFlushBar = Flushbar<List<String>>(
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeOutCubic,
      animationDuration: Duration(milliseconds: 600),
      duration: Duration(seconds: 6),
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
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(10.0),
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
    )
      ..show(context).then((result) {
        if (result != null) {
          String address = result[0];
          print('ADDRESS TYPED IS $address');
        } else {}
      });
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

    return '\₹ ' + total.toString();
  }
}

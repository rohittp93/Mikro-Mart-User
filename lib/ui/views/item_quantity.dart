import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/core/models/item_quantity.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';
import '../shared/text_styles.dart' as style;

class ItemQuantityWidget extends StatefulWidget {
  final Function(int) itemQuantityChanged;
  final Item item;
  final int itemQuantity;
  final ItemQuantity displayableItemQuantity;
  final CartItem cartItem;

  const ItemQuantityWidget(
      {Key key,
        @required this.itemQuantityChanged,
        @required this.item,
        @required this.itemQuantity,
        @required this.displayableItemQuantity,
        this.cartItem})
      : super(key: key);

  @override
  _ItemQuantityWidgetState createState() => _ItemQuantityWidgetState();
}

class _ItemQuantityWidgetState extends State<ItemQuantityWidget> {
  //int _itemQuantity = 1;
  final AuthService _auth = AuthService();

  Flushbar _cartItemQuantityFlushbar;

  @override
  Widget build(BuildContext context) {
    AppDatabase db = Provider.of<AppDatabase>(context);

    return Align(
      alignment: Alignment.bottomRight,
      child: SizedBox(
        child: Container(
         /* decoration: BoxDecoration(
              color: MikroMartColors.purple,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12)),
              border: Border.all(
                  width: 3,
                  color: MikroMartColors.purple,
                  style: BorderStyle.solid)),*/
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Flexible(
                child: Stack(
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        width: 48,
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Center(
                          child: new Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        if (widget.itemQuantity != 0) {
                          int quantity = widget.itemQuantity - 1;
                          widget.itemQuantityChanged(quantity);

                          if (quantity == 0) {
                            deleteCartItem(widget.cartItem, db);
                          } else {
                            updateCartItemQuantity(
                                widget.cartItem, quantity, db);
                          }
                        } else {}
                      },
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                  child: Text(
                    widget.itemQuantity.toString(),
                    style: style.mediumTextTitle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Flexible(
                child: Stack(
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        width: 48,
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Center(
                          child: new Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        if (validateCartCount(widget.item, widget.itemQuantity,
                            widget.displayableItemQuantity)) {
                          int quantity = widget.itemQuantity + 1;
                          updateCartItemQuantity(widget.cartItem, quantity, db);

                          widget.itemQuantityChanged(quantity);
                        } else {
                          showErrorBottomSheet(widget.item, widget.itemQuantity,
                              widget.displayableItemQuantity);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showErrorBottomSheet(
      Item item, int itemQuantity, ItemQuantity displayableItemQuantity) {
    _cartItemQuantityFlushbar = Flushbar<List<String>>(
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
              child: ((itemQuantity + 1) <=
                  displayableItemQuantity.item_stock_quantity)
                  ? Text(
                'You can add only upto ${item.max_cart_threshold} ${item.item_name} in a single order',
                style: TextStyle(color: Colors.white, fontSize: 16),
              )
                  : Text(
                'There are only ${displayableItemQuantity.item_stock_quantity} ${item.item_name}s in stock. Please add within this limit',
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
                    _cartItemQuantityFlushbar.dismiss();
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
    )..show(context);
  }

  void updateCartItemQuantity(CartItem cartItem, int quantity, AppDatabase db) {
    final item = cartItem.copyWith(
        cartQuantity: quantity, cartPrice: ((cartItem.itemPrice) * quantity));
    _auth.updateCartItem(item, db);
  }

  void deleteCartItem(CartItem cartItem, AppDatabase db) {
    _auth.deleteCartItem(cartItem, db);
  }

  bool validateCartCount(
      Item item, int itemQuantity, ItemQuantity displayableItemQuantity) {
    return (itemQuantity + 1) <= item.max_cart_threshold &&
        (itemQuantity + 1) <= displayableItemQuantity.item_stock_quantity;
  }
}
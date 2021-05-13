import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/core/models/item_quantity.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/shared/dottedline.dart';
import 'package:userapp/ui/views/item_quantity.dart';
import 'package:userapp/ui/widgets/offers_list.dart';
import '../shared/text_styles.dart' as style;

class ItemDetail extends StatefulWidget {
  final Item item;

  ItemDetail({this.item});

  @override
  _ItemDetailState createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  ItemQuantity displayableItemQuantity = new ItemQuantity();
  List<DropdownMenuItem<ItemQuantity>> _dropdownMenuItems = [];
  bool itemAdded = false;
  List<CartItem> _cartItems = [];
  int _itemQuantity = 0;
  CartItem _cartItem;
  final AuthService _auth = AuthService();

  var _outletChangeFlushbar;

  @override
  void initState() {
    super.initState();
    _dropdownMenuItems = buildDropDownMenuItems(widget.item.item_quantity_list);

    for (var i = 0; i < widget.item.item_quantity_list.length; i++) {
      if (widget.item.item_quantity_list[i].display_quantity) {
        displayableItemQuantity = widget.item.item_quantity_list[i];
        break;
      }
    }
  }

  List<DropdownMenuItem<ItemQuantity>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<ItemQuantity>> items = List();
    for (ItemQuantity listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem.item_quantity),
          //child: Text(listItem.item_quantity.length>20 ? listItem.item_quantity.substring(0,20): listItem.item_quantity.length),
          value: listItem,
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    bool itemOnOffer =
        displayableItemQuantity.item_price < displayableItemQuantity.item_mrp;

    AppDatabase db = Provider.of<AppDatabase>(context);
    _cartItems = Provider.of<List<CartItem>>(context);

    if (_cartItems != null && _cartItems.length > 0) {
      int position = _cartItems.indexWhere((cartItem) {
        return (cartItem.itemId == widget.item.id) &&
            (displayableItemQuantity.item_quantity == cartItem.itemQuantity);
      });

      if (position >= 0) {
        setState(() {
          _cartItem = _cartItems[position];
          itemAdded = true;
          _itemQuantity = _cartItem.cartQuantity;
        });
      } else {
        setState(() {
          itemAdded = false;
          _itemQuantity = 0;
        });
      }
    } else {
      setState(() {
        itemAdded = false;
        _itemQuantity = 0;
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Hero(
                      tag: widget.item.item_name,
                      child: AspectRatio(
                        aspectRatio: 2 / 1.2,
                        child: CachedNetworkImage(
                          imageUrl: widget.item.item_image_path,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                              child: SizedBox(
                            height: 15.0,
                            width: 15.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  MikroMartColors.colorPrimary),
                            ),
                          )),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, (MediaQuery.of(context).size.width) * 0.65, 20, 0),
                  child: Container(
                    width: double.infinity,
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
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: Container(
                            width: 83,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color:
                                  MikroMartColors.itemDetailSwipeIndicatorColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                flex: 80,
                                child: Text(
                                  widget.item.item_name,
                                  style: TextStyle(
                                      fontSize: 19.0,
                                      fontFamily: 'Mulish',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Flexible(
                                flex: 30,
                                child: Text(
                                  '₹ ' +
                                      displayableItemQuantity.item_mrp
                                          .toString(),
                                  style: itemOnOffer
                                      ? style.subHeaderStyle.copyWith(
                                          fontSize: 15,
                                          color: MikroMartColors
                                              .disabledPriceColor,
                                          decoration:
                                              TextDecoration.lineThrough)
                                      : style.subHeaderStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        itemOnOffer
                            ? Padding(
                                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'Discount Price',
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Mulish',
                                          color: MikroMartColors.colorPrimary),
                                    ),
                                    Text(
                                      '₹ ' +
                                          displayableItemQuantity.item_price
                                              .toString(),
                                      style: style.subHeaderStyle.copyWith(
                                        color: MikroMartColors.colorPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        itemOnOffer
                            ? Padding(
                                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'Offer',
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Mulish',
                                          color: MikroMartColors.badgeGreen),
                                    ),
                                    Text(
                                      calculatePercentage(
                                                  displayableItemQuantity
                                                      .item_price,
                                                  displayableItemQuantity
                                                      .item_mrp)
                                              .toString() +
                                          '% OFF',
                                      style: style.subHeaderStyle.copyWith(
                                        color: MikroMartColors.badgeGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: MySeparator(color: Colors.grey),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Item Quantity',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontFamily: 'Mulish',
                                    fontWeight: FontWeight.bold),
                              ),
                              Flexible(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        color: MikroMartColors.cardBG,
                                        border: Border.all(
                                            color:
                                                MikroMartColors.colorPrimary)),
                                    child: Center(
                                      child: DropdownButtonHideUnderline(
                                        child: _dropdownMenuItems.length > 0
                                            ? DropdownButton<ItemQuantity>(
                                                value: displayableItemQuantity,
                                                items: _dropdownMenuItems,
                                                onChanged: (value) {
                                                  setState(() {
                                                    displayableItemQuantity =
                                                        value;
                                                  });
                                                })
                                            : Container(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: MySeparator(color: Colors.grey),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Text(
                              'Product Description',
                              style: TextStyle(
                                  fontSize: 19.0,
                                  fontFamily: 'Mulish',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 6, 20, 10),
                            child: Text(
                              widget.item.item_description,
                              style: style.subHeaderStyle.copyWith(
                                  color: MikroMartColors.disabledPriceColor),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: MySeparator(color: Colors.grey),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Text(
                              'Store',
                              style: TextStyle(
                                  fontSize: 19.0,
                                  fontFamily: 'Mulish',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 6, 20, 300),
                            child: Text(
                              widget.item.outlet_id,
                              style: style.subHeaderStyle.copyWith(
                                  color: MikroMartColors.disabledPriceColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 40, right: 40, bottom: 100.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: MikroMartColors.colorPrimary,
                      ),
                      width: double.infinity,
                      height: 55,
                      child: itemAdded
                          ? ItemQuantityWidget(
                              item: widget.item,
                              cartItem: _cartItem,
                              displayableItemQuantity: displayableItemQuantity,
                              itemQuantity: _itemQuantity,
                              itemQuantityChanged: (itemQuantity) {
                                if (itemQuantity == 0) {
                                  setState(() {
                                    itemAdded = false;
                                  });
                                }
                              },
                            )
                          : InkWell(
                              onTap: () {
                                bool isFromSameOutlet = true;

                                if (displayableItemQuantity
                                        .item_stock_quantity ==
                                    0) {
                                  outOfStockBottomSheet(widget.item);
                                } else {
                                  for (CartItem cartItem in _cartItems) {
                                    if (cartItem.outletId !=
                                        widget.item.outlet_id) {
                                      isFromSameOutlet = false;
                                      break;
                                    }
                                  }

                                  if (isFromSameOutlet) {
                                    addToCart(db, displayableItemQuantity);
                                  } else {
                                    outletChangeErrorSheet(
                                        _cartItems[0], widget.item, () {
                                      db.deleteAllCartItems().then((value) => {
                                            addToCart(
                                                db, displayableItemQuantity)
                                          });
                                    });
                                  }
                                }
                              },
                              child: Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'ADD TO CART',
                                      style: style.mediumTextTitle
                                          .copyWith(color: Colors.white),
                                    ),
                                  )),
                            )),
                ),
              ),
              Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  Container(
                    color: MikroMartColors.colorPrimary,
                    height: 60,
                  ),
                  InkWell(
                    customBorder: new CircleBorder(),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.only(left: 16),
                      width: 50,
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  outOfStockBottomSheet(Item item) {
    _outletChangeFlushbar = Flushbar<List<String>>(
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
              child: Text(
                '${item.item_name} is out of stock',
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Mulish', fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
              child: Align(
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
                      _outletChangeFlushbar.dismiss();
                    },
                  ),
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

  void addToCart(AppDatabase db, ItemQuantity displayableItemQuantity) {
    CartItem cartItem = new CartItem(
        itemId: widget.item.id,
        itemImage: widget.item.item_image_path,
        itemQuantity: displayableItemQuantity.item_quantity,
        cartQuantity: 1,
        itemName: widget.item.item_name,
        cartItemId: widget.item.id + displayableItemQuantity.item_quantity,
        outletId: widget.item.outlet_id,
        itemPrice: displayableItemQuantity.item_price,
        maxQuantity: widget.item.max_cart_threshold,
        quantityInStock: displayableItemQuantity.item_stock_quantity,
        cartPrice: displayableItemQuantity.item_price);

    _auth.addCartItem(cartItem, db);
  }

  outletChangeErrorSheet(CartItem cart_item, Item item, Function onContinue) {
    _outletChangeFlushbar = Flushbar<List<String>>(
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
                'Your cart contains items from ${cart_item.outletId}\n\nDo you wish to clear your cart & continue with order from ${item.outlet_id}',
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Mulish', fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: FlatButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontFamily: 'Mulish'),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      textColor: MikroMartColors.purpleEnd,
                      padding: EdgeInsets.all(6),
                      onPressed: () {
                        _outletChangeFlushbar.dismiss();
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: FlatButton(
                      child: Text(
                        'Continue',
                        style: TextStyle(fontFamily: 'Mulish'),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      textColor: MikroMartColors.purpleEnd,
                      padding: EdgeInsets.all(6),
                      onPressed: () {
                        _outletChangeFlushbar.dismiss();
                        onContinue.call();
                      },
                    ),
                  ),
                ],
              ),
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
}

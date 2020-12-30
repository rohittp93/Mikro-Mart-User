import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/core/models/item_quantity.dart';
import 'package:userapp/core/services/firebase_service.dart';
import 'package:userapp/ui/shared/colors.dart';
import '../shared/text_styles.dart' as style;

final stateBloc = StateBloc();

class ItemDetails extends StatelessWidget {
  final Item data;

  ItemDetails({this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutStarts(
        item: data,
      ),
    );
  }
}

class LayoutStarts extends StatefulWidget {
  final Item item;

  LayoutStarts({this.item});

  @override
  _LayoutStartsState createState() => _LayoutStartsState();
}

class _LayoutStartsState extends State<LayoutStarts> {
  bool itemAdded = false;
  final AuthService _auth = AuthService();
  List<CartItem> _cartItems;
  int _itemQuantity = 0;
  CartItem _cartItem;
  Flushbar _outletChangeFlushbar;
  ItemQuantity displayableItemQuantity = new ItemQuantity();
  List<DropdownMenuItem<ItemQuantity>> _dropdownMenuItems;

  @override
  void initState() {
    super.initState();
    print('IQTAG: initstate called');
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
          value: listItem,
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    AppDatabase db = Provider.of<AppDatabase>(context);
    _cartItems = Provider.of<List<CartItem>>(context);
    print('IQTAG: Cart Rebuilt displayableItemQuantity ' +
        displayableItemQuantity.item_quantity);

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

    return Stack(
      children: <Widget>[
        CarDetailsAnimation(data: widget.item),
        CustomBottomSheet(
          context: context,
          data: widget.item,
          displayableItem: displayableItemQuantity,
          onItemQuantityChanged: (ItemQuantity value) {
            print('IQTAG: Cart Rebuilt ${value.item_quantity}');
            setState(() {
              displayableItemQuantity = value;
            });
          },
          dropDownItems: _dropdownMenuItems,
        ),
        itemAdded
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
            : AddToCartButton(
                itemAdded: () {
                  bool isFromSameOutlet = true;

                  if (displayableItemQuantity.item_stock_quantity == 0) {
                    outOfStockBottomSheet(widget.item);
                  } else {
                    for (CartItem cartItem in _cartItems) {
                      if (cartItem.outletId != widget.item.outlet_id) {
                        isFromSameOutlet = false;
                        break;
                      }
                    }

                    if (isFromSameOutlet) {
                      addToCart(db, displayableItemQuantity);
                    } else {
                      outletChangeErrorSheet(_cartItems[0], widget.item, () {
                        db.deleteAllCartItems().then((value) =>
                            {addToCart(db, displayableItemQuantity)});
                      });
                    }
                  }
                },
              ),
      ],
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
                    _outletChangeFlushbar.dismiss();
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
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: FlatButton(
                    child: Text('Cancel'),
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
                    child: Text('Continue'),
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
}

class AddToCartButton extends StatelessWidget {
  final Function itemAdded;

  AddToCartButton({@required this.itemAdded});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: SizedBox(
        child: Container(
          width: 180,
          child: FlatButton(
            onPressed: () {
              itemAdded();
            },
            child: Text(
              "Add To Cart ",
              style: style.arialTheme,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12)),
            ),
            color: MikroMartColors.colorPrimary,
            padding: EdgeInsets.fromLTRB(0, 25, 0, 25),
          ),
        ),
      ),
    );
  }
}

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
          decoration: BoxDecoration(
              color: MikroMartColors.purple,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12)),
              border: Border.all(
                  width: 3,
                  color: MikroMartColors.purple,
                  style: BorderStyle.solid)),
          width: 180,
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
                    style: style.arialTheme,
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

class CarDetailsAnimation extends StatefulWidget {
  final Item data;

  CarDetailsAnimation({this.data});

  @override
  _CarDetailsAnimationState createState() => _CarDetailsAnimationState();
}

class _CarDetailsAnimationState extends State<CarDetailsAnimation>
    with TickerProviderStateMixin {
  AnimationController fadeController;
  AnimationController scaleController;

  Animation fadeAnimation;
  Animation scaleAnimation;

  @override
  void initState() {
    super.initState();

    fadeController =
        AnimationController(duration: Duration(milliseconds: 180), vsync: this);

    scaleController =
        AnimationController(duration: Duration(milliseconds: 350), vsync: this);

    fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(fadeController);
    scaleAnimation = Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: scaleController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    ));
  }

  forward() {
    scaleController.forward();
    fadeController.forward();
  }

  reverse() {
    scaleController.reverse();
    fadeController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      initialData: StateProvider().isAnimating,
      stream: stateBloc.animationStatus,
      builder: (context, snapshot) {
        snapshot.data ? forward() : reverse();

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: DishDetails(data: widget.data),
          ),
        );
      },
    );
  }
}

class DishDetails extends StatelessWidget {
  final Item data;

  DishDetails({this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
      children: <Widget>[
        Positioned(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: CarCarousel(data: data),
          ),
        ),
        SafeArea(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(left: 25),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 42,
                    ),
                  )),
            ],
          ),
        ),
      ],
    ));
  }
}

class CarCarousel extends StatefulWidget {
  final Item data;

  CarCarousel({this.data});

  @override
  _CarCarouselState createState() => _CarCarouselState();
}

class _CarCarouselState extends State<CarCarousel> {
  //List<String> imgList;

  List<Widget> child() {}

  //List<Widget> childe;

  List<T> _map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  int _current = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 2,
            child: Center(
              child: Image(
                image: NetworkImage(widget.data.item_image_path),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////
class CustomBottomSheet extends StatefulWidget {
  BuildContext context;
  final Item data;
  final ItemQuantity displayableItem;
  final Function onItemQuantityChanged;
  final List<DropdownMenuItem<ItemQuantity>> dropDownItems;

  CustomBottomSheet(
      {this.context,
      this.data,
      this.displayableItem,
      this.onItemQuantityChanged,
      this.dropDownItems});

  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet>
    with SingleTickerProviderStateMixin {
  double sheetTop;

  double minSheetTop = 30;

  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    double sheetTop = MediaQuery.of(widget.context).size.height * 0.5;
    double minSheetTop = 100;
    controller = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    animation = Tween<double>(begin: sheetTop, end: minSheetTop)
        .animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInCubic,
      reverseCurve: Curves.easeInOut,
    ))
          ..addListener(() {
            setState(() {});
          });
  }

  forwardAnimation() {
    controller.forward();
    stateBloc.toggleAnimation();
  }

  reverseAnimation() {
    controller.reverse();
    stateBloc.toggleAnimation();
  }

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: animation.value,
      left: 0,
      child: GestureDetector(
        onTap: () {
          controller.isCompleted ? reverseAnimation() : forwardAnimation();
        },
       /* onPanUpdate: (pan) {
          print('PanUpdated called');
        },*/
        onVerticalDragEnd: (DragEndDetails dragEndDetails) {
          print('DragEnd called');
          //upward drag
          if (dragEndDetails.primaryVelocity < 0.0 && !controller.isCompleted) {
            forwardAnimation();
            controller.forward();
          } else if (dragEndDetails.primaryVelocity > 0.0 &&
              controller.isCompleted) {
            reverseAnimation();
          } else {
            return;
          }
        },
        child: SingleChildScrollView(
          child: SheetContainer(
              data: widget.data,
              displayableItem: widget.displayableItem,
              itemQuantityChanged: widget.onItemQuantityChanged,
              dropDownItems: widget.dropDownItems),
        ),
      ),
    );
  }
}

class SheetContainer extends StatelessWidget {
  final Item data;
  final ItemQuantity displayableItem;
  final Function itemQuantityChanged;
  final List<DropdownMenuItem<ItemQuantity>> dropDownItems;

  SheetContainer(
      {this.data,
      this.displayableItem,
      this.itemQuantityChanged,
      this.dropDownItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          color: Theme.of(context).cardColor),
      child: Column(
        children: <Widget>[
          drawerHandle(),
          Expanded(
            flex: 1,
            child: ListView(
              padding: EdgeInsets.only(left: 15),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      flex: 2,
                      child: Text(
                        data.item_name + ' - ' + displayableItem.item_quantity,
                        style: style.itemDetailHeader,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                            child: Text(
                              '${'₹ ' + displayableItem.item_price.toStringAsFixed(2)}',
                              style: style.itemDetailHeader.copyWith(
                                  color: MikroMartColors.colorPrimary),
                            ),
                          ),
                          displayableItem.item_mrp != null
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 5, 15, 0),
                                  child: displayableItem.item_mrp !=
                                          displayableItem.item_price
                                      ? Text(
                                          'MRP: ₹' +
                                              displayableItem.item_mrp
                                                  .toStringAsFixed(2),
                                          overflow: TextOverflow.ellipsis,
                                          style: style.itemPriceText.copyWith(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontSize: 16,
                                              color: MikroMartColors.ErroColor),
                                        )
                                      : Container(),
                                )
                              : Container(),
                          (displayableItem.item_mrp != null &&
                                  displayableItem.item_mrp !=
                                      displayableItem.item_price)
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 15, 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      calculatePercentage(
                                                  displayableItem.item_price,
                                                  displayableItem.item_mrp)
                                              .toString() +
                                          '% OFF',
                                      overflow: TextOverflow.ellipsis,
                                      style: style.itemPriceText.copyWith(
                                          color: MikroMartColors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Item Quantity',
                      style: style.itemDetailHeader,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Container(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            color: MikroMartColors.white,
                            border: Border.all()),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ItemQuantity>(
                              value: displayableItem,
                              items: dropDownItems,
                              onChanged: (value) {
                                itemQuantityChanged(value);
                              }),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Product Description',
                  style: style.itemDetailHeader,
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                  child: Text(
                    data.item_description,
                    style: style.textTheme,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'Store',
                  style: style.itemDetailHeader,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  data.outlet_id,
                  style: style.textTheme,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  calculatePercentage(itemRate, mrpRate) {
    if (itemRate != 0.0 && mrpRate != 0.0) {
      if (itemRate == mrpRate) {
        return 0;
      } else {
        if (mrpRate > itemRate) {
          double percentage = (100 - ((itemRate / mrpRate) * 100));
          return percentage.round();
        } else {
          return 0;
        }
      }
    }
  }

  drawerHandle() {
    return Container(
      margin: EdgeInsets.only(bottom: 25),
      height: 3,
      width: 65,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Color(0xffd9dbdb)),
    );
  }
}

class StateBloc {
  StreamController animationController = StreamController.broadcast();
  final StateProvider provider = StateProvider();

  Stream get animationStatus => animationController.stream;

  void toggleAnimation() {
    provider.toggleAnimationValue();
    animationController.sink.add(provider.isAnimating);
  }

  void dispose() {
    animationController.close();
  }
}

class StateProvider {
  bool isAnimating = true;

  void toggleAnimationValue() => isAnimating = !isAnimating;
}

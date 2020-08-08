import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:userapp/core/helpers/algolia.dart';
import 'package:userapp/core/models/categories.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/core/models/orders.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/views/itemDetails.dart';
import 'package:userapp/ui/views/order_detail.dart';
import 'package:userapp/ui/widgets/titleAppBar.dart';
import 'package:userapp/core/services/firebase_service.dart' as firebase;
import '../shared/text_styles.dart' as style;

class OrderList extends StatefulWidget {
  const OrderList();

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  List<DocumentSnapshot> _productSnapshots = [];
  List<OrderModel> _products = [];
  bool _isLoading = false;
  int _per_page = 10;
  DocumentSnapshot _lastDocument;
  bool _gettingMoreProducts = false;
  bool _moreProductsAvailable = true;
  ScrollController _scrollController = ScrollController();
  var _blankFocusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    _getProducts();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      print('ITEMLOADMORE : Scrollchanged');
      if (maxScroll - currentScroll <= delta) {
        _getMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getProducts() async {
    setState(() {
      _isLoading = true;
    });

    _productSnapshots = await firebase.getOrders(_per_page);

    _productSnapshots.forEach((document) {
      OrderModel orderModel =
          OrderModel.fromMap(document.data, document.documentID);
      _products.add(orderModel);
    });

    if (_productSnapshots != null && _productSnapshots.length > 0)
      _lastDocument = _productSnapshots[_productSnapshots.length - 1];

    setState(() {
      _isLoading = false;
    });
  }

  _getMoreProducts() async {
    if (_moreProductsAvailable == false) {
      //Display message saying there are no more products
      print('No more products');
      return;
    }

    if (_gettingMoreProducts == true) {
      return;
    }

    print('Get more products called');

    _gettingMoreProducts = true;

    List<DocumentSnapshot> orders =
        await firebase.getMoreOrders(_per_page, _lastDocument);

    if (orders.length < _per_page) {
      _moreProductsAvailable = false;
    }

    _productSnapshots.addAll(orders);
    _lastDocument = _productSnapshots[_productSnapshots.length - 1];

    orders.forEach((document) {
      OrderModel orderModel =
          OrderModel.fromMap(document.data, document.documentID);
      _products.add(orderModel);
    });

    setState(() {});

    _gettingMoreProducts = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        color: MikroMartColors.white,
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TitleAppBar(title: 'My Orders'),
              _isLoading
                  ? Flexible(
                      flex: 1,
                      child: Center(child: CircularProgressIndicator()))
                  : (_products.length == 0
                      ? Expanded(
                        child: Center(
                            child: Text('No order history'),
                          ),
                      )
                      : Expanded(
                          child: Container(
                            child: ListView.separated(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                OrderModel orderModel = _products[index];

                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                new OrderDetail(
                                                  orderModel: orderModel,
                                                )));
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(6.0, 0, 6, 3),
                                    child: Card(
                                      elevation: 4,
                                      child: Container(
                                        color: Colors.white,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      12, 12, 0, 0),
                                              child: Text(
                                                "Order ID : " +
                                                    orderModel.order_id,
                                                style: style.mediumTextTitle
                                                    .copyWith(
                                                        color: MikroMartColors
                                                            .purple),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      12, 6, 0, 0),
                                              child: Text(
                                                "Order Status : " +
                                                    firebase.showOrderStatus(
                                                        orderModel
                                                            .order_status),
                                                style: style.mediumTextSubtitle,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      12, 6, 0, 0),
                                              child: Text(
                                                "Ordered Time : " +
                                                    formatTimestamp((orderModel
                                                        .created_time
                                                        .toDate()
                                                        .millisecondsSinceEpoch)),
                                                style: style.mediumTextSubtitle,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      12, 6, 0, 12),
                                              child: Text(
                                                "Order Total : ₹ " +
                                                    orderModel.total_amount
                                                        .toString(),
                                                style: style.mediumTextSubtitle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              itemCount: _products.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Divider(color: Colors.transparent);
                              },
                            ),
                          ),
                        )),
            ],
          ),
        ),
      ),
    );
  }

  String formatTimestamp(int timestamp) {
    var format = new DateFormat('dd MMM yyyy, hh:mm a');
    return format.format(new DateTime.fromMillisecondsSinceEpoch(timestamp));
  }
}

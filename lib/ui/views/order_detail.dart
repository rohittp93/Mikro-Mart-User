import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:userapp/core/helpers/algolia.dart';
import 'package:userapp/core/models/store.dart';
import 'package:userapp/core/models/item.dart';
import 'package:userapp/core/models/orders.dart';
import 'package:userapp/ui/shared/colors.dart';
import 'package:userapp/ui/views/itemDetails.dart';
import 'package:userapp/ui/widgets/titleAppBar.dart';
import 'package:userapp/core/services/firebase_service.dart' as firebase;
import '../shared/text_styles.dart' as style;

class OrderDetail extends StatefulWidget {
  final OrderModel orderModel;

  const OrderDetail({@required this.orderModel});

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  var _orderItems = [];

  @override
  void initState() {
    super.initState();

    widget.orderModel.cart_items.forEach((cartItem) {
      Item item = new Item.fromOrderItemMap(cartItem);
      _orderItems.add(item);
    });

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: MikroMartColors.white,
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    color: MikroMartColors.colorPrimary,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 50,
                          child: FlatButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        Container(
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Order Detail',
                                style: style.mediumTextTitle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
                          child: Text(
                            "Order ID : " + widget.orderModel.order_id,
                            style: style.mediumTextTitle.copyWith(
                                fontSize: 16, color: MikroMartColors.textGray),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                          child: Text(
                            "Order Status : " +
                                firebase.showOrderStatus(
                                    widget.orderModel.order_status),
                            style: style.mediumTextTitle.copyWith(
                                fontSize: 16, color: MikroMartColors.textGray),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                          child: Text(
                            "Order Total : " +
                                widget.orderModel.total_amount.toString(),
                            style: style.mediumTextTitle.copyWith(
                                fontSize: 16, color: MikroMartColors.textGray),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                          child: Text(
                            "Ordered Time : " +
                                formatTimestamp((widget.orderModel.created_time
                                    .toDate()
                                    .millisecondsSinceEpoch)),
                            style: style.mediumTextSubtitle.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                          child: Text(
                            "Payment : " +
                                ((widget.orderModel.already_paid != null &&
                                        widget.orderModel.already_paid)
                                    ? "Paid"
                                    : "Cash On Delivery"),
                            style: style.mediumTextSubtitle.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 18, 12, 0),
                            child: Text(
                              'ITEMS',
                              style: style.mediumTextTitle
                                  .copyWith(color: MikroMartColors.textGray),
                            ),
                          ),
                        ),
                        Container(
                          child: Expanded(
                            child: ListView.separated(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                Item item = _orderItems[index];

                                return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(6.0, 0, 6, 3),
                                  child: Card(
                                    elevation: 4,
                                    child: Container(
                                      color: Colors.white,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Flexible(
                                            flex: 3,
                                            child: Container(
                                              height: 80,
                                              width: 100,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        12, 6, 0, 0),
                                                child: Image(
                                                  image: NetworkImage(
                                                      item.item_image_path),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 7,
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
                                                    "ID : " + item.id,
                                                    style: style
                                                        .mediumTextSubtitle
                                                        .copyWith(
                                                            fontSize: 14,
                                                            color: MikroMartColors
                                                                .colorPrimary),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          12, 6, 0, 0),
                                                  child: Text(
                                                    "Name : " + item.item_name,
                                                    style: style
                                                        .mediumTextSubtitle
                                                        .copyWith(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          12, 6, 0, 12),
                                                  child: Text(
                                                    "Price : ₹ " +
                                                        item.order_item_price
                                                            .toString(),
                                                    style: style
                                                        .mediumTextSubtitle
                                                        .copyWith(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              itemCount: _orderItems.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Divider(color: Colors.transparent);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

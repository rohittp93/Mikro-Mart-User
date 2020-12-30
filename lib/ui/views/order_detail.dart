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

    setState(() {

    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (v) {

        },
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
                  TitleAppBar(title: 'Order Detail'),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 6,12,0),
                            child: Text(
                              "Order ID : " + widget.orderModel.order_id,
                              style: style.mediumTextTitle
                                  .copyWith(
                                  color:
                                  MikroMartColors
                                      .textGray),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 6,12,0),
                            child: Text(
                              "Order Status : " + firebase.showOrderStatus(
                                  widget.orderModel
                                      .order_status),
                              style: style.mediumTextTitle
                                  .copyWith(
                                  color:
                                  MikroMartColors
                                      .textGray),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 6,12,0),
                            child: Text(
                              "Order Total : " + widget.orderModel
                                  .total_amount
                                  .toString(),
                              style: style.mediumTextTitle
                                  .copyWith(
                                  color:
                                  MikroMartColors
                                      .textGray),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 6,12,0),
                            child: Text(
                              "Ordered Time : " +
                                  formatTimestamp(
                                      (widget.orderModel
                                          .created_time
                                          .toDate()
                                          .millisecondsSinceEpoch)),
                              style: style
                                  .mediumTextSubtitle,
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 18, 12, 0),
                              child: Text('ITEMS',
                                style: style.mediumTextTitle,
                              ),
                            ),
                          ),
                          Container(
                            child: Expanded(
                              child: ListView.separated(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemBuilder:
                                    (BuildContext context, int index) {
                                  Item item = _orderItems[index];

                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        6.0, 0, 6, 3),
                                    child: Card(
                                      elevation: 4,
                                      child: Container(
                                        color: Colors.white,
                                        child: Row(
                                          children: <Widget>[
                                            Container(
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
                                            Column(
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
                                                    "ID : " +
                                                        item.id,
                                                    style: style.mediumTextSubtitle
                                                        .copyWith(
                                                        color:
                                                        MikroMartColors
                                                            .purple),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.fromLTRB(
                                                      12, 6, 0, 0),
                                                  child: Text(
                                                    "Name : " +
                                                        item.item_name,
                                                    style: style
                                                        .mediumTextSubtitle,
                                                  ),
                                                ),

                                                Padding(
                                                  padding:
                                                  const EdgeInsets.fromLTRB(
                                                      12, 6, 0, 12),
                                                  child: Text(
                                                    "Price : ₹ " +
                                                        item.order_item_price.toString(),
                                                    style: style
                                                        .mediumTextSubtitle,
                                                  ),
                                                ),
                                              ],
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

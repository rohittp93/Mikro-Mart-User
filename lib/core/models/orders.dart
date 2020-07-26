import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class OrderModel {
  int order_status;
  Timestamp created_time;
  List<Map<String, dynamic>> cart_items;
  double total_amount;
  String user_name;
  String user_house_name;
  GeoPoint user_location;
  String outlet_name;

  OrderModel({
    @required this.order_status,
    @required this.cart_items,
    @required this.total_amount,
    @required this.user_name,
    @required this.user_house_name,
    @required this.user_location,
    @required this.outlet_name,
  });

  OrderModel.fromMap(Map<String, dynamic> data) {
    order_status = data['order_status'];
    created_time = data['created_time'];
    total_amount = data['total_amount'];
    user_name = data['user_name'];
    user_house_name = data['user_house_name'];
    created_time = data['created_time'];
    user_location = data['user_location'];
    cart_items = data['cart_items'];
    outlet_name = data['outlet_name'];
  }
}

/*
class OrderItem {
  String cart_item_id;
  String cart_item_name;
  int cart_item_quantity;
  double item_price;
  String item_image;

  OrderItem({
    @required this.cart_item_id,
    @required this.cart_item_name,
    @required this.cart_item_quantity,
    @required this.item_price,
    @required this.item_image,
  });
}
*/

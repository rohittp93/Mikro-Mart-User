import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class OrderModel {
  int order_status;
  Timestamp created_time;
  List<dynamic> cart_items;
  double total_amount, delivery_charge;
  bool already_paid;
  String user_name;
  String user_house_name;
  GeoPoint user_location;
  String outlet_name;
  String order_id;
  String extra_item;
  String payment_id;

  OrderModel({
    @required this.order_status,
    @required this.cart_items,
    @required this.total_amount,
    @required this.user_name,
    @required this.user_house_name,
    @required this.user_location,
    @required this.outlet_name,
    @required this.extra_item,
    @required this.already_paid,
    @required this.delivery_charge,
    this.payment_id,
  });

  OrderModel.fromMap(Map<String, dynamic> data, String orderId) {
    order_status = data['order_status'];
    created_time = data['created_time'];
    total_amount = data['total_amount'];
    user_name = data['user_name'];
    user_house_name = data['user_house_name'];
    created_time = data['created_time'];
    user_location = data['user_location'];
    cart_items = data['order_items'];
    outlet_name = data['outlet_name'];
    order_id = orderId;
    delivery_charge =  data['delivery_charge'];
    already_paid =  data['already_paid'];
    payment_id =  data['payment_id'];
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String id, category_id,item_name, item_image_path;
  int item_stock_quantity, max_cart_threshold;
  double item_price;
  Timestamp created_time;

  Item.fromMap(Map<String, dynamic> data){
    //id = data['id'];
    category_id = data['category_id'];
    item_name = data['item_name'];
    item_image_path = data['item_image_path'];
    item_stock_quantity = data['item_stock_quantity'];
    max_cart_threshold = data['max_cart_threshold'];
    created_time = data['created_time'];
    item_price = data['item_price'];
  }


}
import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String id, category_id,item_name, item_image_path, item_quantity, item_description;
  int item_stock_quantity, max_cart_threshold;
  var item_price;
  Timestamp created_time;

  Item.fromMap(Map<String, dynamic> data, String itemId) {
    id = itemId;
    category_id = data['category_id'];
    item_name = data['item_name'];
    item_image_path = data['item_image_path'];
    item_stock_quantity = data['item_stock_quantity'];
    max_cart_threshold = data['max_cart_threshold'];
    created_time = data['created_time'];
    item_price = data['item_price'];
    item_quantity = data['item_quantity'];
    item_description = data['item_description'];
  }


  Item.fromSearchMap(Map<String, dynamic> data, String itemId) {
    id = itemId;
    category_id = data['category_id']['value'];
    item_name = data['item_name']['value'];
    item_name = item_name.replaceAll('<em>', '').replaceAll('</em>', '');
    item_image_path = data['item_image_path']['value'];
    item_image_path = item_image_path.replaceAll('<em>', '').replaceAll('</em>', '');
    item_stock_quantity = int.parse(data['item_stock_quantity']['value']);
    max_cart_threshold = int.parse(data['max_cart_threshold']['value']);
    String itemPriceStr = data['item_price']['value'];
    item_price = int.parse(itemPriceStr.replaceAll('<em>', '').replaceAll('</em>', ''));
    item_quantity = data['item_quantity']['value'];
    item_description = data['item_description']['value'];
    
  }


}
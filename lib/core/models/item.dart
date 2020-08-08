import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String id,
      category_id,
      item_name,
      item_image_path,
      item_quantity,
      item_description,
      outlet_id;
  int item_stock_quantity, max_cart_threshold;
  var item_price, item_mrp;
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
    item_mrp = data['item_mrp'];
    item_quantity = data['item_quantity'];
    item_description = data['item_description'];
    outlet_id = data['outlet_id'];
  }

  Item.fromSearchMap(Map<String, dynamic> data, String itemId) {
    id = itemId;
    category_id = data['category_id'];
    item_name = data['item_name'];
    item_name = item_name.replaceAll('<em>', '').replaceAll('</em>', '');
    item_image_path = data['item_image_path'];
    item_image_path =
        item_image_path.replaceAll('<em>', '').replaceAll('</em>', '');
    item_stock_quantity = data['item_stock_quantity'];
    max_cart_threshold = data['max_cart_threshold'];
    String itemPriceStr = data['item_price'].toString();
    item_price =
        double.parse(itemPriceStr.replaceAll('<em>', '').replaceAll('</em>', ''));

    if (data['item_mrp']!= null) {
      String itemMrpStr = data['item_mrp'].toString();
      print(itemMrpStr);

      item_mrp =
          double.parse(itemMrpStr.replaceAll('<em>', '').replaceAll('</em>', ''));
    }

    item_quantity = data['item_quantity'];
    item_description = data['item_description'].replaceAll('<em>', '').replaceAll('</em>', '');

    outlet_id = data['outlet_id'];
    outlet_id =
        outlet_id.replaceAll('<em>', '').replaceAll('</em>', '');
  }

  Item.fromOrderItemMap(data) {
    id = data['cart_item_id'];
    item_name = data['cart_item_name'];
    item_image_path = data['item_image'];
    item_price = data['item_price'];
    item_quantity = data['cart_item_quantity'].toString();
  }
}

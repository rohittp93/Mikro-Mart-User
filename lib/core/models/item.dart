import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:userapp/core/models/item_quantity.dart';

class Item {
  String id,
      category_id,
      item_name,
      item_image_path,
      //item_quantity,
      item_description,
      outlet_id;
  int /*item_stock_quantity,*/ max_cart_threshold;

  bool show_item;
  double order_item_price;
  String order_item_quantity;

  //var item_price, item_mrp;
  Timestamp created_time;
  Timestamp offer_start;
  List<ItemQuantity> item_quantity_list;

  Item.fromMap(Map<String, dynamic> data, String itemId) {
    id = itemId;
    category_id = data['category_id'];
    item_name = data['item_name'];
    item_image_path = data['item_image_path'];
    //item_stock_quantity = data['item_stock_quantity'];
    max_cart_threshold = data['max_cart_threshold'];
    created_time = data['created_time'];
    if (data['offer_start'] != null) offer_start = data['offer_start'];
    if (data['show_item'] != null) {
      show_item = data['show_item'];
    } else {
      show_item = true;
    }
    //item_quantity_list = data['item_quantity_list'];

    item_quantity_list =
        List<ItemQuantity>.from(data["item_quantity_list"].map((item) {
      return new ItemQuantity.fromMap(item);
    }));

    /* item_price = data['item_price'];
    item_mrp = data['item_mrp'];
    item_quantity = data['item_quantity'];*/
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
    // item_stock_quantity = data['item_stock_quantity'];
    max_cart_threshold = data['max_cart_threshold'];

    if (data['show_item'] != null) {
      show_item = data['show_item'];
    } else {
      show_item = true;
    }

    item_quantity_list =
        List<ItemQuantity>.from(data["item_quantity_list"].map((item) {
      return new ItemQuantity.fromMap(item);
    }));

    //String itemPriceStr = data['item_price'].toString();
    /* item_price =
        double.parse(itemPriceStr.replaceAll('<em>', '').replaceAll('</em>', ''));*/

    item_description =
        data['item_description'].replaceAll('<em>', '').replaceAll('</em>', '');

    outlet_id = data['outlet_id'];
    outlet_id = outlet_id.replaceAll('<em>', '').replaceAll('</em>', '');
  }

  Item.fromOrderItemMap(data) {
    id = data['cart_item_id'];
    item_name = data['cart_item_name'];
    item_image_path = data['item_image'];
    order_item_price = data['item_price'];

    /* var order_items  =
    List<ItemQuantity>.from(data["order_items"].map((item) {
      return new ItemQuantity.fromOrderMap(item);
    }));*/

    order_item_quantity = data['cart_item_quantity'].toString();
  }
}

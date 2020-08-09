import 'package:cloud_firestore/cloud_firestore.dart';

class ItemQuantity {
  String item_quantity;
  double item_price, item_mrp;
  int item_stock_quantity;
  bool display_quantity;

  ItemQuantity() {
    item_quantity = "";
    item_price = 0.0;
    item_mrp = 0.0;
    item_stock_quantity = 0;
    display_quantity = false;
  }

  ItemQuantity.fromMap(Map<String, dynamic> data) {
    item_quantity = data['item_quantity'];
    item_price = data['item_price'].toDouble();
    item_mrp = data['item_mrp'].toDouble();
    item_stock_quantity = data['item_stock_quantity'];
    display_quantity = data['display_quantity'];
  }


  ItemQuantity.fromOrderMap(Map<String, dynamic> data) {
    item_quantity = data['item_quantity'];
    item_price = data['item_price'].toDouble();
  }
}

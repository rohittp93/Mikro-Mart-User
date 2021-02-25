import 'package:cloud_firestore/cloud_firestore.dart';

class Store {
  String id, category_image_name,category_image_path, category_name, outlet_type;
  bool outlet_open;

  Store.fromMap(Map<String, dynamic> data, String docId){
    id = docId;
    category_image_name = data['category_image_name'];
    category_image_path = data['category_image_path'];
    category_name = data['category_name'];
    outlet_open = data['outlet_open'];
    outlet_type = data['outlet_type'];
  }

}
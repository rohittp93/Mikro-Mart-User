import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String id, category_image_name,category_image_path, category_name;
  bool outlet_open;

  Category.fromMap(Map<String, dynamic> data, String docId){
    id = docId;
    category_image_name = data['category_image_name'];
    category_image_path = data['category_image_path'];
    category_name = data['category_name'];
    outlet_open = data['outlet_open'];
  }

}
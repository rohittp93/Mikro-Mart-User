import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String id, category_image_name,category_image_path, category_name;

  Category.fromMap(Map<String, dynamic> data, String docId){
    id = docId;
    category_image_name = data['category_image_name'];
    category_image_path = data['category_image_path'];
    category_name = data['category_name'];
  }

}
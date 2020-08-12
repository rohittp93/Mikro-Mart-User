import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:userapp/core/models/item_quantity.dart';

class BannerImage {
  String banner_image_path;

  BannerImage.fromMap(Map<String, dynamic> data) {
    banner_image_path = data['banner_image_path'];
  }
}

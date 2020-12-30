import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:userapp/core/models/item_quantity.dart';

class Version {
  String current_verion;
  bool force_update;

  Version.fromMap(Map<String, dynamic> data) {
    current_verion = data['current_version'];
    force_update = data['force_update'];
  }
}

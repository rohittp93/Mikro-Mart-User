import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:userapp/core/data/moor_database.dart';
import 'package:userapp/core/models/orders.dart';

class DatabaseService {
  // collection reference
  final String uid;

  DatabaseService({this.uid});

  final CollectionReference userCollection =
      Firestore.instance.collection('users');


  final CollectionReference orderCollection =
      Firestore.instance.collection('orders');

  Future updateUserData(
      String name,
      String email,
      bool twoFactorEnabled,
      String phoneNumber,
      String uid,
      String fcmToken,
      GeoPoint addressLocation,
      String appartmentName,
      bool setData) async {
    if (addressLocation != null) {
      return await userCollection.document(uid).setData({
        'two_factor_enabled': twoFactorEnabled,
        'phone_number': phoneNumber,
        'is_admin': false,
        'registration_date': FieldValue.serverTimestamp(),
        'user_id': uid,
        'device_token': fcmToken,
        'email': email,
        'name': name,
        'location': addressLocation,
        'building_name': appartmentName,
      });
    } else {
      if (setData) {
        return await userCollection.document(uid).setData({
          'two_factor_enabled': twoFactorEnabled,
          'phone_number': phoneNumber,
          'is_admin': false,
          'registration_date': FieldValue.serverTimestamp(),
          'user_id': uid,
          'device_token': fcmToken,
          'email': email,
          'name': name,
        });
      } else {
        return await userCollection.document(uid).updateData({
          'two_factor_enabled': twoFactorEnabled,
          'phone_number': phoneNumber,
          'is_admin': false,
          'registration_date': FieldValue.serverTimestamp(),
          'user_id': uid,
          'device_token': fcmToken,
          'email': email,
          'name': name,
        });
      }
    }
  }

  Future updateFCMToken(String uid, String fcmToken) async {
    return await userCollection
        .document(uid)
        .setData({'device_token': fcmToken});
  }

  Future fetchUserData(String doc_id) async {
    DocumentSnapshot document = await userCollection.document(doc_id).get();
    if (document != null) {
      return document;
    } else {
      return null;
    }
  }

  Future<String> addOrder(String userId, OrderModel order) async {
    //DocumentReference orderDocRef = userCollection.document(userId).collection('orders').document();
    DocumentReference orderDocRef = orderCollection.document();

    await orderDocRef.setData({
      'order_status': order.order_status,
      'total_amount': order.total_amount,
      'user_name': order.user_name,
      'user_house_name': order.user_house_name,
      'user_location': order.user_location,
      'outlet_name': order.outlet_name,
      'order_items': FieldValue.arrayUnion(order.cart_items),
      'created_time': FieldValue.serverTimestamp(),
      'user_id': userId,
    });

    return orderDocRef.documentID;
  }
}

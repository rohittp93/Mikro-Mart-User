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

  final CollectionReference outletCollection =
  Firestore.instance.collection('outlets');


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


  Future updateUserAddress(GeoPoint addressLocation, String appartmentName) async {
    return await userCollection.document(uid).updateData({
      'location': addressLocation,
      'building_name': appartmentName,
    });
  }

  Future updateFCMToken(String uid, String fcmToken) async {
    return await userCollection
        .document(uid)
        .updateData({'device_token': fcmToken});
  }

  Future fetchUserData(String doc_id) async {
    DocumentSnapshot document = await userCollection.document(doc_id).get();
    if (document != null) {
      return document;
    } else {
      return null;
    }
  }

  Future fetchOutletLocation(String outlet_id) async {
    DocumentSnapshot document = await outletCollection.document(outlet_id).get();
    if (document != null) {
      return document;
    } else {
      return null;
    }
  }

  Future<String> addOrder(String userId, OrderModel order, String userPhone) async {
    DocumentReference orderDocRef = orderCollection.document();

    await orderDocRef.setData({
      'order_status': order.order_status,
      'total_amount': order.total_amount,
      'user_name': order.user_name,
      'user_house_name': order.user_house_name,
      'user_location': order.user_location,
      'outlet_name': order.outlet_name,
      'extra_item': order.extra_item!=null ? order.extra_item : null,
      'order_items': FieldValue.arrayUnion(order.cart_items),
      'created_time': FieldValue.serverTimestamp(),
      'user_id': userId,
      'user_phone': userPhone,
      'already_paid': order.already_paid,
      'payment_id' : order.payment_id
    });

    return orderDocRef.documentID;
  }
}

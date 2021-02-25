import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:userapp/core/models/item_quantity.dart';

class RazorPayOrderResponse {
  String id,
      entity,
      currency,
      receipt,
      offer_id,
      status;
  int  amount, amount_paid, amount_due, attempts;

  RazorPayOrderResponse.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    entity = data['entity'];
    currency = data['currency'];
    receipt = data['receipt'];
    amount = data['amount'];
    amount_paid = data['amount_paid'];
    amount_due = data['amount_due'];
    offer_id = data['offer_id'];
    status = data['status'];
    attempts = data['attempts'];
  }
}

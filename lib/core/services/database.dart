import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // collection reference
  final String uid;

  DatabaseService({this.uid});

  final CollectionReference userCollection = Firestore.instance.collection('users');

  Future updateUserData(bool twoFactorEnabled, String phoneNumber) async{
    return await userCollection.document(uid).setData({
      'two_factor_enabled': twoFactorEnabled,
      'phone_number' : phoneNumber
    });
  }

  fetchUserData() {

  }
}
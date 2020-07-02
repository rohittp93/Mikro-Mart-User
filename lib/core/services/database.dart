import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // collection reference
  final String uid;

  DatabaseService({this.uid});

  final CollectionReference userCollection = Firestore.instance.collection('users');

  Future updateUserData(String name,String email, bool twoFactorEnabled, String phoneNumber, String uid, String fcmToken) async{
    return await userCollection.document(uid).setData({
      'two_factor_enabled': twoFactorEnabled,
      'phone_number' : phoneNumber,
      'is_admin' : false,
      'registration_date' : FieldValue.serverTimestamp(),
      'user_id' : uid,
      'device_token': fcmToken,
      'email': email,
      'name': name
    });
  }


  Future updateFCMToken(String uid, String fcmToken) async{
    return await userCollection.document(uid).setData({
      'device_token': fcmToken
    });
  }

  Future fetchUserData(String doc_id) async {
    DocumentSnapshot document = await userCollection.document(doc_id).get();
    if(document!=null){
      return document;
    }else{
      return null;
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/models/user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserInfo(String userId, UserModel user) async {
    await _db.collection('users').doc(userId).set({
      'username': user.username,
      'email': user.email,
      'imgDownloadUrl': user.imgDownloadUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

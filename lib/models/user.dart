import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String username;
  final String email;
  final String imgDownloadUrl;

  UserModel({
    required this.username,
    required this.email,
    required this.imgDownloadUrl,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'imgDownloadUrl': imgDownloadUrl,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

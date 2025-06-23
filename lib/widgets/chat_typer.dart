import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatTyper extends StatefulWidget {
  const ChatTyper({super.key});

  @override
  State<ChatTyper> createState() {
    return _ChatTyperState();
  }
}

class _ChatTyperState extends State<ChatTyper> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.none,
                maxLines: null,
                textAlign: TextAlign.start,
                decoration: InputDecoration(), // later will be styled
              ),
            ),
            IconButton(
              onPressed: onPressed,
              icon: Icon(
                Icons.send,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onPressed() async {
    final enteredMessage = controller.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    controller.clear();
    FocusScope.of(context).unfocus();

    final user = FirebaseAuth.instance.currentUser!;

    final userInfo = await db.collection('users').doc(user.uid).get();

    final response = await db.collection('messages').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userInfo.data()!['username'],
      'userImage': userInfo.data()!['imgDownloadUrl'],
    });

    print(response);
  }
}

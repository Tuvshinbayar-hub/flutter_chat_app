import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/widgets/chat_messages.dart';
import 'package:flutter_chat_app/widgets/chat_typer.dart';

final _fireBase = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  void logOut() async {
    _fireBase.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          IconButton(onPressed: logOut, icon: Icon(Icons.exit_to_app_outlined)),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Column(children: [ChatMessages(), ChatTyper()]),
      ),
    );
  }
}

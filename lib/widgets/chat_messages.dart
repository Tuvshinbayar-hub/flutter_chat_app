import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/widgets/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    User currentUser = FirebaseAuth.instance.currentUser!;

    return Expanded(
      child: Card(
        child: SizedBox(
          width: double.infinity,
          child: Center(
            child: (StreamBuilder(
              stream:
                  FirebaseFirestore.instance
                      .collection('messages')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('Sorry no messages found');
                }

                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemBuilder: (context, index) {
                    final currentMessage = messages[index].data();

                    final currentMessageUserId = currentMessage['userId'];
                    final nextMessageUserId =
                        index + 1 < messages.length
                            ? messages[index + 1].data()['userId']
                            : null;

                    final nextUserIsSame =
                        nextMessageUserId == currentMessageUserId;

                    if (nextUserIsSame) {
                      print('rendering same user');
                      return MessageBubble.next(
                        message: currentMessage['text'],
                        isMe: currentUser.uid == currentMessageUserId,
                      );
                    } else {
                      (print('rendering first user'));

                      return MessageBubble.first(
                        userImage: currentMessage['userImage'],
                        username: currentMessage['username'],
                        message: currentMessage['text'],
                        isMe: currentUser.uid == currentMessage['userId'],
                      );
                    }
                    //return Text(messages[index].data()['text']);
                  },
                  itemCount: messages.length,
                  reverse: true,
                );
              },
            )),
          ),
        ),
      ),
    );
  }
}

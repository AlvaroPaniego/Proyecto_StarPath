import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/message.dart';

class MessageBubble extends StatelessWidget {
  final Message messageData;
  final bool isSender;
  const MessageBubble(
      {super.key, required this.messageData, required this.isSender});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: isSender ? CHAT_OTHER : CHAT_ME,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(messageData.user,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(messageData.message, style: const TextStyle(fontSize: 15))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

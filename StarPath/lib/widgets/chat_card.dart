import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:starpath/model/chat_info.dart';
import 'package:starpath/windows/ChatPage.dart';

class ChatCard extends StatefulWidget {
  final ChatData chatData;
  const ChatCard({super.key, required this.chatData});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  @override
  Widget build(BuildContext context) {
    bool hasValidImage = widget.chatData.receiverUser.profile_picture != 'vacio';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(receiverUser: widget.chatData.receiverUser ),));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Row(
            children: [
              Flexible(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: hasValidImage
                      ? Image.network(widget.chatData.receiverUser.profile_picture)
                      : Image.asset("assets/images/placeholder-image.jpg"),
                ),
              ),
              const Flexible(child: SizedBox(width: 10,)),
              Flexible(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.chatData.receiverUser.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${widget.chatData.lastMessageSender}: ${widget.chatData.lastMessage}', style: const TextStyle(fontWeight: FontWeight.w300),)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

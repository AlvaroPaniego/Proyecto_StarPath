import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/chat_info.dart';
import 'package:starpath/windows/ChatPage.dart';
import 'package:supabase/supabase.dart';

class ChatCard extends StatefulWidget {
  final ChatData chatData;
  const ChatCard({super.key, required this.chatData});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  Future<List<String>> futureFollowers = Future.value([]);
  @override
  void initState() {
    futureFollowers = getLastMessage(widget.chatData.senderUser, widget.chatData.receiverUser.id_user);
    super.initState();
    supabase
        .channel('last_message_changes')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'message',
      callback: (payload) {
        print('callback');
        var idReceiver = payload.newRecord['id_user_receiver'];
        var idSender = payload.newRecord['id_user_sender'];
        if(isMessageInConversation(idSender, idReceiver, widget.chatData.senderUser, widget.chatData.receiverUser.id_user)){
          setState(() {
            futureFollowers = getLastMessage(widget.chatData.senderUser, widget.chatData.receiverUser.id_user);
            print('Poniendo state');
          });
        }
      },
    ).subscribe();
  }

  @override
  void dispose() {
    supabase.channel('last_message_changes').unsubscribe();
    super.dispose();
  }
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
                child: FutureBuilder(future: futureFollowers, builder: (context, snapshot) {
                  if(snapshot.hasData && snapshot.data!.isNotEmpty){
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.chatData.receiverUser.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${snapshot.data![1]}: ${snapshot.data![0]}', style: const TextStyle(fontWeight: FontWeight.w300),)
                      ],
                    );
                  }
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(': ', style: TextStyle(fontWeight: FontWeight.w300),)
                    ],
                  );
                },)
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<List<String>> getLastMessage(String idSender, String idReceiver) async{
    List<String> listData = [];
    var res = await supabase.from('message').select()
        .or('and(id_user_sender.eq.$idSender,id_user_receiver.eq.$idReceiver),and'
        '(id_user_sender.eq.$idReceiver,id_user_receiver.eq.$idSender)');
    listData.add(res.last['message']);
    var resUsername = await supabase
        .from('user')
        .select("username")
        .match({'id_user': res.last['id_user_sender']});
    listData.add(resUsername.last['username']);
    return listData;
  }
  bool isMessageInConversation(String id_userSenderMessage, String id_userReceiverMessage, String sendingUser, String receivingUser){
    var res = (
        (sendingUser == id_userSenderMessage && receivingUser == id_userReceiverMessage)
            || (sendingUser == id_userReceiverMessage && receivingUser == id_userSenderMessage)
    );
    return res;
  }
}

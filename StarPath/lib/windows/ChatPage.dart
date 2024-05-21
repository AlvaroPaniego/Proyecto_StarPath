import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/message.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/message_bubble.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:supabase/supabase.dart';

class ChatPage extends StatefulWidget {
  UserData receiverUser;
  ChatPage({super.key, required this.receiverUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  UserData senderUser = UserData.empty();
  var channel = supabase.channel("chat_room");
  // Future<List<Message>> futureMessages = getFutureMessagesAsync(senderUser.id_user, widget.receiverUser.id_user);

  @override
  void initState() {
    super.initState();
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'message',
      callback: (payload) {
        if(payload.newRecord['id_user_receiver'] == widget.receiverUser.id_user &&
            payload.newRecord['id_user_sender'] == senderUser.id_user){

        }
      },);
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    getUserDataAsync(user.id).then((value) => senderUser = value);
    bool hasValidImage = widget.receiverUser.profile_picture.isNotEmpty;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: BACKGROUND,
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).viewPadding.top,
            ),
            UpperAppBar(
                content: [
                  const BackButton(),
                  Text(widget.receiverUser.username),
                  hasValidImage
                      ? Image.network(widget.receiverUser.profile_picture)
                      : Image.asset("assets/images/placeholder-image.jpg")
                ]),
            Expanded(
                flex: 8,
                child: ListView(
                  children: [
                    MessageBubble(messageData: Message("pepe", "hola"), isSender: true),
                    MessageBubble(messageData: Message("pepe", "que tal?"), isSender: true),
                    MessageBubble(messageData: Message("ana", "bien"), isSender: false),
                    MessageBubble(messageData: Message("pepe", "a"), isSender: true),
                    MessageBubble(messageData: Message("ana", "..."), isSender: false),
                  ],
                )),
            Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                    color: BUTTON_BAR_BACKGROUND
                  ),
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextField(
                          autocorrect: true,
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: "Escribe un mensaje",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(35.0)),
                            filled: true,
                            fillColor: Colors.white38
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                            onPressed: () async{
                              await sendMessageAsync(senderUser.id_user,
                                  widget.receiverUser.id_user,
                                  _messageController.text.trim());
                              _messageController.text = "";
                            },
                            icon: const Icon(Icons.send)),
                      )
                    ],
                  ),
                ))
          ],
        )
    );
  }

  Future<void> sendMessageAsync(String sendingUser, String receiverUser, String message) async{
    if(message.isEmpty){
      print("mensaje vacio");
      return;
    }
    var res = await supabase.from('message').insert({
      'id_user_sender' : sendingUser,
      'id_user_receiver' : receiverUser,
      'message': message
    });
  }
  Future<UserData> getUserDataAsync(String id_user) async{
    UserData user = UserData.empty();
    var res = await supabase
        .from('user')
        .select("id_user, username, profile_picture")
        .match({'id_user': id_user});
    user.id_user = res.first['id_user'];
    user.username = res.first['username'];
    user.profile_picture = res.first['profile_picture'];
    user.followers = '0';
    return user;
  }
}

Future<List<Message>> getFutureMessagesAsync(String id_user, String id_user2) async{
  List<Message> messageList = [];
  return messageList;
}

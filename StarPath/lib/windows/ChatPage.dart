import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/message.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/message_bubble.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/windows/chat_list.dart';
import 'package:starpath/windows/main_page.dart';
import 'package:supabase/supabase.dart';

class ChatPage extends StatefulWidget {
  UserData receiverUser;
  ChatPage({super.key, required this.receiverUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  UserData senderUser = UserData.empty();
  late Future<List<Message>> futureMessages;

  @override
  void initState() {
    super.initState();
    // futureMessages = getFutureMessagesAsync(senderUser.id_user, widget.receiverUser.id_user);
    supabase.channel("chat_room").onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'message',
      callback: (payload) async {
        var idReceiver = payload.newRecord['id_user_receiver'];
        var idSender = payload.newRecord['id_user_sender'];
        if(isMessageInConversation(idSender, idReceiver, senderUser, widget.receiverUser)){
          // var senderUserAux = await getUserDataAsync(idSender);
          // var auxMessageList = await futureMessages;
          setState(() {
            // auxMessageList.add(Message(senderUserAux.username, payload.newRecord['message'], idSender));
            // futureMessages.then((value) {
            //   value.add(Message(senderUserAux.username, payload.newRecord['message'], idSender));
            // });
            futureMessages = getFutureMessagesAsync(idSender, idReceiver);
          });
          // print(_scrollController.position.maxScrollExtent);
            _scrollController.animateTo(0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.bounceIn,
            );
        }
      },).subscribe();
  }
  @override
  void dispose() {
    supabase.channel("chat_room").unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    getUserDataAsync(user.id).then((value) => senderUser = value);
    futureMessages = getFutureMessagesAsync(user.id, widget.receiverUser.id_user);
    bool hasValidImage = widget.receiverUser.profile_picture.isNotEmpty;
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        backgroundColor: BACKGROUND,
        body: KeyboardVisibilityBuilder(builder: (p0, isKeyboardVisible) {
          return Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).viewPadding.top,
              ),
              UpperAppBar(
                  content: [
                    BackArrow(route: MaterialPageRoute(builder: (context) => const ChatListPage(),)),
                    Text(widget.receiverUser.username),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(45.0),
                      child: hasValidImage
                          ? Image.network(widget.receiverUser.profile_picture)
                          : Image.asset("assets/images/placeholder-image.jpg"),
                    )
                  ]),
              Expanded(
                flex: 8,
                child: FutureBuilder(
                  future: futureMessages,
                  builder: (context, snapshot) {
                    if(snapshot.hasData){
                      if(snapshot.data!.isEmpty){
                        return const Center(
                          child: Text("Escribe para empezar la conversacion :)", style: TextStyle(color: TEXT),),
                        );
                      }
                      var finalMessages = snapshot.data!.reversed;
                      return ListView.builder(
                          reverse: true,
                          controller: _scrollController,
                          itemCount: finalMessages.length,
                          itemBuilder: (context, index) {
                            return MessageBubble(messageData: finalMessages.elementAt(index),
                                isSender: finalMessages.elementAt(index).sender_id != user.id);
                          });
                    }else if(snapshot.hasError){
                      return const Center(
                        child: Text("Error de conexion", style: TextStyle(color: TEXT),),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              Expanded(
                  flex: isKeyboardVisible ?  2 : 1,
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
                            onTapOutside: (event) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            autocorrect: true,
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: "Escribe un mensaje",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(35.0)),
                              filled: true,
                              fillColor: Colors.white38,
                            ),
                            maxLines: null,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                              onPressed: () async{
                                await sendMessageAsync(user.id,
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
          );
        },)
        // Column(
        //   children: [
        //     SizedBox(
        //       height: MediaQuery.of(context).viewPadding.top,
        //     ),
        //     UpperAppBar(
        //         content: [
        //           BackArrow(route: MaterialPageRoute(builder: (context) => const ChatListPage(),)),
        //           Text(widget.receiverUser.username),
        //           ClipRRect(
        //             borderRadius: BorderRadius.circular(45.0),
        //             child: hasValidImage
        //                 ? Image.network(widget.receiverUser.profile_picture)
        //                 : Image.asset("assets/images/placeholder-image.jpg"),
        //           )
        //         ]),
        //     Expanded(
        //         flex: 8,
        //         child: FutureBuilder(
        //           future: futureMessages,
        //           builder: (context, snapshot) {
        //             if(snapshot.hasData){
        //               if(snapshot.data!.isEmpty){
        //                 return const Center(
        //                   child: Text("Escribe para empezar la conversacion :)", style: TextStyle(color: TEXT),),
        //                 );
        //               }
        //               var finalMessages = snapshot.data!.reversed;
        //               return ListView.builder(
        //                 reverse: true,
        //                 controller: _scrollController,
        //                 itemCount: finalMessages.length,
        //                 itemBuilder: (context, index) {
        //                   return MessageBubble(messageData: finalMessages.elementAt(index),
        //                       isSender: finalMessages.elementAt(index).sender_id != user.id);
        //                 });
        //             }else if(snapshot.hasError){
        //               return const Center(
        //                 child: Text("Error de conexion", style: TextStyle(color: TEXT),),
        //               );
        //             }
        //             return const Center(
        //               child: CircularProgressIndicator(),
        //             );
        //           },
        //         ),
        //     ),
        //     Expanded(
        //         flex: 2,
        //         child: Container(
        //           decoration: const BoxDecoration(
        //             borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        //             color: BUTTON_BAR_BACKGROUND
        //           ),
        //           padding: const EdgeInsets.all(5.0),
        //           child: Row(
        //             children: [
        //               Expanded(
        //                 flex: 5,
        //                 child: TextField(
        //                   onTapOutside: (event) =>
        //                       FocusManager.instance.primaryFocus?.unfocus(),
        //                   autocorrect: true,
        //                   controller: _messageController,
        //                   decoration: InputDecoration(
        //                     hintText: "Escribe un mensaje",
        //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(35.0)),
        //                     filled: true,
        //                     fillColor: Colors.white38,
        //                   ),
        //                   maxLines: null,
        //                 ),
        //               ),
        //               Expanded(
        //                 flex: 1,
        //                 child: IconButton(
        //                     onPressed: () async{
        //                       await sendMessageAsync(user.id,
        //                           widget.receiverUser.id_user,
        //                           _messageController.text.trim());
        //                       _messageController.text = "";
        //                     },
        //                     icon: const Icon(Icons.send)),
        //               )
        //             ],
        //           ),
        //         ))
        //   ],
        // )
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

Future<List<Message>> getFutureMessagesAsync(String id_userSender, String id_userReceiver) async{
  List<Message> messageList = [];
  Message messageData;
  print("cogiendo mensajes");
  var res = [];
  // print('sender $id_userSender receiver $id_userReceiver');
  try{
    res = await supabase.from('message').select()
        .or('and(id_user_sender.eq.$id_userSender,id_user_receiver.eq.$id_userReceiver),and'
        '(id_user_sender.eq.$id_userReceiver,id_user_receiver.eq.$id_userSender)').order('created_at', ascending: true);
  }catch (e){
    print(e);
  }
  for (var message in res) {
    messageData = Message.empty();
    messageData.message = message['message'];
    var user = await getUserDataAsync(message['id_user_sender']);
    messageData.user = user.username;
    messageData.sender_id = message['id_user_sender'];
    messageList.add(messageData);
  }
  return messageList;
}
bool isMessageInConversation(String id_userSenderMessage, String id_userReceiverMessage, UserData sendingUser, UserData receivingUser){
  var res = (
      (sendingUser.id_user == id_userSenderMessage && receivingUser.id_user == id_userReceiverMessage)
          || (sendingUser.id_user == id_userReceiverMessage && receivingUser.id_user == id_userSenderMessage)
  );
  print(res);
  return res;
}

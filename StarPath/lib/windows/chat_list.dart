import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/chat_info.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/chat_card.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/windows/main_page.dart';
import 'package:supabase/supabase.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  Future<List<ChatData>> futureListChatData = Future.value([]);
  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    futureListChatData = getChatData(user);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: BACKGROUND,
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).viewPadding.top,
            ),
            UpperAppBar(content: [
              BackArrow(route: MaterialPageRoute(builder: (context) => const MainPage(),)),
              const Text('Conversaciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              const SizedBox(width: 40,)
            ]),
            Expanded(
                flex: 9,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder(
                      future: futureListChatData,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if(snapshot.data!.isNotEmpty){
                            return ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) => ChatCard(chatData: snapshot.data![index]));
                          }else{
                            return const Center(child: Text('Todavia no hay chats, ve a explorar',style:  TextStyle(color: TEXT)));
                          }
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),)),
          ],
        )
    );
  }
  Future<List<ChatData>> getChatData(User user) async{
    List<ChatData> listChatData = [];
    List<String> senderList = [];
    List<String> receiverList = [];
    ChatData chatData;
     try{
       var res = await supabase.rpc('getbothuserchats', params: {'idloggeduser' : user.id});
       // var res = await supabase.from('message').select('id_user_sender, id_user_receiver')
       //     .or('id_user_sender.eq.${user.id}, id_user_receiver.eq.${user.id}');
       var data = res as List;
       var finalRes = data.toSet().toList();

       for (int i = 0; i < finalRes.length; i++) {
         if(!senderList.contains(finalRes[i]['id_user_receiver']) || !receiverList.contains(finalRes[i]['id_user_sender'])){
           if(finalRes[i]['id_user_receiver'] == user.id){
             var lastMessageData = await getLastMessage(finalRes[i]['id_user_sender'], finalRes[i]['id_user_receiver']);
             chatData = ChatData();
             chatData.senderUser = user.id;
             chatData.receiverUser = await getUserDataAsync(finalRes[i]['id_user_sender']);
             chatData.lastMessage = lastMessageData[0];
             chatData.lastMessageSender = lastMessageData[1];
             listChatData.add(chatData);
           }else if(finalRes[i]['id_user_sender'] == user.id){
             var lastMessageData = await getLastMessage(user.id, finalRes[i]['id_user_receiver']);
             chatData = ChatData();
             chatData.senderUser = user.id;
             chatData.receiverUser = await getUserDataAsync(finalRes[i]['id_user_receiver']);
             chatData.lastMessage = lastMessageData[0];
             chatData.lastMessageSender = lastMessageData[1];
             listChatData.add(chatData);
           }
         }
         senderList.add(finalRes[i]['id_user_sender']);
         receiverList.add(finalRes[i]['id_user_receiver']);
       }
       // for (var data in finalRes) {
       //   if(data['id_user_receiver'] == user.id){
       //     var lastMessageData = await getLastMessage(user.id, data['id_user_sender']);
       //     chatData = ChatData();
       //     chatData.senderUser = user.id;
       //     chatData.receiverUser = await getUserDataAsync(data['id_user_sender']);
       //     chatData.lastMessage = lastMessageData[0];
       //     chatData.lastMessageSender = lastMessageData[1];
       //     listChatData.add(chatData);
       //   }else if(data['id_user_sender'] == user.id){
       //     var lastMessageData = await getLastMessage(user.id, data['id_user_receiver']);
       //     chatData = ChatData();
       //     chatData.senderUser = user.id;
       //     chatData.receiverUser = await getUserDataAsync(data['id_user_receiver']);
       //     chatData.lastMessage = lastMessageData[0];
       //     chatData.lastMessageSender = lastMessageData[1];
       //     listChatData.add(chatData);
       //   }
       //
       // }
     }catch (e) {
       print(e);
     }
    return listChatData;
  }

  Future<List<String>> getLastMessage(String idSender, String idReceiver) async{
    List<String> listData = [];
    var res = await supabase.from('message').select()
        .or('and(id_user_sender.eq.$idSender,id_user_receiver.eq.$idReceiver),and'
        '(id_user_sender.eq.$idReceiver,id_user_receiver.eq.$idSender)').order('created_at', ascending: true);
    listData.add(res.last['message']);
    var resUsername = await supabase
        .from('user')
        .select("username")
        .match({'id_user': res.last['id_user_sender']});
    listData.add(resUsername.last['username']);
    return listData;
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

import 'package:starpath/model/user_data.dart';

class ChatData{
  UserData receiverUser = UserData.empty();
  String senderUser = 'vacio';
  String lastMessage = 'vacio';
  String lastMessageSender = 'vacio';
  ChatData();
  ChatData.onlyId(this.senderUser, this.receiverUser);
}
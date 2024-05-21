import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/windows/ChatPage.dart';

class UserPageTemp extends StatefulWidget {
  UserData user;
  UserPageTemp({super.key, required this.user});

  @override
  State<UserPageTemp> createState() => _UserPageTempState();
}

class _UserPageTempState extends State<UserPageTemp> {
  @override
  Widget build(BuildContext context) {
    bool hasValidImage = widget.user.profile_picture.isNotEmpty;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: BACKGROUND,
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).viewPadding.top,
            ),
            const UpperAppBar(
                content: [BackButton()]
            ),
            Expanded(
                flex: 3,
                child: Text(widget.user.username, style: const TextStyle(color: TEXT))),
            Expanded(
                flex: 5,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(45.0),
                      child: hasValidImage
                          ? Image.network(widget.user.profile_picture)
                          : Image.asset("assets/images/placeholder-image.jpg"),
                    ))),
            Expanded(
                flex: 1,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(receiverUser: widget.user),));
                    },
                    style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll( BUTTON_BACKGROUND)),
                    child: const Text("Enviar mensaje", style: TextStyle(color: TEXT),)))
          ],
        )
    );
  }
}

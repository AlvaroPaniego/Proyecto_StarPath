import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/widgets/upper_app_bar.dart';

class NewProfilePage extends StatefulWidget {
  const NewProfilePage({super.key});

  @override
  State<NewProfilePage> createState() => _NewProfilePageState();
}

class _NewProfilePageState extends State<NewProfilePage> {
  final TextEditingController _textController = TextEditingController();
  bool privacy = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BACKGROUND,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).viewPadding.top,
          ),
          const UpperAppBar(content: [Text("Creacion de usuario")]),
          Expanded(flex: 3,child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(children: [
              ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(180)), child: Image.asset("assets/images/placeholder-avatar.jpg")),
              const Positioned(
                  bottom: 10.0,
                  right: 10.0,
                  child: Icon(Icons.change_circle_outlined))
            ]),
          )),
          Expanded(flex: 4,child: Container(
              decoration: BoxDecoration(
                color: BUTTON_BAR_BACKGROUND,
                borderRadius: BorderRadius.circular(25.0)
              ),
              margin: const EdgeInsets.all(12.0),
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
              child: TextField(controller: _textController, maxLines: 10, style: const TextStyle(color: BLACK),))),
          Expanded(flex: 1,child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text("Perfil público", style: TextStyle(color: TEXT),),
              Checkbox(value: privacy, onChanged: (value) => setState(() {
                privacy = !privacy;
              }),)
            ],
          )),
          Expanded(flex: 1,child: ElevatedButton(
              style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(BUTTON_BACKGROUND)),
              onPressed: () {
            //completar login
          }, child: const Text("Finalizar", style: TextStyle(color: TEXT),)))
        ],
      ),
    );
  }
}

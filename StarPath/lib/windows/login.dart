import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool remember = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BACKGROUND,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text("LOGIN", style: TextStyle(color: TEXT)),
            Image.asset("assets/images/placeholder-image.jpg"),
            TextFormField(
              autofocus: false,
              style: const TextStyle(color: TEXT),
              decoration: InputDecoration(
                // errorText: "Usuario incorrecto",
                hintText: "Introduzca nombre de usuario",
                hintStyle: const TextStyle(color: HINT),
                labelText: "Usuario",
                labelStyle: const TextStyle(color: TEXT),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: BLACK, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: FOCUS_ORANGE, width: 1.0),
                ),
              ),
            ),
            TextFormField(
              autofocus: false,
              style: const TextStyle(color: TEXT),
              obscureText: true,
              decoration: InputDecoration(
                // errorText: "Usuario incorrecto",
                hintText: "Introduzca contraseña",
                hintStyle: const TextStyle(color: HINT),
                labelText: "Contraseña",
                labelStyle: const TextStyle(color: TEXT),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: BLACK, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: FOCUS_ORANGE, width: 1.0),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () {

                }, child: const Text("Recuperar contraseña")),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Recordarme", style: TextStyle(color: TEXT),),
                    Checkbox(value: remember, onChanged: (value) {
                      setState(() {
                        remember = !remember;
                      });
                    },),
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () {
                }, child: Container(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width * 0.30,
                    decoration: BoxDecoration(
                      color: BUTTON_BACKGROUND,
                      borderRadius: BorderRadius.circular(8.0)
                    ),
                    child: const Center(
                      child: Text("Entrar", textAlign: TextAlign.center, style: TextStyle(
                       color: BLACK
                      ),),
                    )
                  )
                ),TextButton(onPressed: () {

                }, child: Container(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width * 0.30,
                    decoration: BoxDecoration(
                        color: BUTTON_BACKGROUND,
                        borderRadius: BorderRadius.circular(8.0)
                    ),
                    child: const Center(
                      child: Text("Registrarse", textAlign: TextAlign.center, style: TextStyle(
                          color: BLACK
                      ),),
                    )
                )
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

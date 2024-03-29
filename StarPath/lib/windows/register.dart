import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool hasSelectedDate = false;
  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    hasSelectedDate = false;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BACKGROUND,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text("REGISTRARSE", style: TextStyle(color: TEXT)),
            TextFormField(
              autofocus: false,
              style: const TextStyle(color: TEXT),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                // errorText: "Usuario incorrecto",
                hintText: "Introduzca un correo electronico",
                hintStyle: const TextStyle(color: HINT),
                labelText: "Correo",
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
            TextFormField(
              autofocus: false,
              style: const TextStyle(color: TEXT),
              obscureText: true,
              decoration: InputDecoration(
                // errorText: "Usuario incorrecto",
                hintText: "Repita la contraseña",
                hintStyle: const TextStyle(color: HINT),
                labelText: "Repetir contraseña",
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
            Text("Fecha de nacimiento ${hasSelectedDate ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}" : "selecciona una fecha"}", style: const TextStyle(color: TEXT),),
            ElevatedButton(onPressed: () async{
              final DateTime? dateTime = await showDatePicker(context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now());
              if(dateTime != null){
                setState(() {
                  selectedDate = dateTime;
                  hasSelectedDate = true;
                });
              }
            },
              style: ElevatedButton.styleFrom(backgroundColor: BUTTON_BACKGROUND),
              child: const Text("Seleccionar fecha", style: TextStyle(color: BLACK)),
            )
          ],
        ),
      ),
    );
  }
}

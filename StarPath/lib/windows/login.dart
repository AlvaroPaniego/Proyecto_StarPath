import 'package:flutter/material.dart';
import 'package:starpath/misc/constants.dart';
import 'menu.dart';
import 'register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool remember = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BACKGROUND,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 40.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text("LOGIN", style: TextStyle(color: TEXT)),
              Image.asset("assets/images/logo.png"),
              TextFormField(
                autofocus: false,
                style: const TextStyle(color: TEXT),
                decoration: InputDecoration(
                  // errorText: "Usuario incorrecto",
                  // Leer base de datos
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
                    borderSide:
                        const BorderSide(color: FOCUS_ORANGE, width: 1.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre de usuario está vacío';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                autofocus: false,
                style: const TextStyle(color: TEXT),
                obscureText: true,
                decoration: InputDecoration(
                  // errorText: "Contraseña incorrecta",
                  // Leer base de datos
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
                    borderSide:
                        const BorderSide(color: FOCUS_ORANGE, width: 1.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contraseña requerida';
                  } else if (value.length < 6) {
                    return 'La contraseña debe ser mayor o igual a 6 caracteres';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text("Recuperar contraseña"),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Recordarme",
                        style: TextStyle(color: TEXT),
                      ),
                      Checkbox(
                        value: remember,
                        onChanged: (value) {
                          setState(() {
                            remember = !remember;
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        //Hacer el navegar a la pantalla de menú
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Menu()),
                        );
                      }
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.07,
                      width: MediaQuery.of(context).size.width * 0.30,
                      decoration: BoxDecoration(
                        color: BUTTON_BACKGROUND,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Center(
                        child: Text(
                          "Entrar",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: BLACK),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Register()),
                      );
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.07,
                      width: MediaQuery.of(context).size.width * 0.30,
                      decoration: BoxDecoration(
                        color: BUTTON_BACKGROUND,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Center(
                        child: Text(
                          "Registrarse",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: BLACK),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

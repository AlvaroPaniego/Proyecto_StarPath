import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/windows/login.dart';
import 'package:flutter/cupertino.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña está vacía';
    } else if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    } else if (!RegExp(r'^(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}|:"<>?~.,]).{6,}$')
        .hasMatch(value)) {
      return 'La contraseña debe contener al menos un número y un carácter especial';
    }
    return null;
  }

  Future<void> _registerUser() async {
    if (_passwordController.text != _repeatPasswordController.text) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Error'),
            content: Text('Las contraseñas no coinciden.'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );
      return;
    }

    final response = await supabase.auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      data: {
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim()
      },
    );

    if (response.session == null || response.user == null) {
      print('Error al registrar usuario');
    } else {
      print('Usuario registrado con éxito');

      // Redirigir a la pantalla de inicio de sesión
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Login(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                40.0,
                30.0,
                40.0,
                isKeyboardVisible ? 20.0 : 30.0,
              ),
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "REGISTRARSE",
                    style: TextStyle(color: TEXT),
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          autofocus: false,
                          style: const TextStyle(color: TEXT),
                          decoration: InputDecoration(
                            hintText: "Introduzca nombre de usuario",
                            hintStyle: const TextStyle(color: HINT),
                            labelText: "Usuario",
                            labelStyle: const TextStyle(color: TEXT),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  const BorderSide(color: BLACK, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  color: FOCUS_ORANGE, width: 1.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Usuario requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          autofocus: false,
                          style: const TextStyle(color: TEXT),
                          decoration: InputDecoration(
                            hintText: "Introduzca correo electrónico",
                            hintStyle: const TextStyle(color: HINT),
                            labelText: "Correo electrónico",
                            labelStyle: const TextStyle(color: TEXT),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  const BorderSide(color: BLACK, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  color: FOCUS_ORANGE, width: 1.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Correo electrónico requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          autofocus: false,
                          style: const TextStyle(color: TEXT),
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Introduzca contraseña",
                            hintStyle: const TextStyle(color: HINT),
                            labelText: "Contraseña",
                            labelStyle: const TextStyle(color: TEXT),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  const BorderSide(color: BLACK, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  color: FOCUS_ORANGE, width: 1.0),
                            ),
                          ),
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _repeatPasswordController,
                          autofocus: false,
                          style: const TextStyle(color: TEXT),
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Introduzca de nuevo la contraseña",
                            hintStyle: const TextStyle(color: HINT),
                            labelText: "Repetir Contraseña",
                            labelStyle: const TextStyle(color: TEXT),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  const BorderSide(color: BLACK, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  color: FOCUS_ORANGE, width: 1.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Repetir contraseña requerida';
                            } else if (value != _passwordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _registerUser,
                          child: const Text('Registrarse'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

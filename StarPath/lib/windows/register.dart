import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      return 'Contraseña requerida';
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'La contraseña debe ser alfanumérica y puede contener barra baja';
    }
    return null;
  }

  Future<void> _registerUser() async {
    // Verificar contraseñas
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

    // Inicializar SupabaseClient
    final supabaseClient = SupabaseClient(
      supabaseURL,
      supabaseKey,
      authOptions: AuthClientOptions(authFlowType: AuthFlowType.implicit),
    );

    // Registrar usuario en Supabase
    final response = await supabaseClient.auth.signUp(
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

      // Enviar correo de confirmación
      final Email email = Email(
        body: '¡Te has registrado exitosamente en nuestra aplicación!',
        subject: 'Registro exitoso',
        recipients: [_emailController.text],
      );
      //await FlutterEmailSender.send(email);

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
              const Text("REGISTRARSE", style: TextStyle(color: TEXT)),
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
                    return 'Usuario requerido';
                  }
                  return null;
                },
              ),
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
                    return 'Correo electrónico requerido';
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
                validator: _validatePassword,
              ),
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
                    return 'Repetir contraseña requerida';
                  } else if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _registerUser,
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

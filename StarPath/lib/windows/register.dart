import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starpath/misc/constants.dart';
import 'package:supabase/supabase.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool hasSelectedDate = false;
  DateTime selectedDate = DateTime.now();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contraseña requerida';
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'La contraseña debe ser alfanumérica y puede contener barra baja';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    hasSelectedDate = false;
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
                controller: _emailController,
                autofocus: false,
                style: const TextStyle(color: TEXT),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Introduzca un correo electrónico",
                  hintStyle: const TextStyle(color: HINT),
                  labelText: "Correo",
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
                    return 'Correo requerido';
                  }
                  return null;
                },
              ),
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
                autofocus: false,
                style: const TextStyle(color: TEXT),
                obscureText: true,
                decoration: InputDecoration(
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
              Text(
                "Fecha de nacimiento ${hasSelectedDate ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}" : "selecciona una fecha"}",
                style: const TextStyle(color: TEXT),
              ),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? dateTime = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (dateTime != null) {
                    setState(() {
                      selectedDate = dateTime;
                      hasSelectedDate = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: BUTTON_BACKGROUND),
                child: const Text("Seleccionar fecha",
                    style: TextStyle(color: BLACK)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _registerUser();
                  }
                },
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _registerUser() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;
    final dateOfBirth = selectedDate;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final supabaseClient = SupabaseClient(
        'https://yhjunduffguoboqbsqae.supabase.co',
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InloanVuZHVmZmd1b2JvcWJzcWFlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDM3ODEwMTMsImV4cCI6MjAxOTM1NzAxM30.ebBPtXmpowC4iPIaHFkmSoieowV9dT9OZyfmf4G1rgk',
      );
      await supabaseClient.auth.signUp(password: password, email: email);

      supabaseClient.from('user').insert({
        'username': username,
        'email': email,
        'birth_date': dateOfBirth,
      });

      print('Usuario registrado con éxito');
    } catch (error) {
      print('Error al registrar usuario: $error');
    }
  }
}

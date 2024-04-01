import 'package:flutter/material.dart';
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
                  borderSide: const BorderSide(color: FOCUS_ORANGE, width: 1.0),
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
                  borderSide: const BorderSide(color: FOCUS_ORANGE, width: 1.0),
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
                  borderSide: const BorderSide(color: FOCUS_ORANGE, width: 1.0),
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
                  borderSide: const BorderSide(color: FOCUS_ORANGE, width: 1.0),
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
                    lastDate: DateTime.now());
                if (dateTime != null) {
                  setState(() {
                    selectedDate = dateTime;
                    hasSelectedDate = true;
                  });
                }
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: BUTTON_BACKGROUND),
              child: const Text("Seleccionar fecha",
                  style: TextStyle(color: BLACK)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Realizar la lógica para registrar al usuario en la base de datos
                  _registerUser();
                }
              },
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }

  void _registerUser() async {
    // Obtener los datos del formulario
    final email = _emailController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;
    final dateOfBirth = selectedDate;

    final supabaseClient = SupabaseClient(
        'https://ybebufmjnvzatnywturc.supabase.co',
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InliZWJ1Zm1qbnZ6YXRueXd0dXJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE0NzQ1MjQsImV4cCI6MjAyNzA1MDUyNH0.eyFUwoEqNnKlwgG1UjWul_uX8snw8lsmqDNvRIEzDsE');

    final response = await supabaseClient.auth.signUp(email, password);

    if (response.error == null) {
      print('Usuario registrado con éxito');
    } else {
      print('Error al registrar usuario: ${response.error?.message}');
    }
  }
}

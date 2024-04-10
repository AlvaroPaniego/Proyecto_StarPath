import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/windows/menu.dart';
import 'package:starpath/windows/register.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
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
                    return 'El correo electrónico está vacío';
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contraseña requerida';
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final supabaseClient = SupabaseClient(
                          'https://ybebufmjnvzatnywturc.supabase.co',
                          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InliZWJ1Zm1qbnZ6YXRueXd0dXJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE0NzQ1MjQsImV4cCI6MjAyNzA1MDUyNH0.eyFUwoEqNnKlwgG1UjWul_uX8snw8lsmqDNvRIEzDsE',
                          authOptions: AuthClientOptions(
                              authFlowType: AuthFlowType.implicit),
                        );
                        final response =
                            await supabaseClient.auth.signInWithPassword(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );
                        if (response.session == null || response.user == null) {
                          print('Error al logear usuario');
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Menu(),
                            ),
                          );
                        }
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
                        MaterialPageRoute(
                          builder: (context) => const Register(),
                        ),
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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:starpath/model/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/windows/main_page.dart';
import 'package:starpath/windows/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:starpath/windows/create_profile.dart';
import 'package:starpath/windows/forgot_password.dart';

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
  bool _profileCompleted = false;
  bool _passwordVisible = true;

  @override
  void initState() {
    super.initState();
    _loadRememberStatus();
    _checkProfileCompletion();
  }

  Future<void> _checkProfileCompletion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool profileCompleted = prefs.getBool('profileCompleted') ?? false;
    if (profileCompleted) {
      setState(() {
        _profileCompleted = true;
      });
    }
  }

  // Future<void> _saveProfileCompletion() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('profileCompleted', true);
  //   setState(() {
  //     _profileCompleted = true;
  //   });
  // }

  void _loadRememberStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      remember = prefs.getBool('remember') ?? false;
    });
  }

  // void _saveRememberStatus(bool value) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('remember', value);
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: BACKGROUND,
        body: KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  40.0,
                  80.0,
                  40.0,
                  isKeyboardVisible ? 20.0 : 30.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image.asset("assets/images/logo.png"),
                      const SizedBox(height: 40.0),
                      const Text('Iniciar sesión', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: TEXT),),
                      const SizedBox(height: 40.0),
                      TextFormField(
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
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
                            return 'El correo electrónico está vacío';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 60.0),
                      TextFormField(
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        obscureText: _passwordVisible,
                        controller: _passwordController,
                        autofocus: false,
                        style: const TextStyle(color: TEXT),
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
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                            icon: _passwordVisible
                                ? const Icon(Icons.visibility, color: TEXT)
                                : const Icon(Icons.visibility_off, color: TEXT),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La contraseña está vacía';
                          } else if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          } else if (!RegExp(
                                  r'^(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}|:"<>?~.,]).{6,}$')
                              .hasMatch(value)) {
                            return 'La contraseña debe contener al menos un número y un carácter especial';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgotPassword(),
                              ),
                            );
                          },
                          child: const Center(
                            child: Text(
                              'Recuperar contraseña',
                              style: TextStyle(color: FOCUS_ORANGE),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final supabaseClient = SupabaseClient(
                                  supabaseURL,
                                  supabaseKey,
                                  authOptions: const AuthClientOptions(
                                      authFlowType: AuthFlowType.implicit),
                                );

                                final email = _emailController.text.trim();
                                final password =
                                    _passwordController.text.trim();

                                try {
                                  // Verificar si el correo existe en la base de datos
                                  final emailCheckResponse =
                                      await supabaseClient
                                          .from('user')
                                          .select()
                                          .eq('email', email);

                                  if (emailCheckResponse == null) {
                                    _showErrorDialog(
                                        'Error al verificar el correo electrónico.');
                                    return;
                                  }

                                  final userList = emailCheckResponse as List;
                                  if (userList.isEmpty) {
                                    _showErrorDialog(
                                        'El correo electrónico es incorrecto.');
                                    return;
                                  }

                                  final response = await supabaseClient.auth
                                      .signInWithPassword(
                                    email: email,
                                    password: password,
                                  );

                                  if (response.session != null &&
                                      response.user != null) {
                                    final user = response.user!;
                                    final userId = user.id;

                                    // obtener el valor de firstTime
                                    final firstTimeResponse = await supabase
                                        .from('user')
                                        .select('first_time')
                                        .eq('id_user', userId)
                                        .single();
                                    final firstTime =
                                        firstTimeResponse['first_time']
                                                as int? ??
                                            0;

                                    // Actualizar el valor de first_time a 2
                                    if (firstTime == 1) {
                                      await supabase
                                          .from('user')
                                          .update({'first_time': 2}).eq(
                                              'id_user', userId);
                                    }

                                    context
                                        .read<UserProvider>()
                                        .setLoggedUser(newUser: user);

                                    if (firstTime == 1) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                NewProfilePage()),
                                      );
                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MainPage()),
                                      );
                                    }
                                  } else {
                                    // Si el correo existe pero la contraseña es incorrecta
                                    _showErrorDialog(
                                        'La contraseña es incorrecta.');

                                    // Verificar si el perfil del usuario está completo
                                    if (_profileCompleted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MainPage()),
                                      );
                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                NewProfilePage()),
                                      );
                                    }
                                  }
                                } on AuthException catch (e) {
                                  if (e.message ==
                                      'Credenciales de login inválidas') {
                                    _showErrorDialog(
                                        'El correo electrónico o la contraseña son incorrectos.');
                                  } else {
                                    _showErrorDialog(
                                        'El usuario no ha confirmado el registro.');
                                  }
                                }
                              }
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.07,
                              width: MediaQuery.of(context).size.width * 0.30,
                              decoration: BoxDecoration(
                                color: BUTTON_BACKGROUND,
                                borderRadius: BorderRadius.circular(30),
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
                                    builder: (context) => const Register()),
                              );
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.07,
                              width: MediaQuery.of(context).size.width * 0.30,
                              decoration: BoxDecoration(
                                color: BUTTON_BACKGROUND,
                                borderRadius: BorderRadius.circular(30),
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
          },
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

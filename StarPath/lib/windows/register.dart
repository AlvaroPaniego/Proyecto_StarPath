import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/windows/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:email_validator/email_validator.dart';

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

  bool _passwordVisible = true;
  bool _repeatPasswordVisible = true;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña está vacía.';
    } else if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    } else if (!RegExp(r'^(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}|:"<>?~.,]).{6,}$')
        .hasMatch(value)) {
      return 'La contraseña debe contener al menos un número \ny un carácter especial.';
    }
    return null;
  }

  Future<String?> _checkUserEmailExistence(
      String username, String email) async {
    final response = await supabase
        .from('user')
        .select('username, email')
        .or('username.eq.$username,email.eq.$email');

    if (response == null) {
      return null;
    }

    bool usernameExists = false;
    bool emailExists = false;

    for (var user in response) {
      if (user['username'] == username) {
        usernameExists = true;
      }
      if (user['email'] == email) {
        emailExists = true;
      }
    }

    if (usernameExists && emailExists) {
      return 'El nombre de usuario y el correo electrónico ya están en uso.';
    } else if (usernameExists) {
      return 'El nombre de usuario ya está en uso.';
    } else if (emailExists) {
      return 'El correo electrónico ya está en uso.';
    }

    return null;
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();

    final existenceMessage = await _checkUserEmailExistence(username, email);
    if (existenceMessage != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Error'),
            content: Text(existenceMessage),
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
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: _passwordController.text.trim(),
        data: {
          'username': username,
          'email': email,
          'first_time': 1,
        },
      );

      if (response == null) {
        print('Error al registrar usuario.');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Registro Exitoso'),
              content: Text(
                'Se ha enviado un enlace de verificación a su correo electrónico. Por favor, revise su bandeja de entrada y confirme su cuenta antes de iniciar sesión.',
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ),
                    );
                  },
                  child: Text('Aceptar'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Registro Exitoso'),
              content: Text(
                'Se ha enviado un enlace de verificación a su correo electrónico. Por favor, revise su bandeja de entrada y confirme su cuenta antes de iniciar sesión.',
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ),
                    );
                  },
                  child: Text('Aceptar'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Error'),
            content: Text(
                'Se ha producido un error al enviar el correo de confirmación a esa dirección de email.'),
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
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.fromLTRB(
                40.0,
                30.0,
                40.0,
                isKeyboardVisible ? 20.0 : 30.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      "REGISTRARSE",
                      style: TextStyle(color: TEXT, fontSize: 24),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
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
                          borderSide:
                              const BorderSide(color: FOCUS_ORANGE, width: 1.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Usuario requerido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
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
                          borderSide:
                              const BorderSide(color: FOCUS_ORANGE, width: 1.0),
                        ),
                      ),
                      validator: (value) => !EmailValidator.validate(value!)
                          ? 'El formato de email es incorrecto.'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      controller: _passwordController,
                      autofocus: false,
                      style: const TextStyle(color: TEXT),
                      obscureText: _passwordVisible,
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
                          borderSide:
                              const BorderSide(color: FOCUS_ORANGE, width: 1.0),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: TEXT,
                          ),
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      controller: _repeatPasswordController,
                      autofocus: false,
                      style: const TextStyle(color: TEXT),
                      obscureText: _repeatPasswordVisible,
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
                          borderSide:
                              const BorderSide(color: FOCUS_ORANGE, width: 1.0),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _repeatPasswordVisible = !_repeatPasswordVisible;
                            });
                          },
                          icon: Icon(
                            _repeatPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: TEXT,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Repetir contraseña requerido.';
                        } else if (value != _passwordController.text) {
                          return 'Las contraseñas no coinciden.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        TextButton(
                            onPressed: () => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Login(),
                                ),
                                (route) => false),
                            child: const Text(
                              'Ya tengo una cuenta',
                              style: TextStyle(color: FOCUS_ORANGE),
                            )),
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(BUTTON_BACKGROUND)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _registerUser();
                            }
                          },
                          child: const Text(
                            'Registrarse',
                            style: TextStyle(color: BLACK),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

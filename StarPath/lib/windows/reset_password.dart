import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:starpath/misc/constants.dart';
import 'package:flutter/cupertino.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final repeatPasswordC = TextEditingController();
  final resetTokenC = TextEditingController();
  bool _passwordVisible = true;
  bool _repeatPasswordVisible = true;
  final formKey = GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        backgroundColor: BUTTON_BAR_BACKGROUND,
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Olvidé la contraseña',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
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
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 30),
                    TextFormField(
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      controller: resetTokenC,
                      style: TextStyle(color: TEXT),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        hintText: 'Insertar código',
                        hintStyle: TextStyle(color: TEXT),
                      ),
                      validator: (value) {
                        if (value!.isEmpty || value.length < 6) {
                          return 'El código no se ha insertado o no coincide.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      controller: emailC,
                      style: TextStyle(color: TEXT),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        hintText: 'Email',
                        hintStyle: TextStyle(color: TEXT),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => !EmailValidator.validate(value!)
                          ? 'El formato de email es incorrecto.'
                          : null,
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      controller: passwordC,
                      style: TextStyle(color: TEXT),
                      obscureText: _passwordVisible,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        hintText: 'Contraseña',
                        hintStyle: TextStyle(color: TEXT),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          icon: _passwordVisible
                              ? Icon(Icons.visibility, color: TEXT)
                              : Icon(Icons.visibility_off, color: TEXT),
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      controller: repeatPasswordC,
                      style: TextStyle(color: TEXT),
                      obscureText: _repeatPasswordVisible,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        hintText: 'Repetir Contraseña',
                        hintStyle: TextStyle(color: TEXT),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _repeatPasswordVisible = !_repeatPasswordVisible;
                            });
                          },
                          icon: _repeatPasswordVisible
                              ? Icon(Icons.visibility, color: TEXT)
                              : Icon(Icons.visibility_off, color: TEXT),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Repetir contraseña requerido.';
                        } else if (value != passwordC.text) {
                          return 'Las contraseñas no coinciden.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          showDialog(
                            context: context,
                            builder: (context) => const Center(
                                child: CircularProgressIndicator()),
                          );
                          try {
                            await Supabase.instance.client.auth.verifyOTP(
                              email: emailC.text,
                              token: resetTokenC.text,
                              type: OtpType.recovery,
                            );
                            await Supabase.instance.client.auth.updateUser(
                                UserAttributes(password: passwordC.text));
                            Navigator.of(context, rootNavigator: true).pop();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CupertinoAlertDialog(
                                  title: Text('Éxito'),
                                  content: Text(
                                      'El cambio de la contraseña se ha realizado correctamente. Inicie sesión nuevamente.'),
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
                          } catch (error) {
                            Navigator.of(context, rootNavigator: true).pop();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CupertinoAlertDialog(
                                  title: Text('Error'),
                                  content: Text(
                                      'El código ha expirado o es inválido.'),
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
                      },
                      child: const Text('Cambiar Contraseña'),
                    ),
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

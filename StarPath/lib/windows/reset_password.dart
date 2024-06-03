import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final resetTokenC = TextEditingController();
  bool _passwordVisible = true;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Olvidé la contraseña'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: resetTokenC,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  hintText: 'Cambiar TOKEN',
                ),
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'El TOKEN no coincide';
                  }
                  return null;
                },
              ),
              const SizedBox(width: 16, height: 16),
              TextFormField(
                controller: emailC,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  hintText: 'Email',
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => !EmailValidator.validate(value!)
                    ? 'El formato de email es incorrecto'
                    : null,
              ),
              const SizedBox(width: 16, height: 16),
              TextFormField(
                controller: passwordC,
                obscureText: _passwordVisible,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  hintText: 'Contraseña',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                    icon: _passwordVisible
                        ? Icon(Icons.visibility)
                        : Icon(Icons.visibility_off),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'La contraseña no debe tener menos de 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(width: 16, height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    );
                    try {
                      final recovery =
                          await Supabase.instance.client.auth.verifyOTP(
                        email: emailC.text,
                        token: resetTokenC.text,
                        type: OtpType.recovery,
                      );
                      await Supabase.instance.client.auth
                          .updateUser(UserAttributes(password: passwordC.text));
                      Navigator.of(context, rootNavigator: true).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: const Text(
                                'El cambio de la contraseña se ha realizado correctamente. Inicie sesión nuevamente.')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Rellene los datos correctamente')),
                    );
                  }
                },
                child: const Text('Cambiar Contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:starpath/windows/reset_password.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final emailC = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final email = emailC.text.trim();
                    final supabaseClient = Supabase.instance.client;

                    try {
                      // Verificar si el correo existe en la base de datos
                      final emailCheckResponse = await supabaseClient
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
                        _showErrorDialog('El correo electrónico no existe.');
                        return;
                      }

                      await supabaseClient.auth.resetPasswordForEmail(email);

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: const Text(
                            '¡Revise su bandeja de entrada del correo electrónico para ver el TOKEN!',
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ResetPassword(),
                                  ),
                                );
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } on AuthException catch (e) {
                      _showErrorDialog(
                          'Error al enviar el correo de recuperación. Por seguridad, solo puede solicitar la recuperación de contraseña una vez cada 60 segundos.');
                    }
                  }
                },
                child: const Text('Recuperar contraseña'),
              ),
              const SizedBox(width: 16, height: 16),
              Text(
                  '¿Has olvidado la contraseña? Te enviamos un TOKEN al correo electronico de su cuenta para poder cambiarla por una nueva.'),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teste/src/pages/base/base_screen.dart';
import 'package:teste/src/pages/common_widgets/app_name_widget.dart';
import 'package:teste/src/pages/common_widgets/custom_text_field.dart';
import 'package:teste/src/pages/auth/sign_up_screen.dart' hide CustomTextField;
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    
    print('[SignIn] Tentando fazer login com o email: ${_emailController.text.trim()}');

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
     
      print('[SignIn] Login BEM-SUCEDIDO! UID do usuário: ${_auth.currentUser?.uid}');

      if (!mounted) return;
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const BaseScreen()),
      );
    } on FirebaseAuthException catch (e) {
      
      print('[SignIn] Ocorreu um FirebaseAuthException!');
      print('[SignIn] CÓDIGO DO ERRO: ${e.code}');
      print('[SignIn] MENSAGEM DO ERRO: ${e.message}');
      
      String message = switch (e.code) {
        'user-not-found' => 'Nenhum usuário encontrado para este e-mail.',
        'wrong-password' => 'Senha incorreta. Tente novamente.',
        'invalid-email' => 'O formato do e-mail é inválido.',
        'network-request-failed' => 'Falha na conexão de rede. Verifique sua internet.', 
        _ => 'Ocorreu um erro ao fazer login. Verifique suas credenciais.',
      };
      
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      
      print('[SignIn] Ocorreu um ERRO GENÉRICO não esperado: $e');

      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Ocorreu um erro inesperado. Tente novamente mais tarde.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Atualizar senha
  Future<void> _showResetPasswordDialog() async {
    final resetEmailController = TextEditingController();
    final resetFormKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) { 
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Recuperar Senha'),
          content: Form(
            key: resetFormKey,
            child: CustomTextField(
              controller: resetEmailController,
              icon: Icons.email,
              label: 'E-mail',
              validator: (email) {
                if (email == null || email.isEmpty) return 'Por favor, digite seu e-mail.';
                if (!email.contains('@')) return 'Digite um e-mail válido.';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (resetFormKey.currentState!.validate()) {
                  final email = resetEmailController.text.trim();

                  final navigator = Navigator.of(dialogContext);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  setState(() => _isLoading = true);
                  String? errorMessage;

                  try {
                    await _auth.sendPasswordResetEmail(email: email);
                  } on FirebaseAuthException catch (e) {
                    errorMessage = (e.code == 'user-not-found')
                        ? 'Nenhum usuário encontrado para este e-mail.'
                        : 'Ocorreu um erro ao enviar o e-mail. Tente novamente.';
                  }

                  if (!mounted) return;

                  navigator.pop();

                  if (errorMessage != null) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  } else {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Link para recuperação enviado para o e-mail!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  
                  setState(() => _isLoading = false);
                }
              },
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Enviar'),
            ),
          ],
        );
      },
    );

    resetEmailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.green,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    AppNameWidget(
                      greenTitleColor: Colors.white,
                      textSize: 40,
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        icon: Icons.email,
                        label: "Email",
                        validator: (email) {
                          if (email == null || email.isEmpty) return 'Digite seu e-mail';
                          if (!email.contains('@')) return 'Digite um e-mail válido';
                          return null;
                        },
                      ),
                      CustomTextField(
                        controller: _passwordController,
                        icon: Icons.lock,
                        label: "Senha",
                        isSecret: true,
                        validator: (password) {
                          if (password == null || password.isEmpty) return 'Digite sua senha';
                          if (password.length < 6) return 'Senha deve ter no mínimo 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _isLoading ? null : _signIn,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Entrar', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading ? null : _showResetPasswordDialog,
                          child: const Text(
                            'Esqueceu a senha?',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.withAlpha(90), thickness: 2)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text("Ou"),
                          ),
                          Expanded(child: Divider(color: Colors.grey.withAlpha(90), thickness: 2)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            side: const BorderSide(width: 2, color: Colors.green),
                          ),
                          onPressed: _isLoading ? null : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SignUpScreen()),
                            );
                          },
                          child: const Text('Criar conta', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
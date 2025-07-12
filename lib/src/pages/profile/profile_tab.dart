import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teste/src/pages/common_widgets/custom_text_field.dart';
import 'package:teste/src/models/user_model.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? userModel;
  bool isLoading = true;

  final nameController = TextEditingController();
  final cpfController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      userModel = UserModel.fromMap(doc.data()!);
      nameController.text = userModel!.name;
      cpfController.text = userModel!.cpf;
      phoneController.text = userModel!.phone;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update({
      'name': nameController.text.trim(),
      'cpf': cpfController.text.trim(),
      'phone': phoneController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados atualizados com sucesso')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do usuário'),
        actions: [
          IconButton(
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
        children: [
          // Email - somente leitura
          CustomTextField(
            readOnly: true,
            initialValue: _auth.currentUser?.email ?? '',
            icon: Icons.email,
            label: 'Email',
          ),

          // Nome - editável
          CustomTextField(
            controller: nameController,
            icon: Icons.person,
            label: 'Nome',
          ),

          // Celular - editável
          CustomTextField(
            controller: phoneController,
            icon: Icons.phone,
            label: 'Celular',
          ),

          // CPF - editável
          CustomTextField(
            controller: cpfController,
            icon: Icons.file_copy,
            label: 'CPF',
            isSecret: true,
          ),

          const SizedBox(height: 16),

          // Botão para atualizar senha
          SizedBox(
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: updatePassword,
              child: const Text('Atualizar senha'),
            ),
          ),

          const SizedBox(height: 16),

          // Botão para salvar alterações
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Salvar alterações'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updatePassword() async {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Atualização de senha',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      isSecret: true,
                      icon: Icons.lock,
                      label: 'Senha atual',
                      controller: currentPasswordController,
                    ),
                    CustomTextField(
                      isSecret: true,
                      icon: Icons.lock_outline,
                      label: 'Nova senha',
                      controller: newPasswordController,
                    ),
                    CustomTextField(
                      isSecret: true,
                      icon: Icons.lock_outline,
                      label: 'Confirmar nova senha',
                      controller: confirmPasswordController,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () async {
                          final currentPassword = currentPasswordController.text;
                          final newPassword = newPasswordController.text;
                          final confirmPassword = confirmPasswordController.text;

                          if (newPassword != confirmPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Senhas não coincidem')),
                            );
                            return;
                          }

                          final user = _auth.currentUser;

                          try {
                            final cred = EmailAuthProvider.credential(
                              email: user!.email!,
                              password: currentPassword,
                            );

                            await user.reauthenticateWithCredential(cred);
                            await user.updatePassword(newPassword);

                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Senha atualizada com sucesso')),
                            );
                          } catch (e) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro: ${e.toString()}')),
                            );
                          }
                        },
                        child: const Text('Atualizar'),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

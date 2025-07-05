import 'package:flutter/material.dart';
import 'package:teste/screens/add_product.dart';


class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Administrador'),
        backgroundColor: Colors.redAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Botão para Cadastrar Produto
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_box, color: Colors.redAccent),
              title: const Text('Cadastrar Novo Produto'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (c) => const AddProductScreen(),
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
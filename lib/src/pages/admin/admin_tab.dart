import 'package:flutter/material.dart';
// Importe sua tela de cadastro de produto aqui
import 'package:teste/screens/add_product.dart';

class AdminTab extends StatelessWidget {
  const AdminTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Admin'),
        backgroundColor: Colors.redAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_box, color: Colors.redAccent),
              title: const Text('Cadastrar Novo Produto'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (c) => const AddProductScreen()),
                );
              },
            ),
          ),
          // Adicione mais funcionalidades de admin aqui
        ],
      ),
    );
  }
}
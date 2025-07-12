import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teste/src/services/cart_service.dart';

class CartScreen extends StatelessWidget {
  final CartService _cartService = CartService();

  CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carrinho"),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _cartService.getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Erro ao carregar carrinho."));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartDocs = snapshot.data?.docs ?? [];

          if (cartDocs.isEmpty) {
            return const Center(child: Text("Carrinho vazio."));
          }

          return ListView.builder(
            itemCount: cartDocs.length,
            itemBuilder: (context, index) {
              final item = cartDocs[index];
              final name = item['productName'];
              final price = item['price'];
              final quantity = item['quantity'];

              return ListTile(
                title: Text(name),
                subtitle: Text("Qtd: \$quantity"),
                trailing: Text("R\$ ${(price * quantity).toStringAsFixed(2)}"),
              );
            },
          );
        },
      ),
    );
  }
}

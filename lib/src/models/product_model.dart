import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String nome;
  final double preco;
  final String descricao;

  Product({
    required this.id,
    required this.nome,
    required this.preco,
    required this.descricao,
  });

  
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      nome: data['nome'] ?? '',
      preco: (data['preco'] ?? 0).toDouble(),
      descricao: data['descricao'] ?? '',
    );
  }
}
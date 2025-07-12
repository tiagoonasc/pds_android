import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String id;
  String itemName;
  String description;
  double price;
  String imgUrl;
  String unit;

  Product({
    required this.id,
    required this.itemName,
    required this.description,
    required this.price,
    required this.imgUrl,
    required this.unit,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Product(
      id: doc.id,
      itemName: data['itemName'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imgUrl: data['imgUrl'] ?? '',
      unit: data['unit'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'description': description,
      'price': price,
      'imgUrl': imgUrl,
      'unit': unit,
    };
  }
}
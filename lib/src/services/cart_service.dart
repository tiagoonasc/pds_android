
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teste/src/models/product_model.dart';

class CartService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> increaseItemQuantity(String productId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId);

    await docRef.update({'quantity': FieldValue.increment(1)});
  }

  Future<void> decreaseItemQuantity(String productId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId);

    final snapshot = await docRef.get();
    final currentQty = (snapshot.data()?['quantity'] ?? 1);

    if (currentQty > 1) {
      await docRef.update({'quantity': FieldValue.increment(-1)});
    } else {
      await docRef.delete(); // remove se chegar a 0
    }
  }


  Future<void> addToCart(Product product) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final cartRef = _firestore.collection('users').doc(userId).collection('cart').doc(product.id);

    final cartDoc = await cartRef.get();

    if (!cartDoc.exists) {
      await cartRef.set({
        'productId': product.id,
        'productName': product.itemName,
        'price': product.price,
        'description': product.description,
        'quantity': 1,
      });
    } else {
      await cartRef.update({
        'quantity': FieldValue.increment(1),
      });
    }
  }

  Stream<QuerySnapshot> getCartItems() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const Stream.empty();
    }

    return _firestore.collection('users').doc(userId).collection('cart').snapshots();
  }
}

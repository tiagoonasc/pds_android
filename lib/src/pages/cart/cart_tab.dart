import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teste/src/config/custom_colors.dart';
import 'package:teste/src/models/cart_item_model.dart';
import 'package:teste/src/models/item_model.dart';
import 'package:teste/src/models/order_model.dart';
import 'package:teste/src/pages/cart/components/cart_tile.dart';
import 'package:teste/src/pages/common_widgets/payment_dialog.dart';
import 'package:teste/src/services/utils_services.dart';

class CartTab extends StatefulWidget {
 
  const CartTab({super.key});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  final UtilsServices utilsServices = UtilsServices();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void removeItemFromCart(String productId) {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null || productId.isEmpty) return;

    _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  Future<void> _checkout(List<CartItemModel> cartItems, double total) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      utilsServices.showToast(message: 'Faça login para continuar', isError: true);
      return;
    }

    final WriteBatch batch = _firestore.batch();
    final DocumentReference orderRef = _firestore.collection('orders').doc();

    batch.set(orderRef, {
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending_payment',
      'totalAmount': total,
      'items': cartItems.map((cartItem) {
        return {
          'productId': cartItem.item.id,
          'productName': cartItem.item.itemName,
          'price': cartItem.item.price,
          'quantity': cartItem.quantity,
          'imageUrl': cartItem.item.imgUrl,
        };
      }).toList(),
    });

    for (var cartItem in cartItems) {
      final cartItemRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(cartItem.item.id);
      batch.delete(cartItemRef);
    }

    try {
      await batch.commit();

      final orderForDialog = OrderModel(
        id: orderRef.id,
        createdDateTime: DateTime.now(),
        overdueDateTime: DateTime.now().add(const Duration(minutes: 15)),
        items: cartItems,
        status: 'pending_payment',
        copyAndPaste: 'PIX_GERADO_AQUI_${orderRef.id}',
        total: total,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => PaymentDialog(order: orderForDialog),
      );
    } catch (e) {
      utilsServices.showToast(message: 'Falha ao concluir o pedido. Tente novamente.', isError: true);
    }
  }

  Future<bool> showOrderConfirmation() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirmação'),
          content: const Text('Deseja realmente concluir o pedido?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Não'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text("Faça login para ver seu carrinho."));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar o carrinho'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_shopping_cart,
                      size: 40, color: CustomColors.customSwatchColor),
                  const Text('Não há itens no carrinho'),
                ],
              ),
            );
          }

          try {
            final List<CartItemModel> cartItems =
                snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final productId = data['productId'];
              final safeProductId = productId is String ? productId : '';

              return CartItemModel(
                item: ItemModel(
                  id: safeProductId,
                  itemName: data['productName'] ?? 'Nome indisponível',
                  price: (data['price'] ?? 0.0).toDouble(),
                  imgUrl: data['imageUrl'] ?? '',
                  unit: data['unit'] ?? '',
                  description: data['description'] ?? 'Descrição não informada.',
                ),
                quantity: (data['quantity'] ?? 0) as int,
              );
            }).toList();

            final double total =
                cartItems.fold(0.0, (sum, item) => sum + item.totalPrice());

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (_, index) {
                      return CartTile(
                        cartItem: cartItems[index],
                        remove: (cartItem) =>
                            removeItemFromCart(cartItem.item.id),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 3,
                          spreadRadius: 2)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Total geral', style: TextStyle(fontSize: 12)),
                      Text(
                        utilsServices.priceToCurrency(total, 2),
                        style: TextStyle(
                          fontSize: 23,
                          color: CustomColors.customSwatchColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.customSwatchColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                          onPressed: () async {
                            bool result = await showOrderConfirmation();
                            if (result) {
                              _checkout(cartItems, total);
                            }
                          },
                          child: const Text('Concluir pedido',
                              style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } catch (e) {
            print("ERRO AO PROCESSAR CARRINHO: $e");
            return Center(
                child: Text("Ocorreu um erro ao exibir os itens: $e"));
          }
        },
      ),
    );
  }
}
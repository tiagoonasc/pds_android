import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teste/src/models/cart_item_model.dart';
import 'package:teste/src/models/item_model.dart';
import 'package:teste/src/models/order_model.dart';
import 'package:teste/src/pages/common_widgets/payment_dialog.dart';
import 'package:teste/src/services/utils_services.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final UtilsServices utilsServices = UtilsServices();

    final User? user = auth.currentUser;

    if (user == null) {
      return const Center(child: Text("Faça login para ver seus pedidos."));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum pedido encontrado.'));
          }

          final orders = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final itemsData = data['items'] as List<dynamic>? ?? [];

            final items = itemsData.map((item) {
              return CartItemModel(
                item: ItemModel(
                  id: item['productId'] ?? '',
                  itemName: item['productName'] ?? '',
                  price: (item['price'] ?? 0.0).toDouble(),
                  imgUrl: item['imageUrl'] ?? '',
                  unit: item['unit'] ?? '',
                  description: item['description'] ?? '',
                ),
                quantity: (item['quantity'] ?? 0) as int,
              );
            }).toList();

            return OrderModel(
              id: doc.id,
              createdDateTime: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              overdueDateTime: DateTime.now().add(const Duration(minutes: 15)),
              status: data['status'] ?? 'pending_payment',
              copyAndPaste: data['copyAndPaste'] ?? 'PIX_GERADO_AQUI_${doc.id}',
              total: (data['totalAmount'] ?? 0).toDouble(),
              items: items,
              paymentMethod: data['paymentMethod'] ?? 'pix',
              installments: data['installments'] ?? 1,
            );
          }).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (_, index) => const SizedBox(height: 10),
            itemCount: orders.length,
            itemBuilder: (_, index) {
              final order = orders[index];

              return Card(
                elevation: 2,
                child: ExpansionTile(
                  title: Text('Pedido: ${order.id.substring(0, 6)}...'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${_getStatusText(order.status)}'),
                      Text('Total: ${utilsServices.priceToCurrency(order.total, 2)}'),
                      Text('Pagamento: ${_getPaymentText(order)}'),
                    ],
                  ),
                  children: [
                    ...order.items.map((cartItem) {
                      return ListTile(
                        leading: Image.asset(
                          cartItem.item.imgUrl,
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                        title: Text(cartItem.item.itemName),
                        subtitle: Text('Qtd: ${cartItem.quantity}'),
                        trailing: Text(
                          utilsServices.priceToCurrency(cartItem.totalPrice(), 2),
                        ),
                      );
                    }).toList(),

                    if (order.status == 'pending_payment')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => CardPaymentDialog(order: order),
                                );
                              },
                              icon: const Icon(Icons.pix, color: Colors.green),
                              label: const Text(
                                'Pagar com Pix',
                                style: TextStyle(color: Colors.green),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.green),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Implementar lógica de pagamento com cartão
                                showDialog(
                                  context: context,
                                  builder: (_) => const AlertDialog(
                                    title: Text('Pagamento com Cartão'),
                                    content: Text('Funcionalidade em desenvolvimento.'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.credit_card, color: Colors.blue),
                              label: const Text(
                                'Pagar com Cartão',
                                style: TextStyle(color: Colors.blue),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending_payment':
        return 'Aguardando pagamento';
      case 'paid':
        return 'Pago';
      case 'delivered':
        return 'Entregue';
      default:
        return 'Desconhecido';
    }
  }

  String _getPaymentText(OrderModel order) {
    if (order.paymentMethod == 'pix') {
      return 'Pix';
    } else if (order.paymentMethod == 'card') {
      return 'Cartão (${order.installments}x)';
    } else {
      return 'Desconhecido';
    }
  }
}

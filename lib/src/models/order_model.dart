import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teste/src/models/cart_item_model.dart';

class OrderModel {
  final String id;
  final DateTime createdDateTime;
  final DateTime overdueDateTime;
  final List<CartItemModel> items;
  final String status;
  final String copyAndPaste;
  final double total;
  final String paymentMethod; // Ex: 'pix' ou 'card'
  final int installments;     // 1 (à vista) até 6 (cartão)

  OrderModel({
    required this.id,
    required this.createdDateTime,
    required this.overdueDateTime,
    required this.items,
    required this.status,
    required this.copyAndPaste,
    required this.total,
    required this.paymentMethod,
    required this.installments,
  });


  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderModel(
      id: documentId,
      createdDateTime: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      overdueDateTime: (map['createdAt'] as Timestamp?)?.toDate().add(const Duration(minutes: 15)) ?? DateTime.now().add(const Duration(minutes: 15)),
      items: (map['items'] as List<dynamic>? ?? []).map((item) {
        return CartItemModel.fromMap(item as Map<String, dynamic>);
      }).toList(),
      status: map['status'] ?? 'pending_payment',
      copyAndPaste: map['copyAndPaste'] ?? '',
      total: (map['totalAmount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'pix',
      installments: map['installments'] ?? 1,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdDateTime,
      'items': items.map((item) => item.toMap()).toList(),
      'status': status,
      'copyAndPaste': copyAndPaste,
      'totalAmount': total,
      'paymentMethod': paymentMethod,
      'installments': installments,
    };
  }
}

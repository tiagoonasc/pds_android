import 'package:teste/src/models/cart_item_model.dart';

class OrderModel {
  final String id;
  final DateTime createdDateTime;
  final DateTime overdueDateTime;
  final String status;
  final String copyAndPaste;
  final double total;
  final List<CartItemModel> items;

  OrderModel({
    required this.id,
    required this.createdDateTime,
    required this.overdueDateTime,
    required this.status,
    required this.copyAndPaste,
    required this.total,
    required this.items,
  });
}

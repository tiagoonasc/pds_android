import 'package:teste/src/models/item_model.dart';

class CartItemModel {
  ItemModel item;
  int quantity;

  CartItemModel({
    required this.item,
    required this.quantity,
  });

  double totalPrice() => item.price * quantity;

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      item: map['item'] != null
          ? ItemModel.createFromMap(map['item'])
          : ItemModel(
        id: '',
        itemName: '',
        price: 0.0,
        imgUrl: '',
        unit: '',
        description: '',
      ),
      quantity: map['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item': item.toMap(),
      'quantity': quantity,
    };
  }
}

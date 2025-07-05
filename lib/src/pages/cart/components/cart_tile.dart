

import 'package:flutter/material.dart';
import 'package:teste/src/config/custom_colors.dart';
import 'package:teste/src/models/cart_item_model.dart';
import 'package:teste/src/pages/common_widgets/quantity_widget.dart';
import 'package:teste/src/services/utils_services.dart';
import 'package:teste/src/services/cart_service.dart'; // 🔧 Import do service

class CartTile extends StatefulWidget {
  final CartItemModel cartItem;
  final Function(CartItemModel) remove;

  const CartTile({
    super.key,
    required this.cartItem,
    required this.remove,
  });

  @override
  State<CartTile> createState() => _CartTileState();
}

class _CartTileState extends State<CartTile> {
  final UtilsServices utilsServices = UtilsServices();
  final CartService _cartService = CartService(); // 🔧 instância do service

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        // imagem
        leading: Image.asset(
          widget.cartItem.item.imgUrl,
          height: 60,
          width: 60,
        ),

        // Titulo
        title: Text(
          widget.cartItem.item.itemName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),

        // Total
        subtitle: Text(
          utilsServices.priceToCurrency(widget.cartItem.totalPrice(), 2),
          style: TextStyle(
            color: CustomColors.customSwatchColor,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Quantidade
        trailing: QuantityWidget(
          suffixText: widget.cartItem.item.unit,
          value: widget.cartItem.quantity,
          result: (quantity) async {
            if (quantity == 0) {
              await _cartService.decreaseItemQuantity(widget.cartItem.item.id);
              widget.remove(widget.cartItem);
            } else {
              await _cartService.increaseItemQuantity(widget.cartItem.item.id);
            }

            setState(() {
              widget.cartItem.quantity = quantity;
            });
          },
          isRemovable: true,
        ),
      ),
    );
  }
}

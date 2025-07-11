import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teste/src/config/custom_colors.dart';
import 'package:teste/src/models/item_model.dart';
import 'package:teste/src/pages/common_widgets/quantity_widget.dart';
import 'package:teste/src/services/utils_services.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, required this.item});

  final ItemModel item;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final UtilsServices utilsServices = UtilsServices();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int cartItemQuantity = 1;
  bool _isLoading = false;

  Future<void> _addToCart() async {
    final String? userId = _auth.currentUser?.uid;

    if (userId == null) {
      utilsServices.showToast(
        message: 'Faça login para continuar.',
        isError: true,
      );
      return;
    }

    final String? docId = widget.item.id;

    final cartItemRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(docId);

    try {
      await _firestore.runTransaction((transaction) async {
        final DocumentSnapshot snapshot = await transaction.get(cartItemRef);

        if (!snapshot.exists) {
          transaction.set(cartItemRef, {
            'productId': docId,
            'productName': widget.item.itemName,
            'price': widget.item.price,
            'imageUrl': widget.item.imgUrl,
            'unit': widget.item.unit,
            'description': widget.item.description,
            'quantity': cartItemQuantity,
          });

          utilsServices.showToast(
            message: '${widget.item.itemName} adicionado!',
          );
        } else {
          transaction.update(cartItemRef, {
            'quantity': FieldValue.increment(cartItemQuantity),
          });

          utilsServices.showToast(
            message: 'Quantidade de ${widget.item.itemName} atualizada!',
          );
        }
      });
    } catch (e) {
      utilsServices.showToast(
        message: 'Erro ao adicionar ao carrinho.',
        isError: true,
      );
      print("ERRO EM _addToCart: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withAlpha(230),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Hero(
                  tag: widget.item.imgUrl,
                  child: Image.asset(widget.item.imgUrl),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade600,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.item.itemName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          QuantityWidget(
                            suffixText: widget.item.unit,
                            value: cartItemQuantity,
                            result: (quantity) {
                              setState(() => cartItemQuantity = quantity);
                            },
                          ),
                        ],
                      ),
                      Text(
                        utilsServices.priceToCurrency(widget.item.price, 2),
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: CustomColors.customSwatchColor,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SingleChildScrollView(
                            child: Text(
                              widget.item.description,
                              style: const TextStyle(height: 1.5),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 55,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                            setState(() => _isLoading = true);
                            await _addToCart();
                            setState(() => _isLoading = false);
                            if (!mounted) return;
                            Navigator.of(context).pop();
                          },
                          label: _isLoading
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                              : const Text(
                            'Add no carrinho',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          icon: _isLoading
                              ? null
                              : const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 10,
            top: 10,
            child: SafeArea(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

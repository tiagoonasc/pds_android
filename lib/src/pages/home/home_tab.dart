import 'dart:async';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:add_to_cart_animation/add_to_cart_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teste/src/models/item_model.dart';
import 'package:teste/src/pages/home/components/item_tile.dart';

class HomeTab extends StatefulWidget {
  final PageController pageController;

  const HomeTab({
    super.key,
    required this.pageController,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  GlobalKey<CartIconKey> globalKeyCartItems = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCardAnimation;
  int cartQuantity = 0;

  StreamSubscription? _cartSubscription;

  @override
  void initState() {
    super.initState();
    _listenCartQuantity();
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }

  void _listenCartQuantity() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _cartSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .snapshots()
        .listen((snapshot) {
      int totalQuantity = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('quantity') && data['quantity'] is num) {
          totalQuantity += (data['quantity'] as num).toInt();
        }
      }
      if (mounted) {
        setState(() {
          cartQuantity = totalQuantity;
        });
      }
    });
  }

  Future<void> addToCart(ItemModel item) async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faça login para adicionar itens ao carrinho.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (item.id.isEmpty) return;

    final cartItemRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(item.id);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final doc = await transaction.get(cartItemRef);

        if (!doc.exists) {
          transaction.set(cartItemRef, {
            'quantity': 1,
            'productId': item.id,
            'productName': item.itemName,
            'price': item.price,
            'imageUrl': item.imgUrl,
            'unit': item.unit,
            'description': item.description,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          final currentQuantity = (doc.data()?['quantity'] ?? 0) as int;
          transaction.update(cartItemRef, {'quantity': currentQuantity + 1});
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item adicionado ao carrinho!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar item: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Produtos'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 15, right: 15),
            child: GestureDetector(
              onTap: () {
                widget.pageController.jumpToPage(1);
              },
              child: AddToCartIcon(
                key: globalKeyCartItems,
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart,
                      size: 28,
                    ),
                    if (cartQuantity > 0)
                      Positioned(
                        right: 0,
                        top: 2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$cartQuantity',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: AddToCartAnimation(
        gkCart: globalKeyCartItems,
        previewDuration: const Duration(milliseconds: 100),
        previewCurve: Curves.ease,
        receiveCreateAddToCardAnimationMethod: (addToCardAnimationMethod) {
          runAddToCardAnimation = addToCardAnimationMethod;
        },
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  hintText: 'Pesquise aqui...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 21),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(60),
                    borderSide:
                        const BorderSide(width: 0, style: BorderStyle.none),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('produtos')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('Nenhum produto encontrado.'));
                  }

                  final List<ItemModel> loadedItems =
                      snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ItemModel(
                      id: doc.id,
                      itemName: data['itemName'] ?? 'Nome indisponível',
                      price: (data['price'] ?? 0.0).toDouble(),
                      imgUrl: data['imgUrl'] ?? '',
                      unit: data['unit'] ?? '',
                      description: data['description'] ?? 'Sem descrição.',
                    );
                  }).toList();

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 9 / 11.5,
                    ),
                    itemCount: loadedItems.length,
                    itemBuilder: (_, index) {
                      return ItemTile(
                        item: loadedItems[index],
                        onAddToCart: (item, imageKey) {
                          Future.delayed(const Duration(milliseconds: 100),
                              () {
                            addToCart(item);
                            runAddToCardAnimation(imageKey);
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
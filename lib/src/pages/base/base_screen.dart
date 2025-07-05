import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teste/src/pages/cart/cart_tab.dart';
import 'package:teste/src/pages/orders/orders_tab.dart';
import 'package:teste/src/pages/profile/profile_tab.dart';
import 'package:teste/src/pages/admin/admin_tab.dart';

import '../home/home_tab.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int currentIndex = 0;
  final pageController = PageController();

  // 1. Use a nullable bool to represent 3 states:
  // null = loading, true = admin, false = not admin
  bool? _isAdmin;

  @override
  void initState() {
    super.initState();
    // Start the check when the widget is initialized
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isAdmin = false);
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final isAdmin = userDoc.data()?['isAdmin'] ?? false;
      if (mounted) {
        // 2. Update the state with the result, which will trigger a rebuild
        setState(() => _isAdmin = isAdmin);
      }
    } catch (e) {
      print("Erro ao verificar status de admin: $e");
      if (mounted) setState(() => _isAdmin = false); // Default to non-admin on error
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. If _isAdmin is null, we are still loading. Show a spinner.
    if (_isAdmin == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 4. Once we have the status, build the lists with the correct size.
    //    These are now local variables, not state variables.
    final List<Widget> pages = [
      HomeTab(pageController: pageController),
      const CartTab(),
      const OrdersTab(),
      const ProfileTab(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart_outlined),
        label: 'Carrinho',
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Pedidos'),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Perfil',
      ),
    ];

    // If user is an admin, add the admin page and tab
    if (_isAdmin == true) {
      pages.add(const AdminTab());
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      );
    }

    // Now, build the real UI with consistent lists
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: pages, // Use the final list
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            pageController.jumpToPage(index); // jumpToPage is often better here
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withAlpha(100),
        items: navItems, // Use the final list
      ),
    );
  }
}
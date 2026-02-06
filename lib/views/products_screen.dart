//lib/view/widgets/products_screen.dart
import 'package:flutter/material.dart';
import '../core/database/powersync.dart';
import '../models/cart_item.dart';
import 'widgets/cart_sheet.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final List<CartItem> _cart = [];

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final existingIndex = _cart.indexWhere((item) => item.product['id'] == product['id']);
      if (existingIndex >= 0) {
        _cart[existingIndex].quantity++;
      } else {
        _cart.add(CartItem(product: product));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تمت إضافة ${product['name']}'), duration: const Duration(milliseconds: 300)),
    );
  }

  void _openCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CartBottomSheet(
        cart: _cart,
        onClearCart: () => setState(() => _cart.clear()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('كتالوج الطلبات')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: db.watch('SELECT * FROM products ORDER BY created_at DESC').map((results) {
          return results.map((row) => row as Map<String, dynamic>).toList();
        }),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('خطأ: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final products = snapshot.data!;
          if (products.isEmpty) return const Center(child: Text("لا توجد منتجات.."));

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 10, mainAxisSpacing: 10
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: Column(
                  children: [
                    Expanded(
                      child: product['image_url'] != null
                          ? Image.network(product['image_url'], fit: BoxFit.cover, width: double.infinity)
                          : const Icon(Icons.image, size: 50),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(product['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${product['price']}'),
                          ElevatedButton(onPressed: () => _addToCart(product), child: const Text('أضف +')),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCart,
        backgroundColor: Colors.black,
        icon: const Icon(Icons.shopping_cart, color: Colors.white),
        label: Text('${_cart.length}', style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
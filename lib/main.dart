// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p; 
import 'package:powersync/powersync.dart' as ps; 

import 'constants.dart';
import 'widgets/cart_sheet.dart'; 
import 'services/order_service.dart'; 

// ---------------------------------------------------------
// 1. تعريف السكيما (Schema) - مع عمود الترتيب created_at
// ---------------------------------------------------------
final schema = ps.Schema([
  ps.Table('products', [
    ps.Column.text('name'),
    ps.Column.real('price'),
    ps.Column.integer('stock_quantity'),
    ps.Column.text('image_url'),
    ps.Column.text('created_at'), // تأكد من وجوده للمزامنة
  ]),
  ps.Table('orders', [
    ps.Column.text('user_id'),
    ps.Column.text('status'),
  ]),
  ps.Table('order_items', [
    ps.Column.text('order_id'),
    ps.Column.text('product_id'),
    ps.Column.integer('quantity'),
    ps.Column.real('unit_price'),
  ]),
]);

late final ps.PowerSyncDatabase db;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تهيئة Supabase
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );

  // 🔴 كود تسجيل الدخول التلقائي (مكانه هنا في البداية) 🔴
  try {
    await Supabase.instance.client.auth.signInWithPassword(
      email: 'satwrabbas@gmail.com', 
      password: 'Nhmq!1341', // 👈 ضع كلمة المرور الحقيقية هنا
    );
    print("✅ تم تسجيل الدخول بنجاح");
  } catch(e) {
    print("❌ فشل تسجيل الدخول: $e");
  }

  // 3. تهيئة PowerSync
  final dir = await getApplicationSupportDirectory();
  final path = p.join(dir.path, 'wholesale.db');

  db = ps.PowerSyncDatabase(schema: schema, path: path);
  await db.initialize();

  // 4. ربط الموصل
  final connector = SupabaseConnector(db);
  db.connect(connector: connector);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wholesale App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ProductsPage(),
    );
  }
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
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
          if (products.isEmpty) return const Center(child: Text("لا توجد منتجات.. تأكد من تسجيل الدخول والمزامنة"));

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

// ---------------------------------------------------------
// 5. كلاس SupabaseConnector (تم إصلاح متغير session)
// ---------------------------------------------------------
class SupabaseConnector extends ps.PowerSyncBackendConnector {
  final ps.PowerSyncDatabase db;
  SupabaseConnector(this.db);

  @override
  Future<ps.PowerSyncCredentials?> fetchCredentials() async {
    // جلب الجلسة الحالية
    final session = Supabase.instance.client.auth.currentSession;
    
    if (session == null) return null;

    return ps.PowerSyncCredentials(
      endpoint: SUPABASE_POWERSYNC_ENDPOINT, 
      token: session.accessToken,
    );
  }

  @override
  Future<void> uploadData(ps.PowerSyncDatabase database) async {}
}
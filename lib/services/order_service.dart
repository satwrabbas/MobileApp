// lib/services/order_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';

// نموذج المنتج في السلة (ننقله هنا أو في ملف models منفصل)
class CartItem {
  final Map<String, dynamic> product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class OrderService {
  // دالة إرسال الطلب
  static Future<void> submitOrder(List<CartItem> cart) async {
    if (cart.isEmpty) throw Exception("السلة فارغة!");

    final client = Supabase.instance.client;

    // 1. حساب الإجمالي
    double totalAmount = cart.fold(0, (sum, item) => sum + (item.product['price'] * item.quantity));

    // 2. إنشاء الطلب
    final orderResponse = await client
        .from('orders')
        .insert({
          'user_id': FAKE_USER_ID,
          'total_amount': totalAmount,
          'status': 'pending',
        })
        .select()
        .single();

    final orderId = orderResponse['id'];

    // 3. إدخال التفاصيل
    final List<Map<String, dynamic>> orderItems = cart.map((item) {
      return {
        'order_id': orderId,
        'product_id': item.product['id'],
        'quantity': item.quantity,
        'unit_price': item.product['price'],
      };
    }).toList();

    await client.from('order_items').insert(orderItems);
  }
}
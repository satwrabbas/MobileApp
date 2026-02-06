//lib/services/order_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import '../models/cart_item.dart';

class OrderService {
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
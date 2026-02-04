// lib/widgets/cart_sheet.dart
import 'package:flutter/material.dart';
import '../services/order_service.dart';

class CartBottomSheet extends StatefulWidget {
  final List<CartItem> cart;
  final VoidCallback onClearCart; // دالة يتم استدعاؤها عند نجاح الطلب لتنظيف السلة

  const CartBottomSheet({super.key, required this.cart, required this.onClearCart});

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    try {
      await OrderService.submitOrder(widget.cart);
      
      widget.onClearCart(); // تنظيف السلة في الصفحة الرئيسية
      
      if (mounted) {
        Navigator.pop(context); // إغلاق النافذة
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('تم الطلب بنجاح! 🎉'),
            content: Text('الطلب وصل للمستودع.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = widget.cart.fold(0.0, (sum, item) => sum + (item.product['price'] * item.quantity));

    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          const Text('سلة المشتريات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: widget.cart.isEmpty
                ? const Center(child: Text('السلة فارغة'))
                : ListView.builder(
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];
                      return ListTile(
                        title: Text(item.product['name']),
                        subtitle: Text('${item.product['price']} \$ x ${item.quantity}'),
                        trailing: Text('${(item.product['price'] * item.quantity).toStringAsFixed(2)} \$', 
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
          ),
          const Divider(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (widget.cart.isEmpty || _isLoading) ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    widget.cart.isEmpty ? 'السلة فارغة' : 'تأكيد الطلب (${total.toStringAsFixed(2)} \$)',
                    style: const TextStyle(fontSize: 18),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
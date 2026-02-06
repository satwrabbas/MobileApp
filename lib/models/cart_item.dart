//lib/models/cart_item.dart
class CartItem {
  final Map<String, dynamic> product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}
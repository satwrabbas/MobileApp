import 'package:powersync/powersync.dart';

const schema = Schema([
  // جدول المنتجات
  Table('products', [
    Column.text('name'),
    Column.text('description'),
    Column.text('category'),
    Column.real('price'),
    Column.integer('stock_quantity'),
    Column.text('image_url'),
    Column.text('created_at'),
  ]),
  
  // جدول الطلبات
  Table('orders', [
    Column.text('user_id'),
    Column.real('total_amount'),
    Column.text('status'),
    Column.text('created_at'),
  ]),

  // جدول عناصر الطلب
  Table('order_items', [
    Column.text('order_id'),
    Column.text('product_id'),
    Column.integer('quantity'),
    Column.real('unit_price'),
  ]),
]);
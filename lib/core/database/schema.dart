//lib/core/database/schema.dart
import 'package:powersync/powersync.dart' as ps;

final schema = ps.Schema([
  ps.Table('products', [
    ps.Column.text('name'),
    ps.Column.real('price'),
    ps.Column.integer('stock_quantity'),
    ps.Column.text('image_url'),
    ps.Column.text('created_at'),
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
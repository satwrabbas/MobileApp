// lib/services/powersync.dart

import 'package:powersync/powersync.dart' as ps; // إضافة سابقة ps لتجنب تعارض Column
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p; // إضافة سابقة p لتجنب تعارض Context
import 'dart:io';

// 1. تعريف السكيما (Schema) باستخدام اللاحقة ps
final schema = ps.Schema([
  ps.Table('products', [
    ps.Column.text('name'),
    ps.Column.real('price'),
    ps.Column.integer('stock_quantity'),
    ps.Column.text('image_url'),
  ]),
  // جدول الطلبات (نحتاجه للمزامنة التي برمجناها في الداشبورد)
  ps.Table('orders', [
    ps.Column.text('user_id'),
    ps.Column.text('status'),
  ]),
  // جدول عناصر الطلبات
  ps.Table('order_items', [
    ps.Column.text('order_id'),
    ps.Column.text('product_id'),
    ps.Column.integer('quantity'),
    ps.Column.real('unit_price'),
  ]),
]);

// استخدام النوع الصحيح مع السابقة ps
late ps.PowerSyncDatabase db;

// 2. دالة لفتح قاعدة البيانات
Future<void> openDatabase() async {
  // تحديد مسار التخزين باستخدام p.join لتجنب تعارض الأسماء
  final dir = await getApplicationSupportDirectory();
  final path = p.join(dir.path, 'wholesale.db');

  // إنشاء كائن قاعدة البيانات مع السابقة ps
  db = ps.PowerSyncDatabase(schema: schema, path: path);

  // تهيئة المحرك
  await db.initialize();
  
  print("✅ PowerSync Engine Started & Database Opened at: $path");
}
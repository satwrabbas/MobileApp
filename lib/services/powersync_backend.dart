import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart'; // تأكد أن ملف الثوابت موجود

class SupabaseConnector extends PowerSyncBackendConnector {
  final SupabaseClient db;

  SupabaseConnector(this.db);

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    // 1. جلب توكن المصادقة لكي يسمح PowerSync بالاتصال
    final session = db.auth.currentSession;
    if (session == null) {
      // إذا لم يكن مسجلاً، نستخدم التوكن المجهول (لغرض التجربة حالياً)
      // في الإنتاج، يجب أن يكون هناك تسجيل دخول حقيقي
      return PowerSyncCredentials(
        endpoint: 'https://foo.powersync.service', // ⚠️ استبدل هذا برابط مشروعك من PowerSync Dashboard
        token: SUPABASE_ANON_KEY, // مؤقتاً
      );
    }
    
    // هذا الكود الحقيقي عند وجود تسجيل دخول
    // نحتاج هنا لإنشاء توكن خاص بـ PowerSync، سنتجاوز هذه النقطة المعقدة الآن
    // ونستخدم طريقة مبسطة للتجربة.
    return null; 
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    // 2. هذه الدالة تعمل تلقائياً عندما يعود الإنترنت
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) return;

    try {
      for (var op in transaction.crud) {
        final table = op.table;
        final id = op.id;
        final data = op.opData;

        // تنفيذ العمليات على Supabase
        if (op.op == UpdateType.put) {
          // إضافة أو تعديل
           // التعامل مع الحقول التي قد تختلف بين SQLite و Postgres
          var dataCopy = Map<String, dynamic>.from(data!);
          dataCopy.remove('id'); // Supabase ينشئ ID أحياناً، لكن PowerSync يرسله
          
          await db.from(table).upsert({'id': id, ...dataCopy});
        } else if (op.op == UpdateType.patch) {
          // تعديل جزئي
          await db.from(table).update(data!).eq('id', id);
        } else if (op.op == UpdateType.delete) {
          // حذف
          await db.from(table).delete().eq('id', id);
        }
      }
      await transaction.complete(); // نجاح
    } catch (e) {
      print('Upload Error: $e');
      // لا نكمل المعاملة لكي يحاول مرة أخرى لاحقاً
    }
  }
}
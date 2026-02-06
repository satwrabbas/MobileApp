//lib/core/database/powersync.dart
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:powersync/powersync.dart' as ps;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';
import 'schema.dart';

late final ps.PowerSyncDatabase db;

class PowerSyncManager {
  static Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    final path = p.join(dir.path, 'wholesale.db');

    db = ps.PowerSyncDatabase(schema: schema, path: path);
    await db.initialize();

    final connector = SupabaseConnector();
    db.connect(connector: connector);
  }
}

class SupabaseConnector extends ps.PowerSyncBackendConnector {
  @override
  Future<ps.PowerSyncCredentials?> fetchCredentials() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;

    return ps.PowerSyncCredentials(
      endpoint: SUPABASE_POWERSYNC_ENDPOINT,
      token: session.accessToken,
    );
  }

  @override
  Future<void> uploadData(ps.PowerSyncDatabase database) async {
    // منطق رفع البيانات يوضع هنا إذا لزم الأمر
  }
}
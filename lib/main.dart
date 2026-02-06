//lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants.dart';
import 'core/database/powersync.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة Supabase
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );

  // 2. تسجيل الدخول
  try {
    await Supabase.instance.client.auth.signInWithPassword(
      email: 'satwrabbas@gmail.com', 
      password: 'Nhmq!1341', 
    );
  } catch(e) {
    debugPrint("Auth Error: $e");
  }

  // 3. تهيئة PowerSync
  await PowerSyncManager.init();

  runApp(const MyApp());
}
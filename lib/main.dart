import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Load environment variables ────────────────────────────────
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('Vaulted: .env file not found, continuing without it.');
  }

  // ── Firebase (safe fallback if google-services.json is absent) ─
  try {
    await Firebase.initializeApp();
    debugPrint('Vaulted: Firebase initialised.');
  } catch (e) {
    debugPrint('Vaulted: Firebase not configured yet — $e');
  }

  // ── Lock orientation to portrait ──────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Light status-bar icons on dark background ─────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF0C0C14),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ── Launch ────────────────────────────────────────────────────
  runApp(const ProviderScope(child: VaultedApp()));
}

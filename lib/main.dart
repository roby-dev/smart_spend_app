import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_app/config/database/database_helper_drift.dart';
import 'package:smart_spend_app/config/router/app_router.dart';
import 'package:smart_spend_app/config/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final appDatabase = AppDatabase();

  initializeDateFormatting('es_PE', null);
  await Firebase.initializeApp();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(appDatabase),
      ],
      child: const MainApp(),
    ),
  );
}

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smart Spend App',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTHeme().getTheme(),
    );
  }
}

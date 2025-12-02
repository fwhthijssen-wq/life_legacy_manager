// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_router.dart';
import 'core/app_routes.dart';
import 'package:life_legacy_manager/l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: LLMApp()));
}

class LLMApp extends StatelessWidget {
  const LLMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life & Legacy Manager',
      debugShowCheckedModeBanner: false,
      
      // Localization delegates
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Supported locales
      supportedLocales: const [
        Locale('nl', ''), // Nederlands
        Locale('en', ''), // English
      ],
      
      // Default locale (Nederlands)
      locale: const Locale('nl', ''),
      
      // Donker thema
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E6E5D),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      
      // Licht thema (fallback)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E6E5D),
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      
      // Licht thema gebruiken
      themeMode: ThemeMode.light,
      
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
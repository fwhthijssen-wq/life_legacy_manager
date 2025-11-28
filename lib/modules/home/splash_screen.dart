// lib/modules/home/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_routes.dart';
import '../../core/app_database.dart';
import '../auth/providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Kleine delay voor splash effect
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    try {
      // Check of er een user bestaat
      final db = await AppDatabase.instance.database;
      final users = await db.query('users', limit: 1);

      if (users.isEmpty) {
        // Geen user → Ga naar welkomscherm
        _navigateTo(AppRoutes.welcome);
        return;
      }

      // User bestaat, check of PIN enabled is
      final user = users.first;
      final isPinEnabled = (user['is_pin_enabled'] ?? 0) == 1;

      if (isPinEnabled) {
        // PIN enabled → Ga naar unlock scherm
        _navigateTo(AppRoutes.unlock);
      } else {
        // Geen PIN → Ga naar login scherm
        _navigateTo(AppRoutes.login);
      }
    } catch (e) {
      print('❌ Splash error: $e');
      // Bij fout → Ga naar welkomscherm
      _navigateTo(AppRoutes.welcome);
    }
  }

  void _navigateTo(String route) {
    if (mounted) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo/icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App naam
              Text(
                "Life & Legacy Manager",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                "Uw persoonlijke levenscompas",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.primaryColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                "Even geduld...",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
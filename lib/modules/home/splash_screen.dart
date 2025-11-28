// lib/modules/home/splash_screen.dart

import 'package:flutter/material.dart';
import '../../core/app_routes.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, size: 90, color: Color(0xFF4E6E5D)),
            const SizedBox(height: 20),
            const Text(
              "Welkom bij de Life & Legacy Manager",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "We bouwen stap voor stap jouw levensdossier.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, AppRoutes.welcome);
              },
              child: const Text("Start"),
            ),
          ],
        ),
      ),
    );
  }
}

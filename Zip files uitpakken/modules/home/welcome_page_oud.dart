import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welkom"),
      ),
      body: const Center(
        child: Text(
          "Dit is het scherm NA de start-knop.",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

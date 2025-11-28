// lib/modules/home/home_screen.dart

import 'package:flutter/material.dart';
import '../person/select_person_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Life Legacy Manager"),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Personen beheren"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SelectPersonScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

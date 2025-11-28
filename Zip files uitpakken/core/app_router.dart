// lib/core/app_router.dart

import 'package:flutter/material.dart';

// Auth
import '../modules/auth/screens/welcome_screen.dart';
import '../modules/auth/screens/login_screen.dart';
import '../modules/auth/screens/register_screen.dart';
import '../modules/auth/screens/unlock_screen.dart';
import '../modules/auth/screens/setup_pin_screen.dart';

// Home
import '../modules/home/splash_screen.dart';
import '../modules/home/home_screen.dart';

// Personen
import '../modules/person/select_person_screen.dart';
import '../modules/person/add_person_screen.dart';
import '../modules/person/person_detail_screen.dart';
import '../modules/person/edit_person_screen.dart';

import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Start
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      // Auth
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.unlock:
        return MaterialPageRoute(builder: (_) => const UnlockScreen());

      case AppRoutes.setupPin:
       final userId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => SetupPinScreen(userId: userId),
  );


      // Home
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      // Personen
      case AppRoutes.selectPerson:
        return MaterialPageRoute(builder: (_) => const SelectPersonScreen());

      case AppRoutes.addPerson:
        return MaterialPageRoute(builder: (_) => const AddPersonScreen());

      case AppRoutes.personDetail:
        final personId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => PersonDetailScreen(personId: personId),
        );

      case AppRoutes.editPerson:
        final personId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => EditPersonScreen(personId: personId),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Route niet gevonden")),
          ),
        );
    }
  }
}

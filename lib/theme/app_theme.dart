// lib/theme/app_theme.dart
// Centraal theme systeem voor consistente UI/UX

import 'package:flutter/material.dart';

/// App kleuren - consistent door de hele app
class AppColors {
  // Primary palette
  static const primary = Color(0xFF4E6E5D);
  static const primaryLight = Color(0xFF7A9B8A);
  static const primaryDark = Color(0xFF2D4A3C);
  
  // Status kleuren
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);
  
  // Neutrale kleuren
  static const surface = Color(0xFFFAFAFA);
  static const surfaceVariant = Color(0xFFF5F5F5);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint = Color(0xFFBDBDBD);
  static const divider = Color(0xFFE0E0E0);
  
  // Module kleuren
  static const modulePersons = Color(0xFF5C6BC0);      // Indigo
  static const moduleMoney = Color(0xFF26A69A);         // Teal
  static const moduleHousing = Color(0xFF42A5F5);       // Blue
  static const moduleAssets = Color(0xFFAB47BC);        // Purple
  static const moduleSubscriptions = Color(0xFF7E57C2); // Deep Purple
  static const moduleContacts = Color(0xFF66BB6A);      // Green
  static const moduleDocuments = Color(0xFFFFCA28);     // Amber
  static const moduleLegal = Color(0xFF8D6E63);         // Brown
  static const moduleWishes = Color(0xFFEC407A);        // Pink
  static const moduleDigital = Color(0xFF29B6F6);       // Light Blue
  
  /// Bepaal progress kleur op basis van percentage
  static Color progressColor(double percentage) {
    if (percentage >= 80) return success;
    if (percentage >= 50) return warning;
    return error;
  }
}

/// App spacing - consistent margins en padding
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  
  // Card specifiek
  static const double cardMargin = 12;
  static const double cardPadding = 16;
  static const double cardRadius = 12;
  
  // Icon container
  static const double iconContainerSize = 48;
  static const double iconContainerRadius = 12;
  static const double iconSize = 24;
  
  // Empty state
  static const double emptyIconSize = 80;
}

/// App text styles - consistent typography
class AppTextStyles {
  static const cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  
  static const cardSubtitle = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );
  
  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  
  static const emptyStateTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static const emptyStateSubtitle = TextStyle(
    fontSize: 14,
    color: AppColors.textHint,
  );
  
  static const badgeText = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );
}

/// App decorations - herbruikbare box decorations
class AppDecorations {
  /// Icon container decoratie met kleur
  static BoxDecoration iconContainer(Color color, {bool isLocked = false}) {
    return BoxDecoration(
      color: isLocked ? Colors.grey[200] : color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(AppSpacing.iconContainerRadius),
    );
  }
  
  /// Progress badge decoratie
  static BoxDecoration progressBadge(double percentage) {
    return BoxDecoration(
      color: AppColors.progressColor(percentage),
      borderRadius: BorderRadius.circular(12),
    );
  }
  
  /// Card decoratie
  static BoxDecoration card({Color? color}) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

/// Volledig thema voor MaterialApp
class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      fontFamily: 'Segoe UI',
      
      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: AppSpacing.cardMargin),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      
      // FAB theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
        ),
      ),
      
      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
        ),
      ),
      
      // Outlined button theme  
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
        ),
      ),
      
      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),
      
      // Dialog theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
      ),
      
      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
  
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Segoe UI',
      
      // Dezelfde thema instellingen als light, maar dan voor dark mode
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: AppSpacing.cardMargin),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
      ),
      
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),
    );
  }
}


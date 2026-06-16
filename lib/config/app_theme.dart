import 'package:flutter/material.dart';

/// Paleta de cores usada em toda a aplicação.
class AppColors {
  static const Color primary = Color(0xFFCC2229);
  static const Color primaryDark = Color(0xFFB51E24);
  static const Color secondary = Color(0xFF6D4C41);
  static const Color background = Color(0xFFF4F5F7);
  static const Color surface = Colors.white;
  static const Color onPrimary = Colors.white;
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color border = Color(0xFFE2E4E8);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFD32F2F);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
}

class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
}

class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];
}

/// Espaçamentos base para manter consistência entre componentes.
class AppSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: false,
      fontFamily: 'Plus Jakarta Sans',
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
    );

    final textTheme = base.textTheme
        .copyWith(
          displaySmall: base.textTheme.displaySmall?.copyWith(fontSize: 28, fontWeight: FontWeight.w800),
          headlineSmall: base.textTheme.headlineSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
          titleLarge: base.textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
          titleMedium: base.textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.4),
          bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.4),
          bodySmall: base.textTheme.bodySmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
          labelLarge: base.textTheme.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        )
        .apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary);

    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.border, width: 1.2),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          side: BorderSide(color: Colors.grey.shade400),
          foregroundColor: AppColors.textPrimary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.grey.shade400;
        }),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: outlineBorder,
        enabledBorder: outlineBorder,
        focusedBorder: outlineBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        labelStyle: TextStyle(color: AppColors.textMuted),
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        backgroundColor: AppColors.surface,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1),
    );
  }
}

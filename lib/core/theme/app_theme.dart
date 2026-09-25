import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color seed = Color(0xFF1E5FA6);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: seed),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    navigationBarTheme: const NavigationBarThemeData(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
  );

  static ThemeData get comfort {
    final scheme = ColorScheme.fromSeed(seedColor: seed, contrastLevel: 1);
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final text = base.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    final outline = BorderSide(color: scheme.outline, width: 2);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    return base.copyWith(
      textTheme: text.copyWith(
        bodyLarge: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        bodyMedium: text.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        bodySmall: text.bodySmall?.copyWith(fontWeight: FontWeight.w500),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      navigationBarTheme: const NavigationBarThemeData(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 60),
          shape: shape,
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 60),
          shape: shape,
          side: outline,
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(56, 56),
          iconSize: 28,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderSide: outline),
        enabledBorder: OutlineInputBorder(borderSide: outline),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.primary, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.error, width: 3),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        helperMaxLines: 3,
        errorMaxLines: 3,
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: 12,
        titleTextStyle: TextStyle(fontWeight: FontWeight.w700),
      ),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(color: scheme.onSurface, width: 2),
        visualDensity: const VisualDensity(horizontal: 2, vertical: 2),
      ),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.all(12),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        side: outline,
      ),
      dividerTheme: const DividerThemeData(thickness: 1.5),
    );
  }
}

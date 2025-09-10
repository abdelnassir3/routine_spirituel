import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modern Color Palette inspired by the reference designs
class ModernColors {
  ModernColors._();

  // Primary: Energetic Cyan/Turquoise
  static const Color primary = Color(0xFF00BCD4); // Vibrant Cyan
  static const Color primaryDark = Color(0xFF0097A7); // Dark Cyan
  static const Color primaryLight = Color(0xFF4DD0E1); // Light Cyan
  static const Color primaryContainer = Color(0xFFE0F7FA); // Very Light Cyan

  // Secondary: Warm accent colors
  static const Color secondary = Color(0xFF5C6BC0); // Indigo
  static const Color secondaryContainer = Color(0xFFE8EAF6); // Light Indigo

  // Category Colors (inspired by the design)
  static const Color categoryBlue = Color(0xFF1976D2); // Material Blue
  static const Color categoryGreen = Color(0xFF388E3C); // Material Green
  static const Color categoryOrange = Color(0xFFFF9800); // Material Orange
  static const Color categoryPurple = Color(0xFF7B1FA2); // Material Purple
  static const Color categoryRed = Color(0xFFD32F2F); // Material Red
  static const Color categoryCyan = Color(0xFF00ACC1); // Material Cyan

  // Neutral palette - Amélioration de la visibilité
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}

/// Modern gradients inspired by the designs
class ModernGradients {
  ModernGradients._();

  // Theme-aware primary gradient (for buttons/FAB)
  static LinearGradient primary(ColorScheme cs) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [cs.primary, cs.primary.withOpacity(0.85)],
      );

  // Theme-aware header gradient
  static LinearGradient header(ColorScheme cs) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cs.primary,
          cs.primary.withOpacity(0.8),
          cs.secondary.withOpacity(0.6),
        ],
      );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFAFAFA),
    ],
  );

  static const LinearGradient categoryGradients = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE3F2FD), // Light blue
      Color(0xFFFFFFFF), // White
    ],
  );
}

/// Inspired Design System
/// Based on modern To-Do app aesthetics with spiritual touch
class InspiredTheme {
  InspiredTheme._();

  /// Build modern inspired theme
  static ThemeData buildModernTheme(Brightness brightness,
      {ModernPalette? palette}) {
    final bool isDark = brightness == Brightness.dark;
    final ModernPalette effective =
        palette ?? ModernPalettes.available['modern']!;
    final ColorScheme colorScheme = _generateColorScheme(brightness, effective);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,

      // Modern typography
      textTheme: _buildModernTextTheme(colorScheme),

      // Visual density for modern feel
      visualDensity: VisualDensity.comfortable,

      // Modern AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        centerTitle: true,
      ),

      // Modern Cards avec bordures pour la visibilité
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),

      // Modern Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(120, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          // Avoid hard-coding colors so default and tonal variants
          // can both derive correct colors from colorScheme
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Modern Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? colorScheme.surfaceContainer : colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 16,
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 16,
        ),
      ),

      // Modern List Tiles
      listTileTheme: ListTileThemeData(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        iconColor: colorScheme.onSurfaceVariant,
        minLeadingWidth: 40,
      ),

      // Modern FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 8,
        highlightElevation: 12,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        largeSizeConstraints: const BoxConstraints.tightFor(
          width: 64,
          height: 64,
        ),
      ),

      // Modern Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Modern Dividers
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Modern Snackbars
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.inversePrimary,
      ),
    );
  }

  static ColorScheme _generateColorScheme(
      Brightness brightness, ModernPalette palette) {
    // Base from primary
    final base = ColorScheme.fromSeed(
        seedColor: palette.primary, brightness: brightness);
    // Accent for secondary/tertiary families
    final accent = ColorScheme.fromSeed(
        seedColor: palette.secondary, brightness: brightness);
    // Merge families
    final scheme = base.copyWith(
      secondary: accent.secondary,
      onSecondary: accent.onSecondary,
      secondaryContainer: accent.secondaryContainer,
      onSecondaryContainer: accent.onSecondaryContainer,
      tertiary: accent.tertiary,
      onTertiary: accent.onTertiary,
      tertiaryContainer: accent.tertiaryContainer,
      onTertiaryContainer: accent.onTertiaryContainer,
    );
    return scheme;
  }

  /// Modern text theme
  static TextTheme _buildModernTextTheme(ColorScheme colorScheme) {
    const String fontFamily = 'SF Pro Display'; // iOS-like font
    const List<String> fontFamilyFallback = ['Roboto', 'Inter'];

    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w300,
        letterSpacing: -2.0,
        height: 1.1,
        color: colorScheme.onSurface,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),
      displayMedium: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
        height: 1.15,
        color: colorScheme.onSurface,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),
      displaySmall: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: -1.0,
        height: 1.2,
        color: colorScheme.onSurface,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.25,
        color: colorScheme.onSurface,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.3,
        color: colorScheme.onSurface,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
        color: colorScheme.onSurface,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: colorScheme.onSurface,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.45,
        color: colorScheme.onSurface,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.5,
        color: colorScheme.onSurface,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
        color: colorScheme.onSurface,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
        color: colorScheme.onSurface,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.4,
        color: colorScheme.onSurfaceVariant,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: colorScheme.onSurface,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.35,
        color: colorScheme.onSurface,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.3,
        color: colorScheme.onSurfaceVariant,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      ),
    );
  }

  /// Quick access to themes
  static ThemeData get light => buildModernTheme(Brightness.light);
  static ThemeData get dark => buildModernTheme(Brightness.dark);
}

/// Category colors for spiritual routines
class SpiritualCategories {
  static const Map<String, Color> colors = {
    'prayer': ModernColors.categoryBlue,
    'meditation': ModernColors.categoryPurple,
    'reading': ModernColors.categoryGreen,
    'dhikr': ModernColors.categoryCyan,
    'charity': ModernColors.categoryOrange,
    'reflection': ModernColors.secondary,
    'protection': ModernColors.categoryRed,
    'gratitude': ModernColors.categoryGreen,
    'custom': ModernColors.primary,
    'louange': ModernColors.categoryBlue,
    'pardon': ModernColors.categoryPurple,
    'guidance': ModernColors.categoryCyan,
    'healing': ModernColors.categoryOrange,
  };

  static const Map<String, IconData> icons = {
    'prayer': Icons.mosque,
    'meditation': Icons.self_improvement,
    'reading': Icons.book,
    'dhikr': Icons.favorite,
    'charity': Icons.volunteer_activism,
    'reflection': Icons.psychology,
    'protection': Icons.shield,
    'gratitude': Icons.favorite_border,
    'louange': Icons.auto_awesome,
    'pardon': Icons.healing,
    'guidance': Icons.explore,
    'healing': Icons.medical_services,
    'custom': Icons.star,
  };
}

/// Modern theme provider
final modernThemeProvider =
    StateProvider<bool>((ref) => false); // false = light, true = dark

// Accessibilité: réduire les animations globales
final reduceMotionProvider = StateProvider<bool>((ref) => false);

// Palette support
class ModernPalette {
  final String id;
  final String name;
  final Color primary;
  final Color secondary;
  const ModernPalette(
      {required this.id,
      required this.name,
      required this.primary,
      required this.secondary});
}

class ModernPalettes {
  static const Map<String, ModernPalette> available = {
    'modern': ModernPalette(
      id: 'modern',
      name: 'Cyan & Indigo',
      primary: Color(0xFF00BCD4),
      secondary: Color(0xFF5C6BC0),
    ),
    'elegant': ModernPalette(
      id: 'elegant',
      name: 'Violet & Corail',
      primary: Color(0xFF5E35B1),
      secondary: Color(0xFFFF7043),
    ),
    'ocean': ModernPalette(
      id: 'ocean',
      name: 'Océan & Turquoise',
      primary: Color(0xFF0277BD),
      secondary: Color(0xFF26C6DA),
    ),
  };
}

final modernPaletteIdProvider = StateProvider<String>((ref) => 'modern');

/// App theme provider with modern themes
final appModernThemeProvider = Provider<ThemeData>((ref) {
  final isDark = ref.watch(modernThemeProvider);
  final paletteId = ref.watch(modernPaletteIdProvider);
  final palette = ModernPalettes.available[paletteId] ??
      ModernPalettes.available['modern']!;
  return InspiredTheme.buildModernTheme(
      isDark ? Brightness.dark : Brightness.light,
      palette: palette);
});

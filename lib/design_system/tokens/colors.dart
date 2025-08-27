import 'package:flutter/material.dart';

/// Advanced Color System
/// Comprehensive color tokens for premium UI design
class AdvancedColors {
  AdvancedColors._();

  /// Semantic Color Roles
  static class Semantic {
    // Success colors
    static const Color success = Color(0xFF10B981);      // Emerald 500
    static const Color successContainer = Color(0xFFD1FAE5); // Emerald 100
    static const Color onSuccess = Color(0xFFFFFFFF);
    static const Color onSuccessContainer = Color(0xFF047857); // Emerald 700

    // Warning colors
    static const Color warning = Color(0xFFF59E0B);      // Amber 500
    static const Color warningContainer = Color(0xFFFEF3C7); // Amber 100
    static const Color onWarning = Color(0xFFFFFFFF);
    static const Color onWarningContainer = Color(0xFFD97706); // Amber 600

    // Info colors
    static const Color info = Color(0xFF3B82F6);         // Blue 500
    static const Color infoContainer = Color(0xFFDBEAFE); // Blue 100
    static const Color onInfo = Color(0xFFFFFFFF);
    static const Color onInfoContainer = Color(0xFF1D4ED8); // Blue 700

    // Error colors (already defined in Material 3)
    static const Color error = Color(0xFFEF4444);        // Red 500
    static const Color errorContainer = Color(0xFFFEE2E2); // Red 100
    static const Color onError = Color(0xFFFFFFFF);
    static const Color onErrorContainer = Color(0xFFDC2626); // Red 600
  }

  /// Neutral Color Palette
  static class Neutral {
    // Pure whites and blacks
    static const Color white = Color(0xFFFFFFFF);
    static const Color black = Color(0xFF000000);

    // Gray scale (light to dark)
    static const Color gray50 = Color(0xFFFAFAFA);
    static const Color gray100 = Color(0xFFF5F5F5);
    static const Color gray200 = Color(0xFFEEEEEE);
    static const Color gray300 = Color(0xFFE0E0E0);
    static const Color gray400 = Color(0xFFBDBDBD);
    static const Color gray500 = Color(0xFF9E9E9E);
    static const Color gray600 = Color(0xFF757575);
    static const Color gray700 = Color(0xFF616161);
    static const Color gray800 = Color(0xFF424242);
    static const Color gray900 = Color(0xFF212121);

    // Semantic grays for UI
    static const Color surfaceLight = gray50;
    static const Color surfaceMedium = gray100;
    static const Color surfaceDark = gray900;
    static const Color border = gray300;
    static const Color borderSubtle = gray200;
    static const Color textPrimary = gray900;
    static const Color textSecondary = gray600;
    static const Color textTertiary = gray500;
  }

  /// Brand Color Variations
  static class Brand {
    // Spiritual theme variations
    static const List<Color> spiritualBlues = [
      Color(0xFFE3F2FD), // Blue 50
      Color(0xFFBBDEFB), // Blue 100
      Color(0xFF90CAF9), // Blue 200
      Color(0xFF64B5F6), // Blue 300
      Color(0xFF42A5F5), // Blue 400
      Color(0xFF2196F3), // Blue 500
      Color(0xFF1E88E5), // Blue 600
      Color(0xFF1976D2), // Blue 700
      Color(0xFF1565C0), // Blue 800
      Color(0xFF0D47A1), // Blue 900
    ];

    static const List<Color> spiritualAmbers = [
      Color(0xFFFFF8E1), // Amber 50
      Color(0xFFFFECB3), // Amber 100
      Color(0xFFFFE082), // Amber 200
      Color(0xFFFFD54F), // Amber 300
      Color(0xFFFFCA28), // Amber 400
      Color(0xFFFFC107), // Amber 500
      Color(0xFFFFB300), // Amber 600
      Color(0xFFFFA000), // Amber 700
      Color(0xFFFF8F00), // Amber 800
      Color(0xFFFF6F00), // Amber 900
    ];

    // Forest theme variations
    static const List<Color> forestGreens = [
      Color(0xFFE8F5E8), // Green 50
      Color(0xFFC8E6C8), // Green 100
      Color(0xFFA5D6A7), // Green 200
      Color(0xFF81C784), // Green 300
      Color(0xFF66BB6A), // Green 400
      Color(0xFF4CAF50), // Green 500
      Color(0xFF43A047), // Green 600
      Color(0xFF388E3C), // Green 700
      Color(0xFF2E7D32), // Green 800
      Color(0xFF1B5E20), // Green 900
    ];

    // Ocean theme variations
    static const List<Color> oceanBlues = [
      Color(0xFFE1F5FE), // Light Blue 50
      Color(0xFFB3E5FC), // Light Blue 100
      Color(0xFF81D4FA), // Light Blue 200
      Color(0xFF4FC3F7), // Light Blue 300
      Color(0xFF29B6F6), // Light Blue 400
      Color(0xFF03A9F4), // Light Blue 500
      Color(0xFF039BE5), // Light Blue 600
      Color(0xFF0288D1), // Light Blue 700
      Color(0xFF0277BD), // Light Blue 800
      Color(0xFF01579B), // Light Blue 900
    ];
  }

  /// Gradient Definitions
  static class Gradients {
    // Spiritual gradients
    static const LinearGradient spiritualPrimary = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
      stops: [0.0, 1.0],
    );

    static const LinearGradient spiritualSecondary = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
      stops: [0.0, 1.0],
    );

    // Surface gradients for cards
    static const LinearGradient cardLight = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
      stops: [0.0, 1.0],
    );

    static const LinearGradient cardDark = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1E1E1E), Color(0xFF121212)],
      stops: [0.0, 1.0],
    );

    // Overlay gradients
    static const LinearGradient overlayTop = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.center,
      colors: [Color(0xFF000000), Color(0x00000000)],
      stops: [0.0, 1.0],
    );

    static const LinearGradient overlayBottom = LinearGradient(
      begin: Alignment.center,
      end: Alignment.bottomCenter,
      colors: [Color(0x00000000), Color(0xFF000000)],
      stops: [0.0, 1.0],
    );

    // Status gradients
    static const LinearGradient success = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF10B981), Color(0xFF059669)],
      stops: [0.0, 1.0],
    );

    static const LinearGradient warning = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      stops: [0.0, 1.0],
    );

    static const LinearGradient error = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
      stops: [0.0, 1.0],
    );
  }

  /// Shadow Colors
  static class Shadows {
    static Color light = Colors.black.withOpacity(0.1);
    static Color medium = Colors.black.withOpacity(0.15);
    static Color dark = Colors.black.withOpacity(0.25);
    static Color colored = const Color(0xFF1E88E5).withOpacity(0.2);
  }

  /// Alpha Values for Opacity
  static class Alpha {
    static const double disabled = 0.38;
    static const double inactive = 0.6;
    static const double divider = 0.12;
    static const double overlay = 0.16;
    static const double focus = 0.12;
    static const double hover = 0.04;
    static const double pressed = 0.12;
    static const double dragged = 0.16;
  }

  /// Special Purpose Colors
  static class Special {
    // Status indicators
    static const Color online = Color(0xFF10B981);
    static const Color offline = Color(0xFF6B7280);
    static const Color busy = Color(0xFFEF4444);
    static const Color away = Color(0xFFF59E0B);

    // Progress indicators
    static const Color progressBackground = Color(0xFFE5E7EB);
    static const Color progressForeground = Color(0xFF3B82F6);

    // Selection colors
    static const Color selection = Color(0xFF3B82F6);
    static const Color selectionBackground = Color(0xFFDBEAFE);

    // Highlighted text
    static const Color highlight = Color(0xFFFEF3C7);
    static const Color highlightText = Color(0xFF92400E);

    // Link colors
    static const Color link = Color(0xFF3B82F6);
    static const Color linkVisited = Color(0xFF7C3AED);
    static const Color linkHover = Color(0xFF1D4ED8);
  }
}

/// Color utilities
extension ColorExtensions on Color {
  /// Get a lighter shade of the color
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Get a darker shade of the color
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Get complementary color
  Color get complementary {
    final hsl = HSLColor.fromColor(this);
    final hue = (hsl.hue + 180) % 360;
    return hsl.withHue(hue).toColor();
  }

  /// Check if color is light
  bool get isLight {
    final luminance = computeLuminance();
    return luminance > 0.5;
  }

  /// Check if color is dark
  bool get isDark => !isLight;

  /// Get appropriate text color for this background
  Color get onColor => isLight ? Colors.black : Colors.white;
}
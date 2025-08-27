import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Advanced Typography System
/// Optimized for French and Arabic text with premium aesthetics
class AdvancedTypography {
  AdvancedTypography._();

  // Font families
  static const String fontFamilyFR = 'Inter';
  static const List<String> fontFamilyAR = ['NotoNaskhArabic', 'Amiri'];
  static const String fontFamilyDisplay = 'Playfair Display'; // Pour les titres élégants
  static const String fontFamilyMono = 'JetBrains Mono';      // Pour les codes/références

  /// Typography scales based on modern design systems
  static const _TypeScale _displayScale = _TypeScale(
    large: (size: 64, weight: FontWeight.w300, lineHeight: 1.125, spacing: -1.5),
    medium: (size: 48, weight: FontWeight.w300, lineHeight: 1.167, spacing: -1.0),
    small: (size: 40, weight: FontWeight.w400, lineHeight: 1.2, spacing: -0.5),
  );

  static const _TypeScale _headlineScale = _TypeScale(
    large: (size: 32, weight: FontWeight.w600, lineHeight: 1.25, spacing: -0.5),
    medium: (size: 28, weight: FontWeight.w600, lineHeight: 1.286, spacing: -0.25),
    small: (size: 24, weight: FontWeight.w600, lineHeight: 1.333, spacing: 0),
  );

  static const _TypeScale _titleScale = _TypeScale(
    large: (size: 22, weight: FontWeight.w600, lineHeight: 1.364, spacing: 0),
    medium: (size: 18, weight: FontWeight.w600, lineHeight: 1.444, spacing: 0.15),
    small: (size: 16, weight: FontWeight.w600, lineHeight: 1.5, spacing: 0.1),
  );

  static const _TypeScale _bodyScale = _TypeScale(
    large: (size: 16, weight: FontWeight.w400, lineHeight: 1.5, spacing: 0.15),
    medium: (size: 14, weight: FontWeight.w400, lineHeight: 1.429, spacing: 0.25),
    small: (size: 12, weight: FontWeight.w400, lineHeight: 1.333, spacing: 0.4),
  );

  static const _TypeScale _labelScale = _TypeScale(
    large: (size: 14, weight: FontWeight.w500, lineHeight: 1.429, spacing: 0.1),
    medium: (size: 12, weight: FontWeight.w500, lineHeight: 1.333, spacing: 0.5),
    small: (size: 11, weight: FontWeight.w500, lineHeight: 1.273, spacing: 0.5),
  );

  /// Generate advanced text theme with sophisticated styling
  static TextTheme generateTextTheme(ColorScheme colorScheme, Brightness brightness) {
    // Base text color with proper contrast
    final Color onSurface = brightness == Brightness.light 
        ? const Color(0xFF1A1A1A) 
        : const Color(0xFFFFFFFF);
    
    final Color onSurfaceVariant = brightness == Brightness.light
        ? const Color(0xFF666666)
        : const Color(0xFFB3B3B3);

    return TextTheme(
      // Display styles - For hero text and main headlines
      displayLarge: _createTextStyle(_displayScale.large, onSurface, fontFamilyDisplay),
      displayMedium: _createTextStyle(_displayScale.medium, onSurface, fontFamilyDisplay),
      displaySmall: _createTextStyle(_displayScale.small, onSurface, fontFamilyDisplay),

      // Headline styles - For section headers
      headlineLarge: _createTextStyle(_headlineScale.large, onSurface, fontFamilyFR),
      headlineMedium: _createTextStyle(_headlineScale.medium, onSurface, fontFamilyFR),
      headlineSmall: _createTextStyle(_headlineScale.small, onSurface, fontFamilyFR),

      // Title styles - For component titles
      titleLarge: _createTextStyle(_titleScale.large, onSurface, fontFamilyFR),
      titleMedium: _createTextStyle(_titleScale.medium, onSurface, fontFamilyFR),
      titleSmall: _createTextStyle(_titleScale.small, onSurface, fontFamilyFR),

      // Body styles - For main content
      bodyLarge: _createTextStyle(_bodyScale.large, onSurface, fontFamilyFR),
      bodyMedium: _createTextStyle(_bodyScale.medium, onSurface, fontFamilyFR),
      bodySmall: _createTextStyle(_bodyScale.small, onSurfaceVariant, fontFamilyFR),

      // Label styles - For buttons and UI elements
      labelLarge: _createTextStyle(_labelScale.large, onSurface, fontFamilyFR),
      labelMedium: _createTextStyle(_labelScale.medium, onSurface, fontFamilyFR),
      labelSmall: _createTextStyle(_labelScale.small, onSurfaceVariant, fontFamilyFR),
    );
  }

  /// Create text style with advanced properties
  static TextStyle _createTextStyle(
    ({double size, FontWeight weight, double lineHeight, double spacing}) scale,
    Color color,
    String primaryFont,
  ) {
    return TextStyle(
      fontSize: scale.size,
      fontWeight: scale.weight,
      height: scale.lineHeight,
      letterSpacing: scale.spacing,
      color: color,
      fontFamily: primaryFont,
      fontFamilyFallback: primaryFont == fontFamilyFR ? fontFamilyAR : [fontFamilyFR],
      decoration: TextDecoration.none,
      // Improved text rendering
      textBaseline: TextBaseline.alphabetic,
    );
  }

  /// Special text styles for specific use cases
  static class SpecialTextStyles {
    static const TextStyle arabicLarge = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      height: 1.8,
      letterSpacing: 0,
      fontFamily: 'NotoNaskhArabic',
      textBaseline: TextBaseline.alphabetic,
    );

    static const TextStyle arabicMedium = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.7,
      letterSpacing: 0,
      fontFamily: 'NotoNaskhArabic',
      textBaseline: TextBaseline.alphabetic,
    );

    static const TextStyle arabicSmall = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.6,
      letterSpacing: 0,
      fontFamily: 'NotoNaskhArabic',
      textBaseline: TextBaseline.alphabetic,
    );

    static const TextStyle monoCode = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
      letterSpacing: 0.5,
      fontFamily: 'JetBrains Mono',
      textBaseline: TextBaseline.alphabetic,
    );

    static const TextStyle counterDisplay = TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w300,
      height: 1.0,
      letterSpacing: -1.0,
      fontFamily: 'Inter',
      textBaseline: TextBaseline.alphabetic,
    );

    static const TextStyle subtleCaption = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      height: 1.2,
      letterSpacing: 0.5,
      fontFamily: 'Inter',
      textBaseline: TextBaseline.alphabetic,
    );
  }

  /// Text style extensions for better Arabic support
  static extension TextStyleExtensions on TextStyle {
    /// Apply Arabic-specific properties
    TextStyle get arabic => copyWith(
      constraints: BoxConstraints(minHeight: (height ?? 1.0) * 1.2), fontFamily: 'NotoNaskhArabic',
      fontFamilyFallback: ['Amiri', 'Inter'], // Increase line height for Arabic
      letterSpacing: 0, // Reset letter spacing for Arabic
    );

    /// Apply French-specific properties
    TextStyle get french => copyWith(
      fontFamily: 'Inter',
      fontFamilyFallback: const ['NotoNaskhArabic'],
    );

    /// Apply monospace properties
    TextStyle get monospace => copyWith(
      fontFamily: 'JetBrains Mono',
      letterSpacing: 0.5,
    );

    /// Apply display font
    TextStyle get display => copyWith(
      fontFamily: 'Playfair Display',
      fontFamilyFallback: const ['Inter', 'NotoNaskhArabic'],
    );

    /// Subtle opacity for secondary text
    TextStyle get subtle => copyWith(
      color: color?.withOpacity(0.7),
    );

    /// Emphasized weight
    TextStyle get emphasized => copyWith(
      fontWeight: FontWeight.w600,
    );
  }
}

/// Typography scale definition
class _TypeScale {
  final ({double size, FontWeight weight, double lineHeight, double spacing}) large;
  final ({double size, FontWeight weight, double lineHeight, double spacing}) medium;
  final ({double size, FontWeight weight, double lineHeight, double spacing}) small;

  const _TypeScale({
    required this.large,
    required this.medium,
    required this.small,
  });
}
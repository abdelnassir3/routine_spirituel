import 'package:flutter/material.dart';

/// Advanced Shadow System
/// Comprehensive elevation and shadow definitions for premium UI
class AdvancedShadows {
  AdvancedShadows._();

  /// Material 3 Elevation System
  static class Elevation {
    static const double level0 = 0.0;
    static const double level1 = 1.0;
    static const double level2 = 3.0;
    static const double level3 = 6.0;
    static const double level4 = 8.0;
    static const double level5 = 12.0;
  }

  /// Premium Shadow Definitions
  /// Based on modern design systems with subtle, realistic shadows
  static class Shadows {
    // Soft shadows for cards and containers
    static const List<BoxShadow> soft = [
      BoxShadow(
        color: Color(0x0F000000), // 6% opacity
        offset: Offset(0, 1),
        blurRadius: 2,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color(0x0A000000), // 4% opacity
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: -1,
      ),
    ];

    // Medium shadows for elevated cards
    static const List<BoxShadow> medium = [
      BoxShadow(
        color: Color(0x14000000), // 8% opacity
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color(0x0F000000), // 6% opacity
        offset: Offset(0, 4),
        blurRadius: 8,
        spreadRadius: -2,
      ),
    ];

    // Strong shadows for modals and overlays
    static const List<BoxShadow> strong = [
      BoxShadow(
        color: Color(0x1F000000), // 12% opacity
        offset: Offset(0, 4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color(0x14000000), // 8% opacity
        offset: Offset(0, 8),
        blurRadius: 16,
        spreadRadius: -4,
      ),
    ];

    // Premium shadows for FABs and buttons
    static const List<BoxShadow> button = [
      BoxShadow(
        color: Color(0x14000000), // 8% opacity
        offset: Offset(0, 1),
        blurRadius: 2,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color(0x0A000000), // 4% opacity
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: -1,
      ),
    ];

    // Pressed state shadows
    static const List<BoxShadow> pressed = [
      BoxShadow(
        color: Color(0x1F000000), // 12% opacity
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: 0,
      ),
    ];

    // Colored shadows for brand elements
    static List<BoxShadow> colored(Color color, {double opacity = 0.3}) => [
      BoxShadow(
        color: color.withOpacity(opacity * 0.6),
        offset: const Offset(0, 2),
        blurRadius: 8,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: color.withOpacity(opacity * 0.4),
        offset: const Offset(0, 4),
        blurRadius: 16,
        spreadRadius: -2,
      ),
    ];

    // Glow effects for focus states
    static List<BoxShadow> glow(Color color, {double opacity = 0.5}) => [
      BoxShadow(
        color: color.withOpacity(opacity),
        offset: Offset.zero,
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ];

    // Inner shadows (using inset property in custom widgets)
    static const List<BoxShadow> inner = [
      BoxShadow(
        color: Color(0x0F000000), // 6% opacity
        offset: Offset(0, 1),
        blurRadius: 2,
        spreadRadius: 0,
      ),
    ];
  }

  /// Semantic Shadow Assignments
  static class Semantic {
    // Component-specific shadows
    static const List<BoxShadow> card = Shadows.soft;
    static const List<BoxShadow> cardElevated = Shadows.medium;
    static const List<BoxShadow> modal = Shadows.strong;
    static const List<BoxShadow> fab = Shadows.button;
    static const List<BoxShadow> button = Shadows.button;
    static const List<BoxShadow> buttonPressed = Shadows.pressed;
    static const List<BoxShadow> appBar = Shadows.soft;
    static const List<BoxShadow> bottomSheet = Shadows.strong;
    static const List<BoxShadow> dialog = Shadows.strong;
    static const List<BoxShadow> snackBar = Shadows.medium;
    
    // Special effects
    static List<BoxShadow> focus(Color primaryColor) => Shadows.glow(primaryColor, opacity: 0.3);
    static List<BoxShadow> success = Shadows.colored(const Color(0xFF10B981));
    static List<BoxShadow> warning = Shadows.colored(const Color(0xFFF59E0B));
    static List<BoxShadow> error = Shadows.colored(const Color(0xFFEF4444));
  }

  /// Material 3 Elevation Mapping
  static List<BoxShadow> fromElevation(double elevation) {
    switch (elevation) {
      case 0:
        return [];
      case 1:
        return Shadows.soft;
      case 3:
        return Shadows.medium;
      case 6:
      case 8:
        return Shadows.strong;
      default:
        return Shadows.medium;
    }
  }

  /// Dark Mode Shadow Adjustments
  static class DarkMode {
    // Reduced shadows for dark themes
    static const List<BoxShadow> soft = [
      BoxShadow(
        color: Color(0x14000000), // 8% opacity
        offset: Offset(0, 1),
        blurRadius: 3,
        spreadRadius: 0,
      ),
    ];

    static const List<BoxShadow> medium = [
      BoxShadow(
        color: Color(0x1F000000), // 12% opacity
        offset: Offset(0, 2),
        blurRadius: 6,
        spreadRadius: 0,
      ),
    ];

    static const List<BoxShadow> strong = [
      BoxShadow(
        color: Color(0x29000000), // 16% opacity
        offset: Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ];

    // Glowing effects for dark mode
    static List<BoxShadow> glow(Color color, {double opacity = 0.4}) => [
      BoxShadow(
        color: color.withOpacity(opacity),
        offset: Offset.zero,
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ];
  }
}

/// Shadow extensions for easy usage
extension BoxShadowExtensions on List<BoxShadow> {
  /// Convert shadows to dark mode variants
  List<BoxShadow> get darkMode {
    return map((shadow) => BoxShadow(
      color: shadow.color.withOpacity(shadow.color.opacity * 0.7),
      offset: shadow.offset,
      blurRadius: shadow.blurRadius * 0.8,
      spreadRadius: shadow.spreadRadius,
    )).toList();
  }

  /// Add colored tint to shadows
  List<BoxShadow> withColor(Color color, {double opacity = 0.3}) {
    return [
      ...this,
      BoxShadow(
        color: color.withOpacity(opacity),
        offset: const Offset(0, 2),
        blurRadius: 8,
        spreadRadius: -2,
      ),
    ];
  }
}

/// Shadow utilities
class ShadowUtils {
  /// Create custom shadow with specific parameters
  static List<BoxShadow> custom({
    required Color color,
    required double blur,
    Offset offset = Offset.zero,
    double spread = 0,
    double opacity = 1.0,
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        offset: offset,
        blurRadius: blur,
        spreadRadius: spread,
      ),
    ];
  }

  /// Create layered shadows for depth
  static List<BoxShadow> layered({
    required Color color,
    int layers = 2,
    double baseOpacity = 0.1,
    double baseBlur = 2,
  }) {
    return List.generate(layers, (index) {
      final multiplier = (index + 1).toDouble();
      return BoxShadow(
        color: color.withOpacity(baseOpacity / multiplier),
        offset: Offset(0, multiplier),
        blurRadius: baseBlur * multiplier,
        spreadRadius: 0,
      );
    });
  }

  /// Create animated shadow for transitions
  static List<BoxShadow> lerp(
    List<BoxShadow> a,
    List<BoxShadow> b,
    double t,
  ) {
    if (a.isEmpty && b.isEmpty) return [];
    if (a.isEmpty) return b.map((s) => s.scale(t)).toList();
    if (b.isEmpty) return a.map((s) => s.scale(1 - t)).toList();

    final length = a.length > b.length ? a.length : b.length;
    return List.generate(length, (index) {
      final shadowA = index < a.length ? a[index] : a.last;
      final shadowB = index < b.length ? b[index] : b.last;
      return BoxShadow.lerp(shadowA, shadowB, t) ?? shadowA;
    });
  }
}
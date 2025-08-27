import 'package:flutter/material.dart';

/// Material 3 Spacing Tokens
/// Based on 4pt grid system for consistency
class Spacing {
  // Base unit: 4dp
  static const double unit = 4.0;
  
  // Spacing scale
  static const double none = 0;
  static const double xxs = unit * 0.5;  // 2dp
  static const double xs = unit;         // 4dp
  static const double sm = unit * 2;     // 8dp
  static const double md = unit * 3;     // 12dp
  static const double lg = unit * 4;     // 16dp
  static const double xl = unit * 5;     // 20dp
  static const double xxl = unit * 6;    // 24dp
  static const double xxxl = unit * 8;   // 32dp
  static const double xxxxl = unit * 10; // 40dp
  
  // Component-specific spacing
  static const double cardPadding = lg;
  static const double pagePadding = lg;
  static const double listItemGap = sm;
  static const double sectionGap = xxl;
  static const double buttonGap = md;
  
  // Touch targets (minimum 48dp for accessibility)
  static const double minTouchTarget = 48.0;
  static const double minTouchTargetHeight = 48.0;
  static const double minTouchTargetWidth = 64.0;
}

/// Corner Radius Tokens (Material 3)
class Corners {
  static const double none = 0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;
  static const double full = 999.0; // Stadium/Pill shape
  
  // Component-specific radii
  static const double button = md;
  static const double card = lg;
  static const double dialog = xxl;
  static const double chip = sm;
  static const double textField = md;
  static const double fab = lg;
}

/// Elevation Tokens (Material 3)
class Elevations {
  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 3;
  static const double level3 = 6;
  static const double level4 = 8;
  static const double level5 = 12;
}

/// Animation Durations (Material Motion)
class AnimDurations {
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration slower = Duration(milliseconds: 450);
  static const Duration verySlow = Duration(milliseconds: 550);
}

/// Animation Curves (Material 3)
class Curves2 {
  static const standard = Curves.easeInOutCubic;
  static const emphasized = Curves.easeInOutCubicEmphasized;
  static const decelerated = Curves.decelerate;
  static const accelerated = Curves.easeOutCubic;
}
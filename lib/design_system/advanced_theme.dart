import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/design_system/tokens/spacing.dart';
import 'package:spiritual_routines/design_system/tokens/colors.dart';
import 'package:spiritual_routines/design_system/tokens/typography.dart';
import 'package:spiritual_routines/design_system/tokens/shadows.dart';

/// Advanced Design System for Spiritual Routines App
/// Inspired by modern To-Do app designs with premium aesthetics
class AdvancedAppTheme {
  AdvancedAppTheme._();

  /// Premium color palettes inspired by modern productivity apps
  static const Map<String, PremiumPalette> _premiumThemes = {
    'zen': PremiumPalette(
      id: 'zen',
      name: 'Zen Minimal',
      description: 'Minimalisme épuré avec accents dorés',
      primary: Color(0xFF1A1A1A), // Rich Black
      primaryVariant: Color(0xFF2D2D2D), // Soft Black
      secondary: Color(0xFFD4AF37), // Refined Gold
      secondaryVariant: Color(0xFFF4E4B8), // Soft Gold
      surface: Color(0xFFFAFAFA), // Pure White
      surfaceVariant: Color(0xFFF5F5F5), // Off White
      background: Color(0xFFFFFFFF), // White
      accent: Color(0xFF6B73FF), // Soft Purple
      gradient: [Color(0xFFFAFAFA), Color(0xFFF0F0F0)],
    ),
    'forest': PremiumPalette(
      id: 'forest',
      name: 'Forest Serenity',
      description: 'Vert naturel avec tons terreux',
      primary: Color(0xFF0D5D2E), // Deep Forest
      primaryVariant: Color(0xFF1B7A3A), // Forest Green
      secondary: Color(0xFFE8B87D), // Warm Sand
      secondaryVariant: Color(0xFFF5E6D3), // Light Sand
      surface: Color(0xFFF8FBF6), // Soft Green White
      surfaceVariant: Color(0xFFF0F7EC), // Light Green
      background: Color(0xFFFFFFFF), // White
      accent: Color(0xFF7C4DFF), // Purple Accent
      gradient: [Color(0xFFF8FBF6), Color(0xFFEAF4E5)],
    ),
    'ocean': PremiumPalette(
      id: 'ocean',
      name: 'Ocean Depth',
      description: 'Bleu profond avec nuances marines',
      primary: Color(0xFF0D47A1), // Deep Ocean
      primaryVariant: Color(0xFF1565C0), // Ocean Blue
      secondary: Color(0xFF81D4FA), // Sky Blue
      secondaryVariant: Color(0xFFE1F5FE), // Light Sky
      surface: Color(0xFFF3F8FB), // Ocean White
      surfaceVariant: Color(0xFFE8F1F7), // Light Ocean
      background: Color(0xFFFFFFFF), // White
      accent: Color(0xFFFF6B35), // Coral Accent
      gradient: [Color(0xFFF3F8FB), Color(0xFFE3F2FD)],
    ),
    'sunset': PremiumPalette(
      id: 'sunset',
      name: 'Sunset Glow',
      description: 'Coucher de soleil chaleureux',
      primary: Color(0xFF8E24AA), // Deep Purple
      primaryVariant: Color(0xFFAB47BC), // Purple
      secondary: Color(0xFFFFB74D), // Warm Orange
      secondaryVariant: Color(0xFFFFF3E0), // Light Orange
      surface: Color(0xFFFDF8F5), // Warm White
      surfaceVariant: Color(0xFFF9F2EE), // Light Warm
      background: Color(0xFFFFFFFF), // White
      accent: Color(0xFF29B6F6), // Sky Blue Accent
      gradient: [Color(0xFFFDF8F5), Color(0xFFF3E5F5)],
    ),
  };

  /// Generate sophisticated Material 3 theme
  static ThemeData buildPremiumTheme(
    Brightness brightness, {
    String? themeId,
    bool useAdvancedAnimations = true,
  }) {
    final palette = _premiumThemes[themeId ?? 'zen'] ?? _premiumThemes['zen']!;
    final colorScheme = _generateAdvancedColorScheme(brightness, palette);
    final textTheme =
        AdvancedTypography.generateTextTheme(colorScheme, brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // Advanced visual density
      visualDensity: VisualDensity.comfortable,

      // Premium AppBar with gradient background
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: colorScheme.surface,
              )
            : SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: colorScheme.surface,
              ),
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: 24,
        ),
      ),

      // Premium Cards with subtle shadows
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: brightness == Brightness.light
            ? Colors.black.withOpacity(0.05)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: brightness == Brightness.light
            ? colorScheme.surface
            : colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),

      // Premium Buttons with sophisticated styling
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(120, 52),
          maximumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.primary.withOpacity(0.08);
            }
            if (states.contains(WidgetState.hovered)) {
              return colorScheme.primary.withOpacity(0.04);
            }
            return null;
          }),
        ),
      ),

      // Note: Tonal FilledButtons will adopt defaults from Material using colorScheme;
      // we avoid redefining a second filledButtonTheme to prevent overrides.

      // Refined Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          minimumSize: const Size(100, 48),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.5),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: colorScheme.onSurface,
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Modern Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          minimumSize: const Size(80, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Premium Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? colorScheme.surfaceContainer.withOpacity(0.3)
            : colorScheme.surfaceContainer,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
      ),

      // Sophisticated Choice Chips
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.transparent,
        selectedColor: colorScheme.secondaryContainer,
        shadowColor: Colors.transparent,
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.4),
          width: 1,
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        checkmarkColor: colorScheme.onSecondaryContainer,
      ),

      // Modern List Tiles
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: colorScheme.secondaryContainer.withOpacity(0.3),
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        titleTextStyle: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        minLeadingWidth: 32,
      ),

      // Premium FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        largeSizeConstraints:
            const BoxConstraints.tightFor(width: 64, height: 64),
        extendedSizeConstraints: const BoxConstraints.tightFor(height: 56),
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // Modern Dialogs
      dialogTheme: DialogThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
      ),

      // Premium Bottom Sheets
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),

      // Elegant Snackbars
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.inversePrimary,
      ),

      // Modern Navigation
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: brightness == Brightness.light
            ? colorScheme.surface.withOpacity(0.95)
            : colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: colorScheme.onSecondaryContainer,
              size: 24,
            );
          }
          return IconThemeData(
            color: colorScheme.onSurfaceVariant,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
          );
        }),
      ),

      // Premium dividers
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withOpacity(0.5),
        thickness: 0.5,
        space: 1,
      ),

      // Smooth page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Generate sophisticated color scheme
  static ColorScheme _generateAdvancedColorScheme(
    Brightness brightness,
    PremiumPalette palette,
  ) {
    if (brightness == Brightness.light) {
      return ColorScheme.light(
        primary: palette.primary,
        onPrimary: Colors.white,
        primaryContainer: palette.primaryVariant.withOpacity(0.1),
        onPrimaryContainer: palette.primary,
        secondary: palette.secondary,
        onSecondary: palette.primary,
        secondaryContainer: palette.secondaryVariant,
        onSecondaryContainer: palette.primary,
        tertiary: palette.accent,
        onTertiary: Colors.white,
        tertiaryContainer: palette.accent.withOpacity(0.1),
        onTertiaryContainer: palette.accent,
        error: const Color(0xFFD32F2F),
        onError: Colors.white,
        errorContainer: const Color(0xFFFFEBEE),
        onErrorContainer: const Color(0xFFD32F2F),
        surface: palette.surface,
        onSurface: palette.primary,
        surfaceContainer: palette.surfaceVariant,
        onSurfaceVariant: palette.primary.withOpacity(0.7),
        outline: palette.primary.withOpacity(0.2),
        outlineVariant: palette.primary.withOpacity(0.1),
        inverseSurface: palette.primary,
        onInverseSurface: palette.surface,
        inversePrimary: palette.secondary,
        shadow: Colors.black.withOpacity(0.1),
        scrim: Colors.black.withOpacity(0.5),
        surfaceTint: palette.primary.withOpacity(0.05),
      );
    } else {
      return ColorScheme.dark(
        primary: palette.secondary,
        onPrimary: palette.primary,
        primaryContainer: palette.primary.withOpacity(0.2),
        onPrimaryContainer: palette.secondary,
        secondary: palette.accent,
        onSecondary: palette.primary,
        secondaryContainer: palette.primary.withOpacity(0.15),
        onSecondaryContainer: palette.secondary,
        tertiary: palette.secondaryVariant,
        onTertiary: palette.primary,
        tertiaryContainer: palette.primary.withOpacity(0.1),
        onTertiaryContainer: palette.secondaryVariant,
        error: const Color(0xFFEF5350),
        onError: const Color(0xFF1A1A1A),
        errorContainer: const Color(0xFF4E1111),
        onErrorContainer: const Color(0xFFEF5350),
        surface: const Color(0xFF121212),
        onSurface: Colors.white,
        surfaceContainer: const Color(0xFF1E1E1E),
        onSurfaceVariant: Colors.white.withOpacity(0.7),
        outline: Colors.white.withOpacity(0.2),
        outlineVariant: Colors.white.withOpacity(0.1),
        inverseSurface: Colors.white,
        onInverseSurface: const Color(0xFF121212),
        inversePrimary: palette.primary,
        shadow: Colors.black.withOpacity(0.3),
        scrim: Colors.black.withOpacity(0.7),
        surfaceTint: palette.secondary.withOpacity(0.05),
      );
    }
  }

  /// Available premium themes
  static Map<String, PremiumPalette> get availableThemes => _premiumThemes;

  /// Default theme
  static const String defaultThemeId = 'zen';

  /// Quick access to light theme
  static ThemeData get light => buildPremiumTheme(Brightness.light);

  /// Quick access to dark theme
  static ThemeData get dark => buildPremiumTheme(Brightness.dark);

  /// Theme with specific palette
  static ThemeData lightWithTheme(String themeId) =>
      buildPremiumTheme(Brightness.light, themeId: themeId);
  static ThemeData darkWithTheme(String themeId) =>
      buildPremiumTheme(Brightness.dark, themeId: themeId);
}

/// Premium color palette
class PremiumPalette {
  final String id;
  final String name;
  final String description;
  final Color primary;
  final Color primaryVariant;
  final Color secondary;
  final Color secondaryVariant;
  final Color surface;
  final Color surfaceVariant;
  final Color background;
  final Color accent;
  final List<Color> gradient;

  const PremiumPalette({
    required this.id,
    required this.name,
    required this.description,
    required this.primary,
    required this.primaryVariant,
    required this.secondary,
    required this.secondaryVariant,
    required this.surface,
    required this.surfaceVariant,
    required this.background,
    required this.accent,
    required this.gradient,
  });
}

/// Providers for advanced theme system
final advancedThemeIdProvider =
    StateProvider<String>((ref) => AdvancedAppTheme.defaultThemeId);

final advancedAppThemeProvider = Provider<AdvancedAppThemeData>((ref) {
  final themeId = ref.watch(advancedThemeIdProvider);
  return AdvancedAppThemeData(
    light: AdvancedAppTheme.lightWithTheme(themeId),
    dark: AdvancedAppTheme.darkWithTheme(themeId),
    palette: AdvancedAppTheme.availableThemes[themeId]!,
  );
});

/// Advanced theme data container
class AdvancedAppThemeData {
  final ThemeData light;
  final ThemeData dark;
  final PremiumPalette palette;

  const AdvancedAppThemeData({
    required this.light,
    required this.dark,
    required this.palette,
  });
}

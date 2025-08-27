import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/design_system/tokens/spacing.dart';

/// Theme palette definition
class AppThemePalette {
  final String id;
  final String name;
  final String description;
  final Color primarySeed;
  final Color secondarySeed;

  const AppThemePalette({
    required this.id,
    required this.name,
    required this.description,
    required this.primarySeed,
    required this.secondarySeed,
  });
}

/// Material 3 Design System Theme
/// Supports Light/Dark modes, RTL/LTR, and responsive design
class AppTheme {
  // Private constructor
  AppTheme._();

  /// Available theme palettes
  static const Map<String, AppThemePalette> _availableThemes = {
    'spiritual': AppThemePalette(
      id: 'spiritual',
      name: 'Spirituel',
      description: 'Bleu apaisant et ambre chaleureux',
      primarySeed: Color(0xFF1E88E5), // Blue 600
      secondarySeed: Color(0xFFFFA726), // Amber 400
    ),
    'elegant': AppThemePalette(
      id: 'elegant',
      name: 'Élégant',
      description: 'Violet profond et corail moderne',
      primarySeed: Color(0xFF5E35B1), // Deep Purple 600
      secondarySeed: Color(0xFFFF7043), // Deep Orange 400
    ),
    'nature': AppThemePalette(
      id: 'nature',
      name: 'Nature',
      description: 'Vert forêt et terre naturelle',
      primarySeed: Color(0xFF2E7D32), // Green 700
      secondarySeed: Color(0xFF8D6E63), // Brown 400
    ),
    'ocean': AppThemePalette(
      id: 'ocean',
      name: 'Océan',
      description: 'Bleu océan et turquoise',
      primarySeed: Color(0xFF0277BD), // Light Blue 800
      secondarySeed: Color(0xFF26C6DA), // Cyan 400
    ),
  };

  /// Get available themes
  static Map<String, AppThemePalette> get availableThemes => _availableThemes;

  /// Default theme ID
  static const String defaultThemeId = 'spiritual';

  /// Generate Material 3 ColorScheme from palette
  static ColorScheme _generateColorScheme(
    Brightness brightness,
    AppThemePalette palette,
  ) {
    // Generate base scheme from primary seed
    final baseScheme = ColorScheme.fromSeed(
      seedColor: palette.primarySeed,
      brightness: brightness,
    );

    // Generate secondary scheme for accent colors
    final secondaryScheme = ColorScheme.fromSeed(
      seedColor: palette.secondarySeed,
      brightness: brightness,
    );

    // Harmonize the schemes and ensure proper contrast
    final scheme = baseScheme.copyWith(
      secondary: secondaryScheme.secondary,
      onSecondary: secondaryScheme.onSecondary,
      secondaryContainer: secondaryScheme.secondaryContainer,
      onSecondaryContainer: secondaryScheme.onSecondaryContainer,
      tertiary: secondaryScheme.tertiary,
      onTertiary: secondaryScheme.onTertiary,
      tertiaryContainer: secondaryScheme.tertiaryContainer,
      onTertiaryContainer: secondaryScheme.onTertiaryContainer,
    );

    // Ensure proper text contrast for light mode
    if (brightness == Brightness.light) {
      return scheme.copyWith(
        onSurface: const Color(0xFF1C1B1F),
        onSurfaceVariant: const Color(0xFF49454F),
      );
    }

    return scheme;
  }

  /// Material 3 Typography with FR/AR support
  static TextTheme _generateTextTheme(ColorScheme colorScheme) {
    const String fontFamilyFR = 'Inter';
    const List<String> fontFamilyAR = ['NotoNaskhArabic'];

    // Base text style with proper font fallbacks
    TextStyle baseStyle(double size, FontWeight weight, double height) {
      return TextStyle(
        fontSize: size,
        fontWeight: weight,
        height: height,
        fontFamily: fontFamilyFR,
        fontFamilyFallback: fontFamilyAR,
        letterSpacing: 0,
      );
    }

    return TextTheme(
      // Display styles - largest text
      displayLarge: baseStyle(57, FontWeight.w400, 1.12),
      displayMedium: baseStyle(45, FontWeight.w400, 1.16),
      displaySmall: baseStyle(36, FontWeight.w400, 1.22),

      // Headline styles - section headers
      headlineLarge: baseStyle(32, FontWeight.w400, 1.25),
      headlineMedium: baseStyle(28, FontWeight.w400, 1.29),
      headlineSmall: baseStyle(24, FontWeight.w400, 1.33),

      // Title styles - component headers
      titleLarge: baseStyle(22, FontWeight.w500, 1.27),
      titleMedium: baseStyle(16, FontWeight.w500, 1.50),
      titleSmall: baseStyle(14, FontWeight.w500, 1.43),

      // Body styles - main content
      bodyLarge: baseStyle(16, FontWeight.w400, 1.50),
      bodyMedium: baseStyle(14, FontWeight.w400, 1.43),
      bodySmall: baseStyle(12, FontWeight.w400, 1.33),

      // Label styles - buttons and chips
      labelLarge: baseStyle(14, FontWeight.w500, 1.43),
      labelMedium: baseStyle(12, FontWeight.w500, 1.33),
      labelSmall: baseStyle(11, FontWeight.w500, 1.45),
    );
  }

  /// Build complete Material 3 theme with specific palette
  static ThemeData buildTheme(
    Brightness brightness, {
    String? themeId,
  }) {
    final palette = _availableThemes[themeId ?? defaultThemeId] ??
        _availableThemes[defaultThemeId]!;
    final colorScheme = _generateColorScheme(brightness, palette);
    final textTheme = _generateTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: brightness == Brightness.light
            ? colorScheme.onSurface
            : colorScheme.onSurface,
        displayColor: brightness == Brightness.light
            ? colorScheme.onSurface
            : colorScheme.onSurface,
      ),

      // Platform adaptations
      // Use platform defaults; keep adaptive density only
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // System UI overlays
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      // Navigation components
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onSecondaryContainer);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        selectedIconTheme:
            IconThemeData(color: colorScheme.onSecondaryContainer),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Cards with Material 3 styling
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.card),
        ),
        color: brightness == Brightness.light
            ? colorScheme.surfaceContainerLow
            : colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),

      // Elevated Cards
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xxl,
            vertical: Spacing.md,
          ),
          minimumSize:
              const Size(Spacing.minTouchTargetWidth, Spacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.button),
          ),
        ),
      ),

      // Filled Buttons (Primary CTA)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xxl,
            vertical: Spacing.md,
          ),
          minimumSize:
              const Size(Spacing.minTouchTargetWidth, Spacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.button),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Tonal Buttons (Secondary actions)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.sm,
          ),
          minimumSize:
              const Size(Spacing.minTouchTargetWidth, Spacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.button),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xxl,
            vertical: Spacing.md,
          ),
          minimumSize:
              const Size(Spacing.minTouchTargetWidth, Spacing.minTouchTarget),
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.button),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Segmented Buttons (replaces TabBar)
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: Spacing.lg),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Corners.button),
            ),
          ),
          textStyle: WidgetStateProperty.all(textTheme.labelLarge),
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        labelPadding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.chip),
          side: BorderSide(color: colorScheme.outline),
        ),
        labelStyle: textTheme.labelLarge?.copyWith(
          color: brightness == Brightness.light
              ? colorScheme.onSurfaceVariant
              : colorScheme.onSurfaceVariant,
        ),
        backgroundColor: colorScheme.surface,
        selectedColor: colorScheme.secondaryContainer,
        checkmarkColor: colorScheme.onSecondaryContainer,
        deleteIconColor: colorScheme.onSurfaceVariant,
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BorderSide(color: colorScheme.primary);
          }
          return BorderSide(color: colorScheme.outline);
        }),
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
            : colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Corners.textField),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Corners.textField),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Corners.textField),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Corners.textField),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Corners.textField),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: textTheme.bodyLarge?.copyWith(
          color: brightness == Brightness.light
              ? colorScheme.onSurfaceVariant
              : colorScheme.onSurfaceVariant,
        ),
        floatingLabelStyle: textTheme.bodyLarge?.copyWith(
          color: brightness == Brightness.light
              ? colorScheme.primary
              : colorScheme.primary,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: brightness == Brightness.light
              ? colorScheme.onSurfaceVariant.withOpacity(0.6)
              : colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
        helperStyle: textTheme.bodySmall?.copyWith(
          color: brightness == Brightness.light
              ? colorScheme.onSurfaceVariant
              : colorScheme.onSurfaceVariant,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.error,
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        elevation: Elevations.level3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.dialog),
        ),
        backgroundColor: colorScheme.surfaceContainerHigh,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Bottom Sheets
      bottomSheetTheme: BottomSheetThemeData(
        elevation: Elevations.level1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Corners.dialog),
          ),
        ),
        backgroundColor: colorScheme.surfaceContainerLow,
        modalElevation: Elevations.level1,
        modalBackgroundColor: colorScheme.surfaceContainerLow,
      ),

      // Snackbars
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.sm),
        ),
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.inversePrimary,
      ),

      // ListTiles
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodyMedium,
        leadingAndTrailingTextStyle: textTheme.labelMedium,
        minLeadingWidth: Spacing.xxl,
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: Elevations.level3,
        highlightElevation: Elevations.level4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.fab),
        ),
        largeSizeConstraints: const BoxConstraints.tightFor(
          width: 96,
          height: 96,
        ),
        extendedSizeConstraints: const BoxConstraints.tightFor(
          height: 56,
        ),
        extendedTextStyle: textTheme.labelLarge,
      ),

      // Progress Indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: Spacing.lg,
      ),

      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Convenience getters for default theme
  static ThemeData get light => buildTheme(Brightness.light);
  static ThemeData get dark => buildTheme(Brightness.dark);

  // Theme builders with palette selection
  static ThemeData lightWithTheme(String themeId) =>
      buildTheme(Brightness.light, themeId: themeId);
  static ThemeData darkWithTheme(String themeId) =>
      buildTheme(Brightness.dark, themeId: themeId);
}

/// Provider for current theme selection
final currentThemeIdProvider =
    StateProvider<String>((ref) => AppTheme.defaultThemeId);

/// Provider to initialize theme from persistence on app start
final themeInitializationProvider = FutureProvider<void>((ref) async {
  // This will be called from main.dart to initialize the theme
});

/// Provider for the app theme based on current selection
// Renamed to avoid confusion with other theme providers; use InspiredTheme in app
final designSystemThemeProvider = Provider<AppThemeData>((ref) {
  final themeId = ref.watch(currentThemeIdProvider);
  return AppThemeData(
    light: AppTheme.lightWithTheme(themeId),
    dark: AppTheme.darkWithTheme(themeId),
    palette: AppTheme.availableThemes[themeId]!,
  );
});

/// Container for light and dark themes
class AppThemeData {
  final ThemeData light;
  final ThemeData dark;
  final AppThemePalette palette;

  const AppThemeData({
    required this.light,
    required this.dark,
    required this.palette,
  });
}

import 'package:flutter/material.dart';

/// Widget responsive pour adapter l'interface selon la taille de l'écran
/// Supporte les appareils pliables Samsung Fold/Flip et tous les formats Android
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? foldable;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.foldable,
  });

  // Breakpoints adaptés pour Android et appareils pliables
  static bool isCompactPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isFoldable(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final aspectRatio = width / height;

    // Détection des appareils pliables (aspect ratio inhabituel)
    // Fold ouvert: ~7:6, Flip ouvert: ~22:9
    return (width >= 585 && width < 800 && aspectRatio > 0.9) || // Fold
        (aspectRatio > 2.0); // Flip ou écran ultra-wide
  }

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // Priorité aux appareils pliables
    if (isFoldable(context) && foldable != null) {
      return foldable!;
    } else if (size.width >= 1200 && desktop != null) {
      return desktop!;
    } else if (size.width >= 600 && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

/// Classe utilitaire pour les dimensions responsives
/// Optimisé pour Android, tablettes et appareils pliables
class ResponsiveUtils {
  static double getMaxWidth(BuildContext context, {double maxWidth = 800}) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Adapter la largeur max selon le type d'appareil
    if (ResponsiveLayout.isFoldable(context)) {
      return screenWidth * 0.9; // Utiliser plus d'espace sur les pliables
    }
    return screenWidth > maxWidth ? maxWidth : screenWidth;
  }

  static EdgeInsets getPadding(BuildContext context) {
    if (ResponsiveLayout.isCompactPhone(context)) {
      return const EdgeInsets.all(12.0);
    } else if (ResponsiveLayout.isFoldable(context)) {
      return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);
    } else if (ResponsiveLayout.isDesktop(context)) {
      return const EdgeInsets.all(24.0);
    } else if (ResponsiveLayout.isTablet(context)) {
      return const EdgeInsets.all(20.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  static int getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Calcul dynamique basé sur la largeur
    if (width < 360) return 1; // Très petit écran
    if (width < 600) return 2; // Mobile standard
    if (width < 840) return 3; // Tablette petite/Fold
    if (width < 1200) return 4; // Grande tablette
    return 5; // Desktop/TV
  }

  static double getFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;

    // Adaptation progressive de la taille de police
    if (width < 360) {
      return baseSize * 0.9; // Réduire pour petits écrans
    } else if (ResponsiveLayout.isFoldable(context)) {
      return baseSize * 1.05; // Légèrement plus grand pour les pliables
    } else if (ResponsiveLayout.isTablet(context)) {
      return baseSize * 1.1;
    } else if (ResponsiveLayout.isDesktop(context)) {
      return baseSize * 1.2;
    }
    return baseSize;
  }

  // Nouvelle méthode pour l'espacement adaptatif
  static double getSpacing(BuildContext context) {
    if (ResponsiveLayout.isCompactPhone(context)) return 8.0;
    if (ResponsiveLayout.isMobile(context)) return 12.0;
    if (ResponsiveLayout.isTablet(context)) return 16.0;
    return 20.0;
  }

  // Ratio d'aspect pour les cartes
  static double getCardAspectRatio(BuildContext context) {
    if (ResponsiveLayout.isFoldable(context)) {
      final width = MediaQuery.of(context).size.width;
      final height = MediaQuery.of(context).size.height;
      final aspectRatio = width / height;

      // Adapter selon l'orientation du pliable
      if (aspectRatio > 1.5) {
        return 2.0; // Mode paysage/Flip ouvert
      }
      return 1.3; // Fold ouvert
    }
    if (ResponsiveLayout.isTablet(context)) return 1.5;
    if (ResponsiveLayout.isDesktop(context)) return 1.6;
    return 1.2; // Mobile
  }
}

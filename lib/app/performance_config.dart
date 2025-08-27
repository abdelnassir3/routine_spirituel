import 'package:flutter/material.dart';

/// Configuration des performances et optimisations
class PerformanceConfig {
  // Désactiver les logs DEBUG en production
  static const bool enableDebugLogs = false;

  // Configuration des transitions
  static const Duration pageTransitionDuration = Duration(milliseconds: 250);
  static const Curve pageTransitionCurve = Curves.easeInOutCubic;

  // Cache pour éviter les recalculs
  static const bool enableContentCache = true;
  static const Duration cacheExpiration = Duration(minutes: 5);

  // Optimisations des animations
  static const bool enableHeroAnimations = true;
  static const bool enableSmoothScrolling = true;

  // Transitions de pages personnalisées
  static Route<T> createRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: pageTransitionDuration,
      reverseTransitionDuration: pageTransitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Animation fluide avec fade et slide
        const begin = Offset(0.0, 0.02);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        final fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  // Méthode pour logger uniquement en debug
  static void debugLog(String message) {
    if (enableDebugLogs) {
      print(message);
    }
  }
}

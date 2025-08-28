import 'package:flutter/material.dart';

/// Widget qui adapte son affichage pour les appareils pliables
/// Détecte automatiquement les changements de configuration
class FoldableAwareWidget extends StatefulWidget {
  final Widget Function(BuildContext, bool isFolded) builder;
  final Widget? foldedChild;
  final Widget? unfoldedChild;

  const FoldableAwareWidget({
    super.key,
    required this.builder,
    this.foldedChild,
    this.unfoldedChild,
  });

  @override
  State<FoldableAwareWidget> createState() => _FoldableAwareWidgetState();
}

class _FoldableAwareWidgetState extends State<FoldableAwareWidget>
    with WidgetsBindingObserver {
  bool _isFolded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkFoldState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _checkFoldState();
  }

  void _checkFoldState() {
    final size = MediaQuery.of(context).size;
    final aspectRatio = size.width / size.height;

    // Heuristique pour détecter l'état plié/déplié
    // Fold fermé: ~21:9 (aspect ratio ~2.33)
    // Fold ouvert: ~6:5 (aspect ratio ~1.2)
    // Flip fermé: normal phone
    // Flip ouvert: ~22:9 (aspect ratio ~2.44)

    setState(() {
      if (aspectRatio > 2.2) {
        // Probablement un Flip ouvert ou écran ultra-wide
        _isFolded = false;
      } else if (aspectRatio > 1.7) {
        // Phone normal ou Fold fermé
        _isFolded = true;
      } else if (aspectRatio > 1.0 && aspectRatio < 1.4) {
        // Fold ouvert (presque carré)
        _isFolded = false;
      } else {
        // Configuration normale
        _isFolded = aspectRatio > 1.6;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.foldedChild != null && widget.unfoldedChild != null) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isFolded ? widget.foldedChild! : widget.unfoldedChild!,
      );
    }

    return widget.builder(context, _isFolded);
  }
}

/// Extension pour faciliter l'utilisation
extension FoldableContext on BuildContext {
  /// Vérifie si l'appareil est en mode plié
  bool get isFolded {
    final size = MediaQuery.of(this).size;
    final aspectRatio = size.width / size.height;
    return aspectRatio > 1.6 && aspectRatio < 2.2;
  }

  /// Vérifie si c'est un appareil pliable (basé sur l'aspect ratio)
  bool get isFoldableDevice {
    final size = MediaQuery.of(this).size;
    final aspectRatio = size.width / size.height;
    // Ratios inhabituels suggérant un pliable
    return (aspectRatio > 2.2) || // Flip ouvert
        (aspectRatio > 0.9 && aspectRatio < 1.4); // Fold ouvert
  }

  /// Retourne le type de pliable détecté
  FoldableType get foldableType {
    final size = MediaQuery.of(this).size;
    final aspectRatio = size.width / size.height;

    if (aspectRatio > 2.2) {
      return FoldableType.flip;
    } else if (aspectRatio > 0.9 && aspectRatio < 1.4) {
      return FoldableType.fold;
    }
    return FoldableType.none;
  }
}

enum FoldableType {
  none,
  fold, // Samsung Fold
  flip, // Samsung Flip
}

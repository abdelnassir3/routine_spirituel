import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/platform/platform_service.dart';

/// Widget adaptatif qui s'ajuste selon la plateforme
class PlatformAdaptiveWidget extends ConsumerWidget {
  final Widget? iosWidget;
  final Widget? macOSWidget;
  final Widget? androidWidget;
  final Widget? windowsWidget;
  final Widget? linuxWidget;
  final Widget? webWidget;
  final Widget defaultWidget;

  const PlatformAdaptiveWidget({
    super.key,
    this.iosWidget,
    this.macOSWidget,
    this.androidWidget,
    this.windowsWidget,
    this.linuxWidget,
    this.webWidget,
    required this.defaultWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(platformServiceProvider);

    if (platform.isIOS && iosWidget != null) {
      return iosWidget!;
    } else if (platform.isMacOS && macOSWidget != null) {
      return macOSWidget!;
    } else if (platform.isAndroid && androidWidget != null) {
      return androidWidget!;
    } else if (platform.isWindows && windowsWidget != null) {
      return windowsWidget!;
    } else if (platform.isLinux && linuxWidget != null) {
      return linuxWidget!;
    } else if (platform.isWeb && webWidget != null) {
      return webWidget!;
    }

    return defaultWidget;
  }
}

/// Bouton adaptatif selon la plateforme
class PlatformAdaptiveButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;

  const PlatformAdaptiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(platformServiceProvider);
    final theme = Theme.of(context);

    if (platform.useCupertinoDesign) {
      // iOS/macOS: Utiliser CupertinoButton
      return CupertinoButton(
        onPressed: onPressed,
        color: color ?? theme.colorScheme.primary,
        padding: EdgeInsets.all(platform.defaultPadding),
        child: child,
      );
    } else {
      // Android/Windows/Linux/Web: Utiliser ElevatedButton
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? theme.colorScheme.primary,
          padding: EdgeInsets.all(platform.defaultPadding),
        ),
        child: child,
      );
    }
  }
}

/// Dialogue adaptatif selon la plateforme
class PlatformAdaptiveDialog extends ConsumerWidget {
  final String title;
  final String content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const PlatformAdaptiveDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(platformServiceProvider);

    if (platform.useCupertinoDesign) {
      // iOS/macOS: Utiliser CupertinoAlertDialog
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            CupertinoDialogAction(
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              child: Text(cancelText!),
            ),
          if (confirmText != null)
            CupertinoDialogAction(
              onPressed: onConfirm ?? () => Navigator.of(context).pop(),
              isDefaultAction: true,
              child: Text(confirmText!),
            ),
        ],
      );
    } else {
      // Android/Windows/Linux/Web: Utiliser AlertDialog
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              child: Text(cancelText!),
            ),
          if (confirmText != null)
            TextButton(
              onPressed: onConfirm ?? () => Navigator.of(context).pop(),
              child: Text(confirmText!),
            ),
        ],
      );
    }
  }

  /// Affiche le dialogue de manière adaptative
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    final platform = PlatformService.instance;

    if (platform.useCupertinoDesign) {
      return showCupertinoDialog<T>(
        context: context,
        builder: (context) => PlatformAdaptiveDialog(
          title: title,
          content: content,
          confirmText: confirmText,
          cancelText: cancelText,
          onConfirm: onConfirm,
          onCancel: onCancel,
        ),
      );
    } else {
      return showDialog<T>(
        context: context,
        builder: (context) => PlatformAdaptiveDialog(
          title: title,
          content: content,
          confirmText: confirmText,
          cancelText: cancelText,
          onConfirm: onConfirm,
          onCancel: onCancel,
        ),
      );
    }
  }
}

/// Indicateur de chargement adaptatif
class PlatformAdaptiveProgressIndicator extends ConsumerWidget {
  final double? value;
  final Color? color;

  const PlatformAdaptiveProgressIndicator({
    super.key,
    this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(platformServiceProvider);
    final theme = Theme.of(context);

    if (platform.useCupertinoDesign) {
      // iOS/macOS: Utiliser CupertinoActivityIndicator
      return CupertinoActivityIndicator(
        color: color ?? theme.colorScheme.primary,
      );
    } else {
      // Android/Windows/Linux/Web: Utiliser CircularProgressIndicator
      return CircularProgressIndicator(
        value: value,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? theme.colorScheme.primary,
        ),
      );
    }
  }
}

/// Switch adaptatif selon la plateforme
class PlatformAdaptiveSwitch extends ConsumerWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const PlatformAdaptiveSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(platformServiceProvider);
    final theme = Theme.of(context);

    if (platform.useCupertinoDesign) {
      // iOS/macOS: Utiliser CupertinoSwitch
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: activeColor ?? theme.colorScheme.primary,
      );
    } else {
      // Android/Windows/Linux/Web: Utiliser Switch
      return Switch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor ?? theme.colorScheme.primary,
      );
    }
  }
}

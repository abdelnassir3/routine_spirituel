import 'package:flutter/material.dart';
import 'package:spiritual_routines/design_system/tokens/spacing.dart';

/// Material 3 Button Components with enhanced states and animations

/// Primary action button with filled background
class M3FilledButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  const M3FilledButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : icon != null
              ? Icon(icon)
              : const SizedBox.shrink(),
      label: AnimatedSwitcher(
        duration: AnimDurations.fast,
        child: child,
      ),
    );

    return expanded
        ? SizedBox(
            width: double.infinity,
            child: button,
          )
        : button;
  }
}

/// Secondary action button with tonal background
class M3TonalButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;
  final bool isLoading;

  const M3TonalButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
      ),
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onSecondaryContainer,
              ),
            )
          : icon != null
              ? Icon(icon)
              : const SizedBox.shrink(),
      label: child,
    );
  }
}

/// Text button for tertiary actions
class M3TextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;

  const M3TextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return icon != null
        ? TextButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: child,
          )
        : TextButton(
            onPressed: onPressed,
            child: child,
          );
  }
}

/// Outlined button for alternative actions
class M3OutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;

  const M3OutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return icon != null
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: child,
          )
        : OutlinedButton(
            onPressed: onPressed,
            child: child,
          );
  }
}

/// Icon button with proper touch target
class M3IconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final bool selected;
  final Color? color;

  const M3IconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.selected = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final button = IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: selected
          ? colorScheme.primary
          : color ?? colorScheme.onSurfaceVariant,
      style: IconButton.styleFrom(
        backgroundColor: selected ? colorScheme.primaryContainer : null,
      ),
    );

    return tooltip != null
        ? Tooltip(
            message: tooltip!,
            child: button,
          )
        : button;
  }
}

/// Segmented button for switching between options (replaces TabBar)
class M3SegmentedButton<T> extends StatelessWidget {
  final T selected;
  final List<SegmentedButtonOption<T>> options;
  final ValueChanged<T> onSelectionChanged;
  final bool showSelectedIcon;

  const M3SegmentedButton({
    super.key,
    required this.selected,
    required this.options,
    required this.onSelectionChanged,
    this.showSelectedIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: options.map((option) {
        return ButtonSegment<T>(
          value: option.value,
          label: Text(option.label),
          icon: option.icon != null ? Icon(option.icon) : null,
          enabled: option.enabled,
        );
      }).toList(),
      selected: {selected},
      onSelectionChanged: (Set<T> selection) {
        if (selection.isNotEmpty) {
          onSelectionChanged(selection.first);
        }
      },
      showSelectedIcon: showSelectedIcon,
    );
  }
}

class SegmentedButtonOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  final bool enabled;

  const SegmentedButtonOption({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });
}

/// FAB with extended option
class M3FloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? label;
  final bool isExtended;
  final Object? heroTag;

  const M3FloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.isExtended = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        heroTag: heroTag,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      heroTag: heroTag,
      child: Icon(icon),
    );
  }
}

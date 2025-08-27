import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/haptic_provider.dart';
import '../services/haptic_service.dart';

/// Widget wrapper pour ajouter du feedback haptique à n'importe quel widget
class HapticWrapper extends ConsumerWidget {
  final Widget child;
  final HapticType type;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final bool enabled;
  
  const HapticWrapper({
    super.key,
    required this.child,
    this.type = HapticType.light,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.enabled = true,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticService = ref.watch(hapticServiceProvider);
    
    Future<void> handleHaptic(HapticType type) async {
      if (!enabled || !hapticService.isEnabled) return;
      
      switch (type) {
        case HapticType.light:
          await hapticService.lightTap();
          break;
        case HapticType.selection:
          await hapticService.selection();
          break;
        case HapticType.impact:
          await hapticService.impact();
          break;
        case HapticType.success:
          await hapticService.success();
          break;
        case HapticType.error:
          await hapticService.error();
          break;
        case HapticType.longPress:
          await hapticService.longPress();
          break;
      }
    }
    
    return GestureDetector(
      onTap: onTap != null
          ? () async {
              await handleHaptic(type);
              onTap!();
            }
          : null,
      onLongPress: onLongPress != null
          ? () async {
              await handleHaptic(HapticType.longPress);
              onLongPress!();
            }
          : null,
      onDoubleTap: onDoubleTap != null
          ? () async {
              await handleHaptic(HapticType.impact);
              onDoubleTap!();
            }
          : null,
      child: child,
    );
  }
}

/// Types de feedback haptique pour le wrapper
enum HapticType {
  light,
  selection,
  impact,
  success,
  error,
  longPress,
}

/// Extension pour ajouter facilement du haptic aux boutons Flutter
extension HapticButton on ElevatedButton {
  Widget withHaptic({HapticType type = HapticType.selection}) {
    return HapticWrapper(
      type: type,
      onTap: onPressed,
      child: this,
    );
  }
}

extension HapticTextButton on TextButton {
  Widget withHaptic({HapticType type = HapticType.light}) {
    return HapticWrapper(
      type: type,
      onTap: onPressed,
      child: this,
    );
  }
}

extension HapticIconButton on IconButton {
  Widget withHaptic({HapticType type = HapticType.light}) {
    return HapticWrapper(
      type: type,
      onTap: onPressed,
      child: this,
    );
  }
}

/// Widget de bouton flottant avec feedback haptique intégré
class HapticFloatingActionButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Object? heroTag;
  final bool mini;
  final HapticType hapticType;
  
  const HapticFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.heroTag,
    this.mini = false,
    this.hapticType = HapticType.impact,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: onPressed != null
          ? () async {
              await ref.hapticImpact();
              onPressed!();
            }
          : null,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      heroTag: heroTag,
      mini: mini,
      child: child,
    );
  }
}

/// Widget de carte interactive avec feedback haptique
class HapticCard extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final double? elevation;
  final EdgeInsetsGeometry? margin;
  final bool enabled;
  final HapticType hapticType;
  
  const HapticCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.color,
    this.elevation,
    this.margin,
    this.enabled = true,
    this.hapticType = HapticType.selection,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: color,
      elevation: elevation,
      margin: margin,
      child: InkWell(
        onTap: onTap != null && enabled
            ? () async {
                if (hapticType == HapticType.selection) {
                  await ref.hapticSelection();
                } else {
                  await ref.hapticLightTap();
                }
                onTap!();
              }
            : null,
        onLongPress: onLongPress != null && enabled
            ? () async {
                await ref.hapticLongPress();
                onLongPress!();
              }
            : null,
        child: child,
      ),
    );
  }
}

/// ListTile avec feedback haptique intégré
class HapticListTile extends ConsumerWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool enabled;
  final HapticType hapticType;
  
  const HapticListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.enabled = true,
    this.hapticType = HapticType.selection,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      selected: selected,
      enabled: enabled,
      onTap: onTap != null
          ? () async {
              await ref.hapticSelection();
              onTap!();
            }
          : null,
      onLongPress: onLongPress != null
          ? () async {
              await ref.hapticLongPress();
              onLongPress!();
            }
          : null,
    );
  }
}

/// Switch avec feedback haptique
class HapticSwitch extends ConsumerWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? activeTrackColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;
  
  const HapticSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Switch(
      value: value,
      onChanged: onChanged != null
          ? (newValue) async {
              await ref.hapticSelection();
              onChanged!(newValue);
            }
          : null,
      activeColor: activeColor,
      activeTrackColor: activeTrackColor,
      inactiveThumbColor: inactiveThumbColor,
      inactiveTrackColor: inactiveTrackColor,
    );
  }
}

/// Slider avec feedback haptique aux changements
class HapticSlider extends ConsumerStatefulWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;
  
  const HapticSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
  });
  
  @override
  ConsumerState<HapticSlider> createState() => _HapticSliderState();
}

class _HapticSliderState extends ConsumerState<HapticSlider> {
  double? _lastHapticValue;
  
  @override
  Widget build(BuildContext context) {
    return Slider(
      value: widget.value,
      onChanged: widget.onChanged != null
          ? (newValue) async {
              // Haptic feedback aux divisions
              if (widget.divisions != null) {
                final step = (widget.max - widget.min) / widget.divisions!;
                final currentStep = ((newValue - widget.min) / step).round();
                final lastStep = _lastHapticValue != null
                    ? ((_lastHapticValue! - widget.min) / step).round()
                    : -1;
                
                if (currentStep != lastStep) {
                  await ref.hapticLightTap();
                  _lastHapticValue = newValue;
                }
              }
              
              widget.onChanged!(newValue);
            }
          : null,
      onChangeEnd: widget.onChangeEnd != null
          ? (value) async {
              await ref.hapticSelection();
              widget.onChangeEnd!(value);
            }
          : null,
      min: widget.min,
      max: widget.max,
      divisions: widget.divisions,
      label: widget.label,
      activeColor: widget.activeColor,
      inactiveColor: widget.inactiveColor,
    );
  }
}
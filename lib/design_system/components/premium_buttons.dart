import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/providers/haptic_provider.dart';
import 'package:spiritual_routines/design_system/tokens/shadows.dart';
import 'package:spiritual_routines/design_system/tokens/colors.dart';

/// Premium Button Component System
/// Sophisticated buttons with animations and premium aesthetics
class PremiumButton extends ConsumerStatefulWidget {
  const PremiumButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = PremiumButtonVariant.filled,
    this.size = PremiumButtonSize.medium,
    this.isLoading = false,
    this.loadingText,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.fullWidth = false,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.gradient,
    this.elevation = 0,
    this.animateOnPress = true,
    this.hapticFeedback = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final PremiumButtonVariant variant;
  final PremiumButtonSize size;
  final bool isLoading;
  final String? loadingText;
  final IconData? icon;
  final IconPosition iconPosition;
  final bool fullWidth;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final Gradient? gradient;
  final double elevation;
  final bool animateOnPress;
  final bool hapticFeedback;

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends ConsumerState<PremiumButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.animateOnPress && widget.onPressed != null) {
      setState(() => _isPressed = true);
      _scaleController.forward();

      if (widget.hapticFeedback) {
        // Adapter-based haptic (no-op on Web)
        ref.hapticLightTap();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.animateOnPress) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.animateOnPress) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
    }
  }

  void _startShimmer() {
    _shimmerController.repeat();
  }

  void _stopShimmer() {
    _shimmerController.stop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Button sizing
    final buttonSize = _getButtonSize();
    final textStyle = _getTextStyle(theme);
    final iconSize = _getIconSize();

    // Button colors based on variant
    final colors = _getButtonColors(colorScheme, isDark);

    // Loading state
    final isLoading = widget.isLoading;
    final isEnabled = widget.onPressed != null && !isLoading;

    Widget buttonChild = _buildButtonContent(
      textStyle: textStyle,
      iconSize: iconSize,
      colors: colors,
      isLoading: isLoading,
    );

    // Apply shimmer effect for loading
    if (isLoading && widget.variant == PremiumButtonVariant.filled) {
      buttonChild = _buildShimmerEffect(buttonChild, colors);
    }

    // Button container
    Widget button = Container(
      width: widget.fullWidth ? double.infinity : null,
      height: buttonSize.height,
      constraints: BoxConstraints(
        minWidth: buttonSize.minWidth,
        maxWidth: widget.fullWidth ? double.infinity : buttonSize.maxWidth,
      ),
      decoration: BoxDecoration(
        color: widget.gradient == null ? colors.background : null,
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? buttonSize.borderRadius,
        ),
        border: colors.borderColor != null
            ? Border.all(color: colors.borderColor!, width: 1.5)
            : null,
        boxShadow: isEnabled && widget.elevation > 0
            ? (isDark
                ? DarkModeShadows.medium
                : SemanticShadows.button)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? widget.onPressed : null,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? buttonSize.borderRadius,
          ),
          splashColor: colors.foreground.withOpacity(0.1),
          highlightColor: colors.foreground.withOpacity(0.05),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: buttonSize.horizontalPadding,
              vertical: buttonSize.verticalPadding,
            ),
            child: buttonChild,
          ),
        ),
      ),
    );

    // Apply scale animation
    if (widget.animateOnPress) {
      button = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: button,
      );
    }

    return button;
  }

  Widget _buildButtonContent({
    required TextStyle textStyle,
    required double iconSize,
    required _ButtonColors colors,
    required bool isLoading,
  }) {
    final List<Widget> children = [];

    // Loading indicator
    if (isLoading) {
      children.add(
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(colors.foreground),
          ),
        ),
      );

      if (widget.loadingText != null) {
        children.add(const SizedBox(width: 8));
        children.add(
          Text(
            widget.loadingText!,
            style: textStyle.copyWith(color: colors.foreground),
          ),
        );
      }
    } else {
      // Icon (leading)
      if (widget.icon != null && widget.iconPosition == IconPosition.leading) {
        children.add(
          Icon(
            widget.icon,
            size: iconSize,
            color: colors.foreground,
          ),
        );
        children.add(const SizedBox(width: 8));
      }

      // Main content
      children.add(
        DefaultTextStyle(
          style: textStyle.copyWith(color: colors.foreground),
          child: widget.child,
        ),
      );

      // Icon (trailing)
      if (widget.icon != null && widget.iconPosition == IconPosition.trailing) {
        children.add(const SizedBox(width: 8));
        children.add(
          Icon(
            widget.icon,
            size: iconSize,
            color: colors.foreground,
          ),
        );
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildShimmerEffect(Widget child, _ButtonColors colors) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, _) {
        return Stack(
          children: [
            child,
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  widget.borderRadius ?? _getButtonSize().borderRadius,
                ),
                child: Transform.translate(
                  offset: Offset(_shimmerAnimation.value * 200, 0),
                  child: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          colors.foreground.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _ButtonSize _getButtonSize() {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return const _ButtonSize(
          height: 36,
          minWidth: 64,
          maxWidth: 200,
          horizontalPadding: 12,
          verticalPadding: 8,
          borderRadius: 8,
        );
      case PremiumButtonSize.medium:
        return const _ButtonSize(
          height: 44,
          minWidth: 80,
          maxWidth: 300,
          horizontalPadding: 16,
          verticalPadding: 12,
          borderRadius: 12,
        );
      case PremiumButtonSize.large:
        return const _ButtonSize(
          height: 52,
          minWidth: 100,
          maxWidth: 400,
          horizontalPadding: 20,
          verticalPadding: 16,
          borderRadius: 14,
        );
    }
  }

  TextStyle _getTextStyle(ThemeData theme) {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ) ??
            const TextStyle();
      case PremiumButtonSize.medium:
        return theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
            const TextStyle();
      case PremiumButtonSize.large:
        return theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
            const TextStyle();
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return 16;
      case PremiumButtonSize.medium:
        return 20;
      case PremiumButtonSize.large:
        return 24;
    }
  }

  _ButtonColors _getButtonColors(ColorScheme colorScheme, bool isDark) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    switch (widget.variant) {
      case PremiumButtonVariant.filled:
        return _ButtonColors(
          background: isEnabled
              ? (widget.backgroundColor ?? colorScheme.primary)
              : colorScheme.onSurface.withOpacity(0.12),
          foreground: isEnabled
              ? (widget.foregroundColor ?? colorScheme.onPrimary)
              : colorScheme.onSurface.withOpacity(0.38),
          borderColor: null,
        );

      case PremiumButtonVariant.outlined:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: isEnabled
              ? (widget.foregroundColor ?? colorScheme.primary)
              : colorScheme.onSurface.withOpacity(0.38),
          borderColor: isEnabled
              ? (widget.borderColor ?? colorScheme.outline)
              : colorScheme.onSurface.withOpacity(0.12),
        );

      case PremiumButtonVariant.text:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: isEnabled
              ? (widget.foregroundColor ?? colorScheme.primary)
              : colorScheme.onSurface.withOpacity(0.38),
          borderColor: null,
        );

      case PremiumButtonVariant.tonal:
        return _ButtonColors(
          background: isEnabled
              ? (widget.backgroundColor ?? colorScheme.secondaryContainer)
              : colorScheme.onSurface.withOpacity(0.12),
          foreground: isEnabled
              ? (widget.foregroundColor ?? colorScheme.onSecondaryContainer)
              : colorScheme.onSurface.withOpacity(0.38),
          borderColor: null,
        );
    }
  }
}

/// Button variant definitions
enum PremiumButtonVariant { filled, outlined, text, tonal }

/// Button size definitions
enum PremiumButtonSize { small, medium, large }

/// Icon position for buttons with icons
enum IconPosition { leading, trailing }

/// Internal button size data
class _ButtonSize {
  final double height;
  final double minWidth;
  final double maxWidth;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;

  const _ButtonSize({
    required this.height,
    required this.minWidth,
    required this.maxWidth,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.borderRadius,
  });
}

/// Internal button colors data
class _ButtonColors {
  final Color background;
  final Color foreground;
  final Color? borderColor;

  const _ButtonColors({
    required this.background,
    required this.foreground,
    this.borderColor,
  });
}

/// Premium Button Variants for quick access
class PremiumButtons {
  /// Primary action button
  static Widget primary({
    required VoidCallback? onPressed,
    required Widget child,
    IconData? icon,
    bool isLoading = false,
    String? loadingText,
    bool fullWidth = false,
    PremiumButtonSize size = PremiumButtonSize.medium,
  }) {
    return PremiumButton(
      onPressed: onPressed,
      variant: PremiumButtonVariant.filled,
      size: size,
      isLoading: isLoading,
      loadingText: loadingText,
      icon: icon,
      fullWidth: fullWidth,
      elevation: 2,
      child: child,
    );
  }

  /// Secondary action button
  static Widget secondary({
    required VoidCallback? onPressed,
    required Widget child,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
    PremiumButtonSize size = PremiumButtonSize.medium,
  }) {
    return PremiumButton(
      onPressed: onPressed,
      variant: PremiumButtonVariant.tonal,
      size: size,
      isLoading: isLoading,
      icon: icon,
      fullWidth: fullWidth,
      child: child,
    );
  }

  /// Outlined button for secondary actions
  static Widget outlined({
    required VoidCallback? onPressed,
    required Widget child,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
    PremiumButtonSize size = PremiumButtonSize.medium,
  }) {
    return PremiumButton(
      onPressed: onPressed,
      variant: PremiumButtonVariant.outlined,
      size: size,
      isLoading: isLoading,
      icon: icon,
      fullWidth: fullWidth,
      child: child,
    );
  }

  /// Text button for tertiary actions
  static Widget text({
    required VoidCallback? onPressed,
    required Widget child,
    IconData? icon,
    bool isLoading = false,
    PremiumButtonSize size = PremiumButtonSize.medium,
  }) {
    return PremiumButton(
      onPressed: onPressed,
      variant: PremiumButtonVariant.text,
      size: size,
      isLoading: isLoading,
      icon: icon,
      child: child,
    );
  }

  /// Gradient button for special actions
  static Widget gradient({
    required VoidCallback? onPressed,
    required Widget child,
    required Gradient gradient,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
    PremiumButtonSize size = PremiumButtonSize.medium,
  }) {
    return PremiumButton(
      onPressed: onPressed,
      variant: PremiumButtonVariant.filled,
      size: size,
      isLoading: isLoading,
      icon: icon,
      fullWidth: fullWidth,
      gradient: gradient,
      elevation: 3,
      child: child,
    );
  }

  /// Icon button for minimal actions
  static Widget icon({
    required VoidCallback? onPressed,
    required IconData icon,
    Color? color,
    PremiumButtonSize size = PremiumButtonSize.medium,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: PremiumButton(
        onPressed: onPressed,
        variant: PremiumButtonVariant.text,
        size: size,
        borderRadius: 12,
        child: Icon(icon, color: color),
      ),
    );
  }
}

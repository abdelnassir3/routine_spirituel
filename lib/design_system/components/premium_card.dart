import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spiritual_routines/design_system/tokens/shadows.dart';
import 'package:spiritual_routines/design_system/tokens/colors.dart';

/// Premium Card Component
/// Sophisticated card design with animations and premium aesthetics
class PremiumCard extends StatefulWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin = const EdgeInsets.all(8),
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16.0,
    this.elevation = 0,
    this.backgroundColor,
    this.borderColor,
    this.gradient,
    this.showBorder = false,
    this.animateOnTap = true,
    this.animateOnHover = true,
    this.glowColor,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double elevation;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? gradient;
  final bool showBorder;
  final bool animateOnTap;
  final bool animateOnHover;
  final Color? glowColor;
  final double? width;
  final double? height;
  final Clip clipBehavior;

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.animateOnTap) {
      setState(() => _isPressed = true);
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.animateOnTap) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.animateOnTap) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
    }
  }

  void _handleMouseEnter(PointerEnterEvent event) {
    if (widget.animateOnHover) {
      setState(() => _isHovered = true);
      _glowController.forward();
    }
  }

  void _handleMouseExit(PointerExitEvent event) {
    if (widget.animateOnHover) {
      setState(() => _isHovered = false);
      _glowController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Determine card colors
    final cardBackgroundColor = widget.backgroundColor ??
        (isDark ? colorScheme.surfaceContainer : colorScheme.surface);

    final effectiveBorderColor =
        widget.borderColor ?? colorScheme.outline.withOpacity(0.1);

    // Calculate shadows
    List<BoxShadow> shadows = [];
    if (widget.elevation > 0) {
      shadows = isDark
          ? Shadows.medium
          : Shadows.medium;
    }

    // Add glow effect if specified
    if (widget.glowColor != null && (_isHovered || _isPressed)) {
      shadows = [
        ...shadows,
        ...Shadows.glow(widget.glowColor!),
      ];
    }

    Widget cardContent = Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.gradient == null ? cardBackgroundColor : null,
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: widget.showBorder
            ? Border.all(color: effectiveBorderColor, width: 1)
            : null,
        boxShadow: shadows,
      ),
      child: widget.child,
    );

    // Wrap with animations if enabled
    if (widget.animateOnTap || widget.animateOnHover) {
      cardContent = AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: cardContent,
      );
    }

    // Wrap with gesture detection and mouse region
    return Container(
      margin: widget.margin,
      child: MouseRegion(
        onEnter: _handleMouseEnter,
        onExit: _handleMouseExit,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            clipBehavior: widget.clipBehavior,
            child: cardContent,
          ),
        ),
      ),
    );
  }
}

/// Premium Card Variants
class PremiumCardVariants {
  /// Elevated card with subtle shadow
  static Widget elevated({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return PremiumCard(
      onTap: onTap,
      margin: margin ?? const EdgeInsets.all(8),
      padding: padding ?? const EdgeInsets.all(16),
      elevation: 2,
      borderRadius: 12,
      child: child,
    );
  }

  /// Outlined card with border
  static Widget outlined({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? borderColor,
  }) {
    return PremiumCard(
      onTap: onTap,
      margin: margin ?? const EdgeInsets.all(8),
      padding: padding ?? const EdgeInsets.all(16),
      showBorder: true,
      borderColor: borderColor,
      borderRadius: 12,
      child: child,
    );
  }

  /// Gradient card with beautiful gradient background
  static Widget gradient({
    required Widget child,
    required Gradient gradient,
    VoidCallback? onTap,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return PremiumCard(
      onTap: onTap,
      margin: margin ?? const EdgeInsets.all(8),
      padding: padding ?? const EdgeInsets.all(16),
      gradient: gradient,
      borderRadius: 16,
      child: child,
    );
  }

  /// Glowing card for special content
  static Widget glowing({
    required Widget child,
    required Color glowColor,
    VoidCallback? onTap,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return PremiumCard(
      onTap: onTap,
      margin: margin ?? const EdgeInsets.all(8),
      padding: padding ?? const EdgeInsets.all(16),
      glowColor: glowColor,
      borderRadius: 16,
      elevation: 1,
      child: child,
    );
  }

  /// Compact card for list items
  static Widget compact({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return PremiumCard(
      onTap: onTap,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: padding ?? const EdgeInsets.all(12),
      borderRadius: 8,
      showBorder: true,
      child: child,
    );
  }
}

/// Premium Task Card specifically for spiritual routines
class PremiumTaskCard extends StatelessWidget {
  const PremiumTaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.progress,
    this.completedCount,
    this.totalCount,
    this.isCompleted = false,
    this.onTap,
    this.trailing,
    this.leading,
    this.statusColor,
  });

  final String title;
  final String subtitle;
  final double? progress;
  final int? completedCount;
  final int? totalCount;
  final bool isCompleted;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? leading;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PremiumCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: EdgeInsets.zero,
      borderRadius: 16,
      elevation: 1,
      glowColor: statusColor,
      child: Column(
        children: [
          // Header with optional progress indicator
          if (progress != null || statusColor != null)
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: statusColor?.withOpacity(0.2) ?? Colors.transparent,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: progress != null
                  ? LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(
                        statusColor ?? colorScheme.primary,
                      ),
                    )
                  : null,
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Leading widget or status indicator
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 12),
                ] else if (statusColor != null) ...[
                  Container(
                    width: 4,
                    height: 32,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Progress text if available
                      if (completedCount != null && totalCount != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '$completedCount/$totalCount complété',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor ?? colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing widget
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  trailing!,
                ] else if (isCompleted) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF10B981),
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

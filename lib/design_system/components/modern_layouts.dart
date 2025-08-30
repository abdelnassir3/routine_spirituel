import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/providers/haptic_provider.dart';
import 'package:spiritual_routines/design_system/inspired_theme.dart';
import 'package:spiritual_routines/design_system/animations/premium_animations.dart';
import 'package:spiritual_routines/design_system/components/modern_task_card.dart';

/// Modern Layout Components inspired by reference designs
/// Features: Grid layouts, vertical flows, responsive design

/// Daily Plan Grid Layout (inspired by Page 6 - 2x2 grid)
class ModernGridLayout extends StatelessWidget {
  const ModernGridLayout({
    super.key,
    required this.items,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.2,
    this.spacing = 16,
    this.padding = const EdgeInsets.all(16),
    this.animated = true,
  });

  final List<Widget> items;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;
  final EdgeInsets padding;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    if (animated) {
      return Padding(
        padding: padding,
        child: GridLayoutAnimation(
          crossAxisCount: crossAxisCount,
          children: items,
        ),
      );
    }

    return Padding(
      padding: padding,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        children: items,
      ),
    );
  }
}

/// Vertical Flow Layout (inspired by Page 7 - vertical list)
class ModernVerticalFlow extends StatelessWidget {
  const ModernVerticalFlow({
    super.key,
    required this.children,
    this.spacing = 12,
    this.padding = const EdgeInsets.all(16),
    this.animated = true,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final List<Widget> children;
  final double spacing;
  final EdgeInsets padding;
  final bool animated;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }

    Widget column = Column(
      crossAxisAlignment: crossAxisAlignment,
      children: spacedChildren,
    );

    if (animated) {
      column = StaggeredListAnimation(
        staggerDelay: const Duration(milliseconds: 100),
        children: spacedChildren,
      );
    }

    return Padding(
      padding: padding,
      child: column,
    );
  }
}

/// Modern Task Row (inspired by the task layouts in references)
class ModernTaskRow extends StatelessWidget {
  const ModernTaskRow({
    super.key,
    required this.title,
    required this.time,
    this.subtitle,
    this.category = 'prayer',
    this.isCompleted = false,
    this.hasNotification = false,
    this.onTap,
    this.onComplete,
  });

  final String title;
  final String time;
  final String? subtitle;
  final String category;
  final bool isCompleted;
  final bool hasNotification;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = SpiritualCategories.colors[category] ??
        Theme.of(context).colorScheme.primary;

    return MicroInteractionAnimation(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Checkbox
            _buildCheckbox(context, categoryColor),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with notification
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (hasNotification)
                        NotificationBadgeAnimation(
                          isActive: hasNotification,
                          badgeColor: categoryColor,
                          child: const SizedBox.shrink(),
                        ),
                    ],
                  ),

                  // Subtitle
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Time
            TimeDisplayAnimation(
              time: time,
              style: theme.textTheme.labelMedium?.copyWith(
                color: categoryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context, Color categoryColor) {
    return Consumer(builder: (context, ref, _) {
      return GestureDetector(
        onTap: () async {
          await ref.hapticLightTap();
          onComplete?.call(!isCompleted);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCompleted ? categoryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCompleted
                  ? categoryColor
                  : Theme.of(context).colorScheme.outlineVariant,
              width: 2,
            ),
          ),
          child: isCompleted
              ? const Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: Colors.white,
                )
              : null,
        ),
      );
    });
  }
}

/// Modern Page Layout with header
class ModernPageLayout extends StatelessWidget {
  const ModernPageLayout({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    required this.body,
    this.floatingActionButton,
    this.backgroundColor,
    this.showBackButton = true,
    this.headerGradient,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool showBackButton;
  final Gradient? headerGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      body: Column(
        children: [
          // Header
          Builder(builder: (context) {
            final cs = Theme.of(context).colorScheme;
            return Container(
              decoration: BoxDecoration(
                gradient: headerGradient ?? ModernGradients.header(cs),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top bar
                      Row(
                        children: [
                          if (showBackButton && Navigator.canPop(context))
                            Container(
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          Expanded(
                            child: FadeInAnimation(
                              child: Text(
                                title,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  shadows: const [
                                    Shadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(0, 2))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (actions != null) ...actions!,
                        ],
                      ),

                      // Subtitle
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            subtitle!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              shadows: const [
                                Shadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 1))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),

          // Body
          Expanded(
            child: body,
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// CTA Button Layout (inspired by "Add New Plan" buttons)
class ModernCTAButton extends StatelessWidget {
  const ModernCTAButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
    this.fullWidth = true,
    this.animated = true,
  });

  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final bool fullWidth;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    Widget button = Container(
      width: fullWidth ? double.infinity : null,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [effectiveColor, effectiveColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                ],
                Text(
                  text,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (animated) {
      button = CTAButtonAnimation(
        color: effectiveColor,
        onTap: onPressed,
        child: button,
      );
    }

    return button;
  }
}

/// Statistics Card (inspired by progress indicators in designs)
class ModernStatsCard extends StatelessWidget {
  const ModernStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.progress,
    this.color,
    this.onTap,
    this.animated = true,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final double? progress;
  final Color? color;
  final VoidCallback? onTap;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return MicroInteractionAnimation(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 130,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              effectiveColor,
              effectiveColor.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: effectiveColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                // Optional progress indicator
                if (progress != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(progress! * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const Spacer(),

            // Middle section with value
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AnimatedStatValue(
                  value: value,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                    height: 1.0,
                    shadows: const [
                      Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2)),
                    ],
                  ),
                  animated: animated,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ],
            ),

            // Bottom progress bar
            if (progress != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnimatedStatValue extends StatefulWidget {
  const _AnimatedStatValue({
    required this.value,
    required this.style,
    required this.animated,
  });

  final String value;
  final TextStyle? style;
  final bool animated;

  @override
  State<_AnimatedStatValue> createState() => _AnimatedStatValueState();
}

class _AnimatedStatValueState extends State<_AnimatedStatValue> {
  int? _target;

  @override
  void initState() {
    super.initState();
    _parseTarget();
  }

  @override
  void didUpdateWidget(covariant _AnimatedStatValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _parseTarget();
    }
  }

  void _parseTarget() {
    final digits = RegExp(r'^[0-9]+$');
    _target = digits.hasMatch(widget.value) ? int.tryParse(widget.value) : null;
  }

  @override
  Widget build(BuildContext context) {
    if (_target == null || !widget.animated) {
      return Text(
        widget.value,
        style: widget.style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: (_target ?? 0).toDouble()),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          value.toInt().toString(),
          style: widget.style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

/// Empty State Layout
class ModernEmptyState extends StatelessWidget {
  const ModernEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
    this.illustration,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeInAnimation(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration or Icon
              if (illustration != null)
                illustration!
              else
                ScaleAnimation(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              // Action button
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: 32),
                ModernCTAButton(
                  text: actionText!,
                  onPressed: onAction!,
                  fullWidth: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Section Header
class ModernSectionHeader extends StatelessWidget {
  const ModernSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.onActionTap,
  });

  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(
                action!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

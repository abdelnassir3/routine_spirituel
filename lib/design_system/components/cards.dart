import 'package:flutter/material.dart';
import 'package:spiritual_routines/design_system/tokens/spacing.dart';

/// Material 3 Card Components

/// Standard elevated card
class M3Card extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;

  const M3Card({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation ?? 0,
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Corners.card),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(Spacing.cardPadding),
          child: child,
        ),
      ),
    );

    return card;
  }
}

/// Outlined card variant
class M3OutlinedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const M3OutlinedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Corners.card),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Corners.card),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(Spacing.cardPadding),
          child: child,
        ),
      ),
    );
  }
}

/// Filled card variant
class M3FilledCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const M3FilledCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    return Card(
      elevation: 0,
      color: brightness == Brightness.light
          ? colorScheme.surfaceContainer
          : colorScheme.surfaceContainerHigh,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Corners.card),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(Spacing.cardPadding),
          child: child,
        ),
      ),
    );
  }
}

/// Interactive card with hover/press states
class M3InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool selected;

  const M3InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.selected = false,
  });

  @override
  State<M3InteractiveCard> createState() => _M3InteractiveCardState();
}

class _M3InteractiveCardState extends State<M3InteractiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves2.standard,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: AnimDurations.fast,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Corners.card),
                color: widget.selected
                    ? colorScheme.secondaryContainer
                    : colorScheme.surfaceContainerLow,
                border: widget.selected
                    ? Border.all(color: colorScheme.primary, width: 2)
                    : null,
                boxShadow: _isPressed
                    ? []
                    : [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.08),
                          blurRadius: Elevations.level2,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(Corners.card),
                  child: Padding(
                    padding: widget.padding ??
                        const EdgeInsets.all(Spacing.cardPadding),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Card with leading media (image/icon)
class M3MediaCard extends StatelessWidget {
  final Widget? media;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double mediaHeight;

  const M3MediaCard({
    super.key,
    this.media,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.mediaHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (media != null)
              SizedBox(
                height: mediaHeight,
                width: double.infinity,
                child: media!,
              ),
            Padding(
              padding: const EdgeInsets.all(Spacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleMedium!,
                    child: title,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: Spacing.xs),
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      child: subtitle!,
                    ),
                  ],
                  if (trailing != null) ...[
                    const SizedBox(height: Spacing.md),
                    trailing!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

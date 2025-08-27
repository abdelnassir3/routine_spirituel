import 'package:flutter/material.dart';
import 'package:spiritual_routines/design_system/tokens/spacing.dart';

/// Material 3 State Components (Empty, Error, Loading)

/// Empty state widget with illustration
class M3EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;

  const M3EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(Spacing.xxl),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.xxl),
            Text(
              title,
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                description!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: Spacing.xxl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state widget
class M3ErrorState extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback? onRetry;

  const M3ErrorState({
    super.key,
    required this.title,
    this.description,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(Spacing.xxl),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: Spacing.xxl),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                description!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: Spacing.xxl),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading skeleton widget
class M3Skeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const M3Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<M3Skeleton> createState() => _M3SkeletonState();
}

class _M3SkeletonState extends State<M3Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height ?? 20,
          decoration: BoxDecoration(
            borderRadius:
                widget.borderRadius ?? BorderRadius.circular(Corners.sm),
            color: colorScheme.surfaceContainerHighest
                .withOpacity(_animation.value),
          ),
        );
      },
    );
  }
}

/// Text skeleton for loading state
class M3TextSkeleton extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double spacing;

  const M3TextSkeleton({
    super.key,
    this.lines = 3,
    this.lineHeight = 16,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLast = index == lines - 1;
        final width = isLast ? 0.6 : 1.0;

        return Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? spacing : 0),
          child: FractionallySizedBox(
            widthFactor: width,
            child: M3Skeleton(height: lineHeight),
          ),
        );
      }),
    );
  }
}

/// Card skeleton for loading state
class M3CardSkeleton extends StatelessWidget {
  final double height;
  final bool showMedia;

  const M3CardSkeleton({
    super.key,
    this.height = 120,
    this.showMedia = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showMedia) ...[
              M3Skeleton(
                height: 180,
                borderRadius: BorderRadius.circular(Corners.md),
              ),
              const SizedBox(height: Spacing.md),
            ],
            const M3Skeleton(width: 150, height: 24),
            const SizedBox(height: Spacing.sm),
            const M3TextSkeleton(lines: 2),
          ],
        ),
      ),
    );
  }
}

/// Loading indicator with label
class M3LoadingIndicator extends StatelessWidget {
  final String? label;
  final bool linear;

  const M3LoadingIndicator({
    super.key,
    this.label,
    this.linear = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (linear)
            const LinearProgressIndicator()
          else
            const CircularProgressIndicator(),
          if (label != null) ...[
            const SizedBox(height: Spacing.lg),
            Text(
              label!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/providers/haptic_provider.dart';

/// Animation Durations
class AnimationDurations {
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 700);
}

/// Animation Curves
class AnimationCurves {
  static const Curve easeInOut = Cubic(0.4, 0.0, 0.2, 1.0);
  static const Curve easeOut = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve easeIn = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Curve bounce = Cubic(0.175, 0.885, 0.32, 1.275);
  static const Curve spring = Cubic(0.68, -0.55, 0.265, 1.55);
  static const Curve elastic = Cubic(0.25, 0.46, 0.45, 0.94);
}

/// Fade In Animation Widget
class FadeInAnimation extends StatefulWidget {
  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.slideOffset,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset? slideOffset;

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset ?? const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Scale Animation Widget
class ScaleAnimation extends StatefulWidget {
  const ScaleAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.curve = Curves.elasticOut,
    this.initialScale = 0.8,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double initialScale;

  @override
  State<ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.initialScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Staggered List Animation
class StaggeredListAnimation extends StatefulWidget {
  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.slideOffset = const Offset(0, 0.1),
  });

  final List<Widget> children;
  final Duration staggerDelay;
  final Duration animationDuration;
  final Curve curve;
  final Offset slideOffset;

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.children.length,
        (index) => FadeInAnimation(
          duration: widget.animationDuration,
          delay: widget.staggerDelay * index,
          curve: widget.curve,
          slideOffset: widget.slideOffset,
          child: widget.children[index],
        ),
      ),
    );
  }
}

/// Bounce Animation Widget
class BounceAnimation extends StatefulWidget {
  const BounceAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.repeat = false,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final bool repeat;

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) {
      if (widget.repeat) {
        _controller.repeat();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Shimmer Loading Animation
class ShimmerAnimation extends StatefulWidget {
  const ShimmerAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.direction = ShimmerDirection.leftToRight,
  });

  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;
  final ShimmerDirection direction;

  @override
  State<ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: _getGradientBegin(),
              end: _getGradientEnd(),
              transform:
                  GradientRotation(_shimmerAnimation.value * 2 * 3.14159),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }

  Alignment _getGradientBegin() {
    switch (widget.direction) {
      case ShimmerDirection.leftToRight:
        return Alignment.centerLeft;
      case ShimmerDirection.rightToLeft:
        return Alignment.centerRight;
      case ShimmerDirection.topToBottom:
        return Alignment.topCenter;
      case ShimmerDirection.bottomToTop:
        return Alignment.bottomCenter;
    }
  }

  Alignment _getGradientEnd() {
    switch (widget.direction) {
      case ShimmerDirection.leftToRight:
        return Alignment.centerRight;
      case ShimmerDirection.rightToLeft:
        return Alignment.centerLeft;
      case ShimmerDirection.topToBottom:
        return Alignment.bottomCenter;
      case ShimmerDirection.bottomToTop:
        return Alignment.topCenter;
    }
  }
}

/// Pulse Animation Widget
class PulseAnimation extends StatefulWidget {
  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.repeat = true,
  });

  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool repeat;

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Typewriter Animation
class TypewriterAnimation extends StatefulWidget {
  const TypewriterAnimation({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 100),
    this.cursor = '|',
    this.showCursor = true,
  });

  final String text;
  final TextStyle? style;
  final Duration speed;
  final String cursor;
  final bool showCursor;

  @override
  State<TypewriterAnimation> createState() => _TypewriterAnimationState();
}

class _TypewriterAnimationState extends State<TypewriterAnimation>
    with TickerProviderStateMixin {
  late AnimationController _typeController;
  late AnimationController _cursorController;
  String _displayText = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _typeController = AnimationController(
      duration: widget.speed * widget.text.length,
      vsync: this,
    );

    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _typeController.addListener(_updateText);
    _typeController.forward();

    if (widget.showCursor) {
      _cursorController.repeat(reverse: true);
    }
  }

  void _updateText() {
    final newIndex = (_typeController.value * widget.text.length).floor();
    if (newIndex != _currentIndex && newIndex <= widget.text.length) {
      setState(() {
        _currentIndex = newIndex;
        _displayText = widget.text.substring(0, _currentIndex);
      });
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cursorController,
      builder: (context, child) {
        return RichText(
          text: TextSpan(
            style: widget.style ?? DefaultTextStyle.of(context).style,
            children: [
              TextSpan(text: _displayText),
              if (widget.showCursor)
                TextSpan(
                  text: widget.cursor,
                  style: TextStyle(
                    color: (widget.style?.color ?? Colors.black)
                        .withOpacity(_cursorController.value),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Page Transition Animations
class PremiumPageTransitions {
  /// Slide transition from right
  static Widget slideFromRight(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

  /// Fade with scale transition
  static Widget fadeScale(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: child,
      ),
    );
  }
}

/// Shimmer direction enum
enum ShimmerDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}

/// Grid Layout Animation (inspired by Page 6 design - 2x2 grid)
class GridLayoutAnimation extends StatefulWidget {
  const GridLayoutAnimation({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.staggerDelay = const Duration(milliseconds: 150),
    this.animationDuration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutBack,
  });

  final List<Widget> children;
  final int crossAxisCount;
  final Duration staggerDelay;
  final Duration animationDuration;
  final Curve curve;

  @override
  State<GridLayoutAnimation> createState() => _GridLayoutAnimationState();
}

class _GridLayoutAnimationState extends State<GridLayoutAnimation> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return ScaleAnimation(
          duration: widget.animationDuration,
          delay: widget.staggerDelay * index,
          curve: widget.curve,
          initialScale: 0.7,
          child: widget.children[index],
        );
      },
    );
  }
}

/// Notification Badge Animation (inspired by cyan notification icons)
class NotificationBadgeAnimation extends StatefulWidget {
  const NotificationBadgeAnimation({
    super.key,
    required this.child,
    this.isActive = false,
    this.badgeColor = const Color(0xFF00BCD4),
    this.size = 8.0,
  });

  final Widget child;
  final bool isActive;
  final Color badgeColor;
  final double size;

  @override
  State<NotificationBadgeAnimation> createState() =>
      _NotificationBadgeAnimationState();
}

class _NotificationBadgeAnimationState extends State<NotificationBadgeAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    if (widget.isActive) {
      _scaleController.forward();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NotificationBadgeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _scaleController.forward();
        _pulseController.repeat(reverse: true);
      } else {
        _scaleController.reverse();
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isActive)
          Positioned(
            top: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: widget.badgeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.badgeColor.withOpacity(0.4),
                          blurRadius: 4 * _pulseAnimation.value,
                          spreadRadius: 1 * _pulseAnimation.value,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Button CTA Animation (inspired by "Add New Plan" button)
class CTAButtonAnimation extends StatefulWidget {
  const CTAButtonAnimation({
    super.key,
    required this.child,
    this.onTap,
    this.color = const Color(0xFF00BCD4),
    this.shadowIntensity = 0.3,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final double shadowIntensity;

  @override
  State<CTAButtonAnimation> createState() => _CTAButtonAnimationState();
}

class _CTAButtonAnimationState extends State<CTAButtonAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _glowController;
  late Animation<double> _pressAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.2,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressAnimation, _glowAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pressAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(
                        widget.shadowIntensity * _glowAnimation.value),
                    blurRadius: 12 * _glowAnimation.value,
                    offset: const Offset(0, 4),
                    spreadRadius: 2 * _glowAnimation.value,
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Time Display Animation (inspired by elegant timestamps)
class TimeDisplayAnimation extends StatefulWidget {
  const TimeDisplayAnimation({
    super.key,
    required this.time,
    this.style,
    this.countUp = false,
    this.prefix = '',
  });

  final String time;
  final TextStyle? style;
  final bool countUp;
  final String prefix;

  @override
  State<TimeDisplayAnimation> createState() => _TimeDisplayAnimationState();
}

class _TimeDisplayAnimationState extends State<TimeDisplayAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(TimeDisplayAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.time != widget.time) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.prefix.isNotEmpty) ...[
                  Text(
                    widget.prefix,
                    style: widget.style?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: widget.style?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  widget.time,
                  style: widget.style?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Micro Interaction Animation

class MicroInteractionAnimation extends ConsumerStatefulWidget {
  const MicroInteractionAnimation({
    super.key,
    required this.child,
    this.onTap,
    this.hapticFeedback = true,
    this.scaleFactor = 0.98,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool hapticFeedback;
  final double scaleFactor;

  @override
  ConsumerState<MicroInteractionAnimation> createState() =>
      _MicroInteractionAnimationState();
}

class _MicroInteractionAnimationState
    extends ConsumerState<MicroInteractionAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
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

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });

    if (widget.hapticFeedback) {
      // Adapter-based haptic (no-op on Web)
      ref.hapticLightTap();
    }

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Animation utility extensions
extension AnimationExtensions on Animation<double> {
  /// Convert to fade animation
  Animation<double> get fade => this;

  /// Convert to scale animation
  Animation<double> scale({double begin = 0.0, double end = 1.0}) {
    return Tween<double>(begin: begin, end: end).animate(this);
  }

  /// Convert to slide animation
  Animation<Offset> slide(
      {Offset begin = const Offset(0, 1), Offset end = Offset.zero}) {
    return Tween<Offset>(begin: begin, end: end).animate(this);
  }
}

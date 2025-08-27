import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spiritual_routines/design_system/inspired_theme.dart';
import 'package:spiritual_routines/design_system/animations/premium_animations.dart';

/// Modern Task Card inspired by the reference designs
/// Features: Check circle, time display, category colors, smooth animations
class ModernTaskCard extends StatefulWidget {
  const ModernTaskCard({
    super.key,
    required this.title,
    this.subtitle,
    this.time,
    this.date,
    this.isCompleted = false,
    this.category = 'prayer',
    this.onTap,
    this.onComplete,
    this.showCheckbox = true,
    this.showTime = true,
    this.priority,
  });

  final String title;
  final String? subtitle;
  final String? time;
  final String? date;
  final bool isCompleted;
  final String category;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onComplete;
  final bool showCheckbox;
  final bool showTime;
  final TaskPriority? priority;

  @override
  State<ModernTaskCard> createState() => _ModernTaskCardState();
}

class _ModernTaskCardState extends State<ModernTaskCard>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _scaleController;
  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    if (widget.isCompleted) {
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ModernTaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted != oldWidget.isCompleted) {
      if (widget.isCompleted) {
        _checkController.forward();
      } else {
        _checkController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _toggleComplete() {
    widget.onComplete?.call(!widget.isCompleted);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final categoryColor = SpiritualCategories.colors[widget.category] ??
        theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Material(
              elevation: 0,
              borderRadius: BorderRadius.circular(16),
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: categoryColor.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: widget.onTap,
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Checkbox animé
                        if (widget.showCheckbox) ...[
                          _buildAnimatedCheckbox(categoryColor),
                          const SizedBox(width: 16),
                        ],

                        // Enhanced category color indicator
                        Container(
                          width: 5,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                categoryColor,
                                categoryColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: categoryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title avec priorité
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.title,
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                        letterSpacing: -0.2,
                                        decoration: widget.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: widget.isCompleted
                                            ? colorScheme.onSurfaceVariant
                                            : colorScheme.onSurface,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  // Priority indicator
                                  if (widget.priority != null) ...[
                                    const SizedBox(width: 8),
                                    _buildPriorityIndicator(widget.priority!),
                                  ],
                                ],
                              ),

                              // Subtitle
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.subtitle!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],

                              // Date/Time
                              if (widget.date != null ||
                                  widget.time != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (widget.date != null) ...[
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.date!,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                    if (widget.date != null &&
                                        widget.time != null) ...[
                                      const SizedBox(width: 12),
                                      Container(
                                        width: 2,
                                        height: 2,
                                        decoration: BoxDecoration(
                                          color: colorScheme.onSurfaceVariant,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    if (widget.time != null &&
                                        widget.showTime) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              categoryColor.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.access_time_rounded,
                                              size: 14,
                                              color: categoryColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              widget.time!,
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                color: categoryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Trailing actions
                        if (widget.onTap != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Checkbox animé inspiré du design
  Widget _buildAnimatedCheckbox(Color categoryColor) {
    return GestureDetector(
      onTap: _toggleComplete,
      child: AnimatedBuilder(
        animation: _checkAnimation,
        builder: (context, child) {
          final bool isChecked = _checkAnimation.value > 0.5;

          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isChecked ? categoryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isChecked
                    ? categoryColor
                    : Theme.of(context).colorScheme.outlineVariant,
                width: 2,
              ),
              boxShadow: isChecked
                  ? [
                      BoxShadow(
                        color: categoryColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Transform.scale(
              scale: _checkAnimation.value,
              child: const Icon(
                Icons.check_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Indicateur de priorité
  Widget _buildPriorityIndicator(TaskPriority priority) {
    Color color;
    IconData icon;

    switch (priority) {
      case TaskPriority.high:
        color = ModernColors.error;
        icon = Icons.priority_high_rounded;
        break;
      case TaskPriority.medium:
        color = ModernColors.warning;
        icon = Icons.remove_rounded;
        break;
      case TaskPriority.low:
        color = ModernColors.info;
        icon = Icons.keyboard_arrow_down_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
    );
  }
}

/// Task Priority Enum
enum TaskPriority { high, medium, low }

/// Category Card Widget (inspired by the design's category sections)
class ModernCategoryCard extends StatelessWidget {
  const ModernCategoryCard({
    super.key,
    required this.title,
    required this.itemCount,
    required this.icon,
    required this.color,
    this.progress,
    this.onTap,
  });

  final String title;
  final int itemCount;
  final IconData icon;
  final Color color;
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            // Count
            Text(
              '$itemCount ${itemCount == 1 ? 'tâche' : 'tâches'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),

            // Progress bar if available
            if (progress != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress! * 100).toInt()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Header with greeting (inspired by "Hello, Parsley")
class ModernGreetingHeader extends StatelessWidget {
  const ModernGreetingHeader({
    super.key,
    required this.name,
    this.subtitle,
    this.backgroundGradient,
  });

  final String name;
  final String? subtitle;
  final Gradient? backgroundGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: backgroundGradient ??
            ModernGradients.header(Theme.of(context).colorScheme),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🌙✨ Logo Premium avec Design Expert UI (+20 ans d'expérience)
              FadeInAnimation(
                child: Column(
                  children: [
                    // Stack pour effets multiples sophistiqués
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Halo lumineux animé en arrière-plan
                        TweenAnimationBuilder<double>(
                          duration: const Duration(seconds: 4),
                          tween: Tween(begin: 0.8, end: 1.0),
                          builder: (context, value, child) {
                            return AnimatedContainer(
                              duration: const Duration(seconds: 2),
                              width: 140 * value,
                              height: 140 * value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.05 * value),
                                    Colors.white.withOpacity(0.15 * value),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                  stops: const [0.0, 0.3, 0.6, 1.0],
                                ),
                              ),
                            );
                          },
                        ),

                        // Logo principal avec effets premium
                        TweenAnimationBuilder<double>(
                          duration: const Duration(seconds: 3),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: TweenAnimationBuilder<double>(
                                duration: const Duration(seconds: 10),
                                tween: Tween(begin: 0.0, end: 2 * 3.14159),
                                builder: (context, rotation, child) {
                                  return Transform.rotate(
                                    angle: rotation *
                                        0.05, // Rotation très subtile
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.2),
                                            Colors.white.withOpacity(0.05),
                                          ],
                                        ),
                                        boxShadow: [
                                          // Ombre principale
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 20,
                                            offset: const Offset(0, 5),
                                          ),
                                          // Lueur blanche
                                          BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.4),
                                            blurRadius: 15,
                                            spreadRadius: -5,
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Hero(
                                        tag: 'islamic_logo',
                                        child: Image.asset(
                                          'assets/images/islamic_logo_hd.png',
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                          // Amélioration visuelle du logo
                                          color: Colors.white.withOpacity(0.98),
                                          colorBlendMode: BlendMode.modulate,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        // Effet de brillance qui tourne
                        TweenAnimationBuilder<double>(
                          duration: const Duration(seconds: 8),
                          tween: Tween(begin: 0.0, end: 2 * 3.14159),
                          builder: (context, angle, child) {
                            return Transform.rotate(
                              angle: angle,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: SweepGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.1, 0.2],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Titre RISAQ avec design harmonisé
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'RISAQ',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                          fontSize:
                              38, // Taille légèrement réduite pour équilibrer avec le logo
                          shadows: const [
                            Shadow(
                                color: Colors.black45,
                                blurRadius: 12,
                                offset: Offset(0, 4)),
                            Shadow(
                                color: Colors.black26,
                                blurRadius: 24,
                                offset: Offset(0, 6)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // App Subtitle with better readability - centered
              FadeInAnimation(
                delay: const Duration(milliseconds: 100),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Routines Spirituelles et Actions\nQuotidiennes',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.4,
                      shadows: const [
                        Shadow(
                            color: Colors.black87,
                            blurRadius: 10,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Divider
              Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 24),

              // Greeting - larger and centered
              if (name.isNotEmpty)
                FadeInAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      Text(
                        'Assalamu Alaikum, $name',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                          shadows: const [
                            Shadow(
                                color: Colors.black45,
                                blurRadius: 10,
                                offset: Offset(0, 3)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            shadows: const [
                              Shadow(
                                  color: Colors.black54,
                                  blurRadius: 8,
                                  offset: Offset(0, 2)),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modern Time Display (inspired by schedule designs)
class ModernTimeDisplay extends StatelessWidget {
  const ModernTimeDisplay({
    super.key,
    required this.time,
    this.color,
    this.showBackground = true,
  });

  final String time;
  final Color? color;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showBackground ? 12 : 0,
        vertical: showBackground ? 8 : 0,
      ),
      decoration: showBackground
          ? BoxDecoration(
              color: effectiveColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: effectiveColor.withOpacity(0.3),
                width: 1,
              ),
            )
          : null,
      child: Text(
        time,
        style: theme.textTheme.labelMedium?.copyWith(
          color: effectiveColor,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

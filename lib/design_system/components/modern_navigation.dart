import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spiritual_routines/core/providers/haptic_provider.dart';
import 'package:spiritual_routines/design_system/inspired_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/design_system/animations/premium_animations.dart';

/// Modern Bottom Navigation inspired by the reference designs
class ModernBottomNavigation extends StatefulWidget {
  const ModernBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.showLabels = true,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ModernNavItem> items;
  final bool showLabels;

  @override
  State<ModernBottomNavigation> createState() => _ModernBottomNavigationState();
}

class _ModernBottomNavigationState extends State<ModernBottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _animations = _controllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut),
          ),
        )
        .toList();

    // Animate current index
    if (widget.currentIndex < _controllers.length) {
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(ModernBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reset old index
      if (oldWidget.currentIndex < _controllers.length) {
        _controllers[oldWidget.currentIndex].reverse();
      }

      // Animate new index
      if (widget.currentIndex < _controllers.length) {
        _controllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: widget.showLabels ? 65 : 50,
          child: Consumer(builder: (context, ref, _) {
            final reduce = ref.watch(reduceMotionProvider);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(widget.items.length, (index) {
                  final item = widget.items[index];
                  final isSelected = index == widget.currentIndex;
                  return _buildNavItem(
                    context,
                    item,
                    isSelected,
                    reduce ? kAlwaysCompleteAnimation : _animations[index],
                    () async {
                      // Haptic via adapter (no-op on Web)
                      try {
                        await ref.hapticLightTap();
                      } catch (_) {}
                      widget.onTap(index);
                    },
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    ModernNavItem item,
    bool isSelected,
    Animation<double> animation,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with enhanced container
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (animation.value * 0.15),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.primary.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : colorScheme.surfaceContainerHighest
                              .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 20,
                      color: isSelected
                          ? Colors.white
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),

            // Label with better spacing
            if (widget.showLabels) ...[
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: theme.textTheme.labelSmall!.copyWith(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 10,
                  height: 1.0,
                ),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Navigation Item
class ModernNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const ModernNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Modern FAB with floating animation (inspired by the + button)
class ModernFloatingActionButton extends StatefulWidget {
  const ModernFloatingActionButton({
    super.key,
    required this.onPressed,
    this.child,
    this.icon = Icons.add_rounded,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 8,
    this.size = ModernFABSize.regular,
    this.heroTag,
  });

  final VoidCallback? onPressed;
  final Widget? child;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final ModernFABSize size;
  final Object? heroTag;

  @override
  State<ModernFloatingActionButton> createState() =>
      _ModernFloatingActionButtonState();
}

class _ModernFloatingActionButtonState extends State<ModernFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
    _rotationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    _rotationController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
    _rotationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = _getFABSize();
    final cs = theme.colorScheme;

    return Hero(
      tag: widget.heroTag ?? 'modernFAB',
      child: Consumer(builder: (context, ref, _) {
        final reduce = ref.watch(reduceMotionProvider);
        if (reduce) {
          return _staticFab(context, size, cs);
        }
        return AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 3.14159 * 2,
                child: _staticFab(context, size, cs),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _staticFab(BuildContext context, double size, ColorScheme cs) {
    return Container(
      width: size + 8,
      height: size + 8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary,
            cs.primary.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular((size + 8) / 2),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: BorderRadius.circular((size + 8) / 2),
          child: Center(
            child: widget.child ??
                Icon(
                  widget.icon,
                  color: widget.foregroundColor ?? Colors.white,
                  size: size * 0.4,
                ),
          ),
        ),
      ),
    );
  }

  double _getFABSize() {
    switch (widget.size) {
      case ModernFABSize.small:
        return 48;
      case ModernFABSize.regular:
        return 56;
      case ModernFABSize.large:
        return 64;
    }
  }
}

enum ModernFABSize { small, regular, large }

/// Modern App Bar inspired by the reference designs
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ModernAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.showBackButton = true,
    this.gradient,
    this.height = 56,
  });

  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool centerTitle;
  final bool showBackButton;
  final Gradient? gradient;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: gradient == null
            ? (backgroundColor ?? theme.colorScheme.surface)
            : null,
        gradient: gradient,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Leading
              if (leading != null)
                leading!
              else if (showBackButton && Navigator.of(context).canPop())
                ModernBackButton(
                  color: foregroundColor ??
                      (gradient != null
                          ? Colors.white
                          : theme.colorScheme.onSurface),
                ),

              // Title section
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(
                    left: (leading != null ||
                            (showBackButton && Navigator.of(context).canPop()))
                        ? 16
                        : 0,
                    right: actions != null ? 16 : 0,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment:
                        centerTitle ? Alignment.center : Alignment.centerLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: centerTitle
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          DefaultTextStyle(
                            style: theme.textTheme.titleLarge!.copyWith(
                              color: foregroundColor ??
                                  (gradient != null
                                      ? Colors.white
                                      : theme.colorScheme.onSurface),
                              fontWeight: FontWeight.w600,
                            ),
                            child: title!,
                          ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          DefaultTextStyle(
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: (foregroundColor ??
                                      (gradient != null
                                          ? Colors.white
                                          : theme.colorScheme.onSurface))
                                  .withOpacity(0.7),
                            ),
                            child: subtitle!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Actions
              if (actions != null)
                Flexible(
                  flex: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modern Back Button
class ModernBackButton extends StatelessWidget {
  const ModernBackButton({
    super.key,
    this.onPressed,
    this.color,
  });

  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onPressed ?? () => Navigator.of(context).maybePop(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: (color ?? theme.colorScheme.onSurface).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.arrow_back_ios_rounded,
          size: 20,
          color: color ?? theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// Modern Search Bar
class ModernSearchBar extends StatefulWidget {
  const ModernSearchBar({
    super.key,
    this.hintText = 'Rechercher...',
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.autofocus = false,
  });

  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final bool autofocus;

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _focusAnimation;

  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();

    _focusController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeInOut),
    );

    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });

    if (_hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  @override
  void dispose() {
    _focusController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainer : colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color.lerp(
                colorScheme.outlineVariant,
                ModernColors.primary,
                _focusAnimation.value,
              )!,
              width: 1 + _focusAnimation.value,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Color.lerp(
                  colorScheme.onSurfaceVariant,
                  ModernColors.primary,
                  _focusAnimation.value,
                ),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: theme.textTheme.bodyMedium,
          ),
        );
      },
    );
  }
}

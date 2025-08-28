import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gesture_service.dart';
import '../services/haptic_service.dart';
import '../providers/haptic_provider.dart';

/// Détecteur de gestes intelligents avec support multi-touch et patterns
class SmartGestureDetector extends ConsumerStatefulWidget {
  final Widget child;

  // Callbacks simples
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final Function(SwipeDirection)? onSwipe;
  final VoidCallback? onCircle;
  final VoidCallback? onZigzag;

  // Callbacks avancés
  final Function(double)? onPinch; // Scale factor
  final Function(double)? onRotate; // Angle en radians
  final Function(Offset)? onPan;

  // Configuration
  final bool enableSwipe;
  final bool enablePinch;
  final bool enableRotate;
  final bool enablePatterns;
  final bool hapticFeedback;

  const SmartGestureDetector({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSwipe,
    this.onCircle,
    this.onZigzag,
    this.onPinch,
    this.onRotate,
    this.onPan,
    this.enableSwipe = true,
    this.enablePinch = false,
    this.enableRotate = false,
    this.enablePatterns = false,
    this.hapticFeedback = true,
  });

  @override
  ConsumerState<SmartGestureDetector> createState() =>
      _SmartGestureDetectorState();
}

class _SmartGestureDetectorState extends ConsumerState<SmartGestureDetector> {
  final GestureService _gestureService = GestureService.instance;

  // Tracking du swipe
  Offset? _swipeStart;
  DateTime? _swipeStartTime;

  // Tracking du dessin
  final List<Offset> _drawPoints = [];
  bool _isDrawing = false;

  // Multi-touch tracking
  double? _initialScale;
  double? _initialRotation;
  int _pointerCount = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Gestes simples
      onTap: widget.onTap != null
          ? () async {
              if (widget.hapticFeedback) {
                await ref.hapticLightTap();
              }
              widget.onTap!();
            }
          : null,

      onDoubleTap: widget.onDoubleTap != null
          ? () async {
              if (widget.hapticFeedback) {
                await ref.hapticSelection();
              }
              widget.onDoubleTap!();
            }
          : null,

      onLongPress: widget.onLongPress != null
          ? () async {
              if (widget.hapticFeedback) {
                await ref.hapticLongPress();
              }
              widget.onLongPress!();
            }
          : null,

      // Pan pour swipe et dessin
      onPanStart: widget.enableSwipe || widget.enablePatterns
          ? (details) {
              _swipeStart = details.globalPosition;
              _swipeStartTime = DateTime.now();

              if (widget.enablePatterns) {
                _isDrawing = true;
                _drawPoints.clear();
                _drawPoints.add(details.localPosition);
              }
            }
          : null,

      onPanUpdate:
          widget.enableSwipe || widget.enablePatterns || widget.onPan != null
              ? (details) {
                  if (widget.enablePatterns && _isDrawing) {
                    _drawPoints.add(details.localPosition);
                  }

                  if (widget.onPan != null) {
                    widget.onPan!(details.delta);
                  }
                }
              : null,

      onPanEnd: widget.enableSwipe || widget.enablePatterns
          ? (details) async {
              // Détecter le swipe
              if (widget.enableSwipe &&
                  _swipeStart != null &&
                  _swipeStartTime != null) {
                final endPosition = details.globalPosition;
                final duration = DateTime.now().difference(_swipeStartTime!);

                final direction = _gestureService.analyzeSwipe(
                  start: _swipeStart!,
                  end: endPosition,
                  duration: duration,
                );

                if (direction != null && widget.onSwipe != null) {
                  if (widget.hapticFeedback) {
                    await ref.hapticSwipe();
                  }
                  widget.onSwipe!(direction);
                }
              }

              // Détecter les patterns de dessin
              if (widget.enablePatterns &&
                  _isDrawing &&
                  _drawPoints.length > 3) {
                // Détection de cercle
                if (_gestureService.detectCircleGesture(_drawPoints)) {
                  if (widget.hapticFeedback) {
                    await ref.hapticSuccess();
                  }
                  widget.onCircle?.call();
                }
                // Détection de zigzag
                else if (_gestureService.detectZigzagGesture(_drawPoints)) {
                  if (widget.hapticFeedback) {
                    await ref.hapticError();
                  }
                  widget.onZigzag?.call();
                }
              }

              // Reset
              _swipeStart = null;
              _swipeStartTime = null;
              _isDrawing = false;
              _drawPoints.clear();
            }
          : null,

      // Scale pour pinch
      onScaleStart: widget.enablePinch || widget.enableRotate
          ? (details) {
              _initialScale = 1.0;
              _initialRotation = 0.0;
              _pointerCount = details.pointerCount;
            }
          : null,

      onScaleUpdate: widget.enablePinch || widget.enableRotate
          ? (details) {
              // Pinch zoom
              if (widget.enablePinch &&
                  widget.onPinch != null &&
                  _pointerCount >= 2) {
                final scaleDiff = details.scale - (_initialScale ?? 1.0);
                if (scaleDiff.abs() > 0.01) {
                  widget.onPinch!(details.scale);
                  _initialScale = details.scale;
                }
              }

              // Rotation
              if (widget.enableRotate &&
                  widget.onRotate != null &&
                  _pointerCount >= 2) {
                final rotationDiff =
                    details.rotation - (_initialRotation ?? 0.0);
                if (rotationDiff.abs() > 0.01) {
                  widget.onRotate!(details.rotation);
                  _initialRotation = details.rotation;
                }
              }
            }
          : null,

      onScaleEnd: widget.enablePinch || widget.enableRotate
          ? (details) {
              _initialScale = null;
              _initialRotation = null;
              _pointerCount = 0;
            }
          : null,

      child: widget.child,
    );
  }
}

/// Widget pour afficher une zone de compteur avec gestes
class GestureCounterZone extends ConsumerStatefulWidget {
  final int count;
  final ValueChanged<int> onCountChanged;
  final VoidCallback? onReset;
  final VoidCallback? onPauseResume;
  final bool showVisualFeedback;

  const GestureCounterZone({
    super.key,
    required this.count,
    required this.onCountChanged,
    this.onReset,
    this.onPauseResume,
    this.showVisualFeedback = true,
  });

  @override
  ConsumerState<GestureCounterZone> createState() => _GestureCounterZoneState();
}

class _GestureCounterZoneState extends ConsumerState<GestureCounterZone>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String? _lastGesture;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  void _showFeedback(String gesture) {
    if (!widget.showVisualFeedback) return;

    setState(() {
      _lastGesture = gesture;
    });

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _lastGesture = null;
        });
      }
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gestureService = GestureService.instance;

    return SmartGestureDetector(
      enableSwipe: true,
      enablePatterns: true,
      hapticFeedback: true,

      // Tap pour incrémenter
      onTap: () {
        widget.onCountChanged(widget.count + 1);
        gestureService.handleCounterIncrement();
        _showFeedback('+1');
      },

      // Double tap pour pause/resume
      onDoubleTap: widget.onPauseResume != null
          ? () {
              widget.onPauseResume!();
              gestureService.handlePauseResume();
              _showFeedback('⏸');
            }
          : null,

      // Long press pour reset
      onLongPress: widget.onReset != null
          ? () {
              widget.onReset!();
              gestureService.handleCounterReset();
              _showFeedback('↻');
            }
          : null,

      // Swipe pour naviguer
      onSwipe: (direction) {
        switch (direction) {
          case SwipeDirection.up:
            widget.onCountChanged(widget.count + 10);
            _showFeedback('+10');
            break;
          case SwipeDirection.down:
            if (widget.count > 0) {
              widget.onCountChanged(widget.count - 1);
              gestureService.handleCounterDecrement();
              _showFeedback('-1');
            }
            break;
          case SwipeDirection.left:
            if (widget.count >= 10) {
              widget.onCountChanged(widget.count - 10);
              _showFeedback('-10');
            }
            break;
          case SwipeDirection.right:
            widget.onCountChanged(widget.count + 5);
            _showFeedback('+5');
            break;
        }
      },

      // Cercle pour reset
      onCircle: widget.onReset != null
          ? () {
              widget.onReset!();
              _showFeedback('↻');
            }
          : null,

      // Zigzag pour annuler dernier
      onZigzag: () {
        if (widget.count > 0) {
          widget.onCountChanged(widget.count - 1);
          _showFeedback('↶');
        }
      },

      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicateur de geste
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _lastGesture != null
                        ? Container(
                            key: ValueKey(_lastGesture),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _lastGesture!,
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox(height: 40),
                  ),

                  const SizedBox(height: 20),

                  // Compteur
                  Text(
                    widget.count.toString(),
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Instructions
                  Text(
                    'Tap: +1 | Swipe ↑: +10 | Swipe →: +5',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    'Long press ou ○: Reset | Double tap: Pause',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

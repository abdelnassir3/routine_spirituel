import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auto_resume_service.dart';
import '../providers/auto_resume_provider.dart';
import '../providers/haptic_provider.dart';

/// Widget de notification pour proposer la reprise d'une session
class ResumeNotification extends ConsumerStatefulWidget {
  final Widget child;
  final Function(ResumeState)? onResume;
  final VoidCallback? onDismiss;
  
  const ResumeNotification({
    super.key,
    required this.child,
    this.onResume,
    this.onDismiss,
  });
  
  @override
  ConsumerState<ResumeNotification> createState() => _ResumeNotificationState();
}

class _ResumeNotificationState extends ConsumerState<ResumeNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isShowing = false;
  Timer? _countdownTimer;
  int _remainingSeconds = 30;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    // Configurer les callbacks
    _setupCallbacks();
    
    // Vérifier s'il y a une session à reprendre au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForResume();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }
  
  void _setupCallbacks() {
    final service = ref.read(autoResumeServiceProvider);
    
    service.onSessionNeedsResume = () {
      if (mounted) {
        _showNotification();
      }
    };
    
    service.onSessionResumed = (state) {
      if (mounted) {
        _hideNotification();
        widget.onResume?.call(state);
      }
    };
    
    service.onSessionExpired = () {
      if (mounted) {
        _hideNotification();
      }
    };
  }
  
  void _checkForResume() {
    final hasResume = ref.read(hasResumeAvailableProvider);
    if (hasResume) {
      _showNotification();
    }
  }
  
  void _showNotification() async {
    if (_isShowing) return;
    
    setState(() {
      _isShowing = true;
      _remainingSeconds = 30;
    });
    
    // Haptic feedback
    await ref.hapticNotification();
    
    // Animation d'entrée
    _animationController.forward();
    
    // Démarrer le compte à rebours
    _startCountdown();
  }
  
  void _hideNotification() {
    if (!_isShowing) return;
    
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isShowing = false;
        });
      }
    });
    
    _countdownTimer?.cancel();
  }
  
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _remainingSeconds--;
      });
      
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _handleDismiss();
      }
    });
  }
  
  Future<void> _handleResume() async {
    final success = await ref.resumePendingSession();
    
    if (success) {
      final resumeState = ref.read(pendingResumeProvider);
      if (resumeState != null) {
        widget.onResume?.call(resumeState);
      }
      _hideNotification();
    }
  }
  
  void _handleDismiss() async {
    await ref.abandonAutoResumeSession();
    widget.onDismiss?.call();
    _hideNotification();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resumeState = ref.watch(pendingResumeProvider);
    
    return Stack(
      children: [
        widget.child,
        
        if (_isShowing && resumeState != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value * 100),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: _ResumeCard(
                      resumeState: resumeState,
                      remainingSeconds: _remainingSeconds,
                      onResume: _handleResume,
                      onDismiss: _handleDismiss,
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

/// Carte de notification de reprise
class _ResumeCard extends StatelessWidget {
  final ResumeState resumeState;
  final int remainingSeconds;
  final VoidCallback onResume;
  final VoidCallback onDismiss;
  
  const _ResumeCard({
    required this.resumeState,
    required this.remainingSeconds,
    required this.onResume,
    required this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 8,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.restore,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session interrompue',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reprendre là où vous vous êtes arrêté',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Informations de la session
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        _getSessionTypeLabel(resumeState.type),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Progrès',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        '${resumeState.progress}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Il y a',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        _formatAge(resumeState.age),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Barre de progression du compte à rebours
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: remainingSeconds / 30,
                minHeight: 4,
                backgroundColor: theme.dividerColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  remainingSeconds > 10 
                      ? theme.primaryColor 
                      : Colors.orange,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Actions
            Row(
              children: [
                Text(
                  'Fermeture dans ${remainingSeconds}s',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onDismiss,
                  child: Text(
                    'Ignorer',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onResume,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reprendre'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _getSessionTypeLabel(String type) {
    switch (type) {
      case 'prayer':
        return 'Prière';
      case 'meditation':
        return 'Méditation';
      case 'reading':
        return 'Lecture';
      default:
        return 'Session';
    }
  }
  
  String _formatAge(Duration age) {
    if (age.inMinutes < 1) {
      return 'quelques secondes';
    } else if (age.inMinutes < 60) {
      return '${age.inMinutes} min';
    } else if (age.inHours < 24) {
      return '${age.inHours}h ${age.inMinutes % 60}min';
    } else {
      return '${age.inDays} jour${age.inDays > 1 ? 's' : ''}';
    }
  }
}
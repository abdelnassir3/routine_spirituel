import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spiritual_routines/core/services/persistence_service.dart';
import 'package:spiritual_routines/core/services/persistence_service_drift.dart';
import 'package:spiritual_routines/core/services/progress_service.dart';
import 'package:spiritual_routines/features/session/session_state.dart';
import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';

// Responsive system
import 'package:spiritual_routines/core/widgets/responsive_breakpoints.dart';
import 'package:spiritual_routines/design_system/components/adaptive_navigation.dart';

// Nouveau design system
import 'package:spiritual_routines/design_system/inspired_theme.dart';
import 'package:spiritual_routines/design_system/components/modern_task_card.dart';
import 'package:spiritual_routines/design_system/components/modern_navigation.dart';
import 'package:spiritual_routines/design_system/components/modern_layouts.dart';
import 'package:spiritual_routines/design_system/components/modern_stats_card_compact.dart';
import 'package:spiritual_routines/design_system/animations/premium_animations.dart';

class ModernHomePage extends ConsumerStatefulWidget {
  const ModernHomePage({super.key});

  @override
  ConsumerState<ModernHomePage> createState() => _ModernHomePageState();
}

class _ModernHomePageState extends ConsumerState<ModernHomePage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _statsController;
  late AnimationController _listController;
  late Animation<double> _headerAnimation;
  late Animation<double> _statsAnimation;
  late ScrollController _scrollController;
  double _scrollOffset = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialisation des animations
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    _statsAnimation = CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutCubic, // Changé de easeOutBack à easeOutCubic
    );

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });

    // Démarrer les animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _statsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _listController.forward();
    });

    // Vérifier la reprise de session après le build initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRecoveryOptions();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _statsController.dispose();
    _listController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _checkRecoveryOptions() async {
    final recovery = await ref.read(recoveryOptionsProvider.future);
    if (recovery.hasSnapshot && recovery.snapshot != null) {
      final sessionId = recovery.snapshot!.payload['sessionId'] as String?;
      if (sessionId != null && mounted && !Navigator.of(context).canPop()) {
        await _showRecoveryDialog(context, ref, sessionId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recovery = ref.watch(recoveryOptionsProvider);
    final theme = Theme.of(context);
    final reduceMotion = ref.watch(reduceMotionProvider);
    final size = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AdaptiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() => _selectedIndex = index);
        switch (index) {
          case 0:
            break; // Already on home
          case 1:
            context.go('/routines');
            break;
          case 2:
            context.go('/reader');
            break;
          case 3:
            context.go('/settings');
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        NavigationDestination(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt),
          label: 'Routines',
        ),
        NavigationDestination(
          icon: Icon(Icons.book_outlined),
          selectedIcon: Icon(Icons.book),
          label: 'Lecture',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Réglages',
        ),
      ],
      body: Stack(
        children: [
          // Fond avec gradient animé plus visible à 75% d'opacité
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF5BA3A8).withOpacity(0.75), // 75% d'opacité
                  const Color(0xFF5BA3A8).withOpacity(0.50), // 50% d'opacité
                  const Color(0xFF5BA3A8).withOpacity(0.25), // 25% d'opacité
                  theme.colorScheme.surface,
                ],
                stops: const [0.0, 0.25, 0.5, 1.0],
              ),
            ),
          ),

          // Contenu principal
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Header moderne et compact
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _headerAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - _headerAnimation.value)),
                      child: Opacity(
                        opacity: _headerAnimation.value.clamp(0.0, 1.0),
                        child: Container(
                          height: 190 + statusBarHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.12),
                                theme.colorScheme.secondary.withOpacity(0.06),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(32),
                              bottomRight: Radius.circular(32),
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Pattern décoratif
                              Positioned(
                                top: -50,
                                right: -50,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        theme.colorScheme.primary
                                            .withOpacity(0.1),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -30,
                                left: -30,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        theme.colorScheme.secondary
                                            .withOpacity(0.08),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Contenu du header centré
                              Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: statusBarHeight,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Logo et titre
                                      Hero(
                                        tag: 'app_logo',
                                        child: Container(
                                          width: 65,
                                          height: 65,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.9),
                                                Colors.white.withOpacity(0.7),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: theme.colorScheme.primary
                                                    .withOpacity(0.2),
                                                blurRadius: 20,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: Image.asset(
                                            'assets/images/app_logo.png',
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(
                                                Icons.star,
                                                size: 35,
                                                color:
                                                    theme.colorScheme.primary,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'RISAQ',
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2.5,
                                          fontSize: 28,
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.9),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Routines Spirituelles et Actions\nQuotidiennes',
                                        textAlign: TextAlign.center,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.6),
                                          height: 1.2,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Cartes de statistiques optimisées avec responsive layout
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _statsAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset:
                          Offset(0, 15 - (10 * (1 - _statsAnimation.value))),
                      child: Transform.scale(
                        scale: 0.92 + (0.08 * _statsAnimation.value),
                        child: Opacity(
                          opacity: _statsAnimation.value.clamp(0.0, 1.0),
                          child: Padding(
                            padding: context.responsivePadding,
                            child: ResponsiveBuilder(
                              builder: (context, constraints, screenType) {
                                // Use grid on larger screens
                                if (screenType != ScreenType.mobile) {
                                  return GridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: context.responsive(
                                      mobile: 2,
                                      tablet: 3,
                                      desktop: 4,
                                    ),
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: context.responsive(
                                      mobile: 1.5,
                                      tablet: 1.3,
                                      desktop: 1.4,
                                    ),
                                    children: [
                                      _buildStatsCard(
                                        context,
                                        title: 'Routines',
                                        value: '5',
                                        subtitle: 'Disponibles',
                                        icon: Icons.list_alt_rounded,
                                        color: ModernColors.categoryBlue,
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          context.go('/routines');
                                        },
                                      ),
                                      _buildStatsCard(
                                        context,
                                        title: 'Aujourd\'hui',
                                        value: '3',
                                        subtitle: 'Complétées',
                                        icon: Icons.check_circle_rounded,
                                        color: ModernColors.categoryGreen,
                                        progress: 0.6,
                                        showProgress: true,
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                        },
                                      ),
                                      if (screenType != ScreenType.mobile) ...[
                                        _buildStatsCard(
                                          context,
                                          title: 'Série',
                                          value: '7',
                                          subtitle: 'Jours',
                                          icon: Icons
                                              .local_fire_department_rounded,
                                          color: ModernColors.categoryOrange,
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                          },
                                        ),
                                      ],
                                      if (screenType == ScreenType.desktop) ...[
                                        _buildStatsCard(
                                          context,
                                          title: 'Total',
                                          value: '42',
                                          subtitle: 'Sessions',
                                          icon: Icons.insights_rounded,
                                          color: ModernColors.categoryPurple,
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                          },
                                        ),
                                      ],
                                    ],
                                  );
                                }
                                // Mobile: keep the row layout
                                return Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatsCard(
                                        context,
                                        title: 'Routines',
                                        value: '5',
                                        subtitle: 'Disponibles',
                                        icon: Icons.list_alt_rounded,
                                        color: ModernColors.categoryBlue,
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          context.go('/routines');
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildStatsCard(
                                        context,
                                        title: 'Aujourd\'hui',
                                        value: '3',
                                        subtitle: 'Complétées',
                                        icon: Icons.check_circle_rounded,
                                        color: ModernColors.categoryGreen,
                                        progress: 0.6,
                                        showProgress: true,
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bouton CTA moderne avec responsive padding
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _listController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - _listController.value)),
                      child: Opacity(
                        opacity: _listController.value.clamp(0.0, 1.0),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            context.responsivePadding.left,
                            30,
                            context.responsivePadding.right,
                            12,
                          ),
                          child: Material(
                            elevation: 8,
                            shadowColor:
                                theme.colorScheme.primary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                context.go('/routines');
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary
                                          .withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Créer une nouvelle routine',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Section des routines récentes avec responsive padding
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.responsivePadding.left,
                    0,
                    context.responsivePadding.right,
                    12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.history_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Routines récentes',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Reprendre où vous avez arrêté',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/routines'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Voir tout',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Liste des routines avec animation et responsive layout
              SliverLayoutBuilder(
                builder: (context, constraints) {
                  final screenType = context.screenType;
                  final routineCards = [
                    _buildRoutineCard(
                      context,
                      title: 'Prière du matin',
                      subtitle: 'Al-Fajr - 5 invocations',
                      time: '05:30',
                      category: 'prayer',
                      delay: 0,
                      onTap: () => _startRoutine(context, ref, 'morning'),
                    ),
                    _buildRoutineCard(
                      context,
                      title: 'Protection quotidienne',
                      subtitle: 'Ayat al-Kursi + Adhkar',
                      time: '06:00',
                      category: 'protection',
                      delay: 100,
                      onTap: () => _startRoutine(context, ref, 'protection'),
                    ),
                    _buildRoutineCard(
                      context,
                      title: 'Gratitude du soir',
                      subtitle: 'Remerciements et méditation',
                      time: '20:00',
                      category: 'gratitude',
                      delay: 200,
                      onTap: () => _startRoutine(context, ref, 'evening'),
                    ),
                  ];

                  // Desktop/Tablet: Grid layout avec padding
                  if (screenType != ScreenType.mobile) {
                    return SliverPadding(
                      padding: context.responsivePadding,
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: context.responsive(
                            mobile: 1,
                            tablet: 2,
                            desktop: 3,
                          ),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: context.responsive(
                            mobile: 3.5,
                            tablet: 2.8,
                            desktop: 3.0,
                          ),
                        ),
                        delegate: SliverChildListDelegate([
                          ...routineCards,
                          const SizedBox(height: 100),
                        ]),
                      ),
                    );
                  }

                  // Mobile: List layout avec padding
                  return SliverPadding(
                    padding: context.responsivePadding,
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        routineCards[0],
                        const SizedBox(height: 10),
                        routineCards[1],
                        const SizedBox(height: 10),
                        routineCards[2],
                        const SizedBox(height: 100),
                      ]),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    double? progress,
    bool showProgress = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      elevation: 3,
      shadowColor: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 16,
                      ),
                    ),
                    const Spacer(),
                    if (showProgress)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(progress! * 100).toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 1),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (showProgress) ...[
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String time,
    required String category,
    required int delay,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final categoryColor =
        SpiritualCategories.colors[category] ?? theme.colorScheme.primary;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Material(
              elevation: 2,
              shadowColor: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      left: BorderSide(
                        color: categoryColor,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxWidth: 100),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: categoryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      time,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: categoryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color:
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRecoveryDialog(
      BuildContext context, WidgetRef ref, String sessionId) async {
    // Code existant pour le dialog de récupération...
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleAnimation(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ModernColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restore_rounded,
                    size: 48,
                    color: ModernColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Reprendre la session ?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Vous pouvez reprendre exactement où vous avez arrêté, ou réinitialiser la routine.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        await ref
                            .read(persistenceServiceProvider)
                            .handleRecovery(RecoveryChoice.reset);
                        ref.read(currentSessionIdProvider.notifier).state =
                            sessionId;
                        ref
                            .read(persistenceServiceProvider)
                            .setCurrentSession(sessionId);
                        await ref
                            .read(progressServiceProvider)
                            .initProgressForSession(sessionId);
                        if (context.mounted) {
                          Navigator.of(ctx).pop();
                          context.go('/reader');
                        }
                      },
                      child: const Text('Réinitialiser'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await ref
                            .read(persistenceServiceProvider)
                            .handleRecovery(RecoveryChoice.resume);
                        ref.read(currentSessionIdProvider.notifier).state =
                            sessionId;
                        ref
                            .read(persistenceServiceProvider)
                            .setCurrentSession(sessionId);
                        if (context.mounted) {
                          Navigator.of(ctx).pop();
                          context.go('/reader');
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: ModernColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Reprendre'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resumeSession(BuildContext context, WidgetRef ref) async {
    final opt = await ref.read(recoveryOptionsProvider.future);
    final sessionId = opt.snapshot?.payload['sessionId'] as String?;
    await ref
        .read(persistenceServiceProvider)
        .handleRecovery(RecoveryChoice.resume);
    if (sessionId != null) {
      ref.read(currentSessionIdProvider.notifier).state = sessionId;
      ref.read(persistenceServiceProvider).setCurrentSession(sessionId);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session reprise')),
      );
      context.go('/reader');
    }
  }

  Future<void> _startRoutine(
      BuildContext context, WidgetRef ref, String routineType) async {
    // Récupérer les routines depuis la base de données
    final routineDao = ref.read(routineDaoProvider);
    final routines = await routineDao.watchAll().first;

    // Chercher une routine correspondante ou créer une ID temporaire
    String? routineId;

    // Essayer de trouver une routine existante par nom
    for (final routine in routines) {
      final nameLower = routine.nameFr.toLowerCase();
      if (routineType == 'morning' &&
          (nameLower.contains('matin') || nameLower.contains('fajr'))) {
        routineId = routine.id;
        break;
      } else if (routineType == 'protection' &&
          (nameLower.contains('protection') || nameLower.contains('ayat'))) {
        routineId = routine.id;
        break;
      } else if (routineType == 'evening' &&
          (nameLower.contains('soir') || nameLower.contains('gratitude'))) {
        routineId = routine.id;
        break;
      }
    }

    if (routineId != null) {
      // Si on a trouvé une routine, naviguer vers sa page
      context.go('/routines/$routineId');
    } else {
      // Sinon, naviguer vers la page des routines pour en créer une
      context.go('/routines');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Créez d\'abord une routine ${_getRoutineLabel(routineType)}'),
            backgroundColor: ModernColors.info,
          ),
        );
      }
    }
  }

  String _getRoutineLabel(String routineType) {
    switch (routineType) {
      case 'morning':
        return 'du matin';
      case 'protection':
        return 'de protection';
      case 'evening':
        return 'du soir';
      default:
        return '';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RISAQ Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5BA3A8),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const OptimizedHomePage(),
    );
  }
}

class OptimizedHomePage extends StatefulWidget {
  const OptimizedHomePage({super.key});

  @override
  State<OptimizedHomePage> createState() => _OptimizedHomePageState();
}

class _OptimizedHomePageState extends State<OptimizedHomePage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _statsController;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();

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

    // Démarrer les animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _statsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _listController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _statsController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Fond avec gradient élégant et visible
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF5BA3A8).withOpacity(0.25),
                  const Color(0xFF5BA3A8).withOpacity(0.12),
                  const Color(0xFF5BA3A8).withOpacity(0.05),
                  theme.colorScheme.surface,
                ],
                stops: const [0.0, 0.25, 0.5, 1.0],
              ),
            ),
          ),

          // Contenu principal
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header moderne et centré
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _headerController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - _headerController.value)),
                      child: Opacity(
                        opacity: _headerController.value,
                        child: Container(
                          height: 200 + statusBarHeight,
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
                              // Patterns décoratifs
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
                              // Contenu centré
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Logo
                                    Container(
                                      width: 65,
                                      height: 65,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.9),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.2),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.star,
                                        size: 35,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'RISAQ',
                                      style: TextStyle(
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
                                      style: TextStyle(
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
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Cartes de statistiques
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _statsController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset:
                          Offset(0, -35 - (15 * (1 - _statsController.value))),
                      child: Transform.scale(
                        scale: 0.92 + (0.08 * _statsController.value),
                        child: Opacity(
                          opacity: _statsController.value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStatsCard(
                                    context,
                                    title: 'Routines',
                                    value: '5',
                                    subtitle: 'Disponibles',
                                    icon: Icons.list_alt_rounded,
                                    color: const Color(0xFF4A90E2),
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
                                    color: const Color(0xFF50C878),
                                    progress: 0.6,
                                    showProgress: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bouton CTA
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _listController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - _listController.value)),
                      child: Opacity(
                        opacity: _listController.value,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: Material(
                            elevation: 8,
                            shadowColor:
                                theme.colorScheme.primary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.mediumImpact();
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

              // Section routines récentes
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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
                        onPressed: () {},
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

              // Liste des routines
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildRoutineCard(
                      context,
                      title: 'Prière du matin',
                      subtitle: 'Al-Fajr - 5 invocations',
                      time: '05:30',
                      color: const Color(0xFF4A90E2),
                    ),
                    const SizedBox(height: 10),
                    _buildRoutineCard(
                      context,
                      title: 'Protection quotidienne',
                      subtitle: 'Ayat al-Kursi + Adhkar',
                      time: '06:00',
                      color: const Color(0xFFE85D75),
                    ),
                    const SizedBox(height: 10),
                    _buildRoutineCard(
                      context,
                      title: 'Gratitude du soir',
                      subtitle: 'Remerciements et méditation',
                      time: '20:00',
                      color: const Color(0xFF50C878),
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 65,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, Icons.home_rounded, 'Accueil', true),
                _buildNavItem(
                    context, Icons.list_alt_rounded, 'Routines', false),
                const SizedBox(width: 60),
                _buildNavItem(
                    context, Icons.settings_rounded, 'Réglages', false),
              ],
            ),
          ),
        ),
      ),

      // FAB
      floatingActionButton: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
            },
            customBorder: const CircleBorder(),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
  }) {
    final theme = Theme.of(context);

    return Material(
      elevation: 3,
      shadowColor: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                ),
                const Spacer(),
                if (showProgress)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(progress! * 100).toInt()}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 26,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
            if (showProgress) ...[
              const SizedBox(height: 6),
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
    );
  }

  Widget _buildRoutineCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Material(
      elevation: 2,
      shadowColor: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: color,
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
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, bool isActive) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:go_router/go_router.dart';

import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';
import 'package:spiritual_routines/core/services/session_service.dart';
import 'package:spiritual_routines/core/utils/id.dart';
import 'package:spiritual_routines/features/session/session_state.dart';
import 'package:spiritual_routines/features/settings/user_settings_service.dart';
import 'package:spiritual_routines/l10n/app_localizations.dart';

// Design system moderne
import 'package:spiritual_routines/design_system/inspired_theme.dart';
import 'package:spiritual_routines/design_system/components/modern_task_card.dart';
import 'package:spiritual_routines/design_system/components/modern_navigation.dart';
import 'package:spiritual_routines/design_system/components/modern_layouts.dart';
import 'package:spiritual_routines/design_system/animations/premium_animations.dart';

// Period filter state
final selectedPeriodFilterProvider = StateProvider<String>((ref) => 'all');

class ModernRoutinesPage extends ConsumerWidget {
  const ModernRoutinesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesStream = ref.watch(routineDaoProvider).watchAll();
    final themesStream = ref.watch(themeDaoProvider).watchAll();
    final periodFilter = ref.watch(selectedPeriodFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Modern Header
          SliverToBoxAdapter(
            child: ModernAppBar(
              title: Text(
                  AppLocalizations.of(context)?.titleRoutines ?? 'Routines'),
              subtitle: const Text('Organisez vos pratiques spirituelles'),
              gradient: ModernGradients.header(theme.colorScheme),
              showBackButton: true,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => _showNewRoutineDialog(context, ref),
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    tooltip: 'Nouvelle routine',
                  ),
                ),
              ],
            ),
          ),

          // Contenu principal
          StreamBuilder<List<ThemeRow>>(
            stream: themesStream,
            builder: (context, themesSnap) {
              final cs = Theme.of(context).colorScheme;
              // Skeleton pendant le chargement des thèmes/routines
              if (themesSnap.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                        color: cs.surfaceContainer,
                                        borderRadius:
                                            BorderRadius.circular(12)))),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                        color: cs.surfaceContainer,
                                        borderRadius:
                                            BorderRadius.circular(12)))),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                        color: cs.surfaceContainer,
                                        borderRadius:
                                            BorderRadius.circular(12)))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        for (int i = 0; i < 3; i++) ...[
                          Container(
                            height: 72,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                                color: cs.surfaceContainer,
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              }
              final themes = themesSnap.data ?? const [];
              return StreamBuilder<List<RoutineRow>>(
                stream: routinesStream,
                builder: (context, routinesSnap) {
                  if (routinesSnap.connectionState == ConnectionState.waiting) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Skeleton de stats rapides
                            Row(
                              children: [
                                Expanded(
                                    child: Container(
                                        height: 80,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                            color: cs.surfaceContainer,
                                            borderRadius:
                                                BorderRadius.circular(16)))),
                                Expanded(
                                    child: Container(
                                        height: 80,
                                        margin: const EdgeInsets.only(left: 8),
                                        decoration: BoxDecoration(
                                            color: cs.surfaceContainer,
                                            borderRadius:
                                                BorderRadius.circular(16)))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Skeleton de listes
                            for (int i = 0; i < 4; i++) ...[
                              Container(
                                  height: 72,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                      color: cs.surfaceContainer,
                                      borderRadius: BorderRadius.circular(16))),
                            ]
                          ],
                        ),
                      ),
                    );
                  }
                  final routines = routinesSnap.data ?? const [];
                  final hasAny = routines.isNotEmpty;

                  if (!hasAny) {
                    return SliverToBoxAdapter(
                      child: _buildEmptyState(context, ref),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Filtres de période
                      _buildPeriodFilters(context, ref, periodFilter),

                      // Statistiques rapides
                      _buildQuickStats(context, routines, themes),

                      // Groupes de routines par période
                      _buildRoutineGroups(
                          context, ref, routines, themes, periodFilter),

                      // Espacement en bas
                      const SizedBox(height: 100),
                    ]),
                  );
                },
              );
            },
          ),
        ],
      ),

      // Bottom Navigation moderne
      bottomNavigationBar: ModernBottomNavigation(
        currentIndex: 1, // Index pour la page routines
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              break; // Déjà sur routines
            case 2:
              context.go('/settings');
              break;
          }
        },
        items: const [
          ModernNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Accueil',
          ),
          ModernNavItem(
            icon: Icons.list_alt_outlined,
            activeIcon: Icons.list_alt_rounded,
            label: 'Routines',
          ),
          ModernNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            label: 'Réglages',
          ),
        ],
      ),

      // FAB moderne
      floatingActionButton: ModernFloatingActionButton(
        onPressed: () => _showNewRoutineDialog(context, ref),
        icon: Icons.add_rounded,
        size: ModernFABSize.regular,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: ModernEmptyState(
        icon: Icons.self_improvement_rounded,
        title: 'Aucune routine',
        description:
            'Créez votre première routine spirituelle pour commencer votre cheminement de développement personnel.',
        actionText: 'Créer une routine',
        onAction: () => _showNewRoutineDialog(context, ref),
        illustration: ScaleAnimation(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: ModernGradients.primary(Theme.of(context).colorScheme),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.self_improvement_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodFilters(
      BuildContext context, WidgetRef ref, String periodFilter) {
    final periods = ['all', 'daily', 'weekly', 'monthly'];
    final l10n = AppLocalizations.of(context);

    String labelFor(String freq) => switch (freq) {
          'all' => l10n?.filterAll ?? 'Tous',
          'daily' => l10n?.filterDaily ?? 'Quotidien',
          'weekly' => l10n?.filterWeekly ?? 'Hebdomadaire',
          'monthly' => l10n?.filterMonthly ?? 'Mensuel',
          _ => freq,
        };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced filter header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filtrer par période',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Enhanced filter chips
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: periods.map((period) {
              final isSelected = periodFilter == period;
              return MicroInteractionAnimation(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  ref.read(selectedPeriodFilterProvider.notifier).state =
                      period;
                  await ref
                      .read(userSettingsServiceProvider)
                      .writeValue('routines_filter_period', period);
                },
                child: Builder(builder: (context) {
                  final cs = Theme.of(context).colorScheme;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    constraints: const BoxConstraints(minHeight: 52),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                cs.primary,
                                cs.primary.withOpacity(0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : cs.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : cs.outlineVariant.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          labelFor(period),
                          style: TextStyle(
                            color: isSelected ? Colors.white : cs.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: isSelected ? 15 : 14,
                            letterSpacing: isSelected ? 0.3 : 0,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
      BuildContext context, List<RoutineRow> routines, List<ThemeRow> themes) {
    final dailyCount = routines
        .where((r) =>
            themes.any((t) => t.id == r.themeId && t.frequency == 'daily'))
        .length;
    final weeklyCount = routines
        .where((r) =>
            themes.any((t) => t.id == r.themeId && t.frequency == 'weekly'))
        .length;
    final monthlyCount = routines
        .where((r) =>
            themes.any((t) => t.id == r.themeId && t.frequency == 'monthly'))
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Aperçu header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.dashboard_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Aperçu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ModernColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  '${routines.length} total',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Enhanced stats cards with better visuals
          Row(
            children: [
              Expanded(
                child: FadeInAnimation(
                  delay: const Duration(milliseconds: 100),
                  child: _buildEnhancedStatsCard(
                    context: context,
                    title: 'Quotidien',
                    value: '$dailyCount',
                    icon: Icons.wb_sunny_rounded,
                    color: const Color(0xFF4A90E2),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FadeInAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: _buildEnhancedStatsCard(
                    context: context,
                    title: 'Hebdo',
                    value: '$weeklyCount',
                    icon: Icons.view_week_rounded,
                    color: const Color(0xFF4CAF50),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FadeInAnimation(
                  delay: const Duration(milliseconds: 300),
                  child: _buildEnhancedStatsCard(
                    context: context,
                    title: 'Mensuel',
                    value: '$monthlyCount',
                    icon: Icons.calendar_month_rounded,
                    color: const Color(0xFFFF9800),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineGroups(
    BuildContext context,
    WidgetRef ref,
    List<RoutineRow> routines,
    List<ThemeRow> themes,
    String periodFilter,
  ) {
    final periods = ['daily', 'weekly', 'monthly'];
    final l10n = AppLocalizations.of(context);

    String labelFor(String freq) => switch (freq) {
          'daily' => l10n?.filterDaily ?? 'Quotidien',
          'weekly' => l10n?.filterWeekly ?? 'Hebdomadaire',
          'monthly' => l10n?.filterMonthly ?? 'Mensuel',
          _ => freq,
        };

    IconData iconFor(String freq) => switch (freq) {
          'daily' => Icons.wb_sunny_rounded,
          'weekly' => Icons.view_week_rounded,
          'monthly' => Icons.calendar_month_rounded,
          _ => Icons.schedule_rounded,
        };

    Color colorFor(String freq) => switch (freq) {
          'daily' => const Color(0xFF4A90E2),
          'weekly' => const Color(0xFF4CAF50),
          'monthly' => const Color(0xFFFF9800),
          _ => Theme.of(context).colorScheme.primary,
        };

    return Column(
      children: periods
          .where((period) => periodFilter == 'all' || periodFilter == period)
          .map((period) {
        final periodThemes =
            themes.where((t) => t.frequency == period).toList();
        final routinesInPeriod = routines
            .where((r) => periodThemes.any((t) => t.id == r.themeId))
            .toList();

        if (routinesInPeriod.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced section header with icon and color
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    // Period icon with colored background
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorFor(period),
                            colorFor(period).withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: colorFor(period).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        iconFor(period),
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            labelFor(period),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${routinesInPeriod.length} routine${routinesInPeriod.length > 1 ? 's' : ''} spirituelle${routinesInPeriod.length > 1 ? 's' : ''}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Action button
                    Container(
                      decoration: BoxDecoration(
                        color: colorFor(period).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () =>
                              _manageSubcategoriesDialog(context, ref, period),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.settings_rounded,
                                  size: 16,
                                  color: colorFor(period),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Gérer',
                                  style: TextStyle(
                                    color: colorFor(period),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Routine cards with staggered animation
              ModernVerticalFlow(
                animated: true,
                spacing: 14,
                padding: EdgeInsets.zero,
                children: routinesInPeriod.asMap().entries.map((entry) {
                  final index = entry.key;
                  final routine = entry.value;
                  return FadeInAnimation(
                    delay: Duration(milliseconds: 100 + (index * 50)),
                    child:
                        _buildModernRoutineCard(context, ref, routine, themes),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModernRoutineCard(
    BuildContext context,
    WidgetRef ref,
    RoutineRow routine,
    List<ThemeRow> themes,
  ) {
    final theme = themes.firstWhere(
      (t) => t.id == routine.themeId,
      orElse: () => ThemeRow(
        id: '',
        nameFr: 'Non classé',
        nameAr: 'غير مصنف',
        frequency: 'daily',
        createdAt: DateTime.now(),
        metadata: '{}',
      ),
    );

    final categoryColor =
        SpiritualCategories.colors[_getCategoryFromTheme(theme)] ??
            ModernColors.primary;

    final frequencyColor = switch (theme.frequency) {
      'daily' => const Color(0xFF4A90E2),
      'weekly' => const Color(0xFF4CAF50),
      'monthly' => const Color(0xFFFF9800),
      _ => ModernColors.primary,
    };

    return MicroInteractionAnimation(
      onTap: () => context.go('/routines/${routine.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.98),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: frequencyColor.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: frequencyColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.go('/routines/${routine.id}'),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Category icon with gradient background
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          categoryColor,
                          categoryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: categoryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getIconForCategory(_getCategoryFromTheme(theme)),
                      color: Colors.white,
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with enhanced typography
                        Text(
                          routine.nameFr,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    letterSpacing: -0.3,
                                    height: 1.2,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 6),

                        // Arabic name with RTL support
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            routine.nameAr,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontFamily: 'NotoNaskhArabic',
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  height: 1.3,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Theme badge with frequency indicator
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: frequencyColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: frequencyColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getFrequencyIcon(theme.frequency),
                                    size: 14,
                                    color: frequencyColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    theme.nameFr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: frequencyColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow with animation
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: frequencyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: frequencyColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    return switch (category) {
      'prayer' => Icons.mosque_rounded,
      'protection' => Icons.shield_rounded,
      'gratitude' => Icons.favorite_rounded,
      'reading' => Icons.menu_book_rounded,
      'meditation' => Icons.self_improvement_rounded,
      'dhikr' => Icons.loop_rounded,
      'charity' => Icons.volunteer_activism_rounded,
      'guidance' => Icons.explore_rounded,
      'healing' => Icons.healing_rounded,
      _ => Icons.auto_awesome_rounded,
    };
  }

  IconData _getFrequencyIcon(String frequency) {
    return switch (frequency) {
      'daily' => Icons.wb_sunny_outlined,
      'weekly' => Icons.view_week_outlined,
      'monthly' => Icons.calendar_today_outlined,
      _ => Icons.schedule_outlined,
    };
  }

  String _getCategoryFromTheme(ThemeRow theme) {
    // Mapper les thèmes vers les catégories spirituelles
    final name = theme.nameFr.toLowerCase();
    if (name.contains('matin') || name.contains('fajr')) return 'prayer';
    if (name.contains('protection') || name.contains('حماية'))
      return 'protection';
    if (name.contains('gratitude') || name.contains('شكر')) return 'gratitude';
    if (name.contains('lecture') || name.contains('قراءة')) return 'reading';
    if (name.contains('méditation') || name.contains('تأمل'))
      return 'meditation';
    if (name.contains('dhikr') || name.contains('ذكر')) return 'dhikr';
    if (name.contains('charité') || name.contains('صدقة')) return 'charity';
    if (name.contains('guidance') || name.contains('هداية')) return 'guidance';
    if (name.contains('guérison') || name.contains('شفاء')) return 'healing';
    return 'custom';
  }

  TaskPriority _getPriorityFromFrequency(String frequency) {
    switch (frequency) {
      case 'daily':
        return TaskPriority.high;
      case 'weekly':
        return TaskPriority.medium;
      case 'monthly':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  Widget _buildEnhancedStatsCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with enhanced background
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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

          const SizedBox(height: 12),

          // Value with animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: double.tryParse(value) ?? 0,
            ),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                animatedValue.toInt().toString(),
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 4),

          // Title
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog functions (reprises de l'original avec style moderne)
Future<void> _showNewRoutineDialog(BuildContext context, WidgetRef ref) async {
  final nameFrCtrl = TextEditingController();
  final nameArCtrl = TextEditingController();
  final subcatFrCtrl = TextEditingController();
  final subcatArCtrl = TextEditingController();
  String period = 'daily';
  final formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              ModernColors.primaryContainer.withOpacity(0.1),
            ],
          ),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: ModernGradients.primary(
                          Theme.of(context).colorScheme),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)?.newRoutine ??
                          'Nouvelle routine',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Nom FR
              TextFormField(
                controller: nameFrCtrl,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.nameFrLabel ??
                      'Nom (Français)',
                  prefixIcon: const Icon(Icons.title_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),

              const SizedBox(height: 16),

              // Nom AR
              TextFormField(
                controller: nameArCtrl,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.nameArLabel ??
                      'Nom (Arabe)',
                  prefixIcon: const Icon(Icons.translate_rounded),
                ),
              ),

              const SizedBox(height: 16),

              // Période
              DropdownButtonFormField<String>(
                value: period,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)?.periodLabel ?? 'Période',
                  prefixIcon: const Icon(Icons.schedule_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Quotidien')),
                  DropdownMenuItem(
                      value: 'weekly', child: Text('Hebdomadaire')),
                  DropdownMenuItem(value: 'monthly', child: Text('Mensuel')),
                ],
                onChanged: (v) => period = v ?? 'daily',
              ),

              const SizedBox(height: 16),

              // Catégorie FR
              TextFormField(
                controller: subcatFrCtrl,
                decoration: const InputDecoration(
                  labelText: 'Catégorie (Français)',
                  prefixIcon: Icon(Icons.category_rounded),
                  hintText: 'ex: Matin, Protection, Gratitude',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),

              const SizedBox(height: 16),

              // Catégorie AR
              TextFormField(
                controller: subcatArCtrl,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'Catégorie (Arabe)',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                          AppLocalizations.of(context)?.cancel ?? 'Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ModernCTAButton(
                      text: AppLocalizations.of(context)?.create ?? 'Créer',
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final themeDao = ref.read(themeDaoProvider);
                        final routineDao = ref.read(routineDaoProvider);

                        // Créer ou trouver le thème
                        final themeId = newId();
                        await themeDao.upsertTheme(ThemesCompanion.insert(
                          id: themeId,
                          nameFr: subcatFrCtrl.text.trim(),
                          nameAr: subcatArCtrl.text.trim().isEmpty
                              ? subcatFrCtrl.text.trim()
                              : subcatArCtrl.text.trim(),
                          frequency: period,
                        ));

                        // Créer la routine
                        final routineId = newId();
                        await routineDao.upsertRoutine(RoutinesCompanion.insert(
                          id: routineId,
                          themeId: themeId,
                          nameFr: nameFrCtrl.text.trim(),
                          nameAr: nameArCtrl.text.trim().isEmpty
                              ? nameFrCtrl.text.trim()
                              : nameArCtrl.text.trim(),
                          orderIndex: const drift.Value(9999),
                        ));

                        if (context.mounted) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Routine créée avec succès'),
                              backgroundColor: ModernColors.success,
                            ),
                          );
                          context.go('/routines/$routineId');
                        }
                      },
                      fullWidth: true,
                      animated: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// Fonction simplifiée pour gérer les sous-catégories
Future<void> _manageSubcategoriesDialog(
    BuildContext context, WidgetRef ref, String period) async {
  // Version simplifiée de la gestion des catégories
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Gestion des catégories $period - À implémenter'),
      backgroundColor: ModernColors.info,
    ),
  );
}

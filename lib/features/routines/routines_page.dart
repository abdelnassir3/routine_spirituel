import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:go_router/go_router.dart';

import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';
import 'package:spiritual_routines/core/services/session_service.dart';
import 'package:spiritual_routines/core/services/content_service.dart';
import 'package:spiritual_routines/core/utils/id.dart';
import 'package:spiritual_routines/core/widgets/responsive_layout.dart';
import 'package:spiritual_routines/features/session/session_state.dart';
import 'package:spiritual_routines/features/settings/user_settings_service.dart';
import 'package:spiritual_routines/l10n/app_localizations.dart';

// Period filter state: 'all' | 'daily' | 'weekly' | 'monthly'
final selectedPeriodFilterProvider = StateProvider<String>((ref) => 'all');

class RoutinesPage extends ConsumerWidget {
  const RoutinesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesStream = ref.watch(routineDaoProvider).watchAll();
    final themesStream = ref.watch(themeDaoProvider).watchAll();
    final periodFilter = ref.watch(selectedPeriodFilterProvider);

    // One-time load of saved period filter
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final saved = await ref
          .read(userSettingsServiceProvider)
          .readValue('routines_filter_period');
      if (saved != null && saved != periodFilter) {
        if (['all', 'daily', 'weekly', 'monthly'].contains(saved)) {
          ref.read(selectedPeriodFilterProvider.notifier).state = saved;
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
          title:
              Text(AppLocalizations.of(context)?.titleRoutines ?? 'Routines')),
      body: StreamBuilder<List<ThemeRow>>(
        stream: themesStream,
        builder: (context, themesSnap) {
          final themes = themesSnap.data ?? const [];
          return StreamBuilder<List<RoutineRow>>(
            stream: routinesStream,
            builder: (context, routinesSnap) {
              final routines = routinesSnap.data ?? const [];
              final hasAny = routines.isNotEmpty;

              // Group by frequency (period)
              const periods = ['daily', 'weekly', 'monthly'];
              final l10n = AppLocalizations.of(context);
              String labelFor(String freq) => switch (freq) {
                    'daily' => l10n?.filterDaily ?? 'Quotidien',
                    'weekly' => l10n?.filterWeekly ?? 'Hebdomadaire',
                    'monthly' => l10n?.filterMonthly ?? 'Mensuel',
                    _ => freq,
                  };

              return ListView(
                padding: ResponsiveUtils.getPadding(context),
                children: [
                  // Period quick filter
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(l10n?.filterAll ?? 'Tous'),
                        selected: periodFilter == 'all',
                        onSelected: (s) async {
                          if (!s) return;
                          ref
                              .read(selectedPeriodFilterProvider.notifier)
                              .state = 'all';
                          await ref
                              .read(userSettingsServiceProvider)
                              .writeValue('routines_filter_period', 'all');
                        },
                      ),
                      for (final p in periods)
                        ChoiceChip(
                          label: Text(labelFor(p)),
                          selected: periodFilter == p,
                          onSelected: (s) async {
                            if (!s) return;
                            ref
                                .read(selectedPeriodFilterProvider.notifier)
                                .state = p;
                            await ref
                                .read(userSettingsServiceProvider)
                                .writeValue('routines_filter_period', p);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (!hasAny) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n?.emptyRoutinesTitle ?? 'Aucune routine',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Text(
                                l10n?.emptyRoutinesBody ??
                                    'Créez une routine personnelle ou générez un exemple pour découvrir l\'interface.',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                FilledButton(
                                  onPressed: () =>
                                      _showNewRoutineDialog(context, ref),
                                  child: Text(
                                      l10n?.newRoutine ?? 'Nouvelle routine'),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.tonal(
                                  onPressed: () async => _seedExample(ref),
                                  child: Text(l10n?.generateExample ??
                                      'Générer un exemple'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],

                  for (final period in periods) ...[
                    if (periodFilter != 'all' && periodFilter != period)
                      const SizedBox.shrink()
                    else
                      Builder(builder: (context) {
                        final periodThemes =
                            themes.where((t) => t.frequency == period).toList();
                        final routinesInPeriod = routines
                            .where((r) =>
                                periodThemes.any((t) => t.id == r.themeId))
                            .toList();
                        if (routinesInPeriod.isEmpty)
                          return const SizedBox.shrink();
                        final countPeriod = routinesInPeriod.length;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4, bottom: 8, top: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      labelFor(period),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                  Chip(label: Text('$countPeriod')),
                                  TextButton.icon(
                                    onPressed: () => _manageSubcategoriesDialog(
                                        context, ref, period),
                                    icon: const Icon(Icons.settings_rounded,
                                        size: 18),
                                    label: Text(l10n?.manage ?? 'Gérer'),
                                  ),
                                ],
                              ),
                            ),
                            _PeriodThemesReorderable(
                                period: period,
                                themes: periodThemes,
                                routines: routines),
                            const SizedBox(height: 16),
                          ],
                        );
                      }),
                  ],

                  const SizedBox(height: 80),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewRoutineDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Routine'),
      ),
    );
  }
}

class _RoutineCard extends ConsumerWidget {
  final RoutineRow row;
  final bool showDragHandle;
  final int? dragIndex;
  const _RoutineCard(
      {required this.row, this.showDragHandle = false, this.dragIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.self_improvement_rounded, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.nameFr,
                        style: Theme.of(context).textTheme.titleMedium,
                        softWrap: true,
                      ),
                      const SizedBox(height: 2),
                      Text('Ordre: ${row.orderIndex}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (showDragHandle && dragIndex != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: ReorderableDragStartListener(
                      index: dragIndex!,
                      child: const Icon(Icons.drag_indicator_rounded),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () => context.go('/routines/${row.id}'),
                  child: const Text('Ouvrir'),
                ),
                FilledButton(
                  onPressed: () async {
                    final sessionId = await ref
                        .read(sessionServiceProvider)
                        .startRoutine(row.id);
                    ref.read(currentSessionIdProvider.notifier).state =
                        sessionId;
                    if (context.mounted) context.go('/reader');
                  },
                  child: const Text('Démarrer'),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Plus',
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit':
                        if (context.mounted) context.go('/routines/${row.id}');
                        break;
                      case 'delete':
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Supprimer la routine ?'),
                            content: Text(
                                '“${row.nameFr}” sera supprimée définitivement.'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Annuler')),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Supprimer'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await ref.read(routineDaoProvider).deleteById(row.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Routine supprimée')),
                            );
                          }
                        }
                        break;
                    }
                  },
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(value: 'edit', child: Text('Modifier')),
                    PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _PeriodThemesReorderable extends ConsumerStatefulWidget {
  final String period;
  final List<ThemeRow> themes;
  final List<RoutineRow> routines;
  const _PeriodThemesReorderable(
      {required this.period, required this.themes, required this.routines});

  @override
  ConsumerState<_PeriodThemesReorderable> createState() =>
      _PeriodThemesReorderableState();
}

class _PeriodThemesReorderableState
    extends ConsumerState<_PeriodThemesReorderable> {
  late List<String> _order; // theme ids in display order
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _syncOrderWithThemes(initial: true);
  }

  @override
  void didUpdateWidget(covariant _PeriodThemesReorderable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If themes changed (add/remove), sync while preserving existing order
    if (oldWidget.themes.map((e) => e.id).toSet() !=
        widget.themes.map((e) => e.id).toSet()) {
      _syncOrderWithThemes();
    }
  }

  Future<void> _syncOrderWithThemes({bool initial = false}) async {
    final settings = ref.read(userSettingsServiceProvider);
    final key = 'themes_order_${widget.period}';
    final saved = await settings.readValue(key);
    final currentIds = widget.themes.map((e) => e.id).toList();
    List<String> order;
    if (saved != null) {
      try {
        final parts = saved.split(',');
        order = parts.where((id) => currentIds.contains(id)).toList();
        // append any new ids at end
        for (final id in currentIds) {
          if (!order.contains(id)) order.add(id);
        }
      } catch (_) {
        order = currentIds;
      }
    } else {
      order = currentIds;
    }
    if (mounted) {
      setState(() {
        _order = order;
        _initialized = true;
      });
    }
    if (initial) await settings.writeValue(key, _order.join(','));
  }

  Future<void> _persist() async {
    final settings = ref.read(userSettingsServiceProvider);
    final key = 'themes_order_${widget.period}';
    await settings.writeValue(key, _order.join(','));
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SizedBox.shrink();
    }
    // Map id->ThemeRow
    final byId = {for (final t in widget.themes) t.id: t};
    final items =
        _order.where(byId.containsKey).map((id) => byId[id]!).toList();

    int countFor(String themeId) =>
        widget.routines.where((r) => r.themeId == themeId).length;
    final expandByDefault = items.length <= 2;

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      proxyDecorator: (child, index, animation) => Material(
        elevation: 6,
        color: Colors.transparent,
        child: child,
      ),
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) newIndex -= 1;
        final updated = List<String>.from(_order);
        final moved = updated.removeAt(oldIndex);
        updated.insert(newIndex, moved);
        setState(() => _order = updated);
        await _persist();
        // Haptic + feedback
        final hapticsOn = (await ref
                .read(userSettingsServiceProvider)
                .readValue('ui_reorder_haptics')) !=
            'off';
        if (hapticsOn) await HapticFeedback.selectionClick();
        final showSnack = (await ref
                .read(userSettingsServiceProvider)
                .readValue('ui_reorder_snackbar')) !=
            'off';
        if (mounted && showSnack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context)?.reorderCategoriesUpdated ??
                      'Ordre des catégories mis à jour'),
              duration: const Duration(milliseconds: 800),
            ),
          );
        }
      },
      itemCount: items.length,
      itemBuilder: (context, index) {
        final th = items[index];
        final count = countFor(th.id);
        return Container(
          key: ValueKey('theme_${th.id}'),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ExpansionTile(
            initiallyExpanded: expandByDefault,
            leading: const Icon(Icons.label_rounded),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    th.nameFr,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(label: Text('$count')),
                const SizedBox(width: 8),
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_indicator_rounded),
                ),
              ],
            ),
            children: [
              _ThemeRoutinesReorderable(
                themeId: th.id,
                routines:
                    widget.routines.where((r) => r.themeId == th.id).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeRoutinesReorderable extends ConsumerStatefulWidget {
  final String themeId;
  final List<RoutineRow> routines;
  const _ThemeRoutinesReorderable(
      {required this.themeId, required this.routines});

  @override
  ConsumerState<_ThemeRoutinesReorderable> createState() =>
      _ThemeRoutinesReorderableState();
}

class _ThemeRoutinesReorderableState
    extends ConsumerState<_ThemeRoutinesReorderable> {
  late List<String> _order; // routine ids

  @override
  void initState() {
    super.initState();
    _syncFromProps();
  }

  @override
  void didUpdateWidget(covariant _ThemeRoutinesReorderable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routines.map((e) => e.id).toSet() !=
            widget.routines.map((e) => e.id).toSet() ||
        !_isSameOrder(oldWidget.routines, widget.routines)) {
      _syncFromProps();
    }
  }

  void _syncFromProps() {
    final sorted = [...widget.routines]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    _order = sorted.map((e) => e.id).toList();
  }

  bool _isSameOrder(List<RoutineRow> a, List<RoutineRow> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].orderIndex != b[i].orderIndex)
        return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final byId = {for (final r in widget.routines) r.id: r};
    final items =
        _order.where(byId.containsKey).map((id) => byId[id]!).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    // Affichage adaptatif selon le type d'appareil
    if (!ResponsiveLayout.isMobile(context) ||
        ResponsiveLayout.isFoldable(context)) {
      final crossAxisCount = ResponsiveUtils.getCrossAxisCount(context);
      final spacing = ResponsiveUtils.getSpacing(context);
      final aspectRatio = ResponsiveUtils.getCardAspectRatio(context);

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount > 2
              ? crossAxisCount - 1
              : crossAxisCount, // Ajuster pour les routines
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: aspectRatio,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final r = items[index];
          return _RoutineCard(row: r, showDragHandle: false, dragIndex: index);
        },
      );
    }

    // Sur mobile, garder la liste réorganisable
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) newIndex -= 1;
        final updated = List<String>.from(_order);
        final moved = updated.removeAt(oldIndex);
        updated.insert(newIndex, moved);
        setState(() => _order = updated);
        // persist order
        final routineDao = ref.read(routineDaoProvider);
        for (int i = 0; i < updated.length; i++) {
          await routineDao.updateOrder(updated[i], i);
        }
        final hapticsOn = (await ref
                .read(userSettingsServiceProvider)
                .readValue('ui_reorder_haptics')) !=
            'off';
        if (hapticsOn) await HapticFeedback.lightImpact();
        final showSnack = (await ref
                .read(userSettingsServiceProvider)
                .readValue('ui_reorder_snackbar')) !=
            'off';
        if (mounted && showSnack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context)?.reorderRoutinesUpdated ??
                      'Ordre des routines mis à jour'),
              duration: const Duration(milliseconds: 800),
            ),
          );
        }
      },
      itemCount: items.length,
      itemBuilder: (context, index) {
        final r = items[index];
        return Container(
          key: ValueKey('routine_${r.id}'),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: _RoutineCard(row: r, showDragHandle: true, dragIndex: index),
        );
      },
    );
  }
}

Future<void> _showNewRoutineDialog(BuildContext context, WidgetRef ref) async {
  final nameFrCtrl = TextEditingController();
  final nameArCtrl = TextEditingController();
  final subcatFrCtrl = TextEditingController();
  final subcatArCtrl = TextEditingController();
  String period = 'daily';
  final formKey = GlobalKey<FormState>();

  // Prefill with last used values (if any)
  final settings = ref.read(userSettingsServiceProvider);
  final lastPeriod = await settings.readValue('last_routine_period');
  final lastSubFr = await settings.readValue('last_routine_subcat_fr');
  final lastSubAr = await settings.readValue('last_routine_subcat_ar');
  if (lastPeriod != null &&
      ['daily', 'weekly', 'monthly'].contains(lastPeriod)) {
    period = lastPeriod;
  }
  if ((lastSubFr ?? '').isNotEmpty) subcatFrCtrl.text = lastSubFr!;
  if ((lastSubAr ?? '').isNotEmpty) subcatArCtrl.text = lastSubAr!;

  // Existing subcategories (themes) for suggestions
  final allThemes = await ref.read(themeDaoProvider).all();

  List<Map<String, String>> periodSuggestions(String p) {
    switch (p) {
      case 'weekly':
        return const [
          {'fr': 'Bilan', 'ar': 'تقييم'},
          {'fr': 'Objectifs', 'ar': 'أهداف'},
          {'fr': 'Jeûne', 'ar': 'صيام'},
          {'fr': 'Lecture', 'ar': 'قراءة'},
          {'fr': 'Protection', 'ar': 'حماية'},
        ];
      case 'monthly':
        return const [
          {'fr': 'Aumône', 'ar': 'صدقة'},
          {'fr': 'Révision', 'ar': 'مراجعة'},
          {'fr': 'Objectifs', 'ar': 'أهداف'},
          {'fr': 'Planification', 'ar': 'تخطيط'},
        ];
      case 'daily':
      default:
        return const [
          {'fr': 'Matin', 'ar': 'صباح'},
          {'fr': 'Soir', 'ar': 'مساء'},
          {'fr': 'Protection', 'ar': 'حماية'},
          {'fr': 'Gratitude', 'ar': 'شكر'},
          {'fr': 'Guérison', 'ar': 'شفاء'},
          {'fr': 'Guidance', 'ar': 'هداية'},
        ];
    }
  }

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title:
          Text(AppLocalizations.of(context)?.newRoutine ?? 'Nouvelle routine'),
      content: StatefulBuilder(
        builder: (context, setState) {
          final suggs = periodSuggestions(period);
          final existingForPeriod = allThemes
              .where((t) => t.frequency == period)
              .toList()
            ..sort((a, b) =>
                a.nameFr.toLowerCase().compareTo(b.nameFr.toLowerCase()));
          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameFrCtrl,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.nameFrLabel ??
                          'Nom FR'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameArCtrl,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.nameArLabel ??
                          'Nom AR'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: period,
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)?.periodLabel ??
                                    'Période'),
                        items: const [
                          DropdownMenuItem(
                              value: 'daily', child: Text('Quotidien')),
                          DropdownMenuItem(
                              value: 'weekly', child: Text('Hebdomadaire')),
                          DropdownMenuItem(
                              value: 'monthly', child: Text('Mensuel')),
                        ],
                        onChanged: (v) => setState(() => period = v ?? 'daily'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: subcatFrCtrl,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.subcatFrLabel ??
                          'Sous-catégorie FR (ex: Richesse, Pardon)'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: subcatArCtrl,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.subcatArLabel ??
                          'Sous-catégorie AR'),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      AppLocalizations.of(context)?.suggestions ??
                          'Suggestions',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final s in suggs)
                      ActionChip(
                        label: Text(s['fr']!),
                        onPressed: () {
                          subcatFrCtrl.text = s['fr']!;
                          subcatArCtrl.text = s['ar']!;
                        },
                      ),
                  ],
                ),
                if (existingForPeriod.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Existants',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final t in existingForPeriod)
                        ActionChip(
                          label: Text(t.nameFr),
                          onPressed: () {
                            subcatFrCtrl.text = t.nameFr;
                            subcatArCtrl.text = t.nameAr;
                          },
                        ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Annuler')),
        FilledButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            final themeDao = ref.read(themeDaoProvider);
            final routineDao = ref.read(routineDaoProvider);
            // Find or create theme for selected period + subcategory
            final themes = await themeDao.all();
            final scFr = subcatFrCtrl.text.trim();
            final scAr = subcatArCtrl.text.trim().isEmpty
                ? scFr
                : subcatArCtrl.text.trim();
            final existing = themes.firstWhere(
              (t) =>
                  t.frequency == period &&
                  t.nameFr.toLowerCase() == scFr.toLowerCase(),
              orElse: () => ThemeRow(
                id: '',
                nameFr: '',
                nameAr: '',
                frequency: '',
                createdAt: DateTime.now(),
                metadata: '{}',
              ),
            );
            final themeId = existing.id.isNotEmpty ? existing.id : newId();
            if (existing.id.isEmpty) {
              await themeDao.upsertTheme(ThemesCompanion.insert(
                id: themeId,
                nameFr: scFr,
                nameAr: scAr,
                frequency: period,
              ));
            }
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
            // Remember last used values
            await settings.writeValue('last_routine_period', period);
            await settings.writeValue('last_routine_subcat_fr', scFr);
            await settings.writeValue('last_routine_subcat_ar', scAr);
            if (context.mounted) {
              Navigator.of(ctx).pop();
              context.go('/routines/$routineId');
            }
          },
          child: Text(AppLocalizations.of(context)?.create ?? 'Créer'),
        ),
      ],
    ),
  );
}

Future<void> _manageSubcategoriesDialog(
    BuildContext context, WidgetRef ref, String period) async {
  final themeDao = ref.read(themeDaoProvider);
  final routineDao = ref.read(routineDaoProvider);
  var allThemes = await themeDao.all();
  var allRoutines = await routineDao.watchAll().first;
  List<ThemeRow> periodThemes =
      allThemes.where((t) => t.frequency == period).toList();

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        int countFor(String themeId) =>
            allRoutines.where((r) => r.themeId == themeId).length;

        Future<void> renameTheme(ThemeRow th) async {
          final frCtrl = TextEditingController(text: th.nameFr);
          final arCtrl = TextEditingController(text: th.nameAr);
          final formKey = GlobalKey<FormState>();
          final ok = await showDialog<bool>(
            context: ctx,
            builder: (_) => AlertDialog(
              title: const Text('Renommer la sous-catégorie'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: frCtrl,
                      decoration: const InputDecoration(labelText: 'Nom FR'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requis' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: arCtrl,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(labelText: 'Nom AR'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(_).pop(false),
                    child: const Text('Annuler')),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(_).pop(true);
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
          );
          if (ok == true) {
            await themeDao.upsertTheme(ThemesCompanion(
              id: drift.Value(th.id),
              nameFr: drift.Value(frCtrl.text.trim()),
              nameAr: drift.Value(arCtrl.text.trim().isEmpty
                  ? frCtrl.text.trim()
                  : arCtrl.text.trim()),
              frequency: drift.Value(period),
            ));
            allThemes = await themeDao.all();
            periodThemes =
                allThemes.where((t) => t.frequency == period).toList();
            setState(() {});
          }
        }

        Future<String?> addTheme() async {
          final frCtrl = TextEditingController();
          final arCtrl = TextEditingController();
          final formKey = GlobalKey<FormState>();
          final ok = await showDialog<bool>(
            context: ctx,
            builder: (_) => AlertDialog(
              title: const Text('Ajouter une sous-catégorie'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: frCtrl,
                      decoration: const InputDecoration(labelText: 'Nom FR'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requis' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: arCtrl,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(labelText: 'Nom AR'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(_).pop(false),
                    child: const Text('Annuler')),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(_).pop(true);
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          );
          if (ok == true) {
            final newThemeId = newId();
            await themeDao.upsertTheme(ThemesCompanion.insert(
              id: newThemeId,
              nameFr: frCtrl.text.trim(),
              nameAr: arCtrl.text.trim().isEmpty
                  ? frCtrl.text.trim()
                  : arCtrl.text.trim(),
              frequency: period,
            ));
            allThemes = await themeDao.all();
            periodThemes =
                allThemes.where((t) => t.frequency == period).toList();
            setState(() {});
            return newThemeId;
          }
          return null;
        }

        Future<void> tryDelete(ThemeRow th) async {
          final count = countFor(th.id);
          if (count > 0) {
            // Offer reassignment to another theme
            String? selectedId;
            final confirmed = await showDialog<bool>(
              context: ctx,
              builder: (_) => StatefulBuilder(
                builder: (c, setLocal) {
                  final others =
                      periodThemes.where((t) => t.id != th.id).toList();
                  selectedId ??= others.isNotEmpty ? others.first.id : null;
                  return AlertDialog(
                    title: const Text('Réaffecter et supprimer'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            'Cette sous-catégorie contient $count routine(s). Choisissez une destination:'),
                        const SizedBox(height: 12),
                        if (others.isNotEmpty)
                          DropdownButtonFormField<String>(
                            value: selectedId,
                            items: [
                              for (final o in others)
                                DropdownMenuItem(
                                    value: o.id, child: Text(o.nameFr)),
                            ],
                            onChanged: (v) => setLocal(() => selectedId = v),
                            decoration:
                                const InputDecoration(labelText: 'Destination'),
                          )
                        else
                          const Text(
                              'Aucune autre sous-catégorie. Créez-en une pour continuer.'),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () async {
                              final newId = await addTheme();
                              if (newId != null)
                                setLocal(() => selectedId = newId);
                            },
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Nouvelle sous-catégorie'),
                          ),
                        )
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(c).pop(false),
                          child: const Text('Annuler')),
                      FilledButton(
                        onPressed: selectedId == null
                            ? null
                            : () => Navigator.of(c).pop(true),
                        child: const Text('Réaffecter'),
                      ),
                    ],
                  );
                },
              ),
            );
            if (confirmed == true && selectedId != null) {
              await routineDao.reassignTheme(th.id, selectedId!);
              allRoutines = await routineDao.watchAll().first;
              await themeDao.deleteById(th.id);
              allThemes = await themeDao.all();
              periodThemes =
                  allThemes.where((t) => t.frequency == period).toList();
              setState(() {});
            }
            return;
          }
          // No routines: simple delete confirm
          final ok = await showDialog<bool>(
            context: ctx,
            builder: (_) => AlertDialog(
              title: const Text('Supprimer la sous-catégorie ?'),
              content: Text('“${th.nameFr}” sera supprimée.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(_).pop(false),
                    child: const Text('Annuler')),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(ctx).colorScheme.error),
                  onPressed: () => Navigator.of(_).pop(true),
                  child: const Text('Supprimer'),
                ),
              ],
            ),
          );
          if (ok == true) {
            await themeDao.deleteById(th.id);
            allThemes = await themeDao.all();
            periodThemes =
                allThemes.where((t) => t.frequency == period).toList();
            setState(() {});
          }
        }

        // Sort by routine count (desc) then name
        final sortedPeriodThemes = [...periodThemes]..sort((a, b) {
            final ca = countFor(a.id);
            final cb = countFor(b.id);
            if (cb != ca) return cb.compareTo(ca);
            return a.nameFr.toLowerCase().compareTo(b.nameFr.toLowerCase());
          });

        return AlertDialog(
          title: Text(
              'Gérer les sous-catégories — ${period == 'daily' ? 'Quotidien' : period == 'weekly' ? 'Hebdomadaire' : 'Mensuel'}'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (periodThemes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('Aucune sous-catégorie pour cette période.',
                        style: Theme.of(ctx).textTheme.bodyMedium),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: sortedPeriodThemes.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final th = sortedPeriodThemes[i];
                        final cnt = countFor(th.id);
                        return ListTile(
                          leading: const Icon(Icons.label_rounded),
                          title: Text(th.nameFr),
                          subtitle: Text(th.nameAr),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(label: Text('$cnt')),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                onSelected: (v) async {
                                  switch (v) {
                                    case 'rename':
                                      renameTheme(th);
                                      break;
                                    case 'reassign':
                                      // direct reassignment without deletion
                                      String? selectedId;
                                      await showDialog<bool>(
                                        context: ctx,
                                        builder: (_) => StatefulBuilder(
                                          builder: (c, setLocal) {
                                            final others = periodThemes
                                                .where((t) => t.id != th.id)
                                                .toList();
                                            selectedId ??= others.isNotEmpty
                                                ? others.first.id
                                                : null;
                                            return AlertDialog(
                                              title: const Text(
                                                  'Réaffecter les routines'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                      'Déplacer $cnt routine(s) vers:'),
                                                  const SizedBox(height: 12),
                                                  if (others.isNotEmpty)
                                                    DropdownButtonFormField<
                                                        String>(
                                                      value: selectedId,
                                                      items: [
                                                        for (final o in others)
                                                          DropdownMenuItem(
                                                              value: o.id,
                                                              child: Text(
                                                                  o.nameFr)),
                                                      ],
                                                      onChanged: (v) =>
                                                          setLocal(() =>
                                                              selectedId = v),
                                                      decoration:
                                                          const InputDecoration(
                                                              labelText:
                                                                  'Destination'),
                                                    )
                                                  else
                                                    const Text(
                                                        'Aucune autre sous-catégorie. Créez-en une pour continuer.'),
                                                  const SizedBox(height: 8),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: TextButton.icon(
                                                      onPressed: () async {
                                                        final newId =
                                                            await addTheme();
                                                        if (newId != null)
                                                          setLocal(() =>
                                                              selectedId =
                                                                  newId);
                                                      },
                                                      icon: const Icon(
                                                          Icons.add_rounded),
                                                      label: const Text(
                                                          'Nouvelle sous-catégorie'),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(c)
                                                            .pop(false),
                                                    child:
                                                        const Text('Annuler')),
                                                FilledButton(
                                                  onPressed: selectedId == null
                                                      ? null
                                                      : () async {
                                                          await routineDao
                                                              .reassignTheme(
                                                                  th.id,
                                                                  selectedId!);
                                                          allRoutines =
                                                              await routineDao
                                                                  .watchAll()
                                                                  .first;
                                                          Navigator.of(c)
                                                              .pop(true);
                                                          setState(() {});
                                                        },
                                                  child:
                                                      const Text('Réaffecter'),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      );
                                      break;
                                    case 'delete':
                                      tryDelete(th);
                                      break;
                                  }
                                },
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                      value: 'rename',
                                      child: Text(AppLocalizations.of(context)
                                              ?.rename ??
                                          'Renommer')),
                                  PopupMenuItem(
                                      value: 'reassign',
                                      child: Text(AppLocalizations.of(context)
                                              ?.reassign ??
                                          'Réaffecter')),
                                  PopupMenuItem(
                                      value: 'delete',
                                      child: Text(AppLocalizations.of(context)
                                              ?.delete ??
                                          'Supprimer')),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Fermer')),
            FilledButton.icon(
                onPressed: addTheme,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Ajouter')),
          ],
        );
      },
    ),
  );
}

Future<void> _seedExample(WidgetRef ref) async {
  final themeDao = ref.read(themeDaoProvider);
  final routineDao = ref.read(routineDaoProvider);
  final taskDao = ref.read(taskDaoProvider);
  final content = ref.read(contentServiceProvider);

  final themeId = newId();
  await themeDao.upsertTheme(ThemesCompanion.insert(
    id: themeId,
    nameFr: 'Matin',
    nameAr: 'صباح',
    frequency: 'daily',
  ));

  final routineId = newId();
  await routineDao.upsertRoutine(RoutinesCompanion.insert(
    id: routineId,
    themeId: themeId,
    nameFr: 'Routine du matin',
    nameAr: 'ورد الصباح',
    orderIndex: const drift.Value(0),
  ));

  final t1 = newId();
  await taskDao.upsertTask(TasksCompanion.insert(
    id: t1,
    routineId: routineId,
    type: 'text',
    category: 'gratitude',
    defaultReps: const drift.Value(3),
    orderIndex: const drift.Value(0),
    notesFr: const drift.Value('Rappel de gratitude'),
    notesAr: const drift.Value('ذكر الشكر'),
  ));
  await content.putContent(
    taskId: t1,
    locale: 'fr',
    kind: 'text',
    title: 'Gratitude',
    body: 'Merci pour cette nouvelle journée.',
  );
  await content.putContent(
    taskId: t1,
    locale: 'ar',
    kind: 'text',
    title: 'الشكر',
    body: 'الحمد لله على هذا اليوم الجديد.',
  );
}

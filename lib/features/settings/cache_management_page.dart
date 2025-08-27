import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/services/tts_cache_service.dart';
import 'package:spiritual_routines/design_system/inspired_theme.dart';

class CacheManagementPage extends ConsumerWidget {
  const CacheManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final routinesStream = ref.watch(routineDaoProvider).watchAll();

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Modern gradient header
            Container(
              decoration: BoxDecoration(
                gradient: ModernGradients.header(cs),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Row(
                    children: [
                      // Back button
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.30),
                              Colors.white.withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.40),
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Gestion du cache TTS',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Global cache stats + quick actions card
                      _GlobalCacheCard(),
                      const SizedBox(height: 16),

                      // Per-routine cache stats card
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                              width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: StreamBuilder(
                          stream: routinesStream,
                          builder: (context, snapshot) {
                            final routines = snapshot.data ?? const [];
                            if (routines.isEmpty) {
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 20, 16, 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inbox_rounded,
                                        color: cs.onSurfaceVariant, size: 32),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Aucune routine',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: cs.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Créez une routine pour gérer son cache audio.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: routines.length,
                              separatorBuilder: (_, __) =>
                                  Divider(height: 1, color: cs.outlineVariant),
                              itemBuilder: (context, i) {
                                final r = routines[i];
                                return FutureBuilder<(int, int)>(
                                  future: ref
                                      .read(ttsCacheServiceProvider)
                                      .statsForRoutine(r.id),
                                  builder: (context, snap) {
                                    final files = (snap.data?.$1 ?? 0);
                                    final bytes = (snap.data?.$2 ?? 0);
                                    final mb = (bytes / (1024 * 1024))
                                        .toStringAsFixed(2);
                                    final hasCache = files > 0;

                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                      leading: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: cs.primary.withOpacity(0.10),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.auto_awesome_rounded,
                                            color: cs.primary),
                                      ),
                                      title: Text(
                                        r.nameFr,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      subtitle: Text(
                                        hasCache
                                            ? '$files fichiers • $mb Mo'
                                            : 'Aucun cache pour cette routine',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: cs.onSurfaceVariant),
                                      ),
                                      trailing: hasCache
                                          ? FilledButton.tonalIcon(
                                              onPressed: () async {
                                                final removed = await ref
                                                    .read(
                                                        ttsCacheServiceProvider)
                                                    .clearRoutine(r.id);
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Cache vidé ($removed fichiers)')),
                                                  );
                                                }
                                              },
                                              icon: const Icon(
                                                  Icons.delete_outline_rounded),
                                              label: const Text('Vider'),
                                            )
                                          : null,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlobalCacheCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_GlobalCacheCard> createState() => _GlobalCacheCardState();
}

class _GlobalCacheCardState extends ConsumerState<_GlobalCacheCard> {
  int _bytes = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      _bytes = await ref.read(ttsCacheServiceProvider).sizeBytes();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mb = (_bytes / (1024 * 1024)).toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.cloud_queue_rounded, color: cs.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cache audio total',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _loading ? 'Calcul en cours…' : '$mb Mo utilisés',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _loading
                    ? null
                    : () async {
                        await ref.read(ttsCacheServiceProvider).clear();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Cache audio totalement vidé')),
                          );
                          await _refresh();
                        }
                      },
                icon: const Icon(Icons.delete_sweep_rounded),
                label: const Text('Vider tout'),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                onPressed: _loading
                    ? null
                    : () async {
                        final removed = await ref
                            .read(ttsCacheServiceProvider)
                            .purgeOlderThan(const Duration(days: 30));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Anciens fichiers supprimés: $removed')),
                          );
                          await _refresh();
                        }
                      },
                icon: const Icon(Icons.history_toggle_off_rounded),
                label: const Text('Purger > 30 jours'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

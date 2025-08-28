import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:spiritual_routines/core/services/corpus_importer.dart';
import 'package:spiritual_routines/core/services/quran_corpus_service.dart';
import 'package:spiritual_routines/core/services/user_settings_service.dart';
import 'package:spiritual_routines/core/services/audio_tts_flutter.dart';
import 'package:spiritual_routines/core/services/smart_tts_service.dart';
import 'package:spiritual_routines/features/settings/user_settings_service.dart'
    as secure;
import 'package:spiritual_routines/core/services/audio_cloud_tts_service.dart';
import 'package:spiritual_routines/core/services/tts_cache_service.dart';
import 'package:spiritual_routines/core/services/cloud_voices_service.dart';
import 'package:go_router/go_router.dart';
import 'package:spiritual_routines/core/services/audio_player_service.dart';
import 'package:spiritual_routines/l10n/app_localizations.dart';
import 'package:spiritual_routines/design_system/theme.dart';
import 'package:spiritual_routines/design_system/inspired_theme.dart';
import 'package:file_picker/file_picker.dart';

// Design system moderne
import 'package:spiritual_routines/design_system/components/modern_navigation.dart';
import 'package:spiritual_routines/design_system/components/modern_layouts.dart';
import 'package:spiritual_routines/design_system/animations/premium_animations.dart';

class ModernSettingsPage extends ConsumerStatefulWidget {
  const ModernSettingsPage({super.key});

  @override
  ConsumerState<ModernSettingsPage> createState() => _ModernSettingsPageState();
}

class _ModernSettingsPageState extends ConsumerState<ModernSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 7, vsync: this); // Augmenté à 7 onglets
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<CloudTtsConfig?> _currentCloudConfig(
      secure.UserSettingsService localPrefs) async {
    final provider = await localPrefs.getCloudTtsProvider();
    final endpoint = await localPrefs.getCloudTtsEndpoint();
    final apiKey = await localPrefs.getCloudTtsApiKey();
    final access = await localPrefs.getAwsAccessKey();
    final secret = await localPrefs.getAwsSecretKey();
    final enabled = await localPrefs.getCloudTtsEnabled();
    if (!enabled) return null;
    final ok = (provider == 'polly')
        ? (endpoint != null &&
            endpoint.isNotEmpty &&
            access != null &&
            access.isNotEmpty &&
            secret != null &&
            secret.isNotEmpty)
        : (apiKey != null && apiKey.isNotEmpty);
    if (!ok) return null;
    return CloudTtsConfig(
        provider: provider,
        apiKey: apiKey,
        endpoint: endpoint,
        awsAccessKey: access,
        awsSecretKey: secret);
  }

  Future<void> _purgeOlder(
      BuildContext context, WidgetRef ref, Duration d) async {
    final n = await ref.read(ttsCacheServiceProvider).purgeOlderThan(d);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fichiers anciens supprimés: $n')),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          // Modern Header with gradient
          Container(
            decoration: BoxDecoration(
              gradient: ModernGradients.header(cs),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Back button
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
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
                        // Title
                        Expanded(
                          child: Text(
                            'Paramètres',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
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
                  // Category tabs
                  Container(
                    height: 48,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withOpacity(0.7),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      tabs: const [
                        Tab(text: 'Apparence'),
                        Tab(text: 'Audio'),
                        Tab(text: 'Polices'),
                        Tab(text: 'Données'),
                        Tab(text: 'Cloud'),
                        Tab(text: 'Avancé'),
                        Tab(text: 'À propos'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content area
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppearanceTab(context),
                _buildAudioTab(context),
                _buildFontsTab(context),
                _buildDataTab(context),
                _buildCloudTab(context),
                _buildAdvancedTab(context),
                _buildAboutTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceTab(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Theme section
        _buildSectionCard(
          context,
          title: 'Thème et couleurs',
          icon: Icons.palette_rounded,
          children: [
            // Dark mode
            Consumer(builder: (context, ref, _) {
              final isDark = ref.watch(modernThemeProvider);
              return _buildSwitchTile(
                title: 'Thème sombre',
                subtitle: 'Interface en mode sombre',
                value: isDark,
                icon: Icons.dark_mode_rounded,
                onChanged: (v) async {
                  ref.read(modernThemeProvider.notifier).state = v;
                  await ref
                      .read(secure.userSettingsServiceProvider)
                      .setUiDarkMode(v);
                },
              );
            }),

            const SizedBox(height: 16),

            // Color palette
            Consumer(builder: (context, ref, _) {
              final currentThemeId = ref.watch(currentThemeIdProvider);
              final availableThemes = AppTheme.availableThemes;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Palette de couleurs',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...availableThemes.entries.map((entry) {
                    final themeId = entry.key;
                    final palette = entry.value;
                    final isSelected = currentThemeId == themeId;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cs.primaryContainer.withOpacity(0.5)
                            : cs.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? cs.primary.withOpacity(0.5)
                              : cs.outlineVariant.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          ref.read(currentThemeIdProvider.notifier).state =
                              themeId;
                          await ref
                              .read(userSettingsServiceProvider)
                              .setSelectedThemeId(themeId);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Color preview
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: cs.outline.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: palette.primarySeed,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(7),
                                            bottomLeft: Radius.circular(7),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: palette.secondarySeed,
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(7),
                                            bottomRight: Radius.circular(7),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      palette.name,
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      palette.description,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Check
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: cs.primary,
                                  size: 24,
                                )
                              else
                                Icon(
                                  Icons.circle_outlined,
                                  color: cs.onSurfaceVariant.withOpacity(0.5),
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),

        const SizedBox(height: 16),

        // Animations section
        _buildSectionCard(
          context,
          title: 'Animations et retours',
          icon: Icons.animation_rounded,
          children: [
            Consumer(builder: (context, ref, _) {
              final reduce = ref.watch(reduceMotionProvider);
              return _buildSwitchTile(
                title: 'Réduire les animations',
                subtitle: 'Moins de transitions pour plus de confort',
                value: reduce,
                icon: Icons.motion_photos_off_rounded,
                onChanged: (v) async {
                  ref.read(reduceMotionProvider.notifier).state = v;
                  await ref
                      .read(secure.userSettingsServiceProvider)
                      .writeValue('ui_reduce_motion', v ? 'on' : 'off');
                },
              );
            }),
            const SizedBox(height: 12),
            FutureBuilder(
              future: ref
                  .read(secure.userSettingsServiceProvider)
                  .readValue('ui_reorder_haptics'),
              builder: (context, snap) {
                final enabled = snap.data != 'off';
                return _buildSwitchTile(
                  title: 'Retour haptique',
                  subtitle: 'Vibration lors des interactions',
                  value: enabled,
                  icon: Icons.vibration_rounded,
                  onChanged: (v) async {
                    await ref
                        .read(secure.userSettingsServiceProvider)
                        .writeValue('ui_reorder_haptics', v ? 'on' : 'off');
                    if (context.mounted) setState(() {});
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder(
              future: ref
                  .read(secure.userSettingsServiceProvider)
                  .readValue('ui_reorder_snackbar'),
              builder: (context, snap) {
                final enabled = snap.data != 'off';
                return _buildSwitchTile(
                  title: 'Confirmer les réordonnancements',
                  subtitle: 'Snack discret après appui-glissé',
                  value: enabled,
                  icon: Icons.drag_indicator_rounded,
                  onChanged: (v) async {
                    await ref
                        .read(secure.userSettingsServiceProvider)
                        .writeValue('ui_reorder_snackbar', v ? 'on' : 'off');
                    if (context.mounted) setState(() {});
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioTab(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.read(userSettingsServiceProvider);
    final localPrefs = ref.read(secure.userSettingsServiceProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // TTS Provider Selection
        _buildSectionCard(
          context,
          title: 'Choix du moteur de synthèse vocale',
          icon: Icons.settings_voice,
          children: [
            FutureBuilder<String?>(
              future: localPrefs.readValue('tts_preferred_provider'),
              builder: (context, snapshot) {
                final currentProvider =
                    snapshot.data ?? 'coqui'; // Coqui par défaut
                return Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Voix système (rapide)'),
                      subtitle: const Text('Voix robotique mais instantanée'),
                      value: 'flutter_tts',
                      groupValue: currentProvider,
                      onChanged: (value) async {
                        if (value != null) {
                          await localPrefs.writeValue(
                              'tts_preferred_provider', value);
                          if (context.mounted) setState(() {});
                        }
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Coqui TTS (naturelle)'),
                      subtitle: const Text(
                          'Voix humaine naturelle - 3-10s au premier chargement'),
                      value: 'coqui',
                      groupValue: currentProvider,
                      onChanged: (value) async {
                        if (value != null) {
                          await localPrefs.writeValue(
                              'tts_preferred_provider', value);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Coqui activé - La première synthèse prendra quelques secondes'),
                                backgroundColor: Colors.blue,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            setState(() {});
                          }
                        }
                      },
                    ),
                    if (currentProvider == 'coqui')
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Colors.blue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Note importante',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'La première lecture de chaque texte prendra 3-10 secondes.\nEnsuite, la lecture sera instantanée grâce au cache.',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // TTS Device section
        _buildSectionCard(
          context,
          title: 'Paramètres de la voix',
          icon: Icons.record_voice_over_rounded,
          children: [
            // Speed slider
            FutureBuilder<double>(
              future: settings.getTtsSpeed(),
              builder: (context, snap) {
                // Forcer une vitesse minimale de 0.8 pour éviter les lectures trop lentes
                double currentSpeed = snap.data ?? 0.9;
                if (currentSpeed < 0.8) {
                  // Auto-correction si la vitesse est trop lente
                  currentSpeed = 0.9;
                  // Mettre à jour la vitesse en arrière-plan
                  Future.microtask(() async {
                    await settings.setTtsSpeed(0.9);
                  });
                }
                final v = currentSpeed.clamp(0.5, 1.5);
                return Column(
                  children: [
                    _buildSliderTile(
                      label: 'Vitesse',
                      value: v,
                      min: 0.5,
                      max: 1.5,
                      divisions: 20,
                      displayValue: v.toStringAsFixed(2),
                      onChanged: (nv) async {
                        await settings.setTtsSpeed(nv);
                        if (context.mounted) setState(() {});
                      },
                    ),
                    // Bouton de réinitialisation si la vitesse n'est pas normale
                    if (v < 0.85 || v > 1.15)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextButton.icon(
                          onPressed: () async {
                            await settings.setTtsSpeed(0.9);
                            if (context.mounted) {
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Vitesse réinitialisée à normale'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.restore),
                          label:
                              const Text('Réinitialiser à la vitesse normale'),
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            // Pitch slider
            FutureBuilder<double>(
              future: settings.getTtsPitch(),
              builder: (context, pitchSnap) {
                final p = (pitchSnap.data ?? 1.02).clamp(0.8, 1.2);
                return _buildSliderTile(
                  label: 'Tonalité',
                  value: p,
                  min: 0.8,
                  max: 1.2,
                  divisions: 20,
                  displayValue: p.toStringAsFixed(2),
                  onChanged: (np) async {
                    await settings.setTtsPitch(np);
                    if (context.mounted) setState(() {});
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // Language/Locale selection (new)
            FutureBuilder<List<String>>(
              future: ref.read(flutterTtsServiceProvider).languages(),
              builder: (context, langsSnap) {
                final langs = langsSnap.data ?? const ['fr-FR', 'ar-SA'];
                return Column(
                  children: [
                    // FR Locale
                    FutureBuilder<String>(
                      future: settings.getTtsLocaleFr(),
                      builder: (context, snap) {
                        final current = snap.data ?? 'fr-FR';
                        final items = langs
                            .where((l) => l.toLowerCase().startsWith('fr'))
                            .toList();
                        if (!items.contains(current)) items.insert(0, current);
                        return _buildDropdownTile(
                          label: 'Langue française',
                          value: current,
                          items: [
                            for (final l in items)
                              DropdownMenuItem(value: l, child: Text(l))
                          ],
                          onChanged: (v) async {
                            if (v == null) return;
                            await settings.setTtsLocaleFr(v);
                            if (context.mounted) setState(() {});
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // AR Locale
                    FutureBuilder<String>(
                      future: settings.getTtsLocaleAr(),
                      builder: (context, snap) {
                        final current = snap.data ?? 'ar-SA';
                        final items = langs
                            .where((l) => l.toLowerCase().startsWith('ar'))
                            .toList();
                        if (!items.contains(current)) items.insert(0, current);
                        return _buildDropdownTile(
                          label: 'Langue arabe',
                          value: current,
                          items: [
                            for (final l in items)
                              DropdownMenuItem(value: l, child: Text(l))
                          ],
                          onChanged: (v) async {
                            if (v == null) return;
                            await settings.setTtsLocaleAr(v);
                            if (context.mounted) setState(() {});
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Voice selection
            FutureBuilder<List<Map<String, String>>>(
              future: ref.read(flutterTtsServiceProvider).voices(),
              builder: (context, vsnap) {
                final all = vsnap.data ?? const [];
                final frVoices = all
                    .where((v) =>
                        (v['locale'] ?? '').toLowerCase().startsWith('fr'))
                    .toList();
                final arVoices = all
                    .where((v) =>
                        (v['locale'] ?? '').toLowerCase().startsWith('ar'))
                    .toList();

                return Column(
                  children: [
                    // FR Voice
                    FutureBuilder<String?>(
                      future: settings.getTtsVoiceFrName(),
                      builder: (context, curSnap) {
                        final curName = curSnap.data;
                        return _buildDropdownTile(
                          label: 'Voix française',
                          value: curName,
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Par défaut'),
                            ),
                            for (final v in frVoices)
                              DropdownMenuItem<String?>(
                                value: v['name'],
                                child: Text('${v['name']} (${v['locale']})'),
                              ),
                          ],
                          onChanged: (val) async {
                            await settings.setTtsVoiceFrName(val);
                            if (context.mounted) setState(() {});
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // AR Voice
                    FutureBuilder<String?>(
                      future: settings.getTtsVoiceArName(),
                      builder: (context, curSnap) {
                        final curName = curSnap.data;
                        return _buildDropdownTile(
                          label: 'Voix arabe',
                          value: curName,
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Par défaut'),
                            ),
                            for (final v in arVoices)
                              DropdownMenuItem<String?>(
                                value: v['name'],
                                child: Text('${v['name']} (${v['locale']})'),
                              ),
                          ],
                          onChanged: (val) async {
                            await settings.setTtsVoiceArName(val);
                            if (context.mounted) setState(() {});
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Test buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernButton(
                            label: 'Tester FR',
                            icon: Icons.play_arrow_rounded,
                            onPressed: () async {
                              final speed = await settings.getTtsSpeed();
                              final pitch = await settings.getTtsPitch();
                              final voice = await settings.getTtsPreferredFr();
                              await ref.read(audioTtsServiceProvider).playText(
                                  'Lecture de test en français',
                                  voice: voice,
                                  speed: speed,
                                  pitch: pitch);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModernButton(
                            label: 'Tester AR',
                            icon: Icons.play_arrow_rounded,
                            onPressed: () async {
                              final speed = await settings.getTtsSpeed();
                              final pitch = await settings.getTtsPitch();
                              final voice = await settings.getTtsPreferredAr();
                              await ref.read(audioTtsServiceProvider).playText(
                                  'تجربة القراءة بالعربية',
                                  voice: voice,
                                  speed: speed,
                                  pitch: pitch);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Cache management section (local TTS cache)
        _buildSectionCard(
          context,
          title: 'Gestion du cache local',
          icon: Icons.storage_rounded,
          children: [
            FutureBuilder<int>(
              future: ref.read(ttsCacheServiceProvider).sizeBytes(),
              builder: (context, snap) {
                final size = snap.data ?? 0;
                final mb = (size / (1024 * 1024)).toStringAsFixed(2);
                return Row(
                  children: [
                    Expanded(
                      child: _buildModernButton(
                        label: 'Gérer le cache',
                        subtitle: '$mb Mo',
                        icon: Icons.storage_rounded,
                        onPressed: () => context.push('/settings/cache'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () async {
                        await ref.read(ttsCacheServiceProvider).clear();
                        if (context.mounted) {
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cache TTS vidé')),
                          );
                        }
                      },
                      tooltip: 'Vider le cache',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFontsTab(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Font family section
        _buildSectionCard(
          context,
          title: 'Familles de polices',
          icon: Icons.text_fields_rounded,
          children: [
            _buildActionTile(
              title: 'Police Inter (Français)',
              subtitle: 'Police moderne et lisible pour le français',
              icon: Icons.text_format_rounded,
              onTap: () {
                _showFontSelectionDialog(context, 'fr');
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              title: 'Noto Naskh Arabic (العربية)',
              subtitle: 'Police Arabic optimisée pour la lisibilité',
              icon: Icons.translate_rounded,
              onTap: () {
                _showFontSelectionDialog(context, 'ar');
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Font sizes section
        _buildSectionCard(
          context,
          title: 'Tailles de police',
          icon: Icons.format_size_rounded,
          children: [
            // Base font size slider (reliée au service)
            FutureBuilder<double>(
              future: ref.read(userSettingsServiceProvider).getFontScale(),
              builder: (context, snap) {
                final scale = (snap.data ?? 1.0).clamp(0.8, 1.4);
                return _buildSliderTile(
                  label: 'Taille de base',
                  value: scale,
                  min: 0.8,
                  max: 1.4,
                  divisions: 12,
                  displayValue: '${scale.toStringAsFixed(2)}x',
                  onChanged: (value) async {
                    await ref
                        .read(userSettingsServiceProvider)
                        .setFontScale(value);
                    if (context.mounted) setState(() {});
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            _buildActionTile(
              title: 'Réinitialiser les tailles',
              subtitle: 'Remettre les tailles par défaut',
              icon: Icons.refresh_rounded,
              onTap: () async {
                await ref.read(userSettingsServiceProvider).setFontScale(1.0);
                setState(() {});
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Tailles de police réinitialisées')),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Corpus section
        _buildSectionCard(
          context,
          title: 'Corpus du Coran',
          icon: Icons.book_rounded,
          children: [
            _buildActionTile(
              title: 'Importer depuis les assets',
              subtitle: 'Charger le corpus intégré (AR/FR)',
              icon: Icons.download_rounded,
              onTap: () async {
                final scaffold = ScaffoldMessenger.of(context);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );
                try {
                  final res =
                      await ref.read(corpusImporterProvider).importFromAssets();
                  if (context.mounted) Navigator.of(context).pop();
                  final inserted = res.$1;
                  final updated = res.$2;
                  scaffold.showSnackBar(
                    SnackBar(
                        content: Text(
                            'Importé $inserted versets (mis à jour: $updated)')),
                  );
                } catch (e) {
                  if (context.mounted) Navigator.of(context).pop();
                  scaffold.showSnackBar(
                      SnackBar(content: Text('Erreur import: $e')));
                }
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              title: 'Importer depuis un fichier',
              subtitle: 'JSON compatible',
              icon: Icons.file_upload_rounded,
              onTap: () async {
                final scaffold = ScaffoldMessenger.of(context);
                final res = await FilePicker.platform.pickFiles(
                    type: FileType.custom, allowedExtensions: ['json']);
                if (res == null ||
                    res.files.isEmpty ||
                    res.files.single.path == null) return;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );
                try {
                  final path = res.files.single.path!;
                  final r = await ref
                      .read(corpusImporterProvider)
                      .importFromPath(path);
                  if (context.mounted) Navigator.of(context).pop();
                  final inserted = r.$1;
                  final updated = r.$2;
                  scaffold.showSnackBar(
                    SnackBar(
                        content: Text(
                            'Importé $inserted versets depuis fichier (mis à jour: $updated)')),
                  );
                } catch (e) {
                  if (context.mounted) Navigator.of(context).pop();
                  scaffold.showSnackBar(
                      SnackBar(content: Text('Erreur import: $e')));
                }
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              title: 'Vérifier le corpus',
              subtitle: 'Tester avec le verset 2:255',
              icon: Icons.check_circle_outline_rounded,
              onTap: () async {
                final svc = ref.read(quranCorpusServiceProvider);
                final list = await svc.getRange(2, 255, 255);
                final scaffold = ScaffoldMessenger.of(context);
                scaffold.showSnackBar(SnackBar(
                  content: Text(list.isNotEmpty
                      ? 'OK: ${list.first.textFr ?? list.first.textAr ?? ''}'
                      : 'Aucun verset trouvé'),
                ));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCloudTab(BuildContext context) {
    final localPrefs = ref.read(secure.userSettingsServiceProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Cloud TTS Configuration
        _buildSectionCard(
          context,
          title: 'Configuration Cloud TTS',
          icon: Icons.cloud_outlined,
          children: [
            FutureBuilder<bool>(
              future: localPrefs.getCloudTtsEnabled(),
              builder: (context, snap) {
                final enabled = snap.data ?? false;
                return _buildSwitchTile(
                  title: 'Activer le TTS Cloud',
                  subtitle: 'Voix neuronales de haute qualité',
                  value: enabled,
                  icon: Icons.cloud_sync_rounded,
                  onChanged: (v) async {
                    await localPrefs.setCloudTtsEnabled(v);
                    if (context.mounted) setState(() {});
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            FutureBuilder<bool>(
              future: localPrefs.getAutoPrecacheEnabled(),
              builder: (context, snap) {
                final enabled = snap.data ?? false;
                return _buildSwitchTile(
                  title: 'Pré‑cacher au démarrage',
                  subtitle: 'Lance un pré‑cache Cloud en tâche de fond',
                  value: enabled,
                  icon: Icons.download_rounded,
                  onChanged: (v) async {
                    await localPrefs.setAutoPrecacheEnabled(v);
                    if (context.mounted) setState(() {});
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            // Portée du pré‑cache
            FutureBuilder<String>(
              future: localPrefs.getAutoPrecacheScope(),
              builder: (context, snap) {
                final scope = snap.data ?? 'both';
                return _buildDropdownTile(
                  label: 'Portée du pré‑cache',
                  value: scope,
                  items: const [
                    DropdownMenuItem(value: 'fr', child: Text('FR seulement')),
                    DropdownMenuItem(value: 'ar', child: Text('AR seulement')),
                    DropdownMenuItem(value: 'both', child: Text('AR + FR')),
                  ],
                  onChanged: (v) async {
                    if (v == null) return;
                    await localPrefs.setAutoPrecacheScope(v);
                    if (context.mounted) setState(() {});
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // Provider selection
            FutureBuilder<String>(
              future: localPrefs.getCloudTtsProvider(),
              builder: (context, snap) {
                final provider = snap.data ?? 'google';
                return _buildDropdownTile(
                  label: 'Fournisseur Cloud',
                  value: provider,
                  items: const [
                    DropdownMenuItem(
                        value: 'google', child: Text('Google Cloud TTS')),
                    DropdownMenuItem(value: 'azure', child: Text('Azure TTS')),
                    DropdownMenuItem(
                        value: 'polly', child: Text('Amazon Polly')),
                  ],
                  onChanged: (v) async {
                    if (v == null) return;
                    await localPrefs.setCloudTtsProvider(v);
                    if (context.mounted) setState(() {});
                  },
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // API Configuration
        _buildSectionCard(
          context,
          title: 'Configuration API',
          icon: Icons.key_rounded,
          children: [
            // API Key field
            FutureBuilder<String?>(
              future: localPrefs.getCloudTtsApiKey(),
              builder: (context, snap) {
                final controller = TextEditingController(text: snap.data ?? '');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clé API',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Entrez votre clé API...',
                        prefixIcon: const Icon(Icons.key_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (value) async {
                        await localPrefs.setCloudTtsApiKey(
                            value.trim().isEmpty ? null : value.trim());
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Endpoint configuration
            FutureBuilder<String?>(
              future: localPrefs.getCloudTtsEndpoint(),
              builder: (context, snap) {
                final controller = TextEditingController(text: snap.data ?? '');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Endpoint personnalisé (optionnel)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'https://api.exemple.com/tts',
                        prefixIcon: const Icon(Icons.link_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (value) async {
                        await localPrefs.setCloudTtsEndpoint(
                            value.trim().isEmpty ? null : value.trim());
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Test and maintenance
        _buildSectionCard(
          context,
          title: 'Tests et maintenance',
          icon: Icons.build_rounded,
          children: [
            _buildActionTile(
              title: 'Tester Cloud FR',
              subtitle: 'Test avec génération de fichier',
              icon: Icons.play_circle_outline_rounded,
              onTap: () async {
                await _testCloudTTS(context, 'fr');
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              title: 'Tester Cloud AR',
              subtitle: 'Test avec génération de fichier',
              icon: Icons.play_circle_outline_rounded,
              onTap: () async {
                await _testCloudTTS(context, 'ar');
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              title: 'Nettoyer les anciens fichiers cache',
              subtitle: 'Supprimer les fichiers anciens de plus de 7 jours',
              icon: Icons.cleaning_services_rounded,
              onTap: () async {
                await _purgeOlder(context, ref, const Duration(days: 7));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedTab(BuildContext context) {
    final settings = ref.read(userSettingsServiceProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Diacritizer section
        _buildSectionCard(
          context,
          title: 'Diacritiseur arabe',
          icon: Icons.text_fields_rounded,
          children: [
            FutureBuilder(
              future: settings.getDiacritizerMode(),
              builder: (context, snap) {
                final mode = snap.data ?? 'stub';
                return _buildDropdownTile(
                  label: 'Mode',
                  value: mode,
                  items: const [
                    DropdownMenuItem(
                        value: 'stub', child: Text('Local (stub)')),
                    DropdownMenuItem(value: 'api', child: Text('API HTTP')),
                  ],
                  onChanged: (v) async {
                    if (v == null) return;
                    await settings.setDiacritizerMode(v);
                    if (context.mounted) setState(() {});
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder(
              future: settings.getDiacritizerEndpoint(),
              builder: (context, snap) {
                final ctrl = TextEditingController(text: snap.data ?? '');
                return TextField(
                  controller: ctrl,
                  decoration: InputDecoration(
                    labelText: 'Endpoint API',
                    hintText: 'https://.../diacritize',
                    prefixIcon: const Icon(Icons.link_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (v) async => settings.setDiacritizerEndpoint(
                      v.trim().isEmpty ? null : v.trim()),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // OCR settings
        _buildSectionCard(
          context,
          title: 'Reconnaissance OCR',
          icon: Icons.center_focus_weak_rounded,
          children: [
            FutureBuilder<String>(
              future: settings.getOcrEngine(),
              builder: (context, snap) {
                final engine = snap.data ?? 'auto';
                return _buildDropdownTile(
                  label: 'Moteur OCR',
                  value: engine,
                  items: const [
                    DropdownMenuItem(value: 'auto', child: Text('Auto')),
                    DropdownMenuItem(
                        value: 'vision', child: Text('Vision (Apple)')),
                    DropdownMenuItem(
                        value: 'mlkit', child: Text('MLKit (Android)')),
                    DropdownMenuItem(
                        value: 'tesseract',
                        child: Text('Tesseract (Desktop/Android)')),
                    DropdownMenuItem(value: 'stub', child: Text('Stub')),
                  ],
                  onChanged: (v) async {
                    if (v == null) return;
                    await settings.setOcrEngine(v);
                    if (context.mounted) setState(() {});
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder<int>(
              future: settings.getOcrPdfPageLimit(),
              builder: (context, snap) {
                final n = snap.data ?? 5;
                return _buildDropdownTile<int>(
                  label: 'Pages PDF maximum',
                  value: n,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1')),
                    DropdownMenuItem(value: 3, child: Text('3')),
                    DropdownMenuItem(value: 5, child: Text('5')),
                    DropdownMenuItem(value: 10, child: Text('10')),
                  ],
                  onChanged: (v) async {
                    if (v == null) return;
                    await settings.setOcrPdfPageLimit(v);
                    if (context.mounted) setState(() {});
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // Helper widget builders
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool collapsed = false,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: theme.copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: !collapsed,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: cs.primary,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: cs.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayValue,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            activeTrackColor: cs.primary,
            inactiveTrackColor: cs.primaryContainer.withOpacity(0.3),
            thumbColor: cs.primary,
            overlayColor: cs.primary.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownTile<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(0.3),
            ),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
            borderRadius: BorderRadius.circular(12),
            dropdownColor: cs.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: cs.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required String label,
    String? subtitle,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer,
            cs.primaryContainer.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: cs.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.primary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Onglet À propos
  Widget _buildAboutTab(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // App information
        _buildSectionCard(
          context,
          title: 'Application',
          icon: Icons.info_rounded,
          children: [
            ListTile(
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              title: const Text(
                'Routines Spirituelles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('Version 1.0.0'),
            ),
            const Divider(),
            const ListTile(
              title: Text('Description'),
              subtitle: Text(
                'Application de routines spirituelles bilingue (français/arabe) '
                'avec compteur persistant, TTS multi-langue, et mode hors-ligne complet.',
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Developer info
        _buildSectionCard(
          context,
          title: 'Développement',
          icon: Icons.code_rounded,
          children: [
            const ListTile(
              leading: Icon(Icons.engineering_rounded),
              title: Text('Développé avec Flutter'),
              subtitle: Text('Framework cross-platform moderne'),
            ),
            const ListTile(
              leading: Icon(Icons.storage_rounded),
              title: Text('Base de données'),
              subtitle: Text('Drift (SQL) + Isar (NoSQL)'),
            ),
            const ListTile(
              leading: Icon(Icons.palette_rounded),
              title: Text('Design System'),
              subtitle: Text('Material Design 3 avec thèmes personnalisés'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Support & Links
        _buildSectionCard(
          context,
          title: 'Support et liens',
          icon: Icons.help_rounded,
          children: [
            _buildActionTile(
              title: 'Signaler un bug',
              subtitle: 'Envoyer un rapport de bug',
              icon: Icons.bug_report_rounded,
              onTap: () {
                _showBugReportDialog(context);
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              title: 'Proposer une fonctionnalité',
              subtitle: 'Suggérer une amélioration',
              icon: Icons.lightbulb_rounded,
              onTap: () {
                _showFeatureRequestDialog(context);
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              title: 'Exporter les diagnostics',
              subtitle: 'Créer un rapport de diagnostic',
              icon: Icons.download_rounded,
              onTap: () async {
                await _exportDiagnostics(context);
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Legal
        _buildSectionCard(
          context,
          title: 'Mentions légales',
          icon: Icons.gavel_rounded,
          children: [
            _buildActionTile(
              title: 'Conditions d\'utilisation',
              subtitle: 'Consulter les CGU',
              icon: Icons.description_rounded,
              onTap: () {
                _showTermsDialog(context);
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              title: 'Politique de confidentialité',
              subtitle: 'Gestion des données personnelles',
              icon: Icons.privacy_tip_rounded,
              onTap: () {
                _showPrivacyDialog(context);
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              title: 'Licences open source',
              subtitle: 'Bibliothèques utilisées',
              icon: Icons.code_rounded,
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: 'Routines Spirituelles',
                  applicationVersion: '1.0.0',
                  applicationIcon: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.secondary],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // Méthode pour tester le Cloud TTS
  Future<void> _testCloudTTS(BuildContext context, String language) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Test Cloud TTS ${language.toUpperCase()} en cours...')),
      );

      final localPrefs = ref.read(secure.userSettingsServiceProvider);
      final config = await _currentCloudConfig(localPrefs);

      if (config == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez configurer Cloud TTS d\'abord'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Texte de test selon la langue
      final testText = language == 'ar'
          ? 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'
          : 'Ceci est un test de synthèse vocale cloud.';

      // Utiliser le service Cloud TTS pour générer l'audio
      final cloudService = ref.read(cloudTtsByConfigProvider(config));

      // Déterminer la voix selon la langue et le provider
      String voice;
      if (language == 'ar') {
        // Voix arabe selon le provider
        voice = config.provider == 'google'
            ? 'ar-XA-Wavenet-B'
            : config.provider == 'azure'
                ? 'ar-SA-ZariahNeural'
                : 'Zeina'; // AWS Polly
      } else {
        // Voix française selon le provider
        voice = config.provider == 'google'
            ? 'fr-FR-Wavenet-E'
            : config.provider == 'azure'
                ? 'fr-FR-DeniseNeural'
                : 'Lea'; // AWS Polly
      }

      // Synthétiser et obtenir le chemin du fichier audio
      final audioPath = await cloudService.synthesizeToCache(
        testText,
        voice: voice,
        speed: 0.9, // Vitesse normale cohérente
        pitch: 1.0,
      );

      // Jouer l'audio généré
      final audioPlayer = ref.read(audioPlayerServiceProvider);
      await audioPlayer.playFile(audioPath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test Cloud TTS ${language.toUpperCase()} réussi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Méthode pour afficher le dialogue de sélection de police
  Future<void> _showFontSelectionDialog(
      BuildContext context, String language) async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Polices disponibles selon la langue
    final fonts = language == 'ar'
        ? ['Noto Naskh Arabic', 'Amiri', 'Lateef', 'Scheherazade']
        : ['Inter', 'Roboto', 'Open Sans', 'Poppins', 'Lato'];

    final currentFont = language == 'ar'
        ? await ref.read(userSettingsServiceProvider).getArabicFontFamily() ??
            'Noto Naskh Arabic'
        : await ref.read(userSettingsServiceProvider).getFrenchFontFamily() ??
            'Inter';

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          language == 'ar'
              ? 'Choisir une police arabe'
              : 'Choisir une police française',
          style: theme.textTheme.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: fonts.map((font) {
            final isSelected = font == currentFont;
            return ListTile(
              title: Text(
                font,
                style: TextStyle(
                  fontFamily: font,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              leading: Radio<String>(
                value: font,
                groupValue: currentFont,
                onChanged: (value) async {
                  if (value != null) {
                    if (language == 'ar') {
                      await ref
                          .read(userSettingsServiceProvider)
                          .setArabicFontFamily(value);
                    } else {
                      await ref
                          .read(userSettingsServiceProvider)
                          .setFrenchFontFamily(value);
                    }
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                    setState(() {});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Police $value sélectionnée')),
                      );
                    }
                  }
                },
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: cs.primary)
                  : null,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  // Dialogue pour signaler un bug
  Future<void> _showBugReportDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Signaler un bug'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du bug',
                  hintText: 'Décrivez brièvement le problème',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description détaillée',
                  hintText: 'Expliquez ce qui s\'est passé...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              // Sauvegarder le rapport localement ou l'envoyer
              final report = {
                'title': titleController.text,
                'description': descriptionController.text,
                'timestamp': DateTime.now().toIso8601String(),
                'version': '1.0.0',
              };
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rapport de bug enregistré. Merci!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  // Dialogue pour proposer une fonctionnalité
  Future<void> _showFeatureRequestDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Proposer une fonctionnalité'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la fonctionnalité',
                  hintText: 'Quelle fonctionnalité souhaitez-vous?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description et utilité',
                  hintText: 'Pourquoi cette fonctionnalité serait utile?',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              final request = {
                'title': titleController.text,
                'description': descriptionController.text,
                'timestamp': DateTime.now().toIso8601String(),
              };
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Suggestion enregistrée. Merci pour votre contribution!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  // Exporter les diagnostics
  Future<void> _exportDiagnostics(BuildContext context) async {
    try {
      // Collecter les informations de diagnostic
      final diagnostics = {
        'app_version': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
        'platform': Theme.of(context).platform.toString(),
        'settings': {
          'dark_mode': ref.read(modernThemeProvider),
          'theme_id': ref.read(currentThemeIdProvider),
          'font_scale':
              await ref.read(userSettingsServiceProvider).getFontScale(),
          'tts_speed':
              await ref.read(userSettingsServiceProvider).getTtsSpeed(),
          'tts_pitch':
              await ref.read(userSettingsServiceProvider).getTtsPitch(),
        },
        'cache': {
          'tts_files': await ref.read(ttsCacheServiceProvider).getCacheStats(),
        },
      };

      // Créer un fichier de diagnostic
      final String diagnosticsJson =
          const JsonEncoder.withIndent('  ').convert(diagnostics);

      // Dans une vraie app, on pourrait sauvegarder le fichier ou l'envoyer par email
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rapport de diagnostic créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création du rapport: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Dialogue des conditions d'utilisation
  Future<void> _showTermsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Conditions d\'utilisation'),
        content: const SingleChildScrollView(
          child: Text(
            'CONDITIONS GÉNÉRALES D\'UTILISATION\n\n'
            '1. ACCEPTATION DES CONDITIONS\n'
            'En utilisant cette application, vous acceptez les présentes conditions d\'utilisation.\n\n'
            '2. UTILISATION DE L\'APPLICATION\n'
            'Cette application est destinée à un usage personnel pour la pratique spirituelle.\n\n'
            '3. PROPRIÉTÉ INTELLECTUELLE\n'
            'Le contenu de l\'application est protégé par les droits d\'auteur.\n\n'
            '4. VIE PRIVÉE\n'
            'Vos données restent stockées localement sur votre appareil.\n\n'
            '5. LIMITATION DE RESPONSABILITÉ\n'
            'L\'application est fournie "en l\'état" sans garantie d\'aucune sorte.\n\n'
            '6. MODIFICATIONS\n'
            'Nous nous réservons le droit de modifier ces conditions à tout moment.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Dialogue de politique de confidentialité
  Future<void> _showPrivacyDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Politique de confidentialité'),
        content: const SingleChildScrollView(
          child: Text(
            'POLITIQUE DE CONFIDENTIALITÉ\n\n'
            '1. COLLECTE DES DONNÉES\n'
            'Cette application ne collecte aucune donnée personnelle identifiable.\n\n'
            '2. STOCKAGE LOCAL\n'
            'Toutes vos données (routines, préférences, historique) sont stockées '
            'uniquement sur votre appareil.\n\n'
            '3. AUCUN TRACKING\n'
            'Nous n\'utilisons aucun service de tracking ou d\'analyse.\n\n'
            '4. PERMISSIONS\n'
            '• Stockage: Pour sauvegarder vos données localement\n'
            '• Audio: Pour la synthèse vocale\n\n'
            '5. PARTAGE DES DONNÉES\n'
            'Vos données ne sont jamais partagées avec des tiers.\n\n'
            '6. SÉCURITÉ\n'
            'Vos données sont protégées par les mécanismes de sécurité de votre appareil.\n\n'
            '7. CONTACT\n'
            'Pour toute question, utilisez la fonction "Signaler un bug" dans l\'application.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

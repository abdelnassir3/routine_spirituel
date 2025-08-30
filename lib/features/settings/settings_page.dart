import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/services/corpus_importer.dart';
import 'package:spiritual_routines/core/services/quran_corpus_service.dart';
import 'package:spiritual_routines/core/services/user_settings_service.dart';
import 'package:spiritual_routines/core/services/audio_tts_flutter.dart';
import 'package:spiritual_routines/core/providers/tts_adapter_provider.dart';
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

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  Future<void> _purgeOlder(
      BuildContext context, WidgetRef ref, Duration d) async {
    final n = await ref.read(ttsCacheServiceProvider).purgeOlderThan(d);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fichiers anciens supprimés: $n')),
    );
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final settings = ref.read(userSettingsServiceProvider);
    final localPrefs = ref.read(secure.userSettingsServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        children: [
          // Accessibilité — réduire les animations
          Consumer(builder: (context, ref, _) {
            final reduce = ref.watch(reduceMotionProvider);
            return SwitchListTile.adaptive(
              title: const Text('Réduire les animations'),
              subtitle: const Text('Moins de transitions pour plus de confort'),
              value: reduce,
              onChanged: (v) async {
                ref.read(reduceMotionProvider.notifier).state = v;
                await ref
                    .read(secure.userSettingsServiceProvider)
                    .writeValue('ui_reduce_motion', v ? 'on' : 'off');
              },
            );
          }),
          const Divider(height: 0),
          // Palette de couleurs (persistée)
          Consumer(builder: (context, ref, _) {
            final current = ref.watch(modernPaletteIdProvider);
            final entries = ModernPalettes.available.entries.toList();
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: DropdownButtonFormField<String>(
                value: current,
                items: [
                  for (final e in entries)
                    DropdownMenuItem(
                      value: e.key,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [e.value.primary, e.value.secondary],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(e.value.name),
                        ],
                      ),
                    ),
                ],
                onChanged: (val) async {
                  if (val == null) return;
                  ref.read(modernPaletteIdProvider.notifier).state = val;
                  await ref
                      .read(secure.userSettingsServiceProvider)
                      .setUiPaletteId(val);
                },
                decoration:
                    const InputDecoration(labelText: 'Palette de couleurs'),
              ),
            );
          }),
          const Divider(height: 0),
          // Thème sombre (persistance + état global)
          Consumer(builder: (context, ref, _) {
            final isDark = ref.watch(modernThemeProvider);
            return SwitchListTile.adaptive(
              title: const Text('Thème sombre'),
              subtitle: const Text('Bascule clair/sombre de l\'interface'),
              value: isDark,
              onChanged: (v) async {
                ref.read(modernThemeProvider.notifier).state = v;
                await ref
                    .read(secure.userSettingsServiceProvider)
                    .setUiDarkMode(v);
              },
            );
          }),
          const Divider(height: 0),
          FutureBuilder(
            future: localPrefs.readValue('ui_reorder_snackbar'),
            builder: (context, snap) {
              final enabled = snap.data != 'off';
              return SwitchListTile.adaptive(
                title: Text(
                    AppLocalizations.of(context)?.settingsReorderSnackTitle ??
                        'Confirmer les réordonnancements'),
                subtitle: Text(AppLocalizations.of(context)
                        ?.settingsReorderSnackSubtitle ??
                    'Snack discret après appui-glissé'),
                value: enabled,
                onChanged: (v) async {
                  await localPrefs.writeValue(
                      'ui_reorder_snackbar', v ? 'on' : 'off');
                  if (context.mounted) setState(() {});
                },
              );
            },
          ),
          FutureBuilder(
            future: localPrefs.readValue('ui_reorder_haptics'),
            builder: (context, snap) {
              final enabled = snap.data != 'off';
              return SwitchListTile.adaptive(
                title: Text(
                    AppLocalizations.of(context)?.settingsReorderHapticsTitle ??
                        'Retour haptique réorganisation'),
                subtitle: Text(AppLocalizations.of(context)
                        ?.settingsReorderHapticsSubtitle ??
                    'Vibration légère après un déplacement'),
                value: enabled,
                onChanged: (v) async {
                  await localPrefs.writeValue(
                      'ui_reorder_haptics', v ? 'on' : 'off');
                  if (context.mounted) setState(() {});
                },
              );
            },
          ),
          const Divider(height: 0),
          const ListTile(
              title: Text('Voix TTS'),
              subtitle: Text('Choix de la voix et vitesse')),
          const Divider(height: 0),
          // Cloud TTS section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TTS neuronal (Cloud)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.push('/settings/cache'),
                    icon: const Icon(Icons.storage_rounded),
                    label: const Text('Gestion du cache TTS'),
                  ),
                ),
                FutureBuilder<bool>(
                  future: localPrefs.getCloudTtsEnabled(),
                  builder: (context, snap) {
                    final enabled = snap.data ?? false;
                    return SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Activer le TTS Cloud'),
                      value: enabled,
                      onChanged: (v) async {
                        await localPrefs.setCloudTtsEnabled(v);
                        if (context.mounted) setState(() {});
                      },
                    );
                  },
                ),
                FutureBuilder<bool>(
                  future: localPrefs.getAutoPrecacheEnabled(),
                  builder: (context, snap) {
                    final enabled = snap.data ?? false;
                    return SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Pré‑cacher au démarrage de session'),
                      subtitle: const Text(
                          'Lance un pré‑cache Cloud en tâche de fond'),
                      value: enabled,
                      onChanged: (v) async {
                        await localPrefs.setAutoPrecacheEnabled(v);
                        if (context.mounted) setState(() {});
                      },
                    );
                  },
                ),
                FutureBuilder<String>(
                  future: localPrefs.getAutoPrecacheScope(),
                  builder: (context, snap) {
                    final scope = snap.data ?? 'both';
                    return DropdownButtonFormField<String>(
                      value: scope,
                      items: const [
                        DropdownMenuItem(
                            value: 'fr', child: Text('FR seulement')),
                        DropdownMenuItem(
                            value: 'ar', child: Text('AR seulement')),
                        DropdownMenuItem(value: 'both', child: Text('AR + FR')),
                      ],
                      onChanged: (v) async {
                        if (v == null) return;
                        await localPrefs.setAutoPrecacheScope(v);
                        if (context.mounted) setState(() {});
                      },
                      decoration: const InputDecoration(
                          labelText: 'Portée du pré‑cache auto'),
                    );
                  },
                ),
                FutureBuilder<String>(
                  future: localPrefs.getCloudTtsProvider(),
                  builder: (context, snap) {
                    final provider = snap.data ?? 'google';
                    return DropdownButtonFormField<String>(
                      value: provider,
                      items: const [
                        DropdownMenuItem(
                            value: 'google', child: Text('Google Cloud TTS')),
                        DropdownMenuItem(
                            value: 'azure', child: Text('Azure TTS (bientôt)')),
                        DropdownMenuItem(
                            value: 'polly',
                            child: Text('Amazon Polly (bientôt)')),
                      ],
                      onChanged: (v) async {
                        if (v == null) return;
                        await localPrefs.setCloudTtsProvider(v);
                        if (context.mounted) setState(() {});
                      },
                      decoration:
                          const InputDecoration(labelText: 'Fournisseur Cloud'),
                    );
                  },
                ),
                const SizedBox(height: 8),
                FutureBuilder<String>(
                  future: localPrefs.getCloudTtsProvider(),
                  builder: (context, provSnap) {
                    final provider = provSnap.data ?? 'google';
                    return Column(
                      children: [
                        if (provider == 'azure' || provider == 'polly') ...[
                          FutureBuilder<String?>(
                            future: localPrefs.getCloudTtsEndpoint(),
                            builder: (context, snap) {
                              final ctrl =
                                  TextEditingController(text: snap.data ?? '');
                              return TextField(
                                controller: ctrl,
                                decoration: InputDecoration(
                                    labelText: provider == 'azure'
                                        ? 'Region (Azure, ex. francecentral)'
                                        : 'Region (Polly, ex. eu-west-1)'),
                                onSubmitted: (v) async {
                                  await localPrefs
                                      .setCloudTtsEndpoint(v.trim());
                                  if (context.mounted)
                                    FocusScope.of(context).unfocus();
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (provider == 'google' || provider == 'azure')
                          FutureBuilder<String?>(
                            future: localPrefs.getCloudTtsApiKey(),
                            builder: (context, snap) {
                              final ctrl =
                                  TextEditingController(text: snap.data ?? '');
                              return TextField(
                                controller: ctrl,
                                obscureText: true,
                                decoration:
                                    const InputDecoration(labelText: 'API Key'),
                                onSubmitted: (v) async {
                                  await localPrefs.setCloudTtsApiKey(v.trim());
                                  if (context.mounted)
                                    FocusScope.of(context).unfocus();
                                },
                              );
                            },
                          ),
                        if (provider == 'polly') ...[
                          FutureBuilder<String?>(
                            future: localPrefs.getAwsAccessKey(),
                            builder: (context, snap) {
                              final ctrl =
                                  TextEditingController(text: snap.data ?? '');
                              return TextField(
                                controller: ctrl,
                                decoration: const InputDecoration(
                                    labelText: 'AWS Access Key ID'),
                                onSubmitted: (v) async {
                                  await localPrefs.setAwsAccessKey(v.trim());
                                  if (context.mounted)
                                    FocusScope.of(context).unfocus();
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<String?>(
                            future: localPrefs.getAwsSecretKey(),
                            builder: (context, snap) {
                              final ctrl =
                                  TextEditingController(text: snap.data ?? '');
                              return TextField(
                                controller: ctrl,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    labelText: 'AWS Secret Access Key'),
                                onSubmitted: (v) async {
                                  await localPrefs.setAwsSecretKey(v.trim());
                                  if (context.mounted)
                                    FocusScope.of(context).unfocus();
                                },
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 8),
                        FutureBuilder<CloudTtsConfig?>(
                          future: _currentCloudConfig(localPrefs),
                          builder: (context, cfgSnap) {
                            final cfg = cfgSnap.data;
                            if (cfg == null) {
                              return const Text(
                                  'Renseignez les identifiants pour charger les voix Cloud.');
                            }
                            final voicesAsync =
                                ref.watch(cloudVoicesByConfigProvider(cfg));
                            return voicesAsync.when(
                              data: (voices) {
                                final frVoices = voices
                                    .where((v) =>
                                        v.locale.toLowerCase().startsWith('fr'))
                                    .toList();
                                final arVoices = voices
                                    .where((v) =>
                                        v.locale.toLowerCase().startsWith('ar'))
                                    .toList();
                                return Column(
                                  children: [
                                    FutureBuilder<String?>(
                                      future: localPrefs.getCloudVoiceFrName(),
                                      builder: (context, snap) {
                                        final current = snap.data;
                                        return DropdownButtonFormField<String?>(
                                          value: current,
                                          items: [
                                            const DropdownMenuItem<String?>(
                                                value: null,
                                                child: Text('Par défaut')),
                                            for (final v in frVoices)
                                              DropdownMenuItem<String?>(
                                                value: v.name,
                                                child: Text(
                                                    '${v.name} (${v.locale}${v.gender != null ? ', ${v.gender}' : ''})'),
                                              ),
                                          ],
                                          onChanged: (val) async {
                                            await localPrefs
                                                .setCloudVoiceFrName(val);
                                            if (context.mounted)
                                              setState(() {});
                                          },
                                          decoration: const InputDecoration(
                                              labelText: 'Voix Cloud FR'),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    FutureBuilder<String?>(
                                      future: localPrefs.getCloudVoiceArName(),
                                      builder: (context, snap) {
                                        final current = snap.data;
                                        return DropdownButtonFormField<String?>(
                                          value: current,
                                          items: [
                                            const DropdownMenuItem<String?>(
                                                value: null,
                                                child: Text('Par défaut')),
                                            for (final v in arVoices)
                                              DropdownMenuItem<String?>(
                                                value: v.name,
                                                child: Text(
                                                    '${v.name} (${v.locale}${v.gender != null ? ', ${v.gender}' : ''})'),
                                              ),
                                          ],
                                          onChanged: (val) async {
                                            await localPrefs
                                                .setCloudVoiceArName(val);
                                            if (context.mounted)
                                              setState(() {});
                                          },
                                          decoration: const InputDecoration(
                                              labelText: 'Voix Cloud AR'),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                              loading: () => const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: LinearProgressIndicator(),
                              ),
                              error: (_, __) => const Text(
                                  'Impossible de charger les voix Cloud'),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      FutureBuilder<int>(
                        future: ref.read(ttsCacheServiceProvider).sizeBytes(),
                        builder: (context, snap) {
                          final size = snap.data ?? 0;
                          final mb = (size / (1024 * 1024)).toStringAsFixed(2);
                          return OutlinedButton.icon(
                            onPressed: () async {
                              await ref.read(ttsCacheServiceProvider).clear();
                              if (context.mounted) setState(() {});
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Cache TTS vidé')),
                                );
                              }
                            },
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: Text('Vider le cache ($mb Mo)'),
                          );
                        },
                      ),
                      FilledButton.tonal(
                        onPressed: () async {
                          final enabled = await localPrefs.getCloudTtsEnabled();
                          final provider =
                              await localPrefs.getCloudTtsProvider();
                          final endpoint =
                              await localPrefs.getCloudTtsEndpoint();
                          final String? key =
                              await localPrefs.getCloudTtsApiKey();
                          final String? access =
                              await localPrefs.getAwsAccessKey();
                          final String? secret =
                              await localPrefs.getAwsSecretKey();
                          final missing =
                              (provider == 'google' || provider == 'azure')
                                  ? (key == null || key.isEmpty)
                                  : (access == null ||
                                      access.isEmpty ||
                                      secret == null ||
                                      secret.isEmpty ||
                                      (endpoint == null || endpoint.isEmpty));
                          if (!enabled || missing) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Activez le TTS Cloud et renseignez la clé')),
                              );
                            }
                            return;
                          }
                          final settingsSvc =
                              ref.read(userSettingsServiceProvider);
                          final voice = await settingsSvc.getTtsPreferredFr();
                          final speed = await settingsSvc.getTtsSpeed();
                          final pitch = await settingsSvc.getTtsPitch();
                          final cfg = CloudTtsConfig(
                              provider: provider,
                              apiKey: key,
                              endpoint: endpoint,
                              awsAccessKey: access,
                              awsSecretKey: secret);
                          final svc = ref.read(cloudTtsByConfigProvider(cfg));
                          final path = await svc.synthesizeToCache(
                              'Lecture de test cloud en français',
                              voice: voice,
                              speed: speed,
                              pitch: pitch);
                          await ref
                              .read(audioPlayerServiceProvider)
                              .playFile(path);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Audio généré (${path.split('/').last})')),
                            );
                          }
                        },
                        child: const Text('Tester Cloud FR (générer)'),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Nettoyage avancé',
                        onSelected: (v) async {
                          if (v == '7') {
                            await _purgeOlder(
                                context, ref, const Duration(days: 7));
                          } else if (v == '30') {
                            await _purgeOlder(
                                context, ref, const Duration(days: 30));
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                              value: '7', child: Text('Purger > 7 jours')),
                          PopupMenuItem(
                              value: '30', child: Text('Purger > 30 jours')),
                        ],
                        child: const Icon(Icons.more_horiz_rounded),
                      ),
                      FilledButton.tonal(
                        onPressed: () async {
                          final enabled = await localPrefs.getCloudTtsEnabled();
                          final provider =
                              await localPrefs.getCloudTtsProvider();
                          final endpoint =
                              await localPrefs.getCloudTtsEndpoint();
                          final String? key =
                              await localPrefs.getCloudTtsApiKey();
                          final String? access =
                              await localPrefs.getAwsAccessKey();
                          final String? secret =
                              await localPrefs.getAwsSecretKey();
                          final missing =
                              (provider == 'google' || provider == 'azure')
                                  ? (key == null || key.isEmpty)
                                  : (access == null ||
                                      access.isEmpty ||
                                      secret == null ||
                                      secret.isEmpty ||
                                      (endpoint == null || endpoint.isEmpty));
                          if (!enabled || missing) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Activez le TTS Cloud et renseignez la clé')),
                              );
                            }
                            return;
                          }
                          final settingsSvc =
                              ref.read(userSettingsServiceProvider);
                          final voice = await settingsSvc.getTtsPreferredAr();
                          final speed = await settingsSvc.getTtsSpeed();
                          final pitch = await settingsSvc.getTtsPitch();
                          final cfg = CloudTtsConfig(
                              provider: provider,
                              apiKey: key,
                              endpoint: endpoint,
                              awsAccessKey: access,
                              awsSecretKey: secret);
                          final svc = ref.read(cloudTtsByConfigProvider(cfg));
                          final path = await svc.synthesizeToCache(
                              'تجربة السحب باللغة العربية',
                              voice: voice,
                              speed: speed,
                              pitch: pitch);
                          await ref
                              .read(audioPlayerServiceProvider)
                              .playFile(path);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Audio généré (${path.split('/').last})')),
                            );
                          }
                        },
                        child: const Text('Tester Cloud AR (générer)'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const ListTile(
              title: Text('Tailles et polices'),
              subtitle: Text('Inter / Noto Naskh Arabic')),
          const Divider(height: 0),
          const ListTile(
              title: Text('Téléchargements hors-ligne'),
              subtitle: Text('Packs AR/FR, TTS cache')),
          const Divider(height: 0),
          const ListTile(
              title: Text('Lecture audio (TTS)'),
              subtitle: Text('Voix et vitesse')),
          // Aperçu TTS via adaptateur cross‑plateforme (Web-safe)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                FilledButton.tonal(
                  onPressed: () async {
                    final adapter = ref.read(ttsAdapterProvider);
                    // FR demo
                    await adapter.speak(
                      'Bonjour, ceci est un aperçu T T S.',
                      voice: 'fr-FR-DeniseNeural',
                      speed: await settings.getTtsSpeed(),
                      pitch: await settings.getTtsPitch(),
                    );
                  },
                  child: const Text('Aperçu FR (adapter)'),
                ),
                const SizedBox(width: 12),
                FilledButton.tonal(
                  onPressed: () async {
                    final adapter = ref.read(ttsAdapterProvider);
                    // AR demo
                    await adapter.speak(
                      'مرحبا، هذه معاينة تحويل النص إلى كلام.',
                      voice: 'ar-SA-HamedNeural',
                      speed: await settings.getTtsSpeed(),
                      pitch: await settings.getTtsPitch(),
                    );
                  },
                  child: const Text('Aperçu AR (adapter)'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: FutureBuilder<double>(
              future: settings.getTtsSpeed(),
              builder: (context, snap) {
                final v = (snap.data ?? 0.5).clamp(0.3, 1.0);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Vitesse'),
                        const SizedBox(width: 12),
                        Text(v.toStringAsFixed(2)),
                      ],
                    ),
                    Slider(
                      min: 0.3,
                      max: 1.0,
                      divisions: 14,
                      value: v,
                      onChanged: (nv) async {
                        await settings.setTtsSpeed(nv);
                        if (context.mounted) setState(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<double>(
                      future: settings.getTtsPitch(),
                      builder: (context, pitchSnap) {
                        final p = (pitchSnap.data ?? 1.02).clamp(0.8, 1.2);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('Pitch'),
                                const SizedBox(width: 12),
                                Text(p.toStringAsFixed(2)),
                              ],
                            ),
                            Slider(
                              min: 0.8,
                              max: 1.2,
                              divisions: 20,
                              value: p,
                              onChanged: (np) async {
                                await settings.setTtsPitch(np);
                                if (context.mounted) setState(() {});
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: FutureBuilder<List<String>>(
              future: ref.read(flutterTtsServiceProvider).languages(),
              builder: (context, langsSnap) {
                final langs = langsSnap.data ?? const ['fr-FR', 'ar-SA'];
                return Column(
                  children: [
                    FutureBuilder<String>(
                      future: settings.getTtsLocaleFr(),
                      builder: (context, snap) {
                        final current = snap.data ?? 'fr-FR';
                        final items = langs
                            .where((l) => l.toLowerCase().startsWith('fr'))
                            .toList();
                        if (!items.contains(current)) items.insert(0, current);
                        return DropdownButtonFormField<String>(
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
                          decoration: const InputDecoration(
                              labelText: 'Voix FR (locale)'),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<Map<String, String>>>(
                      future: ref.read(flutterTtsServiceProvider).voices(),
                      builder: (context, vsnap) {
                        final all = vsnap.data ?? const [];
                        final frVoices = all
                            .where((v) => (v['locale'] ?? '')
                                .toLowerCase()
                                .startsWith('fr'))
                            .toList();
                        return FutureBuilder<String?>(
                          future: settings.getTtsVoiceFrName(),
                          builder: (context, curSnap) {
                            final curName = curSnap.data; // may be null
                            return DropdownButtonFormField<String?>(
                              value: curName,
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Par défaut (utiliser locale)'),
                                ),
                                for (final v in frVoices)
                                  DropdownMenuItem<String?>(
                                    value: v['name'],
                                    child:
                                        Text('${v['name']} (${v['locale']})'),
                                  ),
                              ],
                              onChanged: (val) async {
                                await settings.setTtsVoiceFrName(val);
                                if (context.mounted) setState(() {});
                              },
                              decoration: const InputDecoration(
                                  labelText: 'Voix FR (nom)'),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<String>(
                      future: settings.getTtsLocaleAr(),
                      builder: (context, snap) {
                        final current = snap.data ?? 'ar-SA';
                        final items = langs
                            .where((l) => l.toLowerCase().startsWith('ar'))
                            .toList();
                        if (!items.contains(current)) items.insert(0, current);
                        return DropdownButtonFormField<String>(
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
                          decoration: const InputDecoration(
                              labelText: 'Voix AR (locale)'),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<Map<String, String>>>(
                      future: ref.read(flutterTtsServiceProvider).voices(),
                      builder: (context, vsnap) {
                        final all = vsnap.data ?? const [];
                        final arVoices = all
                            .where((v) => (v['locale'] ?? '')
                                .toLowerCase()
                                .startsWith('ar'))
                            .toList();
                        return FutureBuilder<String?>(
                          future: settings.getTtsVoiceArName(),
                          builder: (context, curSnap) {
                            final curName = curSnap.data; // may be null
                            return DropdownButtonFormField<String?>(
                              value: curName,
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Par défaut (utiliser locale)'),
                                ),
                                for (final v in arVoices)
                                  DropdownMenuItem<String?>(
                                    value: v['name'],
                                    child:
                                        Text('${v['name']} (${v['locale']})'),
                                  ),
                              ],
                              onChanged: (val) async {
                                await settings.setTtsVoiceArName(val);
                                if (context.mounted) setState(() {});
                              },
                              decoration: const InputDecoration(
                                  labelText: 'Voix AR (nom)'),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        children: [
                          FilledButton.tonal(
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
                            child: const Text('Tester FR'),
                          ),
                          FilledButton.tonal(
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
                            child: const Text('Tester AR'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 0),
          const ListTile(
            title: Text('Thèmes et couleurs'),
            subtitle: Text('Personnalisation de l\'apparence'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Consumer(
              builder: (context, ref, _) {
                final currentThemeId = ref.watch(currentThemeIdProvider);
                final availableThemes = AppTheme.availableThemes;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Palette de couleurs',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    ...availableThemes.entries.map((entry) {
                      final themeId = entry.key;
                      final palette = entry.value;
                      final isSelected = currentThemeId == themeId;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: palette.primarySeed,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    width: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: palette.secondarySeed,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(palette.name),
                          subtitle: Text(palette.description),
                          trailing: isSelected
                              ? Icon(Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary)
                              : const Icon(Icons.radio_button_unchecked),
                          onTap: () async {
                            ref.read(currentThemeIdProvider.notifier).state =
                                themeId;
                            // Persist the selection
                            await ref
                                .read(userSettingsServiceProvider)
                                .setSelectedThemeId(themeId);
                          },
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 0),
          ListTile(
            title: const Text('Importer corpus Coran (hors-ligne)'),
            subtitle: const Text('Depuis assets/corpus/*.json (AR/FR)'),
            trailing: const Icon(Icons.chevron_right_rounded),
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
                final inserted = res.$1; // ← record non nommé
                final updated = res.$2;
                scaffold.showSnackBar(
                  SnackBar(
                      content: Text(
                          'Importé $inserted versets (mis à jour: $updated)')),
                );
              } catch (e) {
                if (context.mounted) Navigator.of(context).pop();
                scaffold
                    .showSnackBar(SnackBar(content: Text('Erreur import: $e')));
              }
            },
          ),
          ListTile(
            title: const Text('Importer corpus depuis un fichier'),
            subtitle: const Text('JSON compatible combiné ou simple'),
            trailing: const Icon(Icons.chevron_right_rounded),
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
                final r =
                    await ref.read(corpusImporterProvider).importFromPath(path);
                if (context.mounted) Navigator.of(context).pop();
                final inserted = r.$1; // ← idem
                final updated = r.$2;
                scaffold.showSnackBar(
                  SnackBar(
                      content: Text(
                          'Importé $inserted versets depuis fichier (mis à jour: $updated)')),
                );
              } catch (e) {
                if (context.mounted) Navigator.of(context).pop();
                scaffold
                    .showSnackBar(SnackBar(content: Text('Erreur import: $e')));
              }
            },
          ),
          ListTile(
            title: const Text('Vérifier un extrait (2:255)'),
            trailing: const Icon(Icons.chevron_right_rounded),
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
          const Divider(height: 0),
          const ListTile(
            title: Text('Diacritiseur (AR)'),
            subtitle: Text('Utiliser un serveur API si disponible'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: FutureBuilder(
              future: settings.getDiacritizerMode(),
              builder: (context, snap) {
                final mode = snap.data ?? 'stub';
                return DropdownButtonFormField<String>(
                  value: mode,
                  decoration: const InputDecoration(labelText: 'Mode'),
                  items: const [
                    DropdownMenuItem(
                        value: 'stub', child: Text('Local (stub)')),
                    DropdownMenuItem(value: 'api', child: Text('API HTTP')),
                  ],
                  onChanged: (v) async {
                    if (v == null) return;
                    await settings.setDiacritizerMode(v);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: FutureBuilder(
              future: settings.getDiacritizerEndpoint(),
              builder: (context, snap) {
                final ctrl = TextEditingController(text: snap.data ?? '');
                return TextFormField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                      labelText: 'Endpoint API (POST)',
                      hintText: 'https://.../diacritize'),
                  onFieldSubmitted: (v) async =>
                      settings.setDiacritizerEndpoint(
                          v.trim().isEmpty ? null : v.trim()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

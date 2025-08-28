import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:spiritual_routines/app/router.dart';
import 'package:spiritual_routines/design_system/inspired_theme.dart'; // Nouveau design system moderne
import 'package:spiritual_routines/features/settings/user_settings_service.dart'
    as secure;
import 'package:spiritual_routines/design_system/inspired_theme.dart'
    show reduceMotionProvider, modernPaletteIdProvider, modernThemeProvider;
import 'package:spiritual_routines/l10n/app_localizations.dart';
import 'package:spiritual_routines/core/services/database_seeder.dart';
import 'package:spiritual_routines/core/services/user_settings_service.dart';
import 'package:spiritual_routines/core/services/api_key_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optimisations de performance en production
  if (kReleaseMode) {
    // Désactiver les logs en production
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Initialiser l'API key Coqui TTS automatiquement
  await ApiKeyInitializer.initialize();

  // Créer le container Riverpod
  final container = ProviderContainer();

  // Initialiser la base de données avec les données de seed au premier lancement
  try {
    final seeder = container.read(databaseSeederProvider);
    await seeder.seedDatabase();

    // Charger le mode sombre depuis les préférences sécurisées
    try {
      final prefs = container.read(secure.userSettingsServiceProvider);
      final dark = await prefs.getUiDarkMode();
      container.read(modernThemeProvider.notifier).state = dark;
      // Charger la palette
      final paletteId = await prefs.getUiPaletteId();
      container.read(modernPaletteIdProvider.notifier).state = paletteId;
      // Charger l'option accessibilité: réduire les animations
      final reduce = (await prefs.readValue('ui_reduce_motion')) == 'on';
      container.read(reduceMotionProvider.notifier).state = reduce;
    } catch (_) {}

    // Charger le thème depuis les paramètres utilisateur
    // final userSettings = container.read(userSettingsServiceProvider);
    // final savedThemeId = await userSettings.getSelectedThemeId();
    // container.read(currentThemeIdProvider.notifier).state = savedThemeId;
  } catch (e) {
    print('Erreur lors de l\'initialisation de la base : $e');
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: const SpiritualRoutinesApp(),
  ));
}

class SpiritualRoutinesApp extends ConsumerWidget {
  const SpiritualRoutinesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final isDarkMode = ref.watch(modernThemeProvider);

    return MaterialApp.router(
      title: 'Routines Spirituelles',
      theme: InspiredTheme.light,
      darkTheme: InspiredTheme.dark,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,

      // Localisation: utilise la langue du système
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spiritual_routines/features/splash/animated_splash_screen.dart';
import 'package:spiritual_routines/features/home/modern_home_page.dart'; // Nouvelle page d'accueil moderne
import 'package:spiritual_routines/features/routines/modern_routines_page.dart';
import 'package:spiritual_routines/features/routines/routine_editor_page.dart';
import 'package:spiritual_routines/features/reader/enhanced_modern_reader_page.dart';
import 'package:spiritual_routines/features/settings/modern_settings_page.dart';
import 'package:spiritual_routines/features/settings/cache_management_page.dart';
import 'package:spiritual_routines/features/content/modern_content_editor_page.dart';
import 'package:spiritual_routines/app/performance_config.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const AnimatedSplashScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const ModernHomePage(),
        routes: [
          GoRoute(
            path: 'routines',
            name: 'routines',
            builder: (context, state) => const ModernRoutinesPage(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'routine_editor',
                builder: (context, state) =>
                    RoutineEditorPage(routineId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: 'reader',
            name: 'reader',
            builder: (context, state) {
              final startTaskId = state.uri.queryParameters['startTask'];
              return EnhancedModernReaderPage(startTaskId: startTaskId);
            },
          ),
          GoRoute(
            path: 'task/:taskId/content',
            name: 'content_editor',
            builder: (context, state) => ModernContentEditorPage(
                taskId: state.pathParameters['taskId']!),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const ModernSettingsPage(),
            routes: [
              GoRoute(
                path: 'cache',
                name: 'cache_management',
                builder: (context, state) => const CacheManagementPage(),
              ),
            ],
          ),
        ],
      )
    ],
  );
});

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

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/', // Start directly at home to avoid splash screen issues on web
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const AnimatedSplashScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) {
          print('🏠 Building home page');
          try {
            return const ModernHomePage();
          } catch (e, stackTrace) {
            print('❌ Error building ModernHomePage: $e');
            print('Stack trace: $stackTrace');
            // Return a simple fallback page
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('RISAQ Home Page'),
                    const Text('Error loading main page'),
                    Text('Error: $e'),
                    ElevatedButton(
                      onPressed: () => context.go('/splash'),
                      child: const Text('Back to Splash'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
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

# PR #001: Fix TabController Crash

## Description
Corrige le crash "No TabController for TabBar" dans ModernSettingsPage en wrappant avec DefaultTabController.

## Impact
- **Gravité**: CRITIQUE - Crash immédiat
- **Platforms**: iOS, Android, Web, macOS
- **Users affectés**: 100% (settings inaccessibles)

## Changements

### 1. lib/features/settings/modern_settings_page.dart

```diff
@@ -32,14 +32,11 @@ class ModernSettingsPage extends ConsumerStatefulWidget {
 class _ModernSettingsPageState extends ConsumerState<ModernSettingsPage>
     with SingleTickerProviderStateMixin {
-  late TabController _tabController;
   int _selectedIndex = 0;
 
   @override
   void initState() {
     super.initState();
-    _tabController =
-        TabController(length: 7, vsync: this); // Augmenté à 7 onglets
-    _tabController.addListener(() {
+    // TabController géré par DefaultTabController maintenant
       setState(() {
         _selectedIndex = _tabController.index;
       });
@@ -48,7 +45,6 @@ class _ModernSettingsPageState extends ConsumerState<ModernSettingsPage>
 
   @override
   void dispose() {
-    _tabController.dispose();
     super.dispose();
   }
 
@@ -166,11 +162,13 @@ class _ModernSettingsPageState extends ConsumerState<ModernSettingsPage>
                       ),
                     ),
                   ),
+                  DefaultTabController(
+                    length: 7,
+                    initialIndex: _selectedIndex,
                     child: Container(
                       decoration: BoxDecoration(
                         color: theme.colorScheme.surface.withOpacity(0.3),
                         borderRadius: BorderRadius.circular(12),
                       ),
                     child: TabBar(
-                      controller: _tabController,
                       indicator: BoxDecoration(
                         color: theme.colorScheme.primary,
                         borderRadius: BorderRadius.circular(10),
@@ -200,10 +198,13 @@ class _ModernSettingsPageState extends ConsumerState<ModernSettingsPage>
                         Tab(icon: Icon(Icons.info_outline)),
                       ],
                     ),
+                    ),
+                  ),
                 ),
               ),
             ),
             // Content area
             Expanded(
+              child: DefaultTabController(
+                length: 7,
+                initialIndex: _selectedIndex,
                 child: TabBarView(
-                  controller: _tabController,
                   children: [
                     _buildGeneralSettings(),
                     _buildAppearanceSettings(),
@@ -214,6 +215,7 @@ class _ModernSettingsPageState extends ConsumerState<ModernSettingsPage>
                     _buildAboutSection(),
                   ],
                 ),
+              ),
             ),
           ],
         ),
```

### 2. lib/features/content/modern_content_editor_page.dart

```diff
@@ -41,13 +41,11 @@ class _ModernContentEditorPageState
     extends ConsumerState<ModernContentEditorPage>
     with SingleTickerProviderStateMixin {
-  late TabController _tabController;
   String _source = 'manual';
   
   @override
   void initState() {
     super.initState();
-    _tabController = TabController(length: 2, vsync: this);
     _loadExisting();
   }
 
@@ -456,8 +454,10 @@ class _ModernContentEditorPageState
           // TabBar moderne
           Container(
             margin: const EdgeInsets.all(20),
+            child: DefaultTabController(
+              length: 2,
+              child: Container(
                 decoration: BoxDecoration(
                   color: theme.colorScheme.surface.withOpacity(0.5),
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: TabBar(
-                  controller: _tabController,
                   indicator: BoxDecoration(
                     color: theme.colorScheme.primary,
                     borderRadius: BorderRadius.circular(10),
@@ -475,14 +475,18 @@ class _ModernContentEditorPageState
                     Tab(text: 'Arabe'),
                   ],
                 ),
+              ),
+            ),
           ),
 
           // TabBarView avec hauteur flexible
           SizedBox(
             height: MediaQuery.of(context).size.height * 0.7,
+            child: DefaultTabController(
+              length: 2,
               child: TabBarView(
-                controller: _tabController,
                 children: [
                   _buildFrenchTab(),
                   _buildArabicTab(),
                 ],
               ),
+            ),
           ),
```

## Tests

```dart
// test/widgets/settings_page_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:spiritual_routines/features/settings/modern_settings_page.dart';

void main() {
  testWidgets('Settings page does not crash with TabBar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ModernSettingsPage(),
      ),
    );
    
    // Should not throw
    expect(tester.takeException(), isNull);
    
    // Should find DefaultTabController
    expect(find.byType(DefaultTabController), findsWidgets);
    
    // Should be able to tap tabs
    await tester.tap(find.text('Apparence'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
```

## Rollback Plan
```bash
git revert HEAD
```

## Checklist
- [ ] Code review passée
- [ ] Tests unitaires ajoutés
- [ ] Tests sur iOS Simulator
- [ ] Tests sur Android Emulator  
- [ ] Pas de regression ailleurs
- [ ] Documentation mise à jour

## Risques
- **Risque**: Très faible, correction standard Flutter
- **Pré-requis**: Aucun
- **Backup**: Git history
- **Monitoring**: Crashlytics pour vérifier disparition du crash
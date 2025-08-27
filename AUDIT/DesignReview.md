# Design System Review — Routines Spirituelles

## État Actuel : Fragmentation

### Problème Principal
**3 systèmes de thème coexistent** causant confusion et incohérence :
1. `theme.dart` — Material 3 basique (380 lignes)
2. `inspired_theme.dart` — Système moderne avec palettes (520 lignes) ✅
3. `advanced_theme.dart` — Expérimentation abandonnée (450 lignes)

### Recommandation
**Garder uniquement `inspired_theme.dart`** qui est le plus complet et utilisé dans main.dart.

## Design System Unifié Proposé

### 1. Tokens de Base (Material 3)

```dart
// lib/design_system/tokens/spacing.dart
class Spacing {
  static const double xs = 4.0;   // Grille 8pt base
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

// lib/design_system/tokens/radius.dart
class Radius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;
}

// lib/design_system/tokens/elevation.dart
class Elevation {
  static const double level0 = 0.0;
  static const double level1 = 1.0;
  static const double level2 = 3.0;
  static const double level3 = 6.0;
  static const double level4 = 8.0;
  static const double level5 = 12.0;
}
```

### 2. Système de Couleurs (60-30-10 Rule)

```dart
// lib/design_system/inspired_theme.dart (existant, à nettoyer)
class InspiredTheme {
  // Palette spirituelle
  static const _primaryGreen = Color(0xFF2E7D32);  // 60% - Vert spirituel
  static const _secondaryGold = Color(0xFFFFB300);  // 30% - Or accent
  static const _tertiaryTeal = Color(0xFF00796B);   // 10% - Teal contraste
  
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryGreen,
      brightness: Brightness.light,
    ).copyWith(
      primary: _primaryGreen,
      secondary: _secondaryGold,
      tertiary: _tertiaryTeal,
      surface: Color(0xFFFAFAFA),
      background: Colors.white,
    ),
    // ...
  );
  
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryGreen,
      brightness: Brightness.dark,
    ).copyWith(
      primary: Color(0xFF4CAF50),
      secondary: Color(0xFFFFD54F),
      tertiary: Color(0xFF26A69A),
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
    ),
    // ...
  );
}
```

### 3. Typographie Bilingue

```dart
// lib/design_system/tokens/typography.dart
class AppTypography {
  // Français - Inter
  static const TextTheme frenchTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.25,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    // ...
  );
  
  // Arabe - Noto Naskh Arabic
  static const TextTheme arabicTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'NotoNaskhArabic',
      fontSize: 64,  // Plus grand pour lisibilité arabe
      fontWeight: FontWeight.w400,
      height: 1.4,   // Plus d'espace vertical pour diacritiques
    ),
    headlineLarge: TextStyle(
      fontFamily: 'NotoNaskhArabic',
      fontSize: 36,
      fontWeight: FontWeight.w600,
      height: 1.5,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'NotoNaskhArabic',
      fontSize: 20,  // Plus grand que français
      fontWeight: FontWeight.w400,
      height: 1.8,   // Espacement généreux
    ),
    // ...
  );
}
```

### 4. Composants Clés

```dart
// lib/design_system/components/spiritual_card.dart
class SpiritualCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  
  const SpiritualCard({
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.elevation,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: elevation ?? 2,
      color: backgroundColor ?? theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radius.lg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radius.lg),
        child: Padding(
          padding: EdgeInsets.all(Spacing.md),
          child: child,
        ),
      ),
    );
  }
}

// lib/design_system/components/counter_widget.dart
class CounterWidget extends StatelessWidget {
  final int count;
  final VoidCallback onDecrement;
  final bool isPulsing;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onDecrement,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
          boxShadow: isPulsing ? [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ] : [],
        ),
        child: Center(
          child: Text(
            '$count',
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
```

### 5. Gabarits d'Écrans

```dart
// Template Home Screen
class HomeScreenTemplate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigationScaffold(
      body: CustomScrollView(
        slivers: [
          // Header avec gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                ),
              ),
              title: Text('Routines Spirituelles'),
            ),
          ),
          
          // Stats Cards Grid
          SliverPadding(
            padding: EdgeInsets.all(Spacing.md),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: Spacing.md,
                crossAxisSpacing: Spacing.md,
              ),
              delegate: SliverChildListDelegate([
                _StatsCard(
                  icon: Icons.today,
                  title: "Aujourd'hui",
                  value: "3/5",
                  color: theme.colorScheme.primary,
                ),
                _StatsCard(
                  icon: Icons.trending_up,
                  title: "Série",
                  value: "7 jours",
                  color: theme.colorScheme.secondary,
                ),
              ]),
            ),
          ),
          
          // Routine List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => RoutineListTile(
                routine: routines[index],
                onTap: () => context.go('/routine/${routines[index].id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Template Reader Screen avec RTL
class ReaderScreenTemplate extends StatelessWidget {
  final bool isArabic;
  
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(isArabic 
              ? Icons.arrow_forward  // Inversé pour RTL
              : Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            // Font size controls
            IconButton(
              icon: Icon(Icons.text_decrease),
              onPressed: () => decreaseFontSize(),
            ),
            IconButton(
              icon: Icon(Icons.text_increase),
              onPressed: () => increaseFontSize(),
            ),
            // Language toggle
            IconButton(
              icon: Text(isArabic ? 'FR' : 'AR'),
              onPressed: () => toggleLanguage(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
            
            // Text content with proper typography
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Spacing.lg),
                child: SelectableText(
                  content,
                  style: isArabic 
                    ? AppTypography.arabicTextTheme.bodyLarge
                    : AppTypography.frenchTextTheme.bodyLarge,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
              ),
            ),
            
            // Counter at bottom
            Container(
              padding: EdgeInsets.all(Spacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: CounterWidget(
                count: remainingCount,
                onDecrement: () => decrementCounter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Règles d'Application

### 1. Hiérarchie Visuelle
- **Primary (60%)** : Navigation, headers, CTAs principaux
- **Secondary (30%)** : Accents, badges, indicateurs
- **Tertiary (10%)** : États hover, focus, détails

### 2. Espacement (Grille 8pt)
- Toujours utiliser les tokens Spacing
- Padding minimum : 8px (sm)
- Marges entre sections : 24px (lg)

### 3. Accessibilité
- Contraste minimum : 4.5:1 (texte normal), 3:1 (large)
- Zones tactiles : 48x48px minimum
- Focus indicators visibles
- Support screen readers

### 4. RTL Guidelines
```dart
// Toujours wrapper le contenu arabe
Directionality(
  textDirection: TextDirection.rtl,
  child: content,
)

// Inverser les icônes directionnelles
Icon(isRTL ? Icons.arrow_forward : Icons.arrow_back)

// Aligner le texte correctement
TextAlign: isRTL ? TextAlign.right : TextAlign.left
```

## Migration Path

1. **Phase 1** : Supprimer theme.dart et advanced_theme.dart
2. **Phase 2** : Migrer tous les imports vers inspired_theme.dart
3. **Phase 3** : Remplacer les valeurs hardcodées par tokens
4. **Phase 4** : Implémenter les nouveaux composants
5. **Phase 5** : Appliquer les templates aux screens existants

## Validation Checklist

- [ ] Un seul système de thème actif
- [ ] Tokens utilisés partout (pas de valeurs magic)
- [ ] RTL fonctionne sur tous les écrans arabes
- [ ] Dark mode cohérent
- [ ] Accessibilité validée (contrast checker)
- [ ] Responsive sur 3+ breakpoints
- [ ] Performance : pas de rebuilds inutiles
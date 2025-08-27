import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/share_service.dart';
import '../../core/services/analytics_service.dart';
import '../../core/providers/analytics_provider.dart';
import '../../core/widgets/haptic_wrapper.dart';

/// Écran de partage social
class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key});
  
  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final ShareService _shareService = ShareService.instance;
  
  // État
  ShareCardType _selectedType = ShareCardType.streak;
  ShareCardStyle _selectedStyle = ShareCardStyle.modern;
  String _customMessage = '';
  bool _isGenerating = false;
  ShareCard? _generatedCard;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelp,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Type de carte
          _SectionCard(
            title: 'Type de partage',
            icon: Icons.category,
            child: Column(
              children: [
                _TypeOption(
                  type: ShareCardType.streak,
                  title: 'Série (Streak)',
                  subtitle: 'Partagez votre série de jours consécutifs',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                  isSelected: _selectedType == ShareCardType.streak,
                  onTap: () => setState(() => _selectedType = ShareCardType.streak),
                ),
                _TypeOption(
                  type: ShareCardType.milestone,
                  title: 'Milestone',
                  subtitle: 'Célébrez un accomplissement atteint',
                  icon: Icons.emoji_events,
                  color: Colors.amber,
                  isSelected: _selectedType == ShareCardType.milestone,
                  onTap: () => setState(() => _selectedType = ShareCardType.milestone),
                ),
                _TypeOption(
                  type: ShareCardType.monthlyStats,
                  title: 'Stats mensuelles',
                  subtitle: 'Résumé de votre mois de pratique',
                  icon: Icons.calendar_month,
                  color: Colors.purple,
                  isSelected: _selectedType == ShareCardType.monthlyStats,
                  onTap: () => setState(() => _selectedType = ShareCardType.monthlyStats),
                ),
                _TypeOption(
                  type: ShareCardType.story,
                  title: 'Story',
                  subtitle: 'Format vertical pour stories Instagram/WhatsApp',
                  icon: Icons.amp_stories,
                  color: Colors.blue,
                  isSelected: _selectedType == ShareCardType.story,
                  onTap: () => setState(() => _selectedType = ShareCardType.story),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Style visuel
          _SectionCard(
            title: 'Style visuel',
            icon: Icons.palette,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _StyleChip(
                      style: ShareCardStyle.modern,
                      label: 'Moderne',
                      isSelected: _selectedStyle == ShareCardStyle.modern,
                      onTap: () => setState(() => _selectedStyle = ShareCardStyle.modern),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StyleChip(
                      style: ShareCardStyle.classic,
                      label: 'Classique',
                      isSelected: _selectedStyle == ShareCardStyle.classic,
                      onTap: () => setState(() => _selectedStyle = ShareCardStyle.classic),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StyleChip(
                      style: ShareCardStyle.minimal,
                      label: 'Minimal',
                      isSelected: _selectedStyle == ShareCardStyle.minimal,
                      onTap: () => setState(() => _selectedStyle = ShareCardStyle.minimal),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Message personnalisé
          _SectionCard(
            title: 'Message personnalisé (optionnel)',
            icon: Icons.edit,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    maxLines: 3,
                    maxLength: 280,
                    decoration: const InputDecoration(
                      hintText: 'Ajoutez un message personnel...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _customMessage = value,
                  ),
                  const SizedBox(height: 12),
                  
                  // Templates de messages
                  Text(
                    'Ou utilisez un template :',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _shareService.getShareTemplates()
                        .take(3)
                        .map((template) => ActionChip(
                              label: Text(template.title),
                              onPressed: () {
                                setState(() {
                                  _customMessage = template.message;
                                });
                              },
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Aperçu des données
          _buildDataPreview(),
          
          const SizedBox(height: 24),
          
          // Résultat généré
          if (_generatedCard != null)
            Card(
              color: Colors.green.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Carte créée avec succès',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Aperçu miniature
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Aperçu disponible après partage',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: HapticWrapper(
                            type: HapticType.selection,
                            onTap: () => _shareCard(),
                            child: FilledButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.share),
                              label: const Text('Partager'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _regenerateCard(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Régénérer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 80),
        ],
      ),
      
      // Bouton de génération
      floatingActionButton: HapticWrapper(
        type: HapticType.impact,
        onTap: _isGenerating ? null : () => _generateCard(),
        child: FloatingActionButton.extended(
          onPressed: null,
          icon: _isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(_isGenerating ? 'Génération...' : 'Créer la carte'),
        ),
      ),
    );
  }
  
  Widget _buildDataPreview() {
    return Consumer(
      builder: (context, ref, _) {
        switch (_selectedType) {
          case ShareCardType.streak:
            final streakAsync = ref.watch(streakDataProvider);
            return streakAsync.when(
              data: (streak) => _DataPreviewCard(
                title: 'Données de série',
                items: [
                  _DataItem('Série actuelle', '${streak.currentStreak} jours'),
                  _DataItem('Record', '${streak.longestStreak} jours'),
                ],
              ),
              loading: () => const _LoadingCard(),
              error: (_, __) => const SizedBox.shrink(),
            );
            
          case ShareCardType.milestone:
            final milestonesAsync = ref.watch(milestonesProvider);
            return milestonesAsync.when(
              data: (milestones) {
                if (milestones.isEmpty) {
                  return const _EmptyDataCard(
                    message: 'Aucun milestone atteint',
                  );
                }
                final latest = milestones.first;
                return _DataPreviewCard(
                  title: 'Dernier milestone',
                  items: [
                    _DataItem('Type', latest.type),
                    _DataItem('Valeur', latest.value.toString()),
                    _DataItem('Description', latest.description),
                  ],
                );
              },
              loading: () => const _LoadingCard(),
              error: (_, __) => const SizedBox.shrink(),
            );
            
          case ShareCardType.monthlyStats:
            final monthlyAsync = ref.watch(monthlyMetricsProvider);
            return monthlyAsync.when(
              data: (metrics) => _DataPreviewCard(
                title: 'Stats du mois',
                items: [
                  _DataItem('Répétitions', metrics.totalRepetitions.toString()),
                  _DataItem('Sessions', metrics.totalSessions.toString()),
                  _DataItem('Jours actifs', '${metrics.activeDays} jours'),
                  if (metrics.progressionPercent != 0)
                    _DataItem(
                      'Progression',
                      '${metrics.progressionPercent > 0 ? '+' : ''}${metrics.progressionPercent}%',
                    ),
                ],
              ),
              loading: () => const _LoadingCard(),
              error: (_, __) => const SizedBox.shrink(),
            );
            
          case ShareCardType.story:
            final chartAsync = ref.watch(repetitionsChartProvider);
            return chartAsync.when(
              data: (data) => _DataPreviewCard(
                title: 'Progression (7 jours)',
                items: [
                  _DataItem('Points de données', '${data.length}'),
                  _DataItem('Format', '9:16 (Story)'),
                ],
              ),
              loading: () => const _LoadingCard(),
              error: (_, __) => const SizedBox.shrink(),
            );
            
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
  
  Future<void> _generateCard() async {
    setState(() {
      _isGenerating = true;
      _generatedCard = null;
    });
    
    try {
      ShareCard? card;
      
      switch (_selectedType) {
        case ShareCardType.streak:
          final streak = await ref.read(streakDataProvider.future);
          card = await _shareService.createStreakCard(
            streak: streak,
            style: _selectedStyle,
            customMessage: _customMessage.isNotEmpty ? _customMessage : null,
          );
          break;
          
        case ShareCardType.milestone:
          final milestones = await ref.read(milestonesProvider.future);
          if (milestones.isNotEmpty) {
            card = await _shareService.createMilestoneCard(
              milestone: milestones.first,
              style: _selectedStyle,
              customMessage: _customMessage.isNotEmpty ? _customMessage : null,
            );
          }
          break;
          
        case ShareCardType.monthlyStats:
          final metrics = await ref.read(monthlyMetricsProvider.future);
          card = await _shareService.createMonthlyStatsCard(
            metrics: metrics,
            style: _selectedStyle,
            customMessage: _customMessage.isNotEmpty ? _customMessage : null,
          );
          break;
          
        case ShareCardType.story:
          final data = await ref.read(repetitionsChartProvider.future);
          card = await _shareService.createProgressStory(
            progressData: data,
            title: 'Ma progression',
            style: ShareCardStyle.story,
            customMessage: _customMessage.isNotEmpty ? _customMessage : null,
          );
          break;
          
        default:
          break;
      }
      
      setState(() {
        _generatedCard = card;
      });
      
      if (card != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Carte créée avec succès !'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }
  
  Future<void> _regenerateCard() async {
    await _generateCard();
  }
  
  Future<void> _shareCard() async {
    if (_generatedCard == null) return;
    
    final success = await _shareService.shareCard(_generatedCard!);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Partagé avec succès !'),
        ),
      );
    }
  }
  
  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comment partager ?'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Choisissez le type de carte à créer\n'
                '2. Sélectionnez un style visuel\n'
                '3. Ajoutez un message personnel (optionnel)\n'
                '4. Cliquez sur "Créer la carte"\n'
                '5. Partagez sur vos réseaux sociaux préférés\n\n'
                'Les cartes sont optimisées pour :\n'
                '• Instagram (feed et stories)\n'
                '• WhatsApp\n'
                '• Facebook\n'
                '• Twitter',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}

/// Card de section
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Option de type
class _TypeOption extends StatelessWidget {
  final ShareCardType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _TypeOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Radio<bool>(
        value: true,
        groupValue: isSelected,
        onChanged: (_) => onTap(),
      ),
      onTap: onTap,
    );
  }
}

/// Chip de style
class _StyleChip extends StatelessWidget {
  final ShareCardStyle style;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _StyleChip({
    required this.style,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? theme.primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? theme.primaryColor : null,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Card d'aperçu des données
class _DataPreviewCard extends StatelessWidget {
  final String title;
  final List<_DataItem> items;
  
  const _DataPreviewCard({
    required this.title,
    required this.items,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      color: theme.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    item.value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

/// Item de données
class _DataItem {
  final String label;
  final String value;
  
  const _DataItem(this.label, this.value);
}

/// Card vide
class _EmptyDataCard extends StatelessWidget {
  final String message;
  
  const _EmptyDataCard({required this.message});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card de chargement
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
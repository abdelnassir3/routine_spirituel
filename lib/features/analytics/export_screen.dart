import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/export_service.dart';
import '../../core/widgets/haptic_wrapper.dart';

/// Écran d'export des données
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});
  
  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  // Configuration de l'export
  DateRange _selectedRange = DateRange.lastMonth();
  ExportFormat _selectedFormat = ExportFormat.pdf;
  final Set<ExportDataType> _selectedDataTypes = {
    ExportDataType.allTimeStats,
    ExportDataType.streakData,
    ExportDataType.milestones,
  };
  
  bool _isExporting = false;
  ExportResult? _lastExport;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exporter les données'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Période
          _SectionCard(
            title: 'Période',
            icon: Icons.date_range,
            child: Column(
              children: [
                _RangeOption(
                  title: 'Dernière semaine',
                  subtitle: '7 derniers jours',
                  value: 'week',
                  groupValue: _getRangeValue(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRange = DateRange.lastWeek();
                    });
                  },
                ),
                _RangeOption(
                  title: 'Dernier mois',
                  subtitle: '30 derniers jours',
                  value: 'month',
                  groupValue: _getRangeValue(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRange = DateRange.lastMonth();
                    });
                  },
                ),
                _RangeOption(
                  title: 'Dernière année',
                  subtitle: '365 derniers jours',
                  value: 'year',
                  groupValue: _getRangeValue(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRange = DateRange.lastYear();
                    });
                  },
                ),
                _RangeOption(
                  title: 'Tout',
                  subtitle: 'Depuis le début',
                  value: 'all',
                  groupValue: _getRangeValue(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRange = DateRange.allTime();
                    });
                  },
                ),
                
                // Date personnalisée
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Période personnalisée'),
                  subtitle: Text(
                    '${_formatDate(_selectedRange.start)} - ${_formatDate(_selectedRange.end)}',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: DateTimeRange(
                        start: _selectedRange.start,
                        end: _selectedRange.end,
                      ),
                    );
                    
                    if (range != null) {
                      setState(() {
                        _selectedRange = DateRange(
                          start: range.start,
                          end: range.end,
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Format
          _SectionCard(
            title: 'Format',
            icon: Icons.description,
            child: Column(
              children: [
                _FormatOption(
                  format: ExportFormat.pdf,
                  title: 'PDF',
                  subtitle: 'Document formaté avec graphiques',
                  icon: Icons.picture_as_pdf,
                  color: Colors.red,
                  isSelected: _selectedFormat == ExportFormat.pdf,
                  onTap: () {
                    setState(() {
                      _selectedFormat = ExportFormat.pdf;
                    });
                  },
                ),
                _FormatOption(
                  format: ExportFormat.csv,
                  title: 'CSV',
                  subtitle: 'Tableur compatible Excel',
                  icon: Icons.table_chart,
                  color: Colors.green,
                  isSelected: _selectedFormat == ExportFormat.csv,
                  onTap: () {
                    setState(() {
                      _selectedFormat = ExportFormat.csv;
                    });
                  },
                ),
                _FormatOption(
                  format: ExportFormat.json,
                  title: 'JSON',
                  subtitle: 'Format structuré pour développeurs',
                  icon: Icons.code,
                  color: Colors.blue,
                  isSelected: _selectedFormat == ExportFormat.json,
                  onTap: () {
                    setState(() {
                      _selectedFormat = ExportFormat.json;
                    });
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Données à inclure
          _SectionCard(
            title: 'Données à inclure',
            icon: Icons.checklist,
            child: Column(
              children: [
                _DataTypeOption(
                  type: ExportDataType.allTimeStats,
                  title: 'Statistiques globales',
                  subtitle: 'Total des répétitions, sessions, temps',
                  isSelected: _selectedDataTypes.contains(ExportDataType.allTimeStats),
                  onChanged: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDataTypes.add(ExportDataType.allTimeStats);
                      } else {
                        _selectedDataTypes.remove(ExportDataType.allTimeStats);
                      }
                    });
                  },
                ),
                _DataTypeOption(
                  type: ExportDataType.dailyMetrics,
                  title: 'Détails quotidiens',
                  subtitle: 'Métriques jour par jour',
                  isSelected: _selectedDataTypes.contains(ExportDataType.dailyMetrics),
                  onChanged: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDataTypes.add(ExportDataType.dailyMetrics);
                      } else {
                        _selectedDataTypes.remove(ExportDataType.dailyMetrics);
                      }
                    });
                  },
                ),
                _DataTypeOption(
                  type: ExportDataType.streakData,
                  title: 'Série (Streak)',
                  subtitle: 'Série actuelle et record',
                  isSelected: _selectedDataTypes.contains(ExportDataType.streakData),
                  onChanged: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDataTypes.add(ExportDataType.streakData);
                      } else {
                        _selectedDataTypes.remove(ExportDataType.streakData);
                      }
                    });
                  },
                ),
                _DataTypeOption(
                  type: ExportDataType.milestones,
                  title: 'Milestones',
                  subtitle: 'Accomplissements atteints',
                  isSelected: _selectedDataTypes.contains(ExportDataType.milestones),
                  onChanged: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDataTypes.add(ExportDataType.milestones);
                      } else {
                        _selectedDataTypes.remove(ExportDataType.milestones);
                      }
                    });
                  },
                ),
                if (_selectedFormat == ExportFormat.pdf)
                  _DataTypeOption(
                    type: ExportDataType.charts,
                    title: 'Graphiques',
                    subtitle: 'Visualisations des tendances',
                    isSelected: _selectedDataTypes.contains(ExportDataType.charts),
                    onChanged: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDataTypes.add(ExportDataType.charts);
                        } else {
                          _selectedDataTypes.remove(ExportDataType.charts);
                        }
                      });
                    },
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Résultat du dernier export
          if (_lastExport != null)
            Card(
              color: _lastExport!.success 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _lastExport!.success 
                              ? Icons.check_circle
                              : Icons.error,
                          color: _lastExport!.success 
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _lastExport!.success 
                              ? 'Export réussi'
                              : 'Échec de l\'export',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _lastExport!.success 
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    if (_lastExport!.success) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Format: ${_lastExport!.format?.name.toUpperCase()}',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        'Taille: ${_formatFileSize(_lastExport!.size ?? 0)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final service = ExportService.instance;
                                await service.shareExport(_lastExport!);
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Partager'),
                            ),
                          ),
                        ],
                      ),
                    ] else if (_lastExport!.error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _lastExport!.error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 80),
        ],
      ),
      
      // Bouton d'export
      floatingActionButton: HapticWrapper(
        type: HapticType.impact,
        onTap: _selectedDataTypes.isEmpty || _isExporting
            ? null
            : () => _performExport(),
        child: FloatingActionButton.extended(
          onPressed: null,
          icon: _isExporting 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.download),
          label: Text(_isExporting ? 'Export...' : 'Exporter'),
          backgroundColor: _selectedDataTypes.isEmpty 
              ? Colors.grey
              : theme.primaryColor,
        ),
      ),
    );
  }
  
  String _getRangeValue() {
    final now = DateTime.now();
    final daysDiff = now.difference(_selectedRange.start).inDays;
    
    if (daysDiff == 7) return 'week';
    if (daysDiff == 30) return 'month';
    if (daysDiff == 365) return 'year';
    if (_selectedRange.start.year == 2020) return 'all';
    return 'custom';
  }
  
  Future<void> _performExport() async {
    setState(() {
      _isExporting = true;
      _lastExport = null;
    });
    
    final service = ExportService.instance;
    ExportResult result;
    
    try {
      switch (_selectedFormat) {
        case ExportFormat.pdf:
          result = await service.exportToPDF(
            range: _selectedRange,
            dataTypes: _selectedDataTypes.toList(),
            includeCharts: _selectedDataTypes.contains(ExportDataType.charts),
          );
          break;
          
        case ExportFormat.csv:
          result = await service.exportToCSV(
            range: _selectedRange,
            dataTypes: _selectedDataTypes.toList(),
            includeDetails: _selectedDataTypes.contains(ExportDataType.dailyMetrics),
          );
          break;
          
        case ExportFormat.json:
          result = await service.exportToJSON(
            range: _selectedRange,
            dataTypes: _selectedDataTypes.toList(),
            prettyPrint: true,
          );
          break;
      }
      
      setState(() {
        _lastExport = result;
      });
      
      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export ${_selectedFormat.name.toUpperCase()} créé avec succès'),
            action: SnackBarAction(
              label: 'Partager',
              onPressed: () async {
                await service.shareExport(result);
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _lastExport = ExportResult(
          success: false,
          error: e.toString(),
        );
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }
  
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
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

/// Option de période
class _RangeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;
  
  const _RangeOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}

/// Option de format
class _FormatOption extends StatelessWidget {
  final ExportFormat format;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _FormatOption({
    required this.format,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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

/// Option de type de données
class _DataTypeOption extends StatelessWidget {
  final ExportDataType type;
  final String title;
  final String subtitle;
  final bool isSelected;
  final ValueChanged<bool> onChanged;
  
  const _DataTypeOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: isSelected,
      onChanged: (value) => onChanged(value ?? false),
    );
  }
}
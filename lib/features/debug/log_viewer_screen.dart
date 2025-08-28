import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../core/services/secure_logging_service.dart';
import '../../core/providers/logging_provider.dart';

/// Écran de visualisation des logs (DEBUG ONLY)
///
/// Permet de voir les logs en temps réel pendant le développement
class LogViewerScreen extends ConsumerStatefulWidget {
  const LogViewerScreen({super.key});

  @override
  ConsumerState<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends ConsumerState<LogViewerScreen> {
  LogLevel? _filterLevel;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<LogEntry> _getFilteredLogs() {
    var logs = ref.watch(recentLogsProvider);

    // Filtrer par niveau
    if (_filterLevel != null) {
      logs =
          logs.where((log) => log.level.index >= _filterLevel!.index).toList();
    }

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      logs = logs.where((log) {
        return log.message.toLowerCase().contains(query) ||
            (log.data?.toString().toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return logs;
  }

  Color _getLogColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.critical:
        return Colors.red.shade900;
    }
  }

  IconData _getLogIcon(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Icons.bug_report;
      case LogLevel.info:
        return Icons.info_outline;
      case LogLevel.warning:
        return Icons.warning_amber;
      case LogLevel.error:
        return Icons.error_outline;
      case LogLevel.critical:
        return Icons.dangerous;
    }
  }

  void _copyLog(LogEntry log) {
    final json = const JsonEncoder.withIndent('  ').convert(log.toJson());
    Clipboard.setData(ClipboardData(text: json));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Log copié dans le presse-papiers'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _clearLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer les logs ?'),
        content: const Text(
            'Cette action effacera tous les logs du buffer mémoire.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ref.read(loggingProvider).clearMemoryBuffer();
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text('Effacer'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _exportLogs() async {
    final logger = ref.read(loggingProvider);
    final file = await logger.exportLogs();

    if (file != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logs exportés: ${file.path}'),
          action: SnackBarAction(
            label: 'Copier le chemin',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: file.path));
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final logs = _getFilteredLogs();
    final analysis = ref.watch(logAnalysisProvider);
    final theme = Theme.of(context);

    // Auto-scroll si activé
    if (_autoScroll && logs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs (Debug)'),
        actions: [
          IconButton(
            icon: Icon(_autoScroll ? Icons.lock_outline : Icons.lock_open),
            onPressed: () {
              setState(() {
                _autoScroll = !_autoScroll;
              });
            },
            tooltip:
                _autoScroll ? 'Auto-scroll activé' : 'Auto-scroll désactivé',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportLogs,
            tooltip: 'Exporter les logs',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearLogs,
            tooltip: 'Effacer les logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistiques
          Container(
            padding: const EdgeInsets.all(8),
            color: theme.primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                _buildStatChip('Total', analysis['total'] ?? 0, Colors.grey),
                const SizedBox(width: 8),
                _buildStatChip('Debug', analysis['debug'] ?? 0, Colors.grey),
                const SizedBox(width: 8),
                _buildStatChip('Info', analysis['info'] ?? 0, Colors.blue),
                const SizedBox(width: 8),
                _buildStatChip(
                    'Warning', analysis['warning'] ?? 0, Colors.orange),
                const SizedBox(width: 8),
                _buildStatChip('Error', analysis['error'] ?? 0, Colors.red),
                const SizedBox(width: 8),
                _buildStatChip(
                    'Critical', analysis['critical'] ?? 0, Colors.red.shade900),
              ],
            ),
          ),

          // Filtres
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Filtre par niveau
                Expanded(
                  child: DropdownButtonFormField<LogLevel?>(
                    value: _filterLevel,
                    decoration: const InputDecoration(
                      labelText: 'Niveau minimum',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tous')),
                      DropdownMenuItem(
                          value: LogLevel.debug, child: Text('Debug')),
                      DropdownMenuItem(
                          value: LogLevel.info, child: Text('Info')),
                      DropdownMenuItem(
                          value: LogLevel.warning, child: Text('Warning')),
                      DropdownMenuItem(
                          value: LogLevel.error, child: Text('Error')),
                      DropdownMenuItem(
                          value: LogLevel.critical, child: Text('Critical')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterLevel = value;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 8),

                // Recherche
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Rechercher',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Liste des logs
          Expanded(
            child: logs.isEmpty
                ? const Center(
                    child: Text(
                      'Aucun log',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    controller: _scrollController,
                    itemCount: logs.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final color = _getLogColor(log.level);
                      final icon = _getLogIcon(log.level);

                      return ExpansionTile(
                        leading: Icon(icon, color: color, size: 20),
                        title: Text(
                          log.message,
                          style: TextStyle(
                            color: color,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${log.timestamp.hour.toString().padLeft(2, '0')}:'
                          '${log.timestamp.minute.toString().padLeft(2, '0')}:'
                          '${log.timestamp.second.toString().padLeft(2, '0')}.'
                          '${(log.timestamp.millisecond ~/ 10).toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          onPressed: () => _copyLog(log),
                        ),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            color: theme.cardColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Message complet
                                SelectableText(
                                  log.message,
                                  style: const TextStyle(fontSize: 12),
                                ),

                                // Données
                                if (log.data != null &&
                                    log.data!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Data:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: SelectableText(
                                      const JsonEncoder.withIndent('  ')
                                          .convert(log.data),
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],

                                // Stack trace
                                if (log.stackTrace != null) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Stack Trace:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: SelectableText(
                                      log.stackTrace.toString(),
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],

                                // Métadonnées
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(
                                        log.level.name.toUpperCase(),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      backgroundColor: color.withOpacity(0.2),
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Env: ${log.environment}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Session: ${log.sessionId}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Chip(
      label: Text(
        '$label: $count',
        style: const TextStyle(fontSize: 11),
      ),
      backgroundColor: color.withOpacity(0.2),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

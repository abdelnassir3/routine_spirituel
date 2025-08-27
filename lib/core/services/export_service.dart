import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../utils/app_logger.dart';
import 'analytics_service.dart';

/// Service d'export des données analytiques
/// 
/// Permet d'exporter les statistiques et données en différents formats
/// (CSV, JSON, PDF) pour partage ou sauvegarde
class ExportService {
  static ExportService? _instance;
  
  // Services
  final AnalyticsService _analyticsService = AnalyticsService.instance;
  
  // Configuration
  static const String _exportFolder = 'spiritual_routines_exports';
  
  // Singleton
  static ExportService get instance {
    _instance ??= ExportService._();
    return _instance!;
  }
  
  ExportService._();
  
  // ===== Export CSV =====
  
  /// Exporter les données en CSV
  Future<ExportResult> exportToCSV({
    required DateRange range,
    required List<ExportDataType> dataTypes,
    bool includeDetails = true,
  }) async {
    try {
      AppLogger.logDebugInfo('Starting CSV export', {
        'range': range.toString(),
        'dataTypes': dataTypes.map((t) => t.name).toList(),
      });
      
      // Collecter les données
      final data = await _collectData(range, dataTypes);
      
      // Créer le CSV
      final csv = await _generateCSV(data, includeDetails);
      
      // Sauvegarder le fichier
      final fileName = 'export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = await _saveToFile(fileName, csv);
      
      AppLogger.logUserAction('data_exported', {
        'format': 'csv',
        'size': file.lengthSync(),
      });
      
      return ExportResult(
        success: true,
        filePath: file.path,
        format: ExportFormat.csv,
        size: file.lengthSync(),
      );
    } catch (e) {
      AppLogger.logError('CSV export failed', e);
      return ExportResult(
        success: false,
        error: e.toString(),
      );
    }
  }
  
  Future<String> _generateCSV(ExportData data, bool includeDetails) async {
    final rows = <List<dynamic>>[];
    
    // En-tête
    rows.add(['Statistiques spirituelles - Export du ${_formatDate(DateTime.now())}']);
    rows.add([]);
    
    // Période
    rows.add(['Période', 'Du ${_formatDate(data.startDate)} au ${_formatDate(data.endDate)}']);
    rows.add([]);
    
    // Statistiques globales
    if (data.allTimeStats != null) {
      rows.add(['=== STATISTIQUES GLOBALES ===']);
      rows.add(['Total des répétitions', data.allTimeStats!.totalRepetitions]);
      rows.add(['Sessions complétées', data.allTimeStats!.totalSessions]);
      rows.add(['Temps de pratique (heures)', (data.allTimeStats!.totalDuration / 3600).toStringAsFixed(1)]);
      rows.add(['Jours de pratique', data.allTimeStats!.totalDays]);
      rows.add([]);
    }
    
    // Streak
    if (data.streakData != null) {
      rows.add(['=== SÉRIE (STREAK) ===']);
      rows.add(['Série actuelle', '${data.streakData!.currentStreak} jours']);
      rows.add(['Record', '${data.streakData!.longestStreak} jours']);
      rows.add(['Dernière activité', _formatDate(data.streakData!.lastActivityDate)]);
      rows.add([]);
    }
    
    // Métriques quotidiennes
    if (data.dailyMetrics.isNotEmpty && includeDetails) {
      rows.add(['=== DÉTAILS QUOTIDIENS ===']);
      rows.add(['Date', 'Sessions', 'Répétitions', 'Durée (min)', 'Taux complétion']);
      
      for (final daily in data.dailyMetrics) {
        rows.add([
          _formatDate(daily.date),
          daily.sessionsCompleted,
          daily.totalRepetitions,
          (daily.totalDuration / 60).toStringAsFixed(1),
          '${(daily.completionRate * 100).round()}%',
        ]);
      }
      rows.add([]);
    }
    
    // Milestones
    if (data.milestones.isNotEmpty) {
      rows.add(['=== MILESTONES ATTEINTS ===']);
      rows.add(['Date', 'Type', 'Valeur', 'Description']);
      
      for (final milestone in data.milestones) {
        rows.add([
          _formatDate(milestone.achievedAt),
          milestone.type,
          milestone.value,
          milestone.description,
        ]);
      }
    }
    
    // Convertir en CSV
    const converter = ListToCsvConverter();
    return converter.convert(rows);
  }
  
  // ===== Export JSON =====
  
  /// Exporter les données en JSON
  Future<ExportResult> exportToJSON({
    required DateRange range,
    required List<ExportDataType> dataTypes,
    bool prettyPrint = true,
  }) async {
    try {
      AppLogger.logDebugInfo('Starting JSON export', {
        'range': range.toString(),
        'dataTypes': dataTypes.map((t) => t.name).toList(),
      });
      
      // Collecter les données
      final data = await _collectData(range, dataTypes);
      
      // Créer le JSON
      final json = await _generateJSON(data, prettyPrint);
      
      // Sauvegarder le fichier
      final fileName = 'export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = await _saveToFile(fileName, json);
      
      AppLogger.logUserAction('data_exported', {
        'format': 'json',
        'size': file.lengthSync(),
      });
      
      return ExportResult(
        success: true,
        filePath: file.path,
        format: ExportFormat.json,
        size: file.lengthSync(),
      );
    } catch (e) {
      AppLogger.logError('JSON export failed', e);
      return ExportResult(
        success: false,
        error: e.toString(),
      );
    }
  }
  
  Future<String> _generateJSON(ExportData data, bool prettyPrint) async {
    final Map<String, dynamic> jsonData = {
      'export': {
        'version': '1.0',
        'app': 'Spiritual Routines',
        'date': DateTime.now().toIso8601String(),
        'range': {
          'start': data.startDate.toIso8601String(),
          'end': data.endDate.toIso8601String(),
        },
      },
      'statistics': {},
      'details': {},
    };
    
    // Statistiques globales
    if (data.allTimeStats != null) {
      jsonData['statistics']['allTime'] = data.allTimeStats!.toJson();
    }
    
    // Streak
    if (data.streakData != null) {
      jsonData['statistics']['streak'] = data.streakData!.toJson();
    }
    
    // Métriques mensuelles
    if (data.monthlyMetrics != null) {
      jsonData['statistics']['currentMonth'] = {
        'totalSessions': data.monthlyMetrics!.totalSessions,
        'totalRepetitions': data.monthlyMetrics!.totalRepetitions,
        'totalDuration': data.monthlyMetrics!.totalDuration,
        'activeDays': data.monthlyMetrics!.activeDays,
        'progressionPercent': data.monthlyMetrics!.progressionPercent,
      };
    }
    
    // Détails quotidiens
    if (data.dailyMetrics.isNotEmpty) {
      jsonData['details']['daily'] = data.dailyMetrics
          .map((d) => d.toJson())
          .toList();
    }
    
    // Milestones
    if (data.milestones.isNotEmpty) {
      jsonData['details']['milestones'] = data.milestones
          .map((m) => m.toJson())
          .toList();
    }
    
    // Graphiques
    if (data.chartData.isNotEmpty) {
      jsonData['details']['charts'] = data.chartData.map((key, value) {
        return MapEntry(key, value.map((c) => {
          'date': c.date.toIso8601String(),
          'value': c.value,
        }).toList());
      });
    }
    
    // Encoder
    final encoder = prettyPrint 
        ? const JsonEncoder.withIndent('  ')
        : const JsonEncoder();
    
    return encoder.convert(jsonData);
  }
  
  // ===== Export PDF =====
  
  /// Exporter les données en PDF
  Future<ExportResult> exportToPDF({
    required DateRange range,
    required List<ExportDataType> dataTypes,
    bool includeCharts = true,
  }) async {
    try {
      AppLogger.logDebugInfo('Starting PDF export', {
        'range': range.toString(),
        'dataTypes': dataTypes.map((t) => t.name).toList(),
      });
      
      // Collecter les données
      final data = await _collectData(range, dataTypes);
      
      // Créer le PDF
      final pdfBytes = await _generatePDF(data, includeCharts);
      
      // Sauvegarder le fichier
      final fileName = 'export_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = await _saveBytesToFile(fileName, pdfBytes);
      
      AppLogger.logUserAction('data_exported', {
        'format': 'pdf',
        'size': file.lengthSync(),
      });
      
      return ExportResult(
        success: true,
        filePath: file.path,
        format: ExportFormat.pdf,
        size: file.lengthSync(),
      );
    } catch (e) {
      AppLogger.logError('PDF export failed', e);
      return ExportResult(
        success: false,
        error: e.toString(),
      );
    }
  }
  
  Future<Uint8List> _generatePDF(ExportData data, bool includeCharts) async {
    final pdf = pw.Document();
    
    // Page de titre
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'Rapport Spirituel',
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Du ${_formatDate(data.startDate)} au ${_formatDate(data.endDate)}',
                style: const pw.TextStyle(fontSize: 18),
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                'Généré le ${_formatDate(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 14),
              ),
            ],
          );
        },
      ),
    );
    
    // Page de statistiques
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPDFHeader('Statistiques Globales'),
              pw.SizedBox(height: 20),
              
              if (data.allTimeStats != null) ...[
                _buildPDFStat('Total des répétitions', 
                    '${data.allTimeStats!.totalRepetitions}'),
                _buildPDFStat('Sessions complétées', 
                    '${data.allTimeStats!.totalSessions}'),
                _buildPDFStat('Temps de pratique', 
                    '${(data.allTimeStats!.totalDuration / 3600).toStringAsFixed(1)} heures'),
                _buildPDFStat('Jours de pratique', 
                    '${data.allTimeStats!.totalDays}'),
              ],
              
              pw.SizedBox(height: 30),
              
              if (data.streakData != null) ...[
                _buildPDFHeader('Série (Streak)'),
                pw.SizedBox(height: 10),
                _buildPDFStat('Série actuelle', 
                    '${data.streakData!.currentStreak} jours'),
                _buildPDFStat('Record', 
                    '${data.streakData!.longestStreak} jours'),
              ],
            ],
          );
        },
      ),
    );
    
    // Page des milestones
    if (data.milestones.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildPDFHeader('Milestones Atteints'),
                pw.SizedBox(height: 20),
                
                ...data.milestones.take(15).map((milestone) {
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 10),
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${milestone.value} ${milestone.type}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          milestone.description,
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          _formatDate(milestone.achievedAt),
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        },
      );
    }
    
    return pdf.save();
  }
  
  pw.Widget _buildPDFHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 20,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue900,
        ),
      ),
    );
  }
  
  pw.Widget _buildPDFStat(String label, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 14)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  // ===== Partage =====
  
  /// Partager les données exportées
  Future<bool> shareExport(ExportResult export) async {
    if (!export.success || export.filePath == null) {
      return false;
    }
    
    try {
      final file = XFile(export.filePath!);
      
      await Share.shareXFiles(
        [file],
        subject: 'Export Spiritual Routines',
        text: 'Mes statistiques spirituelles du ${_formatDate(DateTime.now())}',
      );
      
      AppLogger.logUserAction('export_shared', {
        'format': export.format?.name,
        'size': export.size,
      });
      
      return true;
    } catch (e) {
      AppLogger.logError('Share export failed', e);
      return false;
    }
  }
  
  // ===== Helpers =====
  
  /// Collecter les données selon les types demandés
  Future<ExportData> _collectData(
    DateRange range,
    List<ExportDataType> dataTypes,
  ) async {
    final data = ExportData(
      startDate: range.start,
      endDate: range.end,
    );
    
    // Collecter selon les types demandés
    for (final type in dataTypes) {
      switch (type) {
        case ExportDataType.allTimeStats:
          data.allTimeStats = await _analyticsService.getAllTimeStats();
          break;
          
        case ExportDataType.dailyMetrics:
          data.dailyMetrics = await _collectDailyMetrics(range);
          break;
          
        case ExportDataType.weeklyMetrics:
          data.weeklyMetrics = await _analyticsService.getWeeklyMetrics();
          break;
          
        case ExportDataType.monthlyMetrics:
          data.monthlyMetrics = await _analyticsService.getMonthlyMetrics();
          break;
          
        case ExportDataType.streakData:
          data.streakData = await _analyticsService.getStreakData();
          break;
          
        case ExportDataType.milestones:
          data.milestones = await _analyticsService.getMilestones();
          break;
          
        case ExportDataType.charts:
          data.chartData = await _collectChartData(range);
          break;
          
        case ExportDataType.prayerDistribution:
          data.prayerDistribution = await _analyticsService.getPrayerDistribution();
          break;
      }
    }
    
    return data;
  }
  
  /// Collecter les métriques quotidiennes pour une période
  Future<List<DailyMetrics>> _collectDailyMetrics(DateRange range) async {
    final metrics = <DailyMetrics>[];
    
    for (DateTime date = range.start;
         date.isBefore(range.end.add(const Duration(days: 1)));
         date = date.add(const Duration(days: 1))) {
      final daily = await _analyticsService.getDailyMetrics(date);
      metrics.add(daily);
    }
    
    return metrics;
  }
  
  /// Collecter les données de graphiques
  Future<Map<String, List<ChartData>>> _collectChartData(DateRange range) async {
    return {
      'repetitions': await _analyticsService.getRepetitionsChart(
        startDate: range.start,
        endDate: range.end,
      ),
      'sessions': await _analyticsService.getSessionsChart(
        startDate: range.start,
        endDate: range.end,
      ),
    };
  }
  
  /// Sauvegarder du texte dans un fichier
  Future<File> _saveToFile(String fileName, String content) async {
    final directory = await _getExportDirectory();
    final file = File('${directory.path}/$fileName');
    return await file.writeAsString(content);
  }
  
  /// Sauvegarder des bytes dans un fichier
  Future<File> _saveBytesToFile(String fileName, Uint8List bytes) async {
    final directory = await _getExportDirectory();
    final file = File('${directory.path}/$fileName');
    return await file.writeAsBytes(bytes);
  }
  
  /// Obtenir le répertoire d'export
  Future<Directory> _getExportDirectory() async {
    Directory directory;
    
    if (Platform.isAndroid) {
      // Android : utiliser le dossier Downloads public
      directory = Directory('/storage/emulated/0/Download/$_exportFolder');
    } else if (Platform.isIOS) {
      // iOS : utiliser le dossier Documents de l'app
      directory = await getApplicationDocumentsDirectory();
      directory = Directory('${directory.path}/$_exportFolder');
    } else {
      // Desktop : utiliser le dossier Documents
      directory = await getApplicationDocumentsDirectory();
      directory = Directory('${directory.path}/$_exportFolder');
    }
    
    // Créer le dossier s'il n'existe pas
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    return directory;
  }
  
  /// Formater une date
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }
  
  /// Nettoyer les anciens exports
  Future<void> cleanOldExports({int keepDays = 30}) async {
    try {
      final directory = await _getExportDirectory();
      final now = DateTime.now();
      
      await for (final entity in directory.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified);
          
          if (age.inDays > keepDays) {
            await entity.delete();
            AppLogger.logDebugInfo('Deleted old export', {
              'file': entity.path,
              'age': age.inDays,
            });
          }
        }
      }
    } catch (e) {
      AppLogger.logError('Failed to clean old exports', e);
    }
  }
}

// ===== Modèles =====

/// Plage de dates pour l'export
class DateRange {
  final DateTime start;
  final DateTime end;
  
  DateRange({required this.start, required this.end});
  
  /// Prédéfinis
  factory DateRange.lastWeek() {
    final now = DateTime.now();
    return DateRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );
  }
  
  factory DateRange.lastMonth() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(now.year, now.month - 1, now.day),
      end: now,
    );
  }
  
  factory DateRange.lastYear() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(now.year - 1, now.month, now.day),
      end: now,
    );
  }
  
  factory DateRange.allTime() {
    return DateRange(
      start: DateTime(2020, 1, 1),
      end: DateTime.now(),
    );
  }
  
  @override
  String toString() => '${start.toIso8601String()} - ${end.toIso8601String()}';
}

/// Types de données à exporter
enum ExportDataType {
  allTimeStats,
  dailyMetrics,
  weeklyMetrics,
  monthlyMetrics,
  streakData,
  milestones,
  charts,
  prayerDistribution,
}

/// Formats d'export disponibles
enum ExportFormat {
  csv,
  json,
  pdf,
}

/// Données collectées pour l'export
class ExportData {
  final DateTime startDate;
  final DateTime endDate;
  
  AllTimeStats? allTimeStats;
  List<DailyMetrics> dailyMetrics = [];
  WeeklyMetrics? weeklyMetrics;
  MonthlyMetrics? monthlyMetrics;
  StreakData? streakData;
  List<Milestone> milestones = [];
  Map<String, List<ChartData>> chartData = {};
  Map<String, double>? prayerDistribution;
  
  ExportData({
    required this.startDate,
    required this.endDate,
  });
}

/// Résultat d'un export
class ExportResult {
  final bool success;
  final String? filePath;
  final ExportFormat? format;
  final int? size;
  final String? error;
  
  ExportResult({
    required this.success,
    this.filePath,
    this.format,
    this.size,
    this.error,
  });
}
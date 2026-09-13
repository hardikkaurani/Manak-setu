import 'dart:convert';
import '../models/export_report.dart';
import '../models/multi_factor_confidence.dart';
import '../models/specification_gap_analysis.dart';

/// Service responsible for producing audit-ready export packages in PDF, CSV, and JSON formats.
class ExportService {
  /// Builds a complete export package from analysis outputs.
  static ExportReportPackage buildExportPackage({
    required String reportId,
    required String title,
    required String organizationName,
    required String department,
    required String executiveSummary,
    required List<String> inputRequirements,
    required List<Map<String, dynamic>> recommendedStandards,
    SpecificationGapAnalysis? gapAnalysis,
    List<String> identifiedConflicts = const [],
    List<String> identifiedUnknowns = const [],
    required Map<String, dynamic> decisionTraceSummary,
    required MultiFactorConfidence confidence,
    required Map<String, dynamic> humanReviewSignoff,
    String datasetVersion = 'v1.0.0-global-standards',
    String modelVersion = 'manaksetu-hybrid-rerank-v1.2',
  }) {
    return ExportReportPackage(
      reportId: reportId,
      title: title,
      organizationName: organizationName,
      department: department,
      datasetVersion: datasetVersion,
      modelVersion: modelVersion,
      generatedAt: DateTime.now(),
      executiveSummary: executiveSummary,
      inputRequirements: inputRequirements,
      recommendedStandards: recommendedStandards,
      gapAnalysis: gapAnalysis,
      identifiedConflicts: identifiedConflicts,
      identifiedUnknowns: identifiedUnknowns,
      decisionTraceSummary: decisionTraceSummary,
      confidence: confidence,
      humanReviewSignoff: humanReviewSignoff,
    );
  }

  /// Exports the package as an indented JSON string.
  static String exportJson(ExportReportPackage package) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(package.toJson());
  }

  /// Exports the package as CSV formatted text.
  static String exportCsv(ExportReportPackage package) {
    return package.toCsv();
  }

  /// Exports a clean, printable executive summary text suitable for formal tender scrutiny dossiers.
  static String exportExecutiveSummaryText(ExportReportPackage package) {
    final buffer = StringBuffer();
    buffer.writeln('================================================================================');
    buffer.writeln('MANAKSETU STANDARDS INTELLIGENCE & COMPLIANCE DOSSIER');
    buffer.writeln('Report ID: ${package.reportId} | Date: ${package.generatedAt.toIso8601String()}');
    buffer.writeln('Organization: ${package.organizationName} | Dept: ${package.department}');
    buffer.writeln('Dataset Version: ${package.datasetVersion} | Model: ${package.modelVersion}');
    buffer.writeln('================================================================================');
    buffer.writeln();
    buffer.writeln('EXECUTIVE SUMMARY:');
    buffer.writeln(package.executiveSummary);
    buffer.writeln();
    buffer.writeln('OVERALL DECISION STATE: ${package.confidence.overallDecisionState.label}');
    buffer.writeln('Composite Confidence Score: ${(package.confidence.compositeScore * 100).toStringAsFixed(1)}%');
    buffer.writeln('  - Retrieval Confidence: ${(package.confidence.retrievalConfidence * 100).toStringAsFixed(1)}%');
    buffer.writeln('  - Technical Match: ${(package.confidence.technicalMatchConfidence * 100).toStringAsFixed(1)}%');
    buffer.writeln('  - Lifecycle Certainty: ${(package.confidence.lifecycleConfidence * 100).toStringAsFixed(1)}%');
    buffer.writeln('  - Evidence Grounding: ${(package.confidence.evidenceConfidence * 100).toStringAsFixed(1)}%');
    buffer.writeln();
    buffer.writeln('RECOMMENDED STANDARDS:');
    for (final std in package.recommendedStandards) {
      buffer.writeln('  • ${std['code']} — ${std['title']} [${std['status']}]');
      if (std['evidence'] != null) {
        buffer.writeln('    Citation: ${std['evidence']}');
      }
    }
    buffer.writeln();
    if (package.gapAnalysis != null) {
      final gap = package.gapAnalysis!;
      buffer.writeln('SPECIFICATION GAP ANALYSIS:');
      buffer.writeln('  Coverage: ${gap.coveragePercentage}% (${gap.coveredCount} Covered, ${gap.partialCount} Partial, ${gap.missingCount} Missing, ${gap.conflictingCount} Conflicting)');
      for (final item in gap.items) {
        buffer.writeln('  - [${item.status.label}] ${item.parameterName}: ${item.engineeringRecommendation}');
        if (item.missingElement != null) {
          buffer.writeln('    Missing: ${item.missingElement}');
        }
      }
      buffer.writeln();
    }
    buffer.writeln('HUMAN REVIEW & VIGILANCE SIGNOFF:');
    buffer.writeln('  Status: ${package.humanReviewSignoff['status'] ?? "Pending Review"}');
    buffer.writeln('  Reviewer: ${package.humanReviewSignoff['officer_name'] ?? "Unassigned"} (${package.humanReviewSignoff['officer_id'] ?? "N/A"})');
    buffer.writeln('  Notes: ${package.humanReviewSignoff['comment'] ?? "None"}');
    buffer.writeln('================================================================================');
    return buffer.toString();
  }
}

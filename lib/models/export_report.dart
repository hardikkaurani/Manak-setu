import 'specification_gap_analysis.dart';
import 'multi_factor_confidence.dart';

/// Formatted export artifact formats.
enum ExportFormat { pdf, csv, json }

/// Comprehensive export report package for procurement compliance dossiers and audits.
class ExportReportPackage {
  final String reportId;
  final String title;
  final String organizationName;
  final String department;
  final String datasetVersion;
  final String modelVersion;
  final DateTime generatedAt;
  final String executiveSummary;
  final List<String> inputRequirements;
  final List<Map<String, dynamic>> recommendedStandards;
  final SpecificationGapAnalysis? gapAnalysis;
  final List<String> identifiedConflicts;
  final List<String> identifiedUnknowns;
  final Map<String, dynamic> decisionTraceSummary;
  final MultiFactorConfidence confidence;
  final Map<String, dynamic> humanReviewSignoff;

  const ExportReportPackage({
    required this.reportId,
    required this.title,
    required this.organizationName,
    required this.department,
    required this.datasetVersion,
    required this.modelVersion,
    required this.generatedAt,
    required this.executiveSummary,
    required this.inputRequirements,
    required this.recommendedStandards,
    this.gapAnalysis,
    this.identifiedConflicts = const [],
    this.identifiedUnknowns = const [],
    required this.decisionTraceSummary,
    required this.confidence,
    required this.humanReviewSignoff,
  });

  Map<String, dynamic> toJson() => {
        'report_id': reportId,
        'title': title,
        'organization': organizationName,
        'department': department,
        'dataset_version': datasetVersion,
        'model_version': modelVersion,
        'generated_at': generatedAt.toIso8601String(),
        'executive_summary': executiveSummary,
        'input_requirements': inputRequirements,
        'recommended_standards': recommendedStandards,
        'gap_analysis': gapAnalysis?.toJson(),
        'identified_conflicts': identifiedConflicts,
        'identified_unknowns': identifiedUnknowns,
        'decision_trace_summary': decisionTraceSummary,
        'confidence': confidence.toJson(),
        'human_review_signoff': humanReviewSignoff,
      };

  /// Generates a structured CSV representation of the recommended standards and requirements.
  String toCsv() {
    final buffer = StringBuffer();
    buffer.writeln('Parameter,Requirement,Standard Code,Status,Evidence Citation,Notes');
    if (gapAnalysis != null) {
      for (final item in gapAnalysis!.items) {
        final cleanParam = item.parameterName.replaceAll('"', '""');
        final cleanReq = item.tenderRequirement.replaceAll('"', '""');
        final cleanStd = (item.standardCode ?? 'N/A').replaceAll('"', '""');
        final cleanStat = item.status.label;
        final cleanEvid = (item.evidence?.citationDisplay ?? 'EVIDENCE_UNAVAILABLE').replaceAll('"', '""');
        final cleanRec = item.engineeringRecommendation.replaceAll('"', '""');
        buffer.writeln('"$cleanParam","$cleanReq","$cleanStd","$cleanStat","$cleanEvid","$cleanRec"');
      }
    } else {
      for (final s in recommendedStandards) {
        buffer.writeln('"General Specification","${s['title']}","${s['code']}","${s['status']}","${s['evidence']}","Recommended"');
      }
    }
    return buffer.toString();
  }
}

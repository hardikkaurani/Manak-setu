import 'standard.dart';
import 'compliance_finding.dart';

/// Represents the evaluated result of a tender scrutiny audit.
class TenderAnalysis {
  final String id;
  final String title;
  final String department;
  final String inputClause;
  final int compliancePercentage;
  final String status; // 'NON_COMPLIANT', 'COMPLIANT', 'REVIEW_REQUIRED'
  final int criticalDefects;
  final int highRiskViolations;
  final String summaryText;
  final List<Standard> detectedStandards;
  final List<ComplianceFinding> cvcFlags;
  final String? rectifiedClause;

  const TenderAnalysis({
    required this.id,
    required this.title,
    required this.department,
    required this.inputClause,
    required this.compliancePercentage,
    required this.status,
    required this.criticalDefects,
    required this.highRiskViolations,
    required this.summaryText,
    this.detectedStandards = const [],
    this.cvcFlags = const [],
    this.rectifiedClause,
  });

  bool get isNonCompliant => status == 'NON_COMPLIANT';
  bool get isCompliant => status == 'COMPLIANT';
}

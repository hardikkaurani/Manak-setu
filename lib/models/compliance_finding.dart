import 'evidence.dart';

enum FindingSeverity { critical, high, warning, verified }

/// Represents a CVC vigilance or statutory compliance finding.
class ComplianceFinding {
  final FindingSeverity severity;
  final String title;
  final String description;
  final String statutoryAction;
  final String? matchedEntity;
  final String? standardCitation;
  final Evidence? evidence;

  const ComplianceFinding({
    required this.severity,
    required this.title,
    required this.description,
    required this.statutoryAction,
    this.matchedEntity,
    this.standardCitation,
    this.evidence,
  });

  String get severityLabel {
    switch (severity) {
      case FindingSeverity.critical:
        return 'CRITICAL';
      case FindingSeverity.high:
        return 'HIGH';
      case FindingSeverity.warning:
        return 'REVIEW REQUIRED';
      case FindingSeverity.verified:
        return 'VERIFIED';
    }
  }
}

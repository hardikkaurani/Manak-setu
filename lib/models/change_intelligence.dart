/// Type of standard or regulatory lifecycle event.
enum ChangeType {
  newStandard('New Standard Published', 'First edition of a newly standardized specification'),
  newEdition('New Revision / Edition', 'Comprehensive revision replacing former edition'),
  amendmentPublished('Amendment Published', 'Corrigenda or addendum modifying specific clauses'),
  withdrawn('Standard Withdrawn', 'Standard cancelled or withdrawn without direct replacement'),
  superseded('Standard Superseded', 'Standard replaced by successor document or harmonized standard'),
  regulationUpdated('Statutory Mandate Updated', 'Quality Control Order or legal regulation updated'),
  evidenceUpdated('Evidence Source Updated', 'Official gazette or digital catalog update');

  final String label;
  final String description;
  const ChangeType(this.label, this.description);
}

/// Represents a change event in the global standards catalog.
class StandardChangeEvent {
  final String id;
  final String standardCode;
  final String organization;
  final String jurisdiction;
  final ChangeType changeType;
  final DateTime effectiveDate;
  final String summary;
  final String? previousVersion;
  final String? newVersion;
  final List<String> affectedClauses;
  final String sourceUrl;

  const StandardChangeEvent({
    required this.id,
    required this.standardCode,
    required this.organization,
    required this.jurisdiction,
    required this.changeType,
    required this.effectiveDate,
    required this.summary,
    this.previousVersion,
    this.newVersion,
    this.affectedClauses = const [],
    required this.sourceUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'standard_code': standardCode,
        'organization': organization,
        'jurisdiction': jurisdiction,
        'change_type': changeType.label,
        'effective_date': effectiveDate.toIso8601String(),
        'summary': summary,
        'previous_version': previousVersion,
        'new_version': newVersion,
        'affected_clauses': affectedClauses,
        'source_url': sourceUrl,
      };
}

/// Impact evaluation on an enterprise procurement project when a referenced standard changes.
class ProjectImpactAssessment {
  final String projectId;
  final String projectTitle;
  final StandardChangeEvent changeEvent;
  final String impactSeverity; // 'CRITICAL', 'HIGH', 'MODERATE', 'INFO'
  final String impactAnalysis;
  final List<String> recommendedActions;
  final DateTime evaluatedAt;

  const ProjectImpactAssessment({
    required this.projectId,
    required this.projectTitle,
    required this.changeEvent,
    required this.impactSeverity,
    required this.impactAnalysis,
    required this.recommendedActions,
    required this.evaluatedAt,
  });

  Map<String, dynamic> toJson() => {
        'project_id': projectId,
        'project_title': projectTitle,
        'change_event': changeEvent.toJson(),
        'impact_severity': impactSeverity,
        'impact_analysis': impactAnalysis,
        'recommended_actions': recommendedActions,
        'evaluated_at': evaluatedAt.toIso8601String(),
      };
}

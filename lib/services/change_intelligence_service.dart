import '../models/change_intelligence.dart';
import '../models/tenant_workspace.dart';

/// Service providing change intelligence tracking across global standards and analyzing impact on procurement projects.
class ChangeIntelligenceService {
  static final List<StandardChangeEvent> _changeRegistry = [
    StandardChangeEvent(
      id: 'evt-2026-08-is1180-amd',
      standardCode: 'IS 1180 (Part 1):2014',
      organization: 'Bureau of Indian Standards',
      jurisdiction: 'India',
      changeType: ChangeType.amendmentPublished,
      effectiveDate: DateTime(2026, 8, 15),
      summary: 'Amendment 4 gazetted: mandates revised copper winding test tolerances and digital tamper-evident QR plates.',
      previousVersion: '2014+A3',
      newVersion: '2014+A4',
      affectedClauses: ['Clause 7.2', 'Clause 16.3', 'Table 8'],
      sourceUrl: 'https://services.bis.gov.in/php/BIS_2.0/bisconnect/knowyourstandards/is1180-amd4.pdf',
    ),
    StandardChangeEvent(
      id: 'evt-2026-07-iso4427-rev',
      standardCode: 'ISO 4427-1:2019',
      organization: 'International Organization for Standardization',
      jurisdiction: 'International',
      changeType: ChangeType.newEdition,
      effectiveDate: DateTime(2026, 7, 1),
      summary: 'ISO 4427-1:2019 supersedes ISO 4427-1:2007: harmonizes PE 100-RC slow crack growth (SCG) accelerated test criteria.',
      previousVersion: '2007',
      newVersion: '2019',
      affectedClauses: ['Clause 4.3', 'Clause 6.2'],
      sourceUrl: 'https://www.iso.org/standard/70087.html',
    ),
    StandardChangeEvent(
      id: 'evt-2026-06-is1786-qco',
      standardCode: 'IS 1786:2008',
      organization: 'Ministry of Steel / BIS',
      jurisdiction: 'India',
      changeType: ChangeType.regulationUpdated,
      effectiveDate: DateTime(2026, 6, 1),
      summary: 'Steel and Steel Products (Quality Control) Order updated: strict prohibition on non-BIS marked imported reinforcement bars.',
      previousVersion: 'QCO 2024',
      newVersion: 'QCO 2026 Revision',
      affectedClauses: ['Statutory Order Clause 3'],
      sourceUrl: 'https://steel.gov.in/gazette/qco-steel-2026.pdf',
    ),
  ];

  /// Returns recent standard change events.
  static List<StandardChangeEvent> getRecentChanges({int limit = 10}) {
    return _changeRegistry.take(limit).toList();
  }

  /// Evaluates an enterprise project against recent standard change events to detect potential compliance risk.
  static List<ProjectImpactAssessment> evaluateProjectImpact(ProcurementProject project) {
    final assessments = <ProjectImpactAssessment>[];

    for (final standardCode in project.referencedStandardCodes) {
      final normalizedCode = standardCode.toUpperCase().replaceAll(' ', '');
      for (final event in _changeRegistry) {
        final eventCode = event.standardCode.toUpperCase().replaceAll(' ', '');
        if (eventCode.contains(normalizedCode) || normalizedCode.contains(eventCode.substring(0, 7))) {
          assessments.add(
            ProjectImpactAssessment(
              projectId: project.id,
              projectTitle: project.title,
              changeEvent: event,
              impactSeverity: event.changeType == ChangeType.regulationUpdated ||
                      event.changeType == ChangeType.superseded
                  ? 'CRITICAL'
                  : 'HIGH',
              impactAnalysis:
                  'Project "${project.title}" references standard "${event.standardCode}" which underwent "${event.changeType.label}". Effective from ${event.effectiveDate.year}-${event.effectiveDate.month.toString().padLeft(2, '0')}. Summary: ${event.summary}',
              recommendedActions: [
                'Review tender clause specifications corresponding to: ${event.affectedClauses.join(", ")}.',
                'Issue technical corrigendum updating tender document to reflect the latest active edition/amendment.',
                'Verify bidder test certificates conform to new edition before contract award.',
              ],
              evaluatedAt: DateTime.now(),
            ),
          );
        }
      }
    }

    return assessments;
  }
}

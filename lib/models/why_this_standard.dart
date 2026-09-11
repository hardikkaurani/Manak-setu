import 'knowledge_state.dart';

/// Represents an alternative candidate standard evaluated and compared against the selected standard.
class AlternativeConsidered {
  final String standardCode;
  final String title;
  final String whyConsidered;
  final String whyRejected;
  final KnowledgeState status;

  const AlternativeConsidered({
    required this.standardCode,
    required this.title,
    required this.whyConsidered,
    required this.whyRejected,
    required this.status,
  });
}

/// Represents the deterministic technical rationale explaining why a specific standard was selected
/// and why alternatives were rejected or deprioritized.
class WhyThisStandard {
  final String standardCode;
  final String title;
  final Map<String, String> matchedRequirements;
  final String verificationSummary;
  final KnowledgeState knowledgeState;
  final bool isEvidenceAvailable;
  final String? evidenceSummary;
  final List<AlternativeConsidered> alternativesConsidered;
  final bool isFallback;

  const WhyThisStandard({
    required this.standardCode,
    required this.title,
    required this.matchedRequirements,
    required this.verificationSummary,
    required this.knowledgeState,
    required this.isEvidenceAvailable,
    this.evidenceSummary,
    required this.alternativesConsidered,
    this.isFallback = false,
  });

  /// Fallback when insufficient evidence exists for an unindexed standard.
  factory WhyThisStandard.insufficientEvidence(String standardCode) {
    return WhyThisStandard(
      standardCode: standardCode,
      title: 'Technical Rationale Unavailable',
      matchedRequirements: const {},
      verificationSummary:
          'Reason unavailable — insufficient evidence in current index. Mandatory manual verification required by procurement authority.',
      knowledgeState: KnowledgeState.unknown,
      isEvidenceAvailable: false,
      alternativesConsidered: const [],
      isFallback: true,
    );
  }
}

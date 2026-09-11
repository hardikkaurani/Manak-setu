import 'knowledge_state.dart';

/// Represents a gazetted amendment record for an Indian Standard.
class AmendmentRecord {
  final String amendmentNumber;
  final String dateOrYear;
  final String gazetteReference;
  final String scopeSummary;
  final KnowledgeState state;

  const AmendmentRecord({
    required this.amendmentNumber,
    required this.dateOrYear,
    required this.gazetteReference,
    required this.scopeSummary,
    this.state = KnowledgeState.verified,
  });
}

/// Represents the edition and amendment history for an Indian Standard.
/// Honestly conveys whether detailed clause-level text diffs exist or if only
/// verified lifecycle metadata and gazette notices are available.
class AmendmentDiff {
  final String standardCode;
  final String title;
  final String currentEdition;
  final String? previousEdition;
  final String? supersessionTransition;
  final List<AmendmentRecord> amendments;
  final bool hasClauseDiffData;
  final String diffNotice;

  const AmendmentDiff({
    required this.standardCode,
    required this.title,
    required this.currentEdition,
    this.previousEdition,
    this.supersessionTransition,
    this.amendments = const [],
    this.hasClauseDiffData = false,
    this.diffNotice =
        'Detailed clause-level text diff unavailable in current local dataset. Gazette metadata and lifecycle relations are verified.',
  });
}

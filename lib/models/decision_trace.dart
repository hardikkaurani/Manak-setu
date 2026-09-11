import 'evidence.dart';
import 'knowledge_state.dart';
import 'standard.dart';

/// Represents a single requirement evaluated within the Decision Trace.
class TraceRequirement {
  final String parameter;
  final String specifiedValue;
  final KnowledgeState state;
  final String note;

  const TraceRequirement({
    required this.parameter,
    required this.specifiedValue,
    required this.state,
    required this.note,
  });
}

/// Represents a candidate standard evaluated during the retrieval stage.
class TraceCandidate {
  final String standardCode;
  final String title;
  final int rank;
  final double retrievalScore; // e.g. 0.94
  final bool isSelected;
  final String considerationReason;
  final String? rejectionReason;
  final KnowledgeState state;

  const TraceCandidate({
    required this.standardCode,
    required this.title,
    required this.rank,
    required this.retrievalScore,
    required this.isSelected,
    required this.considerationReason,
    this.rejectionReason,
    required this.state,
  });
}

/// Represents the comprehensive 8-stage engineering audit trail for a tender recommendation.
/// Never exposes private chain-of-thought; presents only observable system decisions,
/// retrieval signals, rule checks, evidence references, verification results, and human sign-off state.
class DecisionTrace {
  final String tenderId;
  final String tenderTitle;
  final String department;
  final String inputClause;
  final List<TraceRequirement> extractedRequirements;
  final List<TraceCandidate> retrievedCandidates;
  final String selectionReason;
  final List<String> exclusionReasons;
  final Standard? selectedStandard;
  final String lifecycleState;
  final Evidence? evidence;
  final KnowledgeState verificationState;
  final String finalRecommendation;
  final String humanApprovalState; // 'PENDING REVIEW', 'ACCEPTED', 'FLAGGED'

  const DecisionTrace({
    required this.tenderId,
    required this.tenderTitle,
    required this.department,
    required this.inputClause,
    required this.extractedRequirements,
    required this.retrievedCandidates,
    required this.selectionReason,
    required this.exclusionReasons,
    this.selectedStandard,
    required this.lifecycleState,
    this.evidence,
    required this.verificationState,
    required this.finalRecommendation,
    required this.humanApprovalState,
  });
}

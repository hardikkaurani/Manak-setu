/// The derived overall decision state for a recommendation or finding.
enum OverallDecisionState {
  verified('VERIFIED', 'Empirically proven by Tier 1/2 authoritative evidence and strict rule validation'),
  inferred('INFERRED', 'Technically matched with high probability; pending explicit statutory citation confirmation'),
  unknown('UNKNOWN', 'Insufficient technical data or missing source evidence in catalog'),
  conflicting('CONFLICTING', 'Contradictory lifecycle status, competing parameters, or divergent regional standards'),
  outOfCoverage('OUT_OF_COVERAGE', 'Issuing organization or domain is outside the currently indexed catalog');

  final String label;
  final String description;
  const OverallDecisionState(this.label, this.description);

  bool get isReliableForProcurement => this == OverallDecisionState.verified;
}

/// Decomposed multi-factor confidence model.
/// Replaces opaque single-number "AI confidence" with four orthogonal, explainable dimensions.
class MultiFactorConfidence {
  final double retrievalConfidence; // How well the query retrieved this standard (0.0 - 1.0)
  final double technicalMatchConfidence; // Degree of parameter and product correspondence (0.0 - 1.0)
  final double lifecycleConfidence; // Certainty of current valid status without unresolved supersession (0.0 - 1.0)
  final double evidenceConfidence; // Source tier weight and exact clause verification (0.0 - 1.0)
  final OverallDecisionState overallDecisionState;
  final List<String> confidenceFactors;
  final List<String> uncertaintyNotes;

  const MultiFactorConfidence({
    required this.retrievalConfidence,
    required this.technicalMatchConfidence,
    required this.lifecycleConfidence,
    required this.evidenceConfidence,
    required this.overallDecisionState,
    this.confidenceFactors = const [],
    this.uncertaintyNotes = const [],
  });

  /// Computes a weighted composite score.
  /// Weights: Technical match (35%), Evidence (30%), Lifecycle (20%), Retrieval (15%).
  double get compositeScore {
    final score = (technicalMatchConfidence * 0.35) +
        (evidenceConfidence * 0.30) +
        (lifecycleConfidence * 0.20) +
        (retrievalConfidence * 0.15);
    return double.parse(score.clamp(0.0, 1.0).toStringAsFixed(3));
  }

  /// Factory evaluator computing orthogonal confidence factors and deriving overall decision state.
  factory MultiFactorConfidence.evaluate({
    required double retrievalScore,
    required double technicalScore,
    required double lifecycleScore,
    required double evidenceScore,
    bool isOutOfCoverage = false,
    bool hasConflict = false,
    List<String>? factors,
    List<String>? uncertainties,
  }) {
    final ret = retrievalScore.clamp(0.0, 1.0);
    final tech = technicalScore.clamp(0.0, 1.0);
    final life = lifecycleScore.clamp(0.0, 1.0);
    final evid = evidenceScore.clamp(0.0, 1.0);

    final resolvedFactors = factors ?? [];
    final resolvedUncertainties = uncertainties ?? [];

    OverallDecisionState state;
    if (isOutOfCoverage) {
      state = OverallDecisionState.outOfCoverage;
    } else if (hasConflict || (life < 0.4 && tech > 0.7)) {
      state = OverallDecisionState.conflicting;
    } else if (evid >= 0.8 && tech >= 0.75 && life >= 0.8) {
      state = OverallDecisionState.verified;
    } else if (tech >= 0.6 && evid >= 0.5) {
      state = OverallDecisionState.inferred;
    } else {
      state = OverallDecisionState.unknown;
    }

    return MultiFactorConfidence(
      retrievalConfidence: ret,
      technicalMatchConfidence: tech,
      lifecycleConfidence: life,
      evidenceConfidence: evid,
      overallDecisionState: state,
      confidenceFactors: resolvedFactors,
      uncertaintyNotes: resolvedUncertainties,
    );
  }

  Map<String, dynamic> toJson() => {
        'retrieval_confidence': retrievalConfidence,
        'technical_match_confidence': technicalMatchConfidence,
        'lifecycle_confidence': lifecycleConfidence,
        'evidence_confidence': evidenceConfidence,
        'composite_score': compositeScore,
        'overall_decision_state': overallDecisionState.label,
        'confidence_factors': confidenceFactors,
        'uncertainty_notes': uncertaintyNotes,
      };
}

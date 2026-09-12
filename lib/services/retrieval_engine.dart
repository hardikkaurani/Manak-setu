import '../models/standard.dart';
import '../models/lifecycle_status.dart';
import '../models/international_equivalence.dart';

/// Structured, explainable rationale for every recommended standard.
///
/// In strict accordance with the core principle:
/// "AI finds → Rules verify → Sources prove → Human approves"
class RecommendationExplanation {
  final String standardCode;
  final String jurisdiction;
  final String issuingOrganization;
  final String versionOrEdition;
  final StandardLifecycleStatus lifecycleStatus;
  final List<String> whySelected;
  final String source;
  final String? clauseOrSection;
  final List<String> relationshipPath;
  final double confidence;
  final String verificationState;
  final DateTime retrievalTimestamp;
  final Map<String, double> scoringBreakdown;
  final InternationalEquivalence? matchedEquivalence;
  final List<InternationalEquivalence> attachedEquivalences;

  const RecommendationExplanation({
    required this.standardCode,
    required this.jurisdiction,
    required this.issuingOrganization,
    required this.versionOrEdition,
    required this.lifecycleStatus,
    required this.whySelected,
    required this.source,
    this.clauseOrSection,
    this.relationshipPath = const [],
    required this.confidence,
    required this.verificationState,
    required this.retrievalTimestamp,
    this.scoringBreakdown = const {},
    this.matchedEquivalence,
    this.attachedEquivalences = const [],
  });

  /// Breakdown of constituent scoring factors for explainability.
  Map<String, double> get factorScores => scoringBreakdown;
}

/// A ranked recommendation candidate with structured score and explainable trace.
class StandardRecommendation {
  final Standard standard;
  final double score;
  final RecommendationExplanation explanation;

  const StandardRecommendation({
    required this.standard,
    required this.score,
    required this.explanation,
  });

  /// Explanation whySelected rationale strings.
  List<String> get whySelected => explanation.whySelected;

  /// Overall recommendation confidence score.
  double get confidenceScore => explanation.confidence;

  /// Expanded international equivalences attached to candidate.
  List<InternationalEquivalence> get equivalences =>
      explanation.attachedEquivalences.isNotEmpty
          ? explanation.attachedEquivalences
          : (explanation.matchedEquivalence != null
              ? [explanation.matchedEquivalence!]
              : const []);

  @override
  String toString() =>
      '${standard.code} (Score: ${(score * 100).toStringAsFixed(1)}%, Status: ${standard.status})';
}

/// Query specification for jurisdiction-aware standards discovery.
class RetrievalQuery {
  final String clauseText;
  final List<String> targetJurisdictions;
  final List<String> preferredFamilies;
  final String? productCategory;
  final bool demoteObsolete;
  final bool includeInternationalEquivalents;

  const RetrievalQuery({
    required this.clauseText,
    this.targetJurisdictions = const [],
    this.preferredFamilies = const [],
    this.productCategory,
    this.demoteObsolete = true,
    this.includeInternationalEquivalents = true,
  });

  /// Factory supporting rawText and jurisdictions aliases for query convenience.
  factory RetrievalQuery.from({
    required String rawText,
    List<String> jurisdictions = const [],
    List<String> families = const [],
    String? productCategory,
    bool demoteObsolete = true,
    bool includeEquivalences = true,
  }) {
    return RetrievalQuery(
      clauseText: rawText,
      targetJurisdictions: jurisdictions,
      preferredFamilies: families,
      productCategory: productCategory,
      demoteObsolete: demoteObsolete,
      includeInternationalEquivalents: includeEquivalences,
    );
  }
}

/// Production-grade hybrid retrieval and multi-factor re-ranking engine.
///
/// Combines lexical token matching, semantic domain alignment, lifecycle status scoring,
/// statutory regulatory weighting, and evidence validation into an explainable ranking.
class HybridRetrievalEngine {
  const HybridRetrievalEngine();

  // Re-ranking weights
  static const double weightLexical = 0.35;
  static const double weightDomain = 0.25;
  static const double weightStatus = 0.15;
  static const double weightRegulatory = 0.15;
  static const double weightEvidence = 0.10;

  /// Executes jurisdiction-aware hybrid retrieval against a candidate catalog.
  List<StandardRecommendation> retrieve({
    required RetrievalQuery query,
    required List<Standard> catalog,
    List<InternationalEquivalence> equivalences = const [],
  }) {
    final queryText = query.clauseText.toLowerCase().trim();
    if (queryText.isEmpty) return [];

    final queryTokens = _tokenize(queryText);
    final now = DateTime.now();

    final scoredCandidates = <StandardRecommendation>[];

    for (final standard in catalog) {
      // 1. Jurisdiction Filter (if explicitly requested)
      final inTargetJurisdiction = query.targetJurisdictions.isEmpty ||
          query.targetJurisdictions.any(
            (j) => j.toUpperCase() == standard.jurisdictionId.toUpperCase(),
          );

      // Check if standard has international equivalence to a target jurisdiction standard
      InternationalEquivalence? matchedEq;
      if (!inTargetJurisdiction && query.includeInternationalEquivalents) {
        matchedEq = _findEquivalence(standard.code, query.targetJurisdictions, equivalences);
        if (matchedEq == null) {
          continue; // Out of target jurisdiction and no equivalence
        }
      }

      // 2. Lexical Relevance Score (token overlap over code, title, scope)
      final lexicalScore = _computeLexicalScore(standard, queryTokens, queryText);

      // Skip candidates with insufficient lexical relevance unless directly mentioned by code
      final codePattern = RegExp(r'\b' + RegExp.escape(standard.code) + r'\b', caseSensitive: false);
      final familyPattern = RegExp(r'\b' + RegExp.escape(standard.standardFamily) + r'\b', caseSensitive: false);
      final codeMentioned = codePattern.hasMatch(queryText) || familyPattern.hasMatch(queryText);

      if (lexicalScore < 0.1 && !codeMentioned && matchedEq == null) {
        continue;
      }

      // 3. Domain & Product Applicability Score
      final domainScore = _computeDomainScore(standard, queryTokens, query.productCategory);

      // 4. Lifecycle & Freshness Score
      final statusScore = _computeStatusScore(standard.lifecycleStatus, query.demoteObsolete);

      // 5. Regulatory & Certification Weight
      final regulatoryScore = standard.isQcoMandatory || standard.regulatoryLinks.isNotEmpty ? 1.0 : 0.5;

      // 6. Evidence Quality Score
      final evidenceScore = standard.evidence != null ? 1.0 : 0.6;

      // Multi-Factor Composite Score
      double compositeScore = (weightLexical * lexicalScore) +
          (weightDomain * domainScore) +
          (weightStatus * statusScore) +
          (weightRegulatory * regulatoryScore) +
          (weightEvidence * evidenceScore);

      // Boost directly cited standards
      if (codeMentioned) {
        compositeScore = (compositeScore + 0.35).clamp(0.0, 1.0);
      }

      // Jurisdiction relevance weighting
      if (inTargetJurisdiction && query.targetJurisdictions.isNotEmpty) {
        compositeScore = (compositeScore * 1.3).clamp(0.0, 1.0);
      } else if (!inTargetJurisdiction && matchedEq != null) {
        compositeScore = (compositeScore * 0.7 * matchedEq.confidence).clamp(0.0, 1.0);
      }

      // Build structured explanation
      final whySelected = <String>[];
      if (codeMentioned) {
        whySelected.add('Direct code citation identified in specification text.');
      }
      if (lexicalScore > 0.4) {
        whySelected.add('High keyword relevance with technical parameters.');
      }
      if (domainScore > 0.3) {
        whySelected.add('Direct technical domain match with ${standard.division}.');
      }
      if (inTargetJurisdiction && query.targetJurisdictions.isNotEmpty) {
        whySelected.add('Target jurisdiction match (${standard.jurisdictionId}).');
      }
      if (standard.isQcoMandatory) {
        whySelected.add('Subject to mandatory Quality Control Order (QCO) certification.');
      }
      if (standard.lifecycleStatus.isObsolete) {
        whySelected.add(
          'WARNING: Standard status is ${standard.status}. ${standard.replacementCode != null ? "Superseded by ${standard.replacementCode}." : "Withdrawn by issuing body."}',
        );
      }
      if (matchedEq != null) {
        whySelected.add(
          'Harmonized international equivalent (${matchedEq.degree.displayName}) to target jurisdiction.',
        );
      }

      final scoringBreakdown = {
        'lexical': lexicalScore,
        'domain': domainScore,
        'technicalDomain': domainScore,
        'jurisdiction': inTargetJurisdiction ? 1.0 : 0.5,
        'lifecycle': statusScore,
        'regulatory': regulatoryScore,
        'evidence': evidenceScore,
      };

      final attachedEqs = _findEquivalencesForStandard(standard.code, equivalences);

      final explanation = RecommendationExplanation(
        standardCode: standard.code,
        jurisdiction: standard.country,
        issuingOrganization: standard.organizationId.toUpperCase(),
        versionOrEdition: standard.edition ?? (standard.year?.toString() ?? 'Latest'),
        lifecycleStatus: standard.lifecycleStatus,
        whySelected: whySelected.isNotEmpty
            ? whySelected
            : ['Statutory category match with specification domain.'],
        source: standard.provenance,
        clauseOrSection: standard.scope != null ? 'Scope / Cl. 1' : null,
        relationshipPath: [standard.standardFamily, standard.code],
        confidence: double.parse(compositeScore.toStringAsFixed(3)),
        verificationState: standard.verificationStatus,
        retrievalTimestamp: now,
        scoringBreakdown: scoringBreakdown,
        matchedEquivalence: matchedEq,
        attachedEquivalences: attachedEqs,
      );

      scoredCandidates.add(
        StandardRecommendation(
          standard: standard,
          score: compositeScore,
          explanation: explanation,
        ),
      );
    }

    // Sort descending by score
    scoredCandidates.sort((a, b) => b.score.compareTo(a.score));

    return scoredCandidates;
  }

  static const Set<String> _procurementStopwords = {
    'the', 'and', 'for', 'with', 'under', 'from', 'this', 'that', 'which',
    'shall', 'must', 'will', 'are', 'per', 'all', 'any', 'can', 'not',
    'specification', 'specifications', 'standard', 'standards',
    'procurement', 'requirements', 'requirement', 'tender', 'clause',
    'section', 'supply', 'conforming', 'strictly', 'array',
  };

  static Set<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2 && !_procurementStopwords.contains(t))
        .toSet();
  }

  static double _computeLexicalScore(Standard std, Set<String> tokens, String fullQuery) {
    if (tokens.isEmpty) return 0.0;

    final targetText = '${std.code} ${std.title} ${std.scope ?? ""} ${std.advisory ?? ""}'.toLowerCase();

    int matchedCount = 0;
    for (final token in tokens) {
      if (targetText.contains(token)) {
        matchedCount++;
      }
    }

    double ratio = matchedCount / tokens.length;
    // Exact phrase match bonus
    if (targetText.contains(fullQuery)) {
      ratio = (ratio + 0.3).clamp(0.0, 1.0);
    }

    return ratio.clamp(0.0, 1.0);
  }

  static double _computeDomainScore(Standard std, Set<String> tokens, String? category) {
    final domainTokens = _tokenize(
      '${std.division} ${std.productCategories.join(" ")} ${std.technicalDomains.join(" ")}',
    );
    if (domainTokens.isEmpty) return 0.5;

    int overlap = 0;
    for (final t in tokens) {
      if (domainTokens.contains(t)) overlap++;
    }

    if (category != null && category.isNotEmpty) {
      final catLower = category.toLowerCase();
      if (std.division.toLowerCase().contains(catLower) ||
          std.title.toLowerCase().contains(catLower) ||
          (std.scope?.toLowerCase().contains(catLower) ?? false) ||
          std.productCategories.any((c) => c.toLowerCase().contains(catLower))) {
        return 1.0;
      }
    }

    return (overlap / domainTokens.length).clamp(0.2, 1.0);
  }

  static List<InternationalEquivalence> _findEquivalencesForStandard(
    String code,
    List<InternationalEquivalence> allEquivalences,
  ) {
    final clean = code.trim().toLowerCase();
    final base = clean.split(RegExp(r'[:\-]')).first.trim();
    return allEquivalences.where((eq) {
      final src = eq.sourceStandardCode.toLowerCase();
      final tgt = eq.targetStandardCode.toLowerCase();
      return src.contains(clean) ||
          tgt.contains(clean) ||
          clean.contains(src) ||
          clean.contains(tgt) ||
          src.contains(base) ||
          tgt.contains(base);
    }).toList();
  }

  static double _computeStatusScore(StandardLifecycleStatus status, bool demoteObsolete) {
    switch (status) {
      case StandardLifecycleStatus.current:
        return 1.0;
      case StandardLifecycleStatus.amended:
        return 0.95;
      case StandardLifecycleStatus.draft:
        return 0.6;
      case StandardLifecycleStatus.unverified:
      case StandardLifecycleStatus.unknown:
        return 0.5;
      case StandardLifecycleStatus.conflicting:
        return 0.4;
      case StandardLifecycleStatus.superseded:
        return demoteObsolete ? 0.3 : 0.8;
      case StandardLifecycleStatus.withdrawn:
        return demoteObsolete ? 0.15 : 0.5;
    }
  }

  static InternationalEquivalence? _findEquivalence(
    String code,
    List<String> targetJurisdictions,
    List<InternationalEquivalence> equivalences,
  ) {
    final clean = code.trim().toLowerCase();
    for (final eq in equivalences) {
      final isSource = eq.sourceStandardCode.toLowerCase().contains(clean);
      final isTarget = eq.targetStandardCode.toLowerCase().contains(clean);

      if (isSource &&
          targetJurisdictions.any(
            (j) => j.toUpperCase() == eq.targetJurisdictionId.toUpperCase(),
          )) {
        return eq;
      }
      if (isTarget &&
          targetJurisdictions.any(
            (j) => j.toUpperCase() == eq.sourceJurisdictionId.toUpperCase(),
          )) {
        return eq;
      }
    }
    return null;
  }
}

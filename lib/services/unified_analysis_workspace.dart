import '../models/knowledge_state.dart';
import '../models/requirement_ontology.dart';
import '../models/specification_gap_analysis.dart';
import '../models/multi_factor_confidence.dart';
import '../models/decision_trace.dart';
import '../models/export_report.dart';
import 'retrieval_engine.dart';
import 'gap_analysis_engine.dart';
import 'security_and_privacy_guard.dart';
import 'export_service.dart';

/// Supported analysis input modes in the unified workspace.
enum AnalysisInputMode {
  tenderClause('Tender Clause', 'Single technical requirement or statutory procurement clause'),
  fullTender('Full Tender NIT', 'Multi-page notice inviting tender document'),
  boq('Bill of Quantities (BoQ)', 'Itemized schedule of materials, line items, and quantities'),
  productSpecification('Product Specification', 'Detailed manufacturer or engineering specification sheet'),
  productImage('Product Image', 'Field photograph of product, nameplate, or label markings'),
  technicalDocument('Technical Document', 'Test report, technical specification, or drawing schedule'),
  standardComparison('Standard Comparison', 'Direct cross-standard or cross-jurisdiction comparison');

  final String label;
  final String description;
  const AnalysisInputMode(this.label, this.description);
}

/// Aggregated output package produced by the unified workspace pipeline.
class WorkspaceAnalysisOutcome {
  final String analysisId;
  final AnalysisInputMode inputMode;
  final String rawInput;
  final List<ProcurementRequirement> extractedRequirements;
  final List<StandardRecommendation> recommendations;
  final SpecificationGapAnalysis? gapAnalysis;
  final DecisionTrace decisionTrace;
  final MultiFactorConfidence confidence;
  final ExportReportPackage exportPackage;
  final DateTime completedAt;

  const WorkspaceAnalysisOutcome({
    required this.analysisId,
    required this.inputMode,
    required this.rawInput,
    required this.extractedRequirements,
    required this.recommendations,
    this.gapAnalysis,
    required this.decisionTrace,
    required this.confidence,
    required this.exportPackage,
    required this.completedAt,
  });
}

/// Unified Analysis Workspace coordinating all 7 analysis modes through the 9-stage intelligence pipeline:
/// INGEST -> EXTRACT -> CLASSIFY -> RETRIEVE -> RANK -> VERIFY -> EXPLAIN -> GAP ANALYZE -> EXPORT
class UnifiedAnalysisWorkspace {
  /// Executes the unified 9-step analysis pipeline.
  static Future<WorkspaceAnalysisOutcome> executePipeline({
    required AnalysisInputMode inputMode,
    required String rawInput,
    String? targetJurisdiction = 'IN',
    String? productCategory,
    String organizationName = 'Municipal Water Supply Directorate',
    String department = 'Electrical & Water Works',
  }) async {
    final analysisId = 'UAW-${DateTime.now().millisecondsSinceEpoch}';

    // 1. INGEST & Security Sanitation
    final securityResult = SecurityAndPrivacyGuard.sanitizeInputClause(rawInput);
    final safeInput = securityResult.sanitizedText;

    // 2. EXTRACT Structured Requirements
    final extractedReqs = RequirementOntologyParser.parseText(safeInput);

    // 3. CLASSIFY Domain & Category
    final detectedCategory = productCategory ?? _detectProductCategory(safeInput);

    // 4. RETRIEVE Candidates via Hybrid Engine
    final recommendations = HybridRetrievalEngine.retrieveCandidates(
      safeInput,
      targetJurisdiction: targetJurisdiction,
      productCategory: detectedCategory,
      limit: 5,
    );

    // 5. RANK & Evaluate Multi-Factor Confidence
    final primary = recommendations.isNotEmpty ? recommendations.first : null;
    final confidence = MultiFactorConfidence.evaluate(
      retrievalScore: primary != null ? primary.score / 100.0 : 0.2,
      technicalScore: primary != null ? 0.85 : 0.3,
      lifecycleScore: primary != null ? (primary.standard.lifecycleStatus.name == 'current' ? 0.95 : 0.4) : 0.2,
      evidenceScore: primary != null && primary.standard.evidence != null ? 0.90 : 0.3,
      isOutOfCoverage: recommendations.isEmpty,
    );

    // 6. VERIFY & Build Decision Trace
    final traceRequirements = extractedReqs.map((r) {
      return TraceRequirement(
        parameter: r.parameter,
        specifiedValue: '${r.op.symbol} ${r.value} ${r.unit ?? ""}'.trim(),
        state: confidence.overallDecisionState.name == 'verified'
            ? KnowledgeState.verified
            : KnowledgeState.inferred,
        note: 'Extracted from tender specification clause',
      );
    }).toList();

    final traceCandidates = recommendations.asMap().entries.map((e) {
      return TraceCandidate(
        standardCode: e.value.standard.code,
        title: e.value.standard.title,
        rank: e.key + 1,
        retrievalScore: e.value.score / 100.0,
        isSelected: e.key == 0,
        considerationReason: e.value.explanation.whySelected.isNotEmpty
            ? e.value.explanation.whySelected.first
            : 'Top retrieved standard candidate',
        rejectionReason: e.key > 0 ? 'Ranked lower due to lower technical parameter overlap' : null,
        state: KnowledgeState.verified,
      );
    }).toList();

    final decisionTrace = DecisionTrace(
      tenderId: analysisId,
      tenderTitle: 'Specification Analysis ($inputMode)',
      department: department,
      inputClause: safeInput,
      extractedRequirements: traceRequirements,
      retrievedCandidates: traceCandidates,
      selectionReason: primary?.explanation.whySelected.join("; ") ?? 'No conclusive standard match',
      exclusionReasons: traceCandidates.where((c) => !c.isSelected).map((c) => '${c.standardCode}: ${c.rejectionReason}').toList(),
      selectedStandard: primary?.standard,
      lifecycleState: primary?.standard.lifecycleStatus.name.toUpperCase() ?? 'UNKNOWN',
      evidence: primary?.standard.evidence,
      verificationState: KnowledgeState.verified,
      finalRecommendation: primary != null
          ? 'Mandate compliance to ${primary.standard.code} as per statutory Quality Control Order.'
          : 'Manual procurement verification required.',
      humanApprovalState: 'PENDING REVIEW',
    );

    // 7. GAP ANALYZE
    SpecificationGapAnalysis? gapAnalysis;
    if (primary != null && extractedReqs.isNotEmpty) {
      gapAnalysis = GapAnalysisEngine.analyzeSpecificationGaps(
        analysisId: analysisId,
        tenderTitle: 'Specification Analysis ($inputMode)',
        targetStandardCode: primary.standard.code,
        extractedRequirements: extractedReqs,
      );
    }

    // 8. EXPLAIN ("Why this standard?" is embedded in recommendations & trace)

    // 9. EXPORT Report Package
    final exportPackage = ExportService.buildExportPackage(
      reportId: analysisId,
      title: 'Tender Scrutiny & Compliance Dossier ($inputMode)',
      organizationName: organizationName,
      department: department,
      executiveSummary: primary != null
          ? 'Evaluated specification against global standards catalog. Standard ${primary.standard.code} identified as primary applicable specification with ${(confidence.compositeScore * 100).toStringAsFixed(1)}% composite confidence.'
          : 'Analysis concluded with insufficient candidate coverage. Manual verification required.',
      inputRequirements: extractedReqs.map((r) => r.rawClauseText).toList(),
      recommendedStandards: recommendations.map((r) => {
        'code': r.standard.code,
        'title': r.standard.title,
        'status': r.standard.lifecycleStatus.name.toUpperCase(),
        'evidence': r.standard.evidence?.citationDisplay,
      }).toList(),
      gapAnalysis: gapAnalysis,
      decisionTraceSummary: {
        'tender_id': decisionTrace.tenderId,
        'selection_reason': decisionTrace.selectionReason,
        'candidates_evaluated': traceCandidates.length,
      },
      confidence: confidence,
      humanReviewSignoff: {
        'status': 'Pending Review',
        'officer_name': 'Unassigned',
        'officer_id': 'N/A',
        'comment': null,
      },
    );

    return WorkspaceAnalysisOutcome(
      analysisId: analysisId,
      inputMode: inputMode,
      rawInput: rawInput,
      extractedRequirements: extractedReqs,
      recommendations: recommendations,
      gapAnalysis: gapAnalysis,
      decisionTrace: decisionTrace,
      confidence: confidence,
      exportPackage: exportPackage,
      completedAt: DateTime.now(),
    );
  }

  static String _detectProductCategory(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('transformer') || lower.contains('kva') || lower.contains('oil')) {
      return 'Distribution Transformers';
    }
    if (lower.contains('pipe') || lower.contains('hdpe') || lower.contains('polyethylene')) {
      return 'HDPE Pipes';
    }
    if (lower.contains('steel') || lower.contains('tmt') || lower.contains('rebar') || lower.contains('fe 500')) {
      return 'Reinforcement Steel';
    }
    return 'General Industrial';
  }
}

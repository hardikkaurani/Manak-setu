import '../models/standard.dart';
import '../models/evidence.dart';
import '../models/specification_gap_analysis.dart';
import '../models/cross_jurisdiction_matrix.dart';
import '../models/requirement_ontology.dart';
import 'retrieval_engine.dart';
import 'providers/concrete_providers.dart';
import 'gap_analysis_engine.dart';
import 'cross_jurisdiction_engine.dart';
import 'security_and_privacy_guard.dart';

/// Clean programmatic SDK Client for ManakSetu Standards Intelligence Platform.
class ManakSetuClient {
  final String apiKey;
  final String? tenantId;
  final String baseUrl;

  ManakSetuClient({
    this.apiKey = 'public-demo-key',
    this.tenantId,
    this.baseUrl = 'https://api.manaksetu.gov.in/api/v1',
  });

  /// Programmatic analysis of a procurement specification clause or tender snippet.
  Future<List<StandardRecommendation>> analyze(
    String specificationClause, {
    String jurisdiction = 'IN',
    String? productCategory,
  }) async {
    // 1. Hostile input sanitization
    final securityResult = SecurityAndPrivacyGuard.sanitizeInputClause(specificationClause);
    final safeText = securityResult.sanitizedText;

    // 2. Hybrid retrieval & multi-factor technical re-ranking
    final candidates = HybridRetrievalEngine.retrieveCandidates(
      safeText,
      targetJurisdiction: jurisdiction,
      productCategory: productCategory,
      limit: 5,
    );

    return candidates;
  }

  /// Searches global standards catalog across jurisdictions and organizations.
  Future<List<Standard>> searchStandards(
    String query, {
    String? jurisdiction,
    String? organizationId,
    int limit = 10,
  }) async {
    final filters = <String, dynamic>{'limit': limit};
    if (jurisdiction != null) {
      filters['jurisdiction'] = jurisdiction;
    }
    final provider = StandardsProviderRegistry.getProvider(organizationId ?? 'BIS');
    if (provider != null) {
      return provider.search(query, filters: filters);
    }
    final all = StandardsProviderRegistry.allRegisteredProviders;
    final results = <Standard>[];
    for (final p in all) {
      final res = await p.search(query, filters: filters);
      results.addAll(res);
      if (results.length >= limit) break;
    }
    return results.take(limit).toList();
  }

  /// Generates a cross-jurisdiction comparison matrix for a product.
  Future<CrossJurisdictionMatrix> compareStandards(String productId) async {
    return CrossJurisdictionEngine.buildComparisonMatrix(productId: productId);
  }

  /// Retrieves verified evidence for a standard and clause.
  Future<Evidence> getEvidence(String standardCode, {String? clause}) async {
    final provider = StandardsProviderRegistry.getProviderForStandard(standardCode);
    if (provider != null) {
      final ev = await provider.getEvidence(standardCode, clause: clause);
      if (ev != null) return ev;
    }
    return Evidence.unavailable(standardCode: standardCode, clause: clause);
  }

  /// Executes specification gap analysis comparing requirements against a standard.
  Future<SpecificationGapAnalysis> gapAnalysis({
    required String targetStandardCode,
    required String tenderTitle,
    required List<ProcurementRequirement> requirements,
  }) async {
    return GapAnalysisEngine.analyzeSpecificationGaps(
      analysisId: 'sdk-${DateTime.now().millisecondsSinceEpoch}',
      tenderTitle: tenderTitle,
      targetStandardCode: targetStandardCode,
      extractedRequirements: requirements,
    );
  }

  /// Conceptual CLI dispatcher executing commands equivalent to `manaksetu <cmd>`.
  Future<Map<String, dynamic>> executeCliCommand(List<String> args) async {
    if (args.isEmpty) {
      return {
        'status': 'error',
        'message': 'Usage: manaksetu <analyze|search|compare|export> [options]',
      };
    }

    final command = args[0].toLowerCase();
    switch (command) {
      case 'analyze':
        final query = args.length > 1 ? args.sublist(1).join(' ') : 'Distribution Transformers';
        final results = await analyze(query);
        return {
          'status': 'success',
          'command': 'analyze',
          'recommendations': results.map((r) => r.standard.code).toList(),
        };

      case 'search':
        final query = args.length > 1 ? args.sublist(1).join(' ') : 'pipe';
        final results = await searchStandards(query);
        return {
          'status': 'success',
          'command': 'search',
          'count': results.length,
          'standards': results.map((s) => '${s.code}: ${s.title}').toList(),
        };

      case 'compare':
        final product = args.length > 1 ? args[1] : 'transformer';
        final matrix = await compareStandards(product);
        return {
          'status': 'success',
          'command': 'compare',
          'product': matrix.productTitle,
          'jurisdictions': matrix.comparedJurisdictions,
          'parameter_rows': matrix.rows.length,
        };

      default:
        return {
          'status': 'error',
          'message': 'Unknown command: $command',
        };
    }
  }
}

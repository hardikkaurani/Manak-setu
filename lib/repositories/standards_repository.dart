import '../data/demo_data.dart';
import '../models/standard.dart';
import '../models/standards_graph_node.dart';
import '../models/qco_order.dart';
import '../models/decision_trace.dart';
import '../models/why_this_standard.dart';
import '../models/amendment_diff.dart';
import '../models/jurisdiction.dart';
import '../models/standards_organization.dart';
import '../models/standard_family.dart';
import '../models/international_equivalence.dart';
import '../services/retrieval_engine.dart';

/// Repository interface and implementation for jurisdiction-agnostic Global Standards Intelligence.
abstract class StandardsRepository {
  // --- Legacy & Domestic Standards Methods ---
  List<Standard> getAllStandards();
  List<Standard> searchStandards({String query = '', String filter = 'ALL'});
  Standard? getStandardByCode(String code);
  List<StandardsGraphNode> getGraphNodesForPreset(String? presetId);
  StandardsGraphBundle getGraphBundleForPreset(String? presetId);
  StandardsGraphBundle getGraphBundleForStandard(String code);
  List<QcoOrder> getAllQcoOrders();
  List<QcoOrder> searchQcoOrders(String query);
  DecisionTrace getDecisionTraceForPreset(String? presetId);
  WhyThisStandard getWhyThisStandard(String standardCode);
  AmendmentDiff getAmendmentDiff(String standardCode);

  // --- Global Standards Intelligence Methods ---
  List<Jurisdiction> getAllJurisdictions();
  Jurisdiction? getJurisdictionById(String id);
  List<StandardsOrganization> getAllOrganizations();
  List<StandardFamily> getAllStandardFamilies();
  List<InternationalEquivalence> getAllEquivalences();
  List<InternationalEquivalence> getEquivalencesForStandard(String standardCode);
  List<Standard> getAllGlobalStandards();
  List<Standard> searchGlobalStandards({
    String query = '',
    List<String>? jurisdictions,
    List<String>? families,
    String filter = 'ALL',
  });
  List<StandardRecommendation> analyzeClauseGlobal(RetrievalQuery query);
}

class DemoStandardsRepository implements StandardsRepository {
  final HybridRetrievalEngine _retrievalEngine;

  const DemoStandardsRepository({
    HybridRetrievalEngine retrievalEngine = const HybridRetrievalEngine(),
  }) : _retrievalEngine = retrievalEngine;

  @override
  List<Standard> getAllStandards() => DemoData.allStandardsCatalog;

  @override
  List<Standard> searchStandards({String query = '', String filter = 'ALL'}) {
    final cleanQuery = query.trim().toLowerCase();
    return DemoData.allStandardsCatalog.where((std) {
      // Filter match
      if (filter == 'CURRENT' && std.status != 'CURRENT') return false;
      if (filter == 'OBSOLETE' && !std.isObsolete) return false;
      if (filter == 'MANDATORY QCO' && !std.isQcoMandatory) return false;
      if (filter == 'ELECTROTECHNICAL' && std.division != 'Electrotechnical') {
        return false;
      }
      if (filter == 'CIVIL' && std.division != 'Civil Engineering') {
        return false;
      }
      if (filter == 'MECHANICAL' && std.division != 'Mechanical') {
        return false;
      }

      // Query match
      if (cleanQuery.isEmpty) return true;
      final matchCode = std.code.toLowerCase().contains(cleanQuery);
      final matchTitle = std.title.toLowerCase().contains(cleanQuery);
      final matchScope =
          std.scope != null && std.scope!.toLowerCase().contains(cleanQuery);
      final matchQco =
          std.mandatoryQco != null &&
          std.mandatoryQco!.toLowerCase().contains(cleanQuery);
      final matchCommittee =
          std.committee != null &&
          std.committee!.toLowerCase().contains(cleanQuery);
      return matchCode || matchTitle || matchScope || matchQco || matchCommittee;
    }).toList();
  }

  @override
  Standard? getStandardByCode(String code) {
    try {
      final clean = code.trim().toLowerCase();
      return DemoData.allGlobalStandardsCatalog.firstWhere(
        (s) => s.code.toLowerCase() == clean || s.code.toLowerCase().contains(clean),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  List<StandardsGraphNode> getGraphNodesForPreset(String? presetId) {
    return DemoData.getGraphNodesForPreset(presetId);
  }

  @override
  StandardsGraphBundle getGraphBundleForPreset(String? presetId) {
    return DemoData.getGraphBundleForPreset(presetId);
  }

  @override
  StandardsGraphBundle getGraphBundleForStandard(String code) {
    return DemoData.getGraphBundleForStandard(code);
  }

  @override
  List<QcoOrder> getAllQcoOrders() => DemoData.allQcoOrdersCatalog;

  @override
  List<QcoOrder> searchQcoOrders(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return DemoData.allQcoOrdersCatalog;
    return DemoData.allQcoOrdersCatalog.where((q) {
      final matchName = q.orderName.toLowerCase().contains(clean);
      final matchGazette = q.gazetteNo.toLowerCase().contains(clean);
      final matchMinistry = q.ministry.toLowerCase().contains(clean);
      final matchStandards =
          q.standards.any((s) => s.toLowerCase().contains(clean));
      return matchName || matchGazette || matchMinistry || matchStandards;
    }).toList();
  }

  @override
  DecisionTrace getDecisionTraceForPreset(String? presetId) {
    return DemoData.getDecisionTraceForPreset(presetId);
  }

  @override
  WhyThisStandard getWhyThisStandard(String standardCode) {
    return DemoData.getWhyThisStandard(standardCode);
  }

  @override
  AmendmentDiff getAmendmentDiff(String standardCode) {
    return DemoData.getAmendmentDiff(standardCode);
  }

  // ==========================================
  // GLOBAL STANDARDS INTELLIGENCE IMPLEMENTATION
  // ==========================================

  @override
  List<Jurisdiction> getAllJurisdictions() => DemoData.jurisdictions;

  @override
  Jurisdiction? getJurisdictionById(String id) => DemoData.getJurisdiction(id);

  @override
  List<StandardsOrganization> getAllOrganizations() => DemoData.standardsOrganizations;

  @override
  List<StandardFamily> getAllStandardFamilies() => DemoData.standardFamilies;

  @override
  List<InternationalEquivalence> getAllEquivalences() => DemoData.internationalEquivalences;

  @override
  List<InternationalEquivalence> getEquivalencesForStandard(String standardCode) =>
      DemoData.getEquivalencesForStandard(standardCode);

  @override
  List<Standard> getAllGlobalStandards() => DemoData.allGlobalStandardsCatalog;

  @override
  List<Standard> searchGlobalStandards({
    String query = '',
    List<String>? jurisdictions,
    List<String>? families,
    String filter = 'ALL',
  }) {
    final cleanQuery = query.trim().toLowerCase();
    final targetJurisdictions = jurisdictions?.map((j) => j.toUpperCase()).toList();
    final targetFamilies = families?.map((f) => f.toUpperCase()).toList();

    return DemoData.allGlobalStandardsCatalog.where((std) {
      // Jurisdiction filter
      if (targetJurisdictions != null && targetJurisdictions.isNotEmpty) {
        if (!targetJurisdictions.contains(std.jurisdictionId.toUpperCase())) {
          return false;
        }
      }

      // Family filter
      if (targetFamilies != null && targetFamilies.isNotEmpty) {
        if (!targetFamilies.contains(std.standardFamily.toUpperCase())) {
          return false;
        }
      }

      // Status / Category filter
      if (filter == 'CURRENT' && std.status != 'CURRENT') return false;
      if (filter == 'OBSOLETE' && !std.isObsolete) return false;
      if (filter == 'MANDATORY QCO' && !std.isQcoMandatory) return false;
      if (filter == 'INTERNATIONAL' && !std.isInternational) return false;
      if (filter == 'ELECTROTECHNICAL' &&
          !std.division.toLowerCase().contains('electrotechnical') &&
          !std.technicalDomains.any((d) => d.toLowerCase().contains('electrotechnical'))) {
        return false;
      }
      if (filter == 'CIVIL' &&
          !std.division.toLowerCase().contains('civil') &&
          !std.technicalDomains.any((d) => d.toLowerCase().contains('civil'))) {
        return false;
      }
      if (filter == 'MECHANICAL' &&
          !std.division.toLowerCase().contains('mechanical') &&
          !std.technicalDomains.any((d) => d.toLowerCase().contains('mechanical'))) {
        return false;
      }

      // Query match
      if (cleanQuery.isEmpty) return true;
      final matchCode = std.code.toLowerCase().contains(cleanQuery);
      final matchTitle = std.title.toLowerCase().contains(cleanQuery);
      final matchScope =
          std.scope != null && std.scope!.toLowerCase().contains(cleanQuery);
      final matchCountry = std.country.toLowerCase().contains(cleanQuery);
      final matchOrg = std.organizationId.toLowerCase().contains(cleanQuery);
      final matchCategory = std.productCategories.any(
        (c) => c.toLowerCase().contains(cleanQuery),
      );

      return matchCode ||
          matchTitle ||
          matchScope ||
          matchCountry ||
          matchOrg ||
          matchCategory;
    }).toList();
  }

  @override
  List<StandardRecommendation> analyzeClauseGlobal(RetrievalQuery query) {
    return _retrievalEngine.retrieve(
      query: query,
      catalog: DemoData.allGlobalStandardsCatalog,
      equivalences: DemoData.internationalEquivalences,
    );
  }
}

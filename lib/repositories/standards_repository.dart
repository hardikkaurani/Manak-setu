import '../data/demo_data.dart';
import '../models/standard.dart';
import '../models/standards_graph_node.dart';
import '../models/qco_order.dart';
import '../models/decision_trace.dart';
import '../models/why_this_standard.dart';
import '../models/amendment_diff.dart';

/// Repository interface and local demo implementation for Indian Standards catalog & ontology.
abstract class StandardsRepository {
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
}

class DemoStandardsRepository implements StandardsRepository {
  const DemoStandardsRepository();

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
      return DemoData.allStandardsCatalog.firstWhere(
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
}


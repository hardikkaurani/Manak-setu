import '../data/demo_data.dart';
import '../models/tender_analysis.dart';
import '../models/boq_item.dart';

/// Repository interface and local demo data source for tender analysis.
/// Isolates UI widgets from direct mock data references, allowing seamless future API swapping.
abstract class TenderRepository {
  List<Map<String, String>> getPresets();
  TenderAnalysis getAnalysisForPreset(String? presetId);
  List<Map<String, String>> getStatutoryCheckpoints();
  BoQAuditResult getSampleBoQAudit();
  Future<TenderAnalysis> auditClause(String clause, {String? presetId});
}

class DemoTenderRepository implements TenderRepository {
  const DemoTenderRepository();

  @override
  List<Map<String, String>> getPresets() => DemoData.presets;

  @override
  TenderAnalysis getAnalysisForPreset(String? presetId) =>
      DemoData.getAnalysisForPreset(presetId);

  @override
  List<Map<String, String>> getStatutoryCheckpoints() =>
      DemoData.statutoryCheckpoints;

  @override
  BoQAuditResult getSampleBoQAudit() => DemoData.sampleBoQAuditResult;

  @override
  Future<TenderAnalysis> auditClause(String clause, {String? presetId}) async {
    // Deterministic simulation delay for institutional feel
    await Future.delayed(const Duration(milliseconds: 600));
    return DemoData.getAnalysisForPreset(presetId);
  }
}

import 'package:flutter/foundation.dart';

import '../data/demo_data.dart';
import '../models/specification.dart';
import '../models/review_action.dart';
import '../models/specification_parameter.dart';

/// Lightweight workspace state controller that coordinates state across
/// Home, Scrutiny, Specification Builder, and Work screens.
class WorkspaceController extends ChangeNotifier {
  static final WorkspaceController _instance = WorkspaceController._internal();
  factory WorkspaceController() => _instance;

  WorkspaceController._internal() {
    _initWorkspace();
  }

  String _activePresetId = 'transformer';
  String get activePresetId => _activePresetId;

  // Review Actions Map: findingId -> ReviewAction
  final Map<String, ReviewAction> _reviewActions = {};
  Map<String, ReviewAction> get reviewActions => Map.unmodifiable(_reviewActions);

  // Custom Purchaser-defined clauses added during authoring
  final List<SpecificationSection> _customPurchaserClauses = [];
  List<SpecificationSection> get customPurchaserClauses =>
      List.unmodifiable(_customPurchaserClauses);

  // Editable parameters per preset: presetId -> List<SpecificationParameter>
  final Map<String, List<SpecificationParameter>> _presetParameters = {};

  // Recent analyses workspace items
  final List<Map<String, dynamic>> _recentAnalyses = [
    {
      'id': 'NIT-DES-8842',
      'presetId': 'transformer',
      'title': 'Distribution Transformers 500 kVA',
      'department': 'Municipal Water Supply Directorate',
      'date': '11-Sep-2026, 09:45 IST',
      'score': 5,
      'status': 'NON_COMPLIANT',
      'criticalDefects': 2,
      'highRiskViolations': 3,
      'reviewState': 'Pending Review',
    },
    {
      'id': 'NIT-MWS-4984',
      'presetId': 'pipe',
      'title': 'HDPE Water Supply Pipes 110mm',
      'department': 'Municipal Water Supply Directorate',
      'date': '11-Sep-2026, 14:15 IST',
      'score': 8,
      'status': 'NON_COMPLIANT',
      'criticalDefects': 2,
      'highRiskViolations': 3,
      'reviewState': 'Flagged for Legal Review',
    },
    {
      'id': 'NIT-CPWD-1786',
      'presetId': 'steel',
      'title': 'TMT Reinforcement Steel Bars',
      'department': 'Central Public Works Department (CPWD)',
      'date': '10-Sep-2026, 16:30 IST',
      'score': 12,
      'status': 'NON_COMPLIANT',
      'criticalDefects': 2,
      'highRiskViolations': 3,
      'reviewState': 'Pending Review',
    },
    {
      'id': 'BOQ-MWS-2026',
      'presetId': 'transformer',
      'title': 'Municipal Pipeline & Substation BoQ Excel',
      'department': 'Water & Power Directorate',
      'date': '11-Sep-2026, 11:20 IST',
      'score': 40,
      'status': 'PARTIALLY_COMPLIANT',
      'criticalDefects': 2,
      'highRiskViolations': 1,
      'reviewState': 'Audit Complete',
    },
  ];
  List<Map<String, dynamic>> get recentAnalyses =>
      List.unmodifiable(_recentAnalyses);

  void _initWorkspace() {
    for (final preset in DemoData.presets) {
      final pid = preset['id']!;
      _presetParameters[pid] = DemoData.getParametersForPreset(pid);
      final initialActions = DemoData.getInitialReviewActions(pid);
      for (final a in initialActions) {
        _reviewActions[a.findingId] = a;
      }
    }
  }

  void setActivePreset(String presetId) {
    _activePresetId = DemoData.normalizePresetId(presetId);
    notifyListeners();
  }

  ReviewAction getReviewActionForFinding(String findingId) {
    return _reviewActions[findingId] ??
        ReviewAction(
          findingId: findingId,
          status: ReviewStatus.pending,
          officerName: DemoData.officerName,
          officerId: DemoData.officerId,
          formattedTimestamp: 'Pending Decision',
        );
  }

  void updateReviewAction(
    String findingId,
    ReviewStatus status, {
    String? comment,
  }) {
    final now = DateTime.now();
    final formattedTime =
        '${now.day.toString().padLeft(2, '0')}-Sep-${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} IST';

    _reviewActions[findingId] = ReviewAction(
      findingId: findingId,
      status: status,
      officerName: DemoData.officerName,
      officerId: DemoData.officerId,
      comment: comment,
      formattedTimestamp: formattedTime,
    );
    notifyListeners();
  }

  List<SpecificationParameter> getParametersForPreset(String? presetId) {
    final pid = DemoData.normalizePresetId(presetId);
    if (!_presetParameters.containsKey(pid)) {
      _presetParameters[pid] = DemoData.getParametersForPreset(pid);
    }
    return _presetParameters[pid]!;
  }

  void updateParameterValue(String? presetId, String paramId, String newValue) {
    final pid = DemoData.normalizePresetId(presetId);
    final currentList = getParametersForPreset(pid);
    final updatedList = currentList.map((p) {
      if (p.id == paramId) {
        return p.copyWith(currentValue: newValue);
      }
      return p;
    }).toList();

    _presetParameters[pid] =
        DemoData.evaluateParameterConflicts(pid, updatedList);
    notifyListeners();
  }

  void addPurchaserClause({
    required String title,
    required String content,
  }) {
    final nextNumber = '6.${_customPurchaserClauses.length + 1}';
    final clause = SpecificationSection(
      id: 'purchaser-${DateTime.now().millisecondsSinceEpoch}',
      sectionNumber: nextNumber,
      title: title,
      status: 'VERIFIED',
      content: content,
      isPurchaserDefined: true,
      recommendation:
          'Purchaser-defined statutory clause. Note: Not mandated by BIS standards.',
    );
    _customPurchaserClauses.add(clause);
    notifyListeners();
  }

  void removePurchaserClause(String id) {
    _customPurchaserClauses.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}

import 'evidence.dart';

/// Represents an Indian Standard (BIS) entry in the catalog and ontology.
class Standard {
  final String code;
  final String title;
  final String status; // 'CURRENT', 'OBSOLETE', 'SUPERSEDED', 'WITHDRAWN'
  final String? replacementCode;
  final String division;
  final String? committee;
  final int? year;
  final String? harmonized;
  final List<String> amendments;
  final String? mandatoryQco;
  final String? advisory;
  final Evidence? evidence;
  final String? scope;
  final String? edition;
  final List<String> relatedStandards;
  final List<String> rawMaterials;
  final List<String> testingMethods;
  final List<String> alliedStandards;
  final bool isQcoMandatory;

  const Standard({
    required this.code,
    required this.title,
    required this.status,
    this.replacementCode,
    this.division = 'General Engineering',
    this.committee,
    this.year,
    this.harmonized,
    this.amendments = const [],
    this.mandatoryQco,
    this.advisory,
    this.evidence,
    this.scope,
    this.edition,
    this.relatedStandards = const [],
    this.rawMaterials = const [],
    this.testingMethods = const [],
    this.alliedStandards = const [],
    this.isQcoMandatory = false,
  });

  bool get isObsolete =>
      status == 'OBSOLETE' || status == 'SUPERSEDED' || status == 'WITHDRAWN';
}

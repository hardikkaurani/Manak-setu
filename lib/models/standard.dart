import 'evidence.dart';

/// Represents an Indian Standard (BIS) entry in the demo.
class Standard {
  final String code;
  final String title;
  final String status; // 'CURRENT', 'OBSOLETE', 'SUPERSEDED'
  final String? replacementCode;
  final String division;
  final List<String> amendments;
  final String? mandatoryQco;
  final String? advisory;
  final Evidence? evidence;

  const Standard({
    required this.code,
    required this.title,
    required this.status,
    this.replacementCode,
    this.division = 'General Engineering',
    this.amendments = const [],
    this.mandatoryQco,
    this.advisory,
    this.evidence,
  });

  bool get isObsolete => status == 'OBSOLETE' || status == 'SUPERSEDED';
}

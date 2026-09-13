import 'evidence.dart';

/// Represents a formal amendment, addendum, or corrigendum published for a standard edition.
class StandardAmendment {
  final String id;
  final String standardCode;
  final String versionId;
  final int amendmentNumber;
  final DateTime publicationDate;
  final DateTime effectiveDate;
  final String scope;
  final List<String> affectedClauses;
  final Evidence? evidence;
  final String? gazetteReference;

  const StandardAmendment({
    required this.id,
    required this.standardCode,
    required this.versionId,
    required this.amendmentNumber,
    required this.publicationDate,
    required this.effectiveDate,
    required this.scope,
    this.affectedClauses = const [],
    this.evidence,
    this.gazetteReference,
  });

  /// True if this amendment was in effect on [date].
  bool isEffectiveOn(DateTime date) => !date.isBefore(effectiveDate);

  @override
  String toString() => '$standardCode AMD $amendmentNumber (Eff: ${effectiveDate.toIso8601String().split('T').first})';
}

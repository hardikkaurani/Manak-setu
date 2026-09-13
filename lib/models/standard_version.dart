import 'evidence.dart';
import 'lifecycle_status.dart';

/// Represents a distinct historical or current edition/revision of a standard.
///
/// Enables retrospective temporal reasoning, version diffing, and supersession tracking.
class StandardVersion {
  final String id;
  final String standardCode;
  final String edition;
  final int? revisionNumber;
  final DateTime publicationDate;
  final DateTime effectiveDate;
  final DateTime? withdrawalDate;
  final StandardLifecycleStatus status;
  final String? supersedesVersionId;
  final String? supersededByVersionId;
  final String? changeSummary;
  final Evidence? evidence;
  final String? gazetteNotification;

  const StandardVersion({
    required this.id,
    required this.standardCode,
    required this.edition,
    this.revisionNumber,
    required this.publicationDate,
    required this.effectiveDate,
    this.withdrawalDate,
    required this.status,
    this.supersedesVersionId,
    this.supersededByVersionId,
    this.changeSummary,
    this.evidence,
    this.gazetteNotification,
  });

  /// True if this specific version was legally in force on [date].
  bool isApplicableOn(DateTime date) {
    if (date.isBefore(effectiveDate)) return false;
    if (withdrawalDate != null && date.isAfter(withdrawalDate!)) return false;
    return true;
  }

  /// True if this version has been withdrawn or superseded.
  bool get isWithdrawn => withdrawalDate != null || status.isObsolete;

  @override
  String toString() => '$standardCode ($edition) [${status.displayName}]';
}

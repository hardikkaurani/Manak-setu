enum ReviewStatus { pending, accepted, rejected, flagged }

/// Represents an authoritative human review action on an audited finding.
class ReviewAction {
  final String findingId;
  final ReviewStatus status;
  final String officerName;
  final String officerId;
  final String? comment;
  final String formattedTimestamp;

  const ReviewAction({
    required this.findingId,
    required this.status,
    required this.officerName,
    required this.officerId,
    this.comment,
    required this.formattedTimestamp,
  });

  String get label {
    switch (status) {
      case ReviewStatus.pending:
        return 'Pending Review';
      case ReviewStatus.accepted:
        return 'Accepted / Approved';
      case ReviewStatus.rejected:
        return 'Rejected (Override)';
      case ReviewStatus.flagged:
        return 'Flagged for Legal Review';
    }
  }

  ReviewAction copyWith({
    String? findingId,
    ReviewStatus? status,
    String? officerName,
    String? officerId,
    String? comment,
    String? formattedTimestamp,
  }) {
    return ReviewAction(
      findingId: findingId ?? this.findingId,
      status: status ?? this.status,
      officerName: officerName ?? this.officerName,
      officerId: officerId ?? this.officerId,
      comment: comment ?? this.comment,
      formattedTimestamp: formattedTimestamp ?? this.formattedTimestamp,
    );
  }
}

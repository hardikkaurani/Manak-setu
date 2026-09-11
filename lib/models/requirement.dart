/// Statutory verification status of an extracted technical requirement.
enum RequirementStatus {
  verified,
  obsoleteCitation,
  brandLockIn,
  reviewRequired,
  unverified,
  conflict,
}

/// Represents an extracted technical clause parameter or requirement from the tender.
class Requirement {
  final String id;
  final String parameterName;
  final String specifiedValue;
  final RequirementStatus status;
  final String? statutoryCitation;
  final String? recommendedValue;
  final String? reason;

  const Requirement({
    required this.id,
    required this.parameterName,
    required this.specifiedValue,
    required this.status,
    this.statutoryCitation,
    this.recommendedValue,
    this.reason,
  });

  String get parameter => parameterName;
  String get extractedValue => specifiedValue;
  String? get clauseNumber => statutoryCitation;
  String? get verificationNote => reason;

  String get statusLabel {
    switch (status) {
      case RequirementStatus.verified:
        return 'VERIFIED';
      case RequirementStatus.obsoleteCitation:
        return 'OBSOLETE CITATION';
      case RequirementStatus.brandLockIn:
        return 'BRAND LOCK-IN';
      case RequirementStatus.reviewRequired:
        return 'REVIEW REQUIRED';
      case RequirementStatus.unverified:
        return 'UNVERIFIED';
      case RequirementStatus.conflict:
        return 'NON-COMPLIANT';
    }
  }

  bool get hasViolation =>
      status == RequirementStatus.obsoleteCitation ||
      status == RequirementStatus.brandLockIn ||
      status == RequirementStatus.reviewRequired ||
      status == RequirementStatus.conflict;
}


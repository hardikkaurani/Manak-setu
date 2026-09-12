/// Comprehensive lifecycle status enumeration for global standards.
///
/// Unlike naive boolean flags, standards lifecycle states reflect statutory,
/// gazetted, and international standardization realities.
enum StandardLifecycleStatus {
  /// Actively governing, in-force standard edition.
  current,

  /// Actively governing standard that has one or more officially gazetted amendments or corrigenda.
  amended,

  /// Replaced by a newer revision or edition of the same standard family.
  superseded,

  /// Formally withdrawn by the issuing body without a direct replacement standard.
  withdrawn,

  /// Preliminary standard, committee draft, or public review document.
  draft,

  /// Status could not be authoritatively resolved from verified gazette records.
  unknown,

  /// Differing regional, national, or jurisdictional statutory validity claims.
  conflicting,

  /// Catalog entry requiring official gazette verification.
  unverified;

  /// User-facing display label.
  String get displayName {
    switch (this) {
      case StandardLifecycleStatus.current:
        return 'CURRENT';
      case StandardLifecycleStatus.amended:
        return 'AMENDED';
      case StandardLifecycleStatus.superseded:
        return 'SUPERSEDED';
      case StandardLifecycleStatus.withdrawn:
        return 'WITHDRAWN';
      case StandardLifecycleStatus.draft:
        return 'DRAFT';
      case StandardLifecycleStatus.unknown:
        return 'UNKNOWN';
      case StandardLifecycleStatus.conflicting:
        return 'CONFLICTING';
      case StandardLifecycleStatus.unverified:
        return 'UNVERIFIED';
    }
  }

  /// Whether the standard is obsolete or cannot legally govern public procurement.
  bool get isObsolete =>
      this == StandardLifecycleStatus.superseded ||
      this == StandardLifecycleStatus.withdrawn;

  /// Whether the standard is currently valid and active.
  bool get isActive =>
      this == StandardLifecycleStatus.current ||
      this == StandardLifecycleStatus.amended;

  /// Parse string status with safe fallback.
  static StandardLifecycleStatus fromString(String? value) {
    if (value == null) return StandardLifecycleStatus.unknown;
    final normalized = value.trim().toUpperCase();
    switch (normalized) {
      case 'CURRENT':
      case 'ACTIVE':
        return StandardLifecycleStatus.current;
      case 'AMENDED':
        return StandardLifecycleStatus.amended;
      case 'SUPERSEDED':
      case 'OBSOLETE':
        return StandardLifecycleStatus.superseded;
      case 'WITHDRAWN':
      case 'CANCELLED':
        return StandardLifecycleStatus.withdrawn;
      case 'DRAFT':
        return StandardLifecycleStatus.draft;
      case 'CONFLICTING':
        return StandardLifecycleStatus.conflicting;
      case 'UNVERIFIED':
        return StandardLifecycleStatus.unverified;
      default:
        return StandardLifecycleStatus.unknown;
    }
  }
}

/// Represents an authoritative standards development organization (SDO) or national standards body (NSB).
class StandardsOrganization {
  final String id;
  final String code;
  final String name;
  final String jurisdictionId;
  final String authorityType; // 'National', 'International', 'Regional', 'IndustryConsortium'
  final String website;
  final List<String> standardsFamilies;
  final String description;

  const StandardsOrganization({
    required this.id,
    required this.code,
    required this.name,
    required this.jurisdictionId,
    required this.authorityType,
    required this.website,
    this.standardsFamilies = const [],
    this.description = '',
  });

  /// Alias for organization identifier
  String get organizationId => id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StandardsOrganization &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$name ($code)';
}

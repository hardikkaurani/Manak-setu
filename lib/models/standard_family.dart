/// Represents a family or series prefix of standards (e.g. ISO, IEC, ASTM, ASME, IEEE, EN, BS, JIS, IS).
class StandardFamily {
  final String id;
  final String code;
  final String defaultOrganizationId;
  final String jurisdictionId;
  final String delimiter;
  final String description;

  const StandardFamily({
    required this.id,
    required this.code,
    required this.defaultOrganizationId,
    required this.jurisdictionId,
    this.delimiter = ' ',
    this.description = '',
  });

  /// Alias for code / series prefix (e.g. ISO, IEC, IS, ASTM)
  String get prefix => code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StandardFamily &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => code;
}

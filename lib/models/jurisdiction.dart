/// Represents a sovereign or international regulatory and standardization jurisdiction.
///
/// Rather than hardcoding national rules into the engine, jurisdictions are treated
/// as first-class domain models containing references to national standard-setting bodies,
/// regulatory agencies, and mandatory certification authorities.
class Jurisdiction {
  final String id;
  final String code;
  final String name;
  final String region;
  final String flagEmoji;
  final List<String> defaultStandardsBodies;
  final List<String> regulatoryBodies;
  final List<String> certificationBodies;
  final List<String> standardFamilies;

  const Jurisdiction({
    required this.id,
    required this.code,
    required this.name,
    required this.region,
    required this.flagEmoji,
    this.defaultStandardsBodies = const [],
    this.regulatoryBodies = const [],
    this.certificationBodies = const [],
    this.standardFamilies = const [],
  });

  bool get isInternational => id.toUpperCase() == 'INT' || id.toUpperCase() == 'GLOBAL';

  /// Alias for id matching database schema
  String get jurisdictionId => id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Jurisdiction && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$name ($code)';
}

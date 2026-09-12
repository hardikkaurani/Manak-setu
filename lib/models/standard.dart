import 'evidence.dart';
import 'lifecycle_status.dart';

/// Represents a national, regional, or international standard within the Global Standards Intelligence catalog.
///
/// Fully supports jurisdiction-agnostic modeling (ISO, IEC, ASTM, EN, BS, JIS, IS, etc.)
/// while maintaining strict backward compatibility with existing Indian Standards (BIS) pipelines.
class Standard {
  final String standardId;
  final String code;
  final String title;
  final String status;
  final StandardLifecycleStatus lifecycleStatus;
  final String? replacementCode;
  final String jurisdictionId;
  final String organizationId;
  final String country;
  final String region;
  final String standardFamily;
  final String issuingBody;
  final String division;
  final String? committee;
  final int? year;
  final String? edition;
  final DateTime? publicationDate;
  final DateTime? effectiveDate;
  final DateTime? withdrawalDate;
  final String? harmonized;
  final List<String> amendments;
  final List<String> supersedes;
  final List<String> supersededBy;
  final List<String> amendedBy;
  final String? mandatoryQco;
  final bool isQcoMandatory;
  final String? advisory;
  final Evidence? evidence;
  final String? scope;
  final List<String> productCategories;
  final List<String> technicalDomains;
  final List<String> certificationRequirements;
  final List<String> regulatoryLinks;
  final List<String> relatedStandards;
  final List<String> rawMaterials;
  final List<String> testingMethods;
  final List<String> alliedStandards;
  final List<String> sourceDocuments;
  final String provenance;
  final DateTime? retrievalTimestamp;
  final String verificationStatus;

  const Standard({
    String? standardId,
    required this.code,
    required this.title,
    required this.status,
    this.lifecycleStatus = StandardLifecycleStatus.current,
    this.replacementCode,
    this.jurisdictionId = 'IN',
    this.organizationId = 'bis',
    this.issuingBody = 'Bureau of Indian Standards',
    this.country = 'India',
    this.region = 'South Asia',
    this.standardFamily = 'IS',
    this.division = 'General Engineering',
    this.committee,
    this.year,
    this.edition,
    this.publicationDate,
    this.effectiveDate,
    this.withdrawalDate,
    this.harmonized,
    this.amendments = const [],
    this.supersedes = const [],
    this.supersededBy = const [],
    this.amendedBy = const [],
    this.mandatoryQco,
    this.isQcoMandatory = false,
    this.advisory,
    this.evidence,
    this.scope,
    this.productCategories = const [],
    this.technicalDomains = const [],
    this.certificationRequirements = const [],
    this.regulatoryLinks = const [],
    this.relatedStandards = const [],
    this.rawMaterials = const [],
    this.testingMethods = const [],
    this.alliedStandards = const [],
    this.sourceDocuments = const [],
    this.provenance = 'Authoritative Gazette & Standards Repository',
    this.retrievalTimestamp,
    this.verificationStatus = 'VERIFIED',
  })  : standardId = standardId ?? code;

  /// Whether the standard is superseded or withdrawn and cannot govern active tenders.
  bool get isObsolete =>
      lifecycleStatus.isObsolete ||
      status == 'OBSOLETE' ||
      status == 'SUPERSEDED' ||
      status == 'WITHDRAWN';

  /// Whether the standard is currently valid.
  bool get isActive => lifecycleStatus.isActive;

  /// Whether this standard belongs to an international standards body (ISO, IEC, ITU).
  bool get isInternational =>
      jurisdictionId.toUpperCase() == 'INT' ||
      organizationId.toLowerCase() == 'iso' ||
      organizationId.toLowerCase() == 'iec';

  /// Convenient display label with jurisdiction badge.
  String get qualifiedLabel => '[$jurisdictionId] $code';

  @override
  String toString() => '$code: $title ($status)';
}

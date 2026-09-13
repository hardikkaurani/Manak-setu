import '../../data/demo_data.dart';
import '../../models/evidence.dart';
import '../../models/lifecycle_status.dart';
import '../../models/standard.dart';
import '../../models/standard_relationship.dart';
import '../../models/standard_version.dart';
import 'standards_provider.dart';

/// Base abstract class providing common parsing, caching, and catalog lookup logic.
abstract class BaseCatalogStandardsProvider implements StandardsProvider {
  final List<Standard> _catalog;

  BaseCatalogStandardsProvider({List<Standard>? catalog})
      : _catalog = catalog ?? DemoData.allGlobalStandardsCatalog;

  @override
  Future<List<Standard>> search(String query, {Map<String, dynamic>? filters}) async {
    final clean = query.trim().toLowerCase();
    final results = _catalog.where((std) {
      if (std.organizationId.toLowerCase() != organizationId.toLowerCase() &&
          std.jurisdictionId.toUpperCase() != jurisdictionId.toUpperCase()) {
        return false;
      }
      if (clean.isEmpty) return true;
      return std.code.toLowerCase().contains(clean) ||
          std.title.toLowerCase().contains(clean) ||
          (std.scope?.toLowerCase().contains(clean) ?? false) ||
          std.productCategories.any((p) => p.toLowerCase().contains(clean));
    }).toList();
    return results;
  }

  @override
  Future<Standard?> getStandard(String identifier) async {
    final clean = identifier.trim().toLowerCase();
    try {
      return _catalog.firstWhere((std) {
        final stdCode = std.code.toLowerCase();
        return stdCode == clean ||
            stdCode.contains(clean) ||
            clean.contains(stdCode);
      });
    } catch (_) {
      return null;
    }
  }

  @override
  Future<StandardLifecycleStatus> getStatus(String identifier) async {
    final std = await getStandard(identifier);
    return std?.lifecycleStatus ?? StandardLifecycleStatus.unknown;
  }

  @override
  Future<Evidence?> getEvidence(String identifier, {String? clause}) async {
    final std = await getStandard(identifier);
    if (std == null || std.evidence == null) {
      return Evidence.unavailable(
        standardCode: identifier,
        clause: clause,
        reason: 'Standard not found in provider index or unverified extract.',
      );
    }
    return std.evidence;
  }

  @override
  Future<Map<String, dynamic>> getMetadata(String identifier) async {
    final std = await getStandard(identifier);
    return {
      'providerId': providerId,
      'organizationId': organizationId,
      'jurisdictionId': jurisdictionId,
      'sourceTier': sourceTier.displayName,
      'isAuthoritative': sourceTier.isAuthoritative,
      'retrievedAt': DateTime.now().toIso8601String(),
      'found': std != null,
      'standardCode': std?.code,
      'status': std?.status,
      'license': 'Licensed / Statutory Public Metadata',
    };
  }
}

/// Provider for Bureau of Indian Standards (BIS) — Tier 1 Authoritative.
class BisStandardsProvider extends BaseCatalogStandardsProvider {
  BisStandardsProvider({super.catalog});

  @override
  String get providerId => 'bis_official_provider';
  @override
  String get organizationId => 'bis';
  @override
  String get jurisdictionId => 'IN';
  @override
  SourceTier get sourceTier => SourceTier.tier1Authoritative;
  @override
  String get authorityTitle => 'Bureau of Indian Standards';
  @override
  String get portalUrl => 'https://www.standardsbis.in';
  @override
  bool get isIndexed => true;
  @override
  List<String> get supportedFamilies => const ['IS'];

  @override
  Future<List<StandardVersion>> getVersions(String identifier) async {
    if (identifier.contains('1180')) {
      return [
        StandardVersion(
          id: 'is1180-1989',
          standardCode: 'IS 1180:1989',
          edition: 'First Revision',
          revisionNumber: 1,
          publicationDate: DateTime(1989, 4, 1),
          effectiveDate: DateTime(1989, 7, 1),
          withdrawalDate: DateTime(2014, 2, 1),
          status: StandardLifecycleStatus.superseded,
          supersededByVersionId: 'is1180-2014',
          changeSummary: 'Superseded by IS 1180 (Part 1):2014. BEE Star ratings introduced.',
        ),
        StandardVersion(
          id: 'is1180-2014',
          standardCode: 'IS 1180 (Part 1):2014',
          edition: 'Fifth Revision',
          revisionNumber: 5,
          publicationDate: DateTime(2014, 2, 1),
          effectiveDate: DateTime(2014, 8, 1),
          status: StandardLifecycleStatus.current,
          supersedesVersionId: 'is1180-1989',
          changeSummary: 'Mandated under Distribution Transformers QCO 2014 with maximum loss limits.',
        ),
      ];
    }
    if (identifier.contains('4984')) {
      return [
        StandardVersion(
          id: 'is4984-1995',
          standardCode: 'IS 4984:1995',
          edition: 'Fourth Revision',
          revisionNumber: 4,
          publicationDate: DateTime(1995, 8, 1),
          effectiveDate: DateTime(1995, 11, 1),
          withdrawalDate: DateTime(2016, 5, 1),
          status: StandardLifecycleStatus.superseded,
          supersededByVersionId: 'is4984-2016',
          changeSummary: 'Superseded by fifth revision with PE-100 material grade inclusion.',
        ),
        StandardVersion(
          id: 'is4984-2016',
          standardCode: 'IS 4984:2016',
          edition: 'Fifth Revision',
          revisionNumber: 5,
          publicationDate: DateTime(2016, 5, 1),
          effectiveDate: DateTime(2016, 11, 1),
          status: StandardLifecycleStatus.current,
          supersedesVersionId: 'is4984-1995',
          changeSummary: 'Active national standard covering PN 2.5 to PN 16 HDPE water supply mains.',
        ),
      ];
    }
    return [];
  }

  @override
  Future<List<StandardRelationship>> getRelationships(String identifier) async {
    if (identifier.contains('1180')) {
      return [
        StandardRelationship(
          id: 'rel-is1180-is335',
          sourceStandardCode: 'IS 1180 (Part 1):2014',
          targetStandardCode: 'IS 335:2018',
          relationshipType: RelationshipType.normativeReference,
          createdAt: DateTime(2026, 1, 1),
        ),
        StandardRelationship(
          id: 'rel-is1180-iec60076',
          sourceStandardCode: 'IS 1180 (Part 1):2014',
          targetStandardCode: 'IEC 60076-1:2011',
          relationshipType: RelationshipType.harmonizedWith,
          createdAt: DateTime(2026, 1, 1),
        ),
      ];
    }
    return [];
  }
}

/// Provider for International Organization for Standardization (ISO) — Tier 1 Authoritative.
class IsoStandardsProvider extends BaseCatalogStandardsProvider {
  IsoStandardsProvider({super.catalog});

  @override
  String get providerId => 'iso_official_provider';
  @override
  String get organizationId => 'iso';
  @override
  String get jurisdictionId => 'INT';
  @override
  SourceTier get sourceTier => SourceTier.tier1Authoritative;
  @override
  String get authorityTitle => 'International Organization for Standardization';
  @override
  String get portalUrl => 'https://www.iso.org';
  @override
  bool get isIndexed => true;
  @override
  List<String> get supportedFamilies => const ['ISO', 'ISO/IEC'];

  @override
  Future<List<StandardVersion>> getVersions(String identifier) async => [];
  @override
  Future<List<StandardRelationship>> getRelationships(String identifier) async => [];
}

/// Provider for International Electrotechnical Commission (IEC) — Tier 1 Authoritative.
class IecStandardsProvider extends BaseCatalogStandardsProvider {
  IecStandardsProvider({super.catalog});

  @override
  String get providerId => 'iec_official_provider';
  @override
  String get organizationId => 'iec';
  @override
  String get jurisdictionId => 'INT';
  @override
  SourceTier get sourceTier => SourceTier.tier1Authoritative;
  @override
  String get authorityTitle => 'International Electrotechnical Commission';
  @override
  String get portalUrl => 'https://www.iec.ch';
  @override
  bool get isIndexed => true;
  @override
  List<String> get supportedFamilies => const ['IEC', 'ISO/IEC'];

  @override
  Future<List<StandardVersion>> getVersions(String identifier) async => [];
  @override
  Future<List<StandardRelationship>> getRelationships(String identifier) async => [];
}

/// Provider for ASTM International — Tier 1 Authoritative.
class AstmStandardsProvider extends BaseCatalogStandardsProvider {
  AstmStandardsProvider({super.catalog});

  @override
  String get providerId => 'astm_official_provider';
  @override
  String get organizationId => 'astm';
  @override
  String get jurisdictionId => 'US';
  @override
  SourceTier get sourceTier => SourceTier.tier1Authoritative;
  @override
  String get authorityTitle => 'ASTM International';
  @override
  String get portalUrl => 'https://www.astm.org';
  @override
  bool get isIndexed => true;
  @override
  List<String> get supportedFamilies => const ['ASTM'];

  @override
  Future<List<StandardVersion>> getVersions(String identifier) async => [];
  @override
  Future<List<StandardRelationship>> getRelationships(String identifier) async => [];
}

/// Provider for Institute of Electrical and Electronics Engineers (IEEE) — Tier 1 Authoritative.
class IeeeStandardsProvider extends BaseCatalogStandardsProvider {
  IeeeStandardsProvider({super.catalog});

  @override
  String get providerId => 'ieee_official_provider';
  @override
  String get organizationId => 'ieee';
  @override
  String get jurisdictionId => 'US';
  @override
  SourceTier get sourceTier => SourceTier.tier1Authoritative;
  @override
  String get authorityTitle => 'IEEE Standards Association';
  @override
  String get portalUrl => 'https://standards.ieee.org';
  @override
  bool get isIndexed => true;
  @override
  List<String> get supportedFamilies => const ['IEEE'];

  @override
  Future<List<StandardVersion>> getVersions(String identifier) async => [];
  @override
  Future<List<StandardRelationship>> getRelationships(String identifier) async => [];
}

/// Provider for British Standards Institution (BSI) — Tier 1 Authoritative.
class BsiStandardsProvider extends BaseCatalogStandardsProvider {
  BsiStandardsProvider({super.catalog});

  @override
  String get providerId => 'bsi_official_provider';
  @override
  String get organizationId => 'bsi';
  @override
  String get jurisdictionId => 'GB';
  @override
  SourceTier get sourceTier => SourceTier.tier1Authoritative;
  @override
  String get authorityTitle => 'British Standards Institution';
  @override
  String get portalUrl => 'https://www.bsigroup.com';
  @override
  bool get isIndexed => true;
  @override
  List<String> get supportedFamilies => const ['BS', 'BS EN'];

  @override
  Future<List<StandardVersion>> getVersions(String identifier) async => [];
  @override
  Future<List<StandardRelationship>> getRelationships(String identifier) async => [];
}

/// Provider for European Committee for Standardization (CEN-CENELEC) — Tier 1 Authoritative.
class CenStandardsProvider extends BaseCatalogStandardsProvider {
  CenStandardsProvider({super.catalog});

  @override
  String get providerId => 'cen_official_provider';
  @override
  String get organizationId => 'cen';
  @override
  String get jurisdictionId => 'EU';
  @override
  SourceTier get sourceTier => SourceTier.tier1Authoritative;
  @override
  String get authorityTitle => 'European Committee for Standardization';
  @override
  String get portalUrl => 'https://www.cencenelec.eu';
  @override
  bool get isIndexed => true;
  @override
  List<String> get supportedFamilies => const ['EN'];

  @override
  Future<List<StandardVersion>> getVersions(String identifier) async => [];
  @override
  Future<List<StandardRelationship>> getRelationships(String identifier) async => [];
}

/// Provider for Japanese Industrial Standards Committee (JISC / JIS).
/// Demonstrator for unindexed / out-of-coverage handling.
class JisStandardsProvider implements StandardsProvider {
  const JisStandardsProvider();

  @override
  String get providerId => 'jis_official_provider';
  @override
  String get organizationId => 'jisc';
  @override
  String get jurisdictionId => 'JP';
  @override
  SourceTier get sourceTier => SourceTier.tier1Authoritative;
  @override
  String get authorityTitle => 'Japanese Industrial Standards Committee';
  @override
  String get portalUrl => 'https://www.jisc.go.jp';
  @override
  bool get isIndexed => false; // Not yet indexed in local catalog!
  @override
  List<String> get supportedFamilies => const ['JIS'];

  @override
  Future<List<Standard>> search(String query, {Map<String, dynamic>? filters}) async => [];
  @override
  Future<Standard?> getStandard(String identifier) async => null;
  @override
  Future<List<StandardVersion>> getVersions(String identifier) async => [];
  @override
  Future<List<StandardRelationship>> getRelationships(String identifier) async => [];
  @override
  Future<Evidence?> getEvidence(String identifier, {String? clause}) async => null;
  @override
  Future<StandardLifecycleStatus> getStatus(String identifier) async => StandardLifecycleStatus.unknown;
  @override
  Future<Map<String, dynamic>> getMetadata(String identifier) async => {
        'providerId': providerId,
        'organizationId': organizationId,
        'isIndexed': false,
        'status': 'OUT_OF_COVERAGE',
      };
}

/// Central registry mapping jurisdictions, organizations, and families to active providers.
class StandardsProviderRegistry {
  static final StandardsProviderRegistry _instance = StandardsProviderRegistry();
  static StandardsProviderRegistry get instance => _instance;
  static List<StandardsProvider> get allRegisteredProviders => _instance._providers.values.toList();

  static StandardsProvider? getProvider(String orgOrId) {
    return _instance.getProviderById(orgOrId) ?? _instance.getProviderForOrganization(orgOrId);
  }

  static StandardsProvider? getProviderForStandard(String standardCode) {
    final code = standardCode.toUpperCase();
    if (code.startsWith('IS ') || code.startsWith('IS-')) return _instance.getProviderForOrganization('bis');
    if (code.startsWith('ISO ') || code.startsWith('ISO-') || code.startsWith('ISO/')) return _instance.getProviderForOrganization('iso');
    if (code.startsWith('IEC ') || code.startsWith('IEC-')) return _instance.getProviderForOrganization('iec');
    if (code.startsWith('ASTM ') || code.startsWith('ASTM-')) return _instance.getProviderForOrganization('astm');
    if (code.startsWith('IEEE ') || code.startsWith('IEEE-')) return _instance.getProviderForOrganization('ieee');
    if (code.startsWith('BS ') || code.startsWith('BS-')) return _instance.getProviderForOrganization('bsi');
    if (code.startsWith('EN ') || code.startsWith('CEN')) return _instance.getProviderForOrganization('cen');
    if (code.startsWith('JIS ') || code.startsWith('JIS-')) return _instance.getProviderForOrganization('jisc');
    return _instance.getProviderForOrganization('bis');
  }

  final Map<String, StandardsProvider> _providers = {};

  StandardsProviderRegistry() {
    register(BisStandardsProvider());
    register(IsoStandardsProvider());
    register(IecStandardsProvider());
    register(AstmStandardsProvider());
    register(IeeeStandardsProvider());
    register(BsiStandardsProvider());
    register(CenStandardsProvider());
    register(const JisStandardsProvider());
  }

  void register(StandardsProvider provider) {
    _providers[provider.providerId] = provider;
  }

  StandardsProvider? getProviderById(String providerId) => _providers[providerId];

  StandardsProvider? getProviderForOrganization(String orgId) {
    final clean = orgId.toLowerCase();
    for (final p in _providers.values) {
      if (p.organizationId.toLowerCase() == clean) return p;
    }
    return null;
  }

  StandardsProvider? getProviderForJurisdiction(String jurisdictionId) {
    final clean = jurisdictionId.toUpperCase();
    for (final p in _providers.values) {
      if (p.jurisdictionId.toUpperCase() == clean) return p;
    }
    return null;
  }

  List<StandardsProvider> get allProviders => _providers.values.toList();
  List<StandardsProvider> get providers => _providers.values.toList();
}

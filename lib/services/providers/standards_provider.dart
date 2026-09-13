import '../../models/evidence.dart';
import '../../models/lifecycle_status.dart';
import '../../models/standard.dart';
import '../../models/standard_relationship.dart';
import '../../models/standard_version.dart';

/// Abstract contract for jurisdiction-specific and global standards data providers.
///
/// Ensures decoupled, extensible integration with national and international bodies
/// (BIS, ISO, IEC, ASTM, IEEE, BSI, CEN, JIS, CSA) with rate limiting, provenance tagging,
/// and source policy compliance.
abstract class StandardsProvider {
  /// Unique identifier of this provider adapter (e.g. 'bis_official_provider').
  String get providerId;

  /// Standards Development Organization code (e.g. 'bis', 'iso', 'iec', 'astm').
  String get organizationId;

  /// Primary jurisdiction code (e.g. 'IN', 'INT', 'US', 'GB', 'EU', 'JP').
  String get jurisdictionId;

  /// Source integrity tier.
  SourceTier get sourceTier;

  /// Human-readable authority title.
  String get authorityTitle;

  /// Official web portal URL.
  String get portalUrl;

  /// Whether this provider dataset is actively indexed in the platform catalog.
  bool get isIndexed;

  /// Supported standard families (e.g. ['IS'] or ['ASTM'] or ['ISO', 'ISO/IEC']).
  List<String> get supportedFamilies;

  /// Searches for standards matching the given query and filters.
  Future<List<Standard>> search(
    String query, {
    Map<String, dynamic>? filters,
  });

  /// Retrieves a standard by its code/identifier.
  Future<Standard?> getStandard(String identifier);

  /// Retrieves the chronological revision history of the given standard.
  Future<List<StandardVersion>> getVersions(String identifier);

  /// Retrieves all outgoing and incoming graph relationships for the standard.
  Future<List<StandardRelationship>> getRelationships(String identifier);

  /// Retrieves authoritative evidence backing a specific clause or page.
  Future<Evidence?> getEvidence(String identifier, {String? clause});

  /// Retrieves the current lifecycle status of the standard.
  Future<StandardLifecycleStatus> getStatus(String identifier);

  /// Retrieves raw provider metadata and citation provenance.
  Future<Map<String, dynamic>> getMetadata(String identifier);
}

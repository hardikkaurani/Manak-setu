import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/models/evidence.dart';
import 'package:manaksetu/models/lifecycle_status.dart';
import 'package:manaksetu/services/providers/concrete_providers.dart';

void main() {
  group('StandardsProvider Architecture Tests', () {
    final registry = StandardsProviderRegistry();

    test('registry contains all required national and global providers', () {
      expect(registry.allProviders.length, greaterThanOrEqualTo(8));

      final bis = registry.getProviderForOrganization('bis');
      expect(bis, isNotNull);
      expect(bis!.sourceTier, SourceTier.tier1Authoritative);
      expect(bis.jurisdictionId, 'IN');

      final iso = registry.getProviderForOrganization('iso');
      expect(iso, isNotNull);
      expect(iso!.jurisdictionId, 'INT');

      final iec = registry.getProviderForOrganization('iec');
      expect(iec, isNotNull);
      expect(iec!.jurisdictionId, 'INT');

      final astm = registry.getProviderForOrganization('astm');
      expect(astm, isNotNull);
      expect(astm!.jurisdictionId, 'US');

      final ieee = registry.getProviderForOrganization('ieee');
      expect(ieee, isNotNull);
      expect(ieee!.jurisdictionId, 'US');

      final bsi = registry.getProviderForOrganization('bsi');
      expect(bsi, isNotNull);
      expect(bsi!.jurisdictionId, 'GB');

      final cen = registry.getProviderForOrganization('cen');
      expect(cen, isNotNull);
      expect(cen!.jurisdictionId, 'EU');
    });

    test('BisStandardsProvider retrieves standard, versions, and relationships', () async {
      final bis = BisStandardsProvider();

      final std = await bis.getStandard('IS 1180');
      expect(std, isNotNull);
      expect(std!.code, contains('1180'));

      final versions = await bis.getVersions('IS 1180');
      expect(versions.length, greaterThanOrEqualTo(2));
      expect(versions.any((v) => v.status == StandardLifecycleStatus.superseded), isTrue);
      expect(versions.any((v) => v.status == StandardLifecycleStatus.current), isTrue);

      final rels = await bis.getRelationships('IS 1180');
      expect(rels.isNotEmpty, isTrue);

      final status = await bis.getStatus('IS 1180 (Part 1):2014');
      expect(status, StandardLifecycleStatus.current);
    });

    test('JisStandardsProvider truthfully reports OUT_OF_COVERAGE and does not hallucinate', () async {
      final jis = registry.getProviderForJurisdiction('JP');
      expect(jis, isNotNull);
      expect(jis!.isIndexed, isFalse);

      final std = await jis.getStandard('JIS G 3101');
      expect(std, isNull);

      final meta = await jis.getMetadata('JIS G 3101');
      expect(meta['status'], 'OUT_OF_COVERAGE');
      expect(meta['isIndexed'], isFalse);
    });
  });
}

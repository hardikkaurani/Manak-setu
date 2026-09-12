import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/models/standard_identifier.dart';

void main() {
  group('StandardIdentifier Universal Parser Tests', () {
    test('parses Indian Standard (IS)', () {
      final id = StandardIdentifier.parse('IS 4984:2016');
      expect(id.family, 'IS');
      expect(id.number, '4984');
      expect(id.year, 2016);
      expect(id.canonical, 'IS 4984:2016');
    });

    test('parses IS standard with part numbers', () {
      final id = StandardIdentifier.parse('IS 1180 (Part 1):2014');
      expect(id.family, 'IS');
      expect(id.number, '1180');
      expect(id.part, '1');
      expect(id.year, 2014);
      expect(id.canonical, 'IS 1180-1:2014');
    });

    test('parses ISO standard', () {
      final id = StandardIdentifier.parse('ISO 9001:2015');
      expect(id.family, 'ISO');
      expect(id.number, '9001');
      expect(id.year, 2015);
      expect(id.canonical, 'ISO 9001:2015');
    });

    test('parses ISO/IEC joint standard with dash part', () {
      final id = StandardIdentifier.parse('ISO/IEC 27001:2022');
      expect(id.family, 'ISO/IEC');
      expect(id.number, '27001');
      expect(id.year, 2022);
      expect(id.canonical, 'ISO/IEC 27001:2022');
    });

    test('parses IEC standard with part', () {
      final id = StandardIdentifier.parse('IEC 60076-1:2011');
      expect(id.family, 'IEC');
      expect(id.number, '60076');
      expect(id.part, '1');
      expect(id.year, 2011);
      expect(id.canonical, 'IEC 60076-1:2011');
    });

    test('parses ASTM standard with letter prefix in designation', () {
      final id = StandardIdentifier.parse('ASTM A615:2020');
      expect(id.family, 'ASTM');
      expect(id.number, 'A615');
      expect(id.year, 2020);
      expect(id.canonical, 'ASTM A615:2020');
    });

    test('parses ASTM dual metric designation', () {
      final id = StandardIdentifier.parse('ASTM D3035/D3035M:2021');
      expect(id.family, 'ASTM');
      expect(id.number, 'D3035/D3035M');
      expect(id.year, 2021);
      expect(id.canonical, 'ASTM D3035/D3035M:2021');
    });

    test('parses IEEE standard with letter prefix', () {
      final id = StandardIdentifier.parse('IEEE C57.12.00:2021');
      expect(id.family, 'IEEE');
      expect(id.number, 'C57.12.00');
      expect(id.year, 2021);
      expect(id.canonical, 'IEEE C57.12.00:2021');
    });

    test('parses European standard (EN)', () {
      final id = StandardIdentifier.parse('EN 50588-1:2017');
      expect(id.family, 'EN');
      expect(id.number, '50588');
      expect(id.part, '1');
      expect(id.year, 2017);
      expect(id.canonical, 'EN 50588-1:2017');
    });

    test('parses British standard (BS)', () {
      final id = StandardIdentifier.parse('BS 4449:2005');
      expect(id.family, 'BS');
      expect(id.number, '4449');
      expect(id.year, 2005);
      expect(id.canonical, 'BS 4449:2005');
    });

    test('parses Japanese Industrial Standard (JIS)', () {
      final id = StandardIdentifier.parse('JIS G 3101:2020');
      expect(id.family, 'JIS');
      expect(id.number, 'G 3101');
      expect(id.year, 2020);
      expect(id.canonical, 'JIS G 3101:2020');
    });

    test('parses harmonized composite prefix (BS EN ISO)', () {
      final id = StandardIdentifier.parse('BS EN ISO 9001:2015');
      expect(id.family, 'BS EN ISO');
      expect(id.number, '9001');
      expect(id.year, 2015);
      expect(id.canonical, 'BS EN ISO 9001:2015');
    });

    test('parses standard with amendment', () {
      final id = StandardIdentifier.parse('IS 4984:2016 AMD 1');
      expect(id.family, 'IS');
      expect(id.number, '4984');
      expect(id.year, 2016);
      expect(id.amendment, '1');
      expect(id.canonical, 'IS 4984:2016+A1');
    });

    test('matchesBase ignores revision year and amendment', () {
      final v1 = StandardIdentifier.parse('IS 1180-1:1989');
      final v2 = StandardIdentifier.parse('IS 1180 (Part 1):2014 AMD 2');
      final v3 = StandardIdentifier.parse('IS 1180-2:2014');

      expect(v1.matchesBase(v2), isTrue);
      expect(v1.matchesBase(v3), isFalse);
    });

    test('isRevisionOf checks year differences correctly', () {
      final v2014 = StandardIdentifier.parse('IS 1180-1:2014');
      final v1989 = StandardIdentifier.parse('IS 1180-1:1989');

      expect(v2014.isRevisionOf(v1989), isTrue);
      expect(v1989.isRevisionOf(v2014), isFalse);
    });

    test('gracefully falls back on arbitrary or unformatted codes', () {
      final custom = StandardIdentifier.parse('CUSTOM-SPEC-999');
      expect(custom.family, 'CUSTOM-SPEC-999');
      expect(custom.number, 'CUSTOM-SPEC-999');
    });
  });
}

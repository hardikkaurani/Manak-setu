/// Universal parser and representation for global standard identifiers.
///
/// Handles multi-jurisdictional standards formatting (ISO, IEC, ISO/IEC, ASTM,
/// ASME, IEEE, EN, BS, JIS, IS, etc.) without assuming any single national syntax.
class StandardIdentifier {
  final String rawInput;
  final String family;
  final List<String> harmonizedPrefixes;
  final String designation;
  final String? metricDesignation;
  final String? part;
  final String? section;
  final int? year;
  final List<String> amendments;

  const StandardIdentifier({
    required this.rawInput,
    required this.family,
    this.harmonizedPrefixes = const [],
    required this.designation,
    this.metricDesignation,
    this.part,
    this.section,
    this.year,
    this.amendments = const [],
  });

  /// True if the standard is harmonized across multiple national/regional bodies
  /// (e.g. BS EN ISO 9001 or DIN EN ISO 14001).
  bool get isHarmonized => harmonizedPrefixes.isNotEmpty || family.contains(' ');

  /// Returns canonical normalized standard code string without redundant whitespace.
  String toNormalizedString() {
    final buffer = StringBuffer();

    if (harmonizedPrefixes.isNotEmpty && !family.startsWith(harmonizedPrefixes.first)) {
      buffer.write('${harmonizedPrefixes.join(" ")} ');
    }

    buffer.write(family);
    buffer.write(' ');
    buffer.write(designation);

    if (metricDesignation != null &&
        metricDesignation!.isNotEmpty &&
        !designation.endsWith('/$metricDesignation')) {
      buffer.write('/$metricDesignation');
    }

    if (part != null && part!.isNotEmpty) {
      buffer.write('-$part');
    }

    if (section != null && section!.isNotEmpty) {
      buffer.write('/Sec $section');
    }

    if (year != null) {
      buffer.write(':$year');
    }

    if (amendments.isNotEmpty) {
      for (final amd in amendments) {
        if (amd.toUpperCase().startsWith('A')) {
          buffer.write('+$amd');
        } else {
          buffer.write('+A$amd');
        }
      }
    }

    return buffer.toString().trim();
  }

  /// Alias getter for core designation number.
  String get number => designation;

  /// Alias getter for normalized canonical representation.
  String get canonical => toNormalizedString();

  /// Primary amendment if present.
  String? get amendment => amendments.isNotEmpty ? amendments.first : null;

  /// Compares base family and designation ignoring revision years and amendments.
  bool matchesBase(StandardIdentifier other) {
    return family.toUpperCase() == other.family.toUpperCase() &&
        designation.toUpperCase() == other.designation.toUpperCase() &&
        part == other.part;
  }

  /// True if this identifier is a newer revision of [other].
  bool isRevisionOf(StandardIdentifier other) {
    return matchesBase(other) && (year ?? 0) > (other.year ?? 0);
  }

  @override
  String toString() => toNormalizedString();

  /// Parse any standard code string across international and national standard families.
  static StandardIdentifier parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const StandardIdentifier(
        rawInput: '',
        family: 'UNKNOWN',
        designation: 'UNKNOWN',
      );
    }

    // Check for harmonized compound prefixes (e.g. BS EN ISO, DIN EN ISO, BS EN)
    final harmonized = <String>[];
    String working = trimmed;

    final compoundPattern = RegExp(
      r'^(BS\s+EN\s+ISO|DIN\s+EN\s+ISO|BS\s+EN|DIN\s+EN|NF\s+EN)\s+',
      caseSensitive: false,
    );
    final compoundMatch = compoundPattern.firstMatch(working);
    if (compoundMatch != null) {
      final leadPrefix = compoundMatch.group(1)!.replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
      harmonized.addAll(leadPrefix.split(' '));
      final detectedFamily = leadPrefix;
      final remainder = working.substring(compoundMatch.end).trim();
      return _parseRemainder(input, detectedFamily, harmonized, remainder);
    }

    // Supported standard families recognized globally
    const knownFamilies = [
      'ISO/IEC',
      'ISO',
      'IEC',
      'ITU-T',
      'ITU-R',
      'ASTM',
      'ASME',
      'IEEE',
      'NFPA',
      'UL',
      'BS',
      'EN',
      'DIN',
      'JIS',
      'AS/NZS',
      'AS',
      'CSA',
      'IS',
      'GOST',
    ];

    String detectedFamily = 'UNKNOWN';
    String remainder = working;

    for (final fam in knownFamilies) {
      final familyPattern = RegExp(
        '^${RegExp.escape(fam)}(?:\\s+|-|:)(.+)\$',
        caseSensitive: false,
      );
      final match = familyPattern.firstMatch(working);
      if (match != null) {
        detectedFamily = fam.toUpperCase();
        remainder = match.group(1)!.trim();
        break;
      }
    }

    // Fallback if no delimiter after family or unknown prefix
    if (detectedFamily == 'UNKNOWN') {
      final genericPrefixMatch = RegExp(r'^([A-Z]{2,10})\s+(.+)$', caseSensitive: false)
          .firstMatch(working);
      if (genericPrefixMatch != null) {
        detectedFamily = genericPrefixMatch.group(1)!.toUpperCase();
        remainder = genericPrefixMatch.group(2)!.trim();
      } else {
        // Fallback on arbitrary or unformatted codes
        return StandardIdentifier(
          rawInput: input,
          family: input,
          designation: input,
        );
      }
    }

    return _parseRemainder(input, detectedFamily, harmonized, remainder);
  }

  static StandardIdentifier _parseRemainder(
    String input,
    String detectedFamily,
    List<String> harmonized,
    String remainder,
  ) {
    // Extract year: e.g. :2014, -2020, /2019
    int? extractedYear;
    final yearMatch = RegExp(r'[:\/-](\d{4})(?:\b|\+)').firstMatch(remainder);
    if (yearMatch != null) {
      extractedYear = int.tryParse(yearMatch.group(1)!);
    } else {
      // Look for 2-digit revision year in ASTM (e.g. ASTM D3035-21 or ASTM A615-20)
      final astmYearMatch = RegExp(r'-(\d{2})(?:\b|\+)').firstMatch(remainder);
      if (astmYearMatch != null) {
        final yy = int.tryParse(astmYearMatch.group(1)!);
        if (yy != null) {
          extractedYear = yy >= 50 ? 1900 + yy : 2000 + yy;
        }
      }
    }

    // Extract amendments (e.g. +A1:2013, +A3:2016, AMD 1, Amd 2, +1)
    final extractedAmendments = <String>[];
    final amdMatches = RegExp(r'\+([A-Za-z0-9:\.]+)').allMatches(remainder);
    for (final m in amdMatches) {
      extractedAmendments.add(m.group(1)!);
    }

    final wordAmdMatch = RegExp(
      r'\b(?:AMD|Amd)\s*([0-9]+)\b',
      caseSensitive: false,
    ).firstMatch(remainder);
    if (wordAmdMatch != null && extractedAmendments.isEmpty) {
      extractedAmendments.add(wordAmdMatch.group(1)!);
    }

    // Extract Part information (e.g. (Part 1), Pt 1, -1)
    String? extractedPart;
    final partParenMatch = RegExp(r'\((?:Part|Pt\.?)\s*([0-9A-Za-z]+)\)', caseSensitive: false)
        .firstMatch(remainder);
    if (partParenMatch != null) {
      extractedPart = partParenMatch.group(1);
    } else {
      // Dashed parts: e.g. IEC 60076-1 or EN 12201-2 or ISO 4427-1 (not ASTM letter dashes)
      final dashedPartMatch = RegExp(r'^[A-Za-z0-9\.]+-([0-9]+)(?:\b|:)').firstMatch(remainder);
      if (dashedPartMatch != null) {
        extractedPart = dashedPartMatch.group(1);
      }
    }

    // Extract Metric designation for dual standards (e.g. ASTM A615/A615M or ASTM D3035/D3035M)
    String? extractedMetric;
    final metricMatch = RegExp(r'\/([A-Za-z0-9]+M)\b').firstMatch(remainder);
    if (metricMatch != null) {
      extractedMetric = metricMatch.group(1);
    }

    // Extract core designation number / alphanumeric token
    String cleanDesignation = remainder;

    // Strip year
    if (yearMatch != null) {
      cleanDesignation = cleanDesignation.replaceAll(yearMatch.group(0)!, '');
    } else if (RegExp(r'-(\d{2})(?:\b|\+)').hasMatch(cleanDesignation)) {
      cleanDesignation = cleanDesignation.replaceAll(
        RegExp(r'-(\d{2})(?:\b|\+)').firstMatch(cleanDesignation)!.group(0)!,
        '',
      );
    }

    // Strip amendments
    cleanDesignation = cleanDesignation.replaceAll(RegExp(r'\+[A-Za-z0-9:\.]+'), '');
    cleanDesignation = cleanDesignation.replaceAll(
      RegExp(r'\b(?:AMD|Amd)\s*[0-9]+\b', caseSensitive: false),
      '',
    );

    // Strip part parentheses
    cleanDesignation = cleanDesignation
        .replaceAll(RegExp(r'\((?:Part|Pt\.?)\s*[0-9A-Za-z]+\)', caseSensitive: false), '')
        .trim();

    // Clean punctuation at tail
    cleanDesignation = cleanDesignation.replaceAll(RegExp(r'[:,\-\/\s]+$'), '').trim();

    // If dashed part was detected, strip the -$extractedPart from base designation
    if (extractedPart != null && cleanDesignation.contains('-$extractedPart')) {
      cleanDesignation = cleanDesignation.replaceAll('-$extractedPart', '').trim();
    }

    return StandardIdentifier(
      rawInput: input,
      family: detectedFamily,
      harmonizedPrefixes: harmonized,
      designation: cleanDesignation.isEmpty ? remainder : cleanDesignation,
      metricDesignation: extractedMetric,
      part: extractedPart,
      year: extractedYear,
      amendments: extractedAmendments,
    );
  }
}

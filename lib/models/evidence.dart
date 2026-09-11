/// Represents authoritative BIS evidence cited for a requirement or finding.
class Evidence {
  final String standardCode;
  final String? defectiveStandardCode;
  final String? replacementStandardCode;
  final String? clause;
  final String? page;
  final String? table;
  final String sourceFile;
  final String textExcerpt;

  const Evidence({
    required this.standardCode,
    this.defectiveStandardCode,
    this.replacementStandardCode,
    this.clause,
    this.page,
    this.table,
    required this.sourceFile,
    required this.textExcerpt,
  });

  String get citationDisplay {
    final parts = <String>[standardCode];
    if (clause != null) parts.add('Clause $clause');
    if (table != null) parts.add(table!);
    if (page != null) parts.add('Page $page');
    return parts.join(' · ');
  }
}

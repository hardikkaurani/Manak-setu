enum BoQStatus { pass, warn, fail }

/// Represents a line item inside an audited Bill of Quantities (BoQ).
class BoQItem {
  final String itemNumber;
  final String description;
  final String quantity;
  final String unit;
  final String citedStandard;
  final BoQStatus status;
  final String recommendedStandard;
  final String statutoryDefect;
  final String recommendedAction;
  final bool mandatoryQcoCited;
  final bool isBrandLocked;

  const BoQItem({
    required this.itemNumber,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.citedStandard,
    required this.status,
    required this.recommendedStandard,
    required this.statutoryDefect,
    required this.recommendedAction,
    this.mandatoryQcoCited = true,
    this.isBrandLocked = false,
  });

  String get statusLabel {
    switch (status) {
      case BoQStatus.pass:
        return 'PASS';
      case BoQStatus.warn:
        return 'WARN';
      case BoQStatus.fail:
        return 'FAIL';
    }
  }
}

/// Represents the overall evaluation result of a Bill of Quantities audit.
class BoQAuditResult {
  final String fileName;
  final int totalItems;
  final int passCount;
  final int warnCount;
  final int failCount;
  final int statutoryComplianceScore;
  final List<BoQItem> items;

  const BoQAuditResult({
    required this.fileName,
    required this.totalItems,
    required this.passCount,
    required this.warnCount,
    required this.failCount,
    required this.statutoryComplianceScore,
    required this.items,
  });
}

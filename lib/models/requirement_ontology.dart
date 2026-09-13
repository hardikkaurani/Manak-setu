import 'evidence.dart';

/// Categories of procurement and engineering requirements.
enum RequirementType {
  performance('Performance', 'Efficiency, loss limits, capacity, rating'),
  material('Material Grade', 'Chemical composition, raw material grade, resin'),
  dimensions('Dimensions & Tolerance', 'Diameter, thickness, pressure rating, SDR'),
  safety('Safety & Protection', 'Earthing, insulation levels, fire resistance'),
  environmental('Environmental', 'Ambient temperature, humidity, corrosion resistance'),
  testing('Testing & Inspection', 'Routine, type, acceptance test protocols'),
  certification('Certification & Marking', 'Mandatory license, ISI mark, CE marking'),
  regulatory('Statutory & Regulatory', 'Quality Control Orders, Public Procurement Orders, GFR'),
  installation('Installation & Workmanship', 'Handling, jointing, laying instructions'),
  documentation('Documentation & Warranty', 'Test certificates, manufacturer warranty');

  final String displayName;
  final String description;
  const RequirementType(this.displayName, this.description);
}

/// Comparison operators for technical parameter thresholds.
enum RequirementOperator {
  greaterThanOrEqual('>='),
  lessThanOrEqual('<='),
  equal('='),
  inRange('BETWEEN'),
  contains('CONTAINS'),
  mandatoryConformity('CONFORMS_TO');

  final String symbol;
  const RequirementOperator(this.symbol);
}

/// A structured procurement requirement decomposed from raw clause text.
class ProcurementRequirement {
  final String id;
  final String domain;
  final String product;
  final RequirementType requirementType;
  final String parameter;
  final RequirementOperator op;
  final String value;
  final String? unit;
  final String? sourceClause;
  final bool isMandatory;
  final Evidence? evidence;

  const ProcurementRequirement({
    required this.id,
    required this.domain,
    required this.product,
    required this.requirementType,
    required this.parameter,
    required this.op,
    required this.value,
    this.unit,
    this.sourceClause,
    this.isMandatory = true,
    this.evidence,
  });

  /// Evaluates whether an extracted technical value satisfies this requirement threshold.
  bool evaluateNumericThreshold(num candidateValue) {
    final parsedValue = num.tryParse(value);
    if (parsedValue == null) return true;

    switch (op) {
      case RequirementOperator.greaterThanOrEqual:
        return candidateValue >= parsedValue;
      case RequirementOperator.lessThanOrEqual:
        return candidateValue <= parsedValue;
      case RequirementOperator.equal:
        return candidateValue == parsedValue;
      default:
        return true;
    }
  }

  @override
  String toString() => '$parameter ${op.symbol} $value${unit != null ? " $unit" : ""} [${requirementType.displayName}]';
}

/// Parser that converts specification snippets into structured ProcurementRequirement entities.
class RequirementOntologyParser {
  const RequirementOntologyParser();

  /// Decomposes raw clause sentences into structured requirement entities.
  static List<ProcurementRequirement> parseClauseSnippet({
    required String domain,
    required String product,
    required String clauseText,
    String? clauseId,
  }) {
    final requirements = <ProcurementRequirement>[];
    final lines = clauseText.split(RegExp(r'[\r\n]+'));

    int counter = 1;
    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // Detect Efficiency parameter
      if (RegExp(r'\befficiency\b', caseSensitive: false).hasMatch(line)) {
        final match = RegExp(r'(\d+(?:\.\d+)?)\s*%').firstMatch(line);
        requirements.add(
          ProcurementRequirement(
            id: 'req-${clauseId ?? "cl"}-$counter',
            domain: domain,
            product: product,
            requirementType: RequirementType.performance,
            parameter: 'Energy Efficiency',
            op: RequirementOperator.greaterThanOrEqual,
            value: match != null ? match.group(1)! : '98.5',
            unit: '%',
            sourceClause: line,
          ),
        );
        counter++;
      }

      // Detect Material grade (e.g. PE-100, Fe 500D)
      if (RegExp(r'\b(PE-100|PE-80|Fe\s*500D|Fe\s*550D)\b', caseSensitive: false).hasMatch(line)) {
        final match = RegExp(r'\b(PE-100|PE-80|Fe\s*500D|Fe\s*550D)\b', caseSensitive: false).firstMatch(line);
        requirements.add(
          ProcurementRequirement(
            id: 'req-${clauseId ?? "cl"}-$counter',
            domain: domain,
            product: product,
            requirementType: RequirementType.material,
            parameter: 'Material Grade',
            op: RequirementOperator.equal,
            value: match!.group(1)!.toUpperCase(),
            sourceClause: line,
          ),
        );
        counter++;
      }

      // Detect Pressure rating / Nominal diameter (e.g. PN 10, SDR 11)
      if (RegExp(r'\b(PN\s*\d+|SDR\s*\d+)\b', caseSensitive: false).hasMatch(line)) {
        final match = RegExp(r'\b(PN\s*\d+|SDR\s*\d+)\b', caseSensitive: false).firstMatch(line);
        requirements.add(
          ProcurementRequirement(
            id: 'req-${clauseId ?? "cl"}-$counter',
            domain: domain,
            product: product,
            requirementType: RequirementType.dimensions,
            parameter: 'Pressure / Dimensional Class',
            op: RequirementOperator.equal,
            value: match!.group(1)!.toUpperCase(),
            sourceClause: line,
          ),
        );
        counter++;
      }

      // Detect Mandatory Certification / QCO
      if (RegExp(r'\b(QCO|BIS|ISI\s*Mark|mandatory)\b', caseSensitive: false).hasMatch(line)) {
        requirements.add(
          ProcurementRequirement(
            id: 'req-${clauseId ?? "cl"}-$counter',
            domain: domain,
            product: product,
            requirementType: RequirementType.certification,
            parameter: 'Statutory Certification',
            op: RequirementOperator.mandatoryConformity,
            value: 'Compulsory Certification (ISI Mark)',
            sourceClause: line,
          ),
        );
        counter++;
      }
    }

    return requirements;
  }
}

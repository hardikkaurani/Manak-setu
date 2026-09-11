/// Represents an editable technical parameter inside the Specification Builder workbench.
class SpecificationParameter {
  final String id;
  final String name;
  final String currentValue;
  final List<String> options;
  final String? unit;
  final String standardReference;
  final bool isVerified;
  final bool hasConflict;
  final String? conflictReason;

  const SpecificationParameter({
    required this.id,
    required this.name,
    required this.currentValue,
    required this.options,
    this.unit,
    required this.standardReference,
    this.isVerified = true,
    this.hasConflict = false,
    this.conflictReason,
  });

  SpecificationParameter copyWith({
    String? id,
    String? name,
    String? currentValue,
    List<String>? options,
    String? unit,
    String? standardReference,
    bool? isVerified,
    bool? hasConflict,
    String? conflictReason,
  }) {
    return SpecificationParameter(
      id: id ?? this.id,
      name: name ?? this.name,
      currentValue: currentValue ?? this.currentValue,
      options: options ?? this.options,
      unit: unit ?? this.unit,
      standardReference: standardReference ?? this.standardReference,
      isVerified: isVerified ?? this.isVerified,
      hasConflict: hasConflict ?? this.hasConflict,
      conflictReason: conflictReason ?? this.conflictReason,
    );
  }

  String get status =>
      hasConflict ? 'conflict' : (isVerified ? 'verified' : 'review');
  List<String> get allowedValues => options;
  String? get conflictMessage => conflictReason;
}


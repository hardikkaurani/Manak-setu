import 'evidence.dart';

/// Represents a statutory section within the Specification Builder workbench.
class SpecificationSection {
  final String id;
  final String sectionNumber; // e.g. "1.0", "2.0"
  final String title;
  final String status; // 'VERIFIED', 'PENDING', 'CONFLICT'
  final String content;
  final String? recommendation;
  final String? suggestedAppend;
  final bool isPurchaserDefined;
  final Evidence? evidence;

  const SpecificationSection({
    required this.id,
    required this.sectionNumber,
    required this.title,
    required this.status,
    required this.content,
    this.recommendation,
    this.suggestedAppend,
    this.isPurchaserDefined = false,
    this.evidence,
  });

  SpecificationSection copyWith({
    String? id,
    String? sectionNumber,
    String? title,
    String? status,
    String? content,
    String? recommendation,
    String? suggestedAppend,
    bool? isPurchaserDefined,
  }) {
    return SpecificationSection(
      id: id ?? this.id,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      title: title ?? this.title,
      status: status ?? this.status,
      content: content ?? this.content,
      recommendation: recommendation ?? this.recommendation,
      suggestedAppend: suggestedAppend ?? this.suggestedAppend,
      isPurchaserDefined: isPurchaserDefined ?? this.isPurchaserDefined,
    );
  }
}

import 'evidence.dart';

/// Semantic relationship type between standards, regulations, test methods, or certifications.
enum RelationshipType {
  normativeReference('NORMATIVE_REFERENCE', 'Indispensable reference for the application of the standard'),
  informativeReference('INFORMATIVE_REFERENCE', 'Guidance or bibliography reference without mandatory conformity'),
  supersedes('SUPERSEDES', 'Formally replaces an older edition or legacy standard'),
  supersededBy('SUPERSEDED_BY', 'Formally replaced by a newer standard or revision'),
  amends('AMENDS', 'Modifies specific clauses of the target standard'),
  amendedBy('AMENDED_BY', 'Subject to formal published amendments'),
  relatedTo('RELATED_TO', 'Allied, complementary, or relevant technical domain standard'),
  adoptedFrom('ADOPTED_FROM', 'National adoption of an international standard'),
  harmonizedWith('HARMONIZED_WITH', 'Identical or technically aligned standard in another jurisdiction'),
  testedBy('TESTED_BY', 'Governed by a dedicated test method or protocol standard'),
  certifiedBy('CERTIFIED_BY', 'Subject to a statutory or voluntary conformity assessment scheme'),
  regulatedBy('REGULATED_BY', 'Mandated by an official government order, QCO, or regulation'),
  conflictsWith('CONFLICTS_WITH', 'Contradictory technical requirements or test parameters');

  final String code;
  final String description;
  const RelationshipType(this.code, this.description);
}

/// Represents a verified, typed relationship between two entities in the standards graph.
class StandardRelationship {
  final String id;
  final String sourceStandardCode;
  final String targetStandardCode;
  final RelationshipType relationshipType;
  final double confidence;
  final Evidence? evidence;
  final String verificationState;
  final DateTime createdAt;
  final String? notes;

  const StandardRelationship({
    required this.id,
    required this.sourceStandardCode,
    required this.targetStandardCode,
    required this.relationshipType,
    this.confidence = 1.0,
    this.evidence,
    this.verificationState = 'VERIFIED',
    required this.createdAt,
    this.notes,
  });

  /// True if the relationship has verified evidentiary proof.
  bool get hasEvidence => evidence != null && evidence!.isAvailable;

  @override
  String toString() => '$sourceStandardCode —[${relationshipType.code}]→ $targetStandardCode ($verificationState)';
}

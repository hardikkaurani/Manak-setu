import 'evidence.dart';
import 'international_equivalence.dart';

/// Comprehensive node categorization within the Standards Knowledge Graph ontology.
enum GraphNodeType {
  // Core Standard Entities (legacy + global)
  primaryStandard,
  supersededStandard,
  foreignEquivalent,
  alliedStandard,

  // Regulatory & Statutory Entities
  qco,
  regulation,
  certification,

  // Technical & Testing Entities
  rawMaterial,
  testingProtocol,
  clause,
  requirement,

  // Structural & Metadata Entities
  organization,
  jurisdiction,
  product,
  amendment,
  edition,
  source,
  country,
  industry,
  technology;

  /// User-friendly label for category filter and drawers.
  String get displayName {
    switch (this) {
      case GraphNodeType.primaryStandard:
        return 'Primary Standard';
      case GraphNodeType.supersededStandard:
        return 'Superseded Standard';
      case GraphNodeType.foreignEquivalent:
        return 'International Equivalent';
      case GraphNodeType.alliedStandard:
        return 'Allied Standard';
      case GraphNodeType.qco:
        return 'Mandatory QCO';
      case GraphNodeType.regulation:
        return 'Statutory Regulation';
      case GraphNodeType.certification:
        return 'Certification Scheme';
      case GraphNodeType.rawMaterial:
        return 'Mandated Material';
      case GraphNodeType.testingProtocol:
        return 'Testing Method';
      case GraphNodeType.clause:
        return 'Standard Clause';
      case GraphNodeType.requirement:
        return 'Technical Requirement';
      case GraphNodeType.organization:
        return 'Standards Organization';
      case GraphNodeType.jurisdiction:
        return 'Jurisdiction';
      case GraphNodeType.product:
        return 'Product Category';
      case GraphNodeType.amendment:
        return 'Gazetted Amendment';
      case GraphNodeType.edition:
        return 'Standard Edition';
      case GraphNodeType.source:
        return 'Official Source';
      case GraphNodeType.country:
        return 'Country';
      case GraphNodeType.industry:
        return 'Industry Sector';
      case GraphNodeType.technology:
        return 'Technology Domain';
    }
  }
}

/// Represents a directed semantic relationship edge in the Standards Knowledge Graph.
class StandardsGraphEdge {
  final String sourceId;
  final String targetId;
  final String relationship;
  final String label;
  final double confidence;
  final Evidence? evidence;
  final EquivalenceDegree? equivalenceDegree;

  const StandardsGraphEdge({
    required this.sourceId,
    required this.targetId,
    required this.relationship,
    required this.label,
    this.confidence = 1.0,
    this.evidence,
    this.equivalenceDegree,
  });

  // Canonical Edge Relationship Constants
  static const String normativeReference = 'NORMATIVE_REFERENCE';
  static const String informativeReference = 'INFORMATIVE_REFERENCE';
  static const String relatedTo = 'RELATED_TO';
  static const String supersedes = 'SUPERSEDES';
  static const String supersededBy = 'SUPERSEDED_BY';
  static const String amends = 'AMENDS';
  static const String amendedBy = 'AMENDED_BY';
  static const String withdrawn = 'WITHDRAWN';
  static const String replacedBy = 'REPLACED_BY';
  static const String equivalentTo = 'EQUIVALENT_TO';
  static const String adoptedFrom = 'ADOPTED_FROM';
  static const String derivedFrom = 'DERIVED_FROM';
  static const String harmonizedWith = 'HARMONIZED_WITH';
  static const String conflictsWith = 'CONFLICTS_WITH';
  static const String implements = 'IMPLEMENTS';
  static const String testedBy = 'TESTED_BY';
  static const String certifiedBy = 'CERTIFIED_BY';
  static const String regulatedBy = 'REGULATED_BY';
  static const String appliesTo = 'APPLIES_TO';
  static const String requires = 'REQUIRES';
}

/// Represents a node within the Global Standards Knowledge Graph ontology.
class StandardsGraphNode {
  final String id;
  final String code;
  final String title;
  final GraphNodeType type;
  final String categoryLabel;
  final String relationship;
  final String status;
  final String description;
  final Evidence? evidence;
  final String jurisdictionId;
  final EquivalenceDegree? equivalenceDegree;
  final double x;
  final double y;

  const StandardsGraphNode({
    required this.id,
    required this.code,
    required this.title,
    required this.type,
    required this.categoryLabel,
    required this.relationship,
    required this.status,
    required this.description,
    this.evidence,
    this.jurisdictionId = 'IN',
    this.equivalenceDegree,
    this.x = 0.0,
    this.y = 0.0,
  });

  StandardsGraphNode copyWith({
    String? id,
    String? code,
    String? title,
    GraphNodeType? type,
    String? categoryLabel,
    String? relationship,
    String? status,
    String? description,
    Evidence? evidence,
    String? jurisdictionId,
    EquivalenceDegree? equivalenceDegree,
    double? x,
    double? y,
  }) {
    return StandardsGraphNode(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      type: type ?? this.type,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      relationship: relationship ?? this.relationship,
      status: status ?? this.status,
      description: description ?? this.description,
      evidence: evidence ?? this.evidence,
      jurisdictionId: jurisdictionId ?? this.jurisdictionId,
      equivalenceDegree: equivalenceDegree ?? this.equivalenceDegree,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}

/// Complete graph bundle containing both nodes and directed edges.
class StandardsGraphBundle {
  final StandardsGraphNode rootNode;
  final List<StandardsGraphNode> nodes;
  final List<StandardsGraphEdge> edges;

  const StandardsGraphBundle({
    required this.rootNode,
    required this.nodes,
    required this.edges,
  });
}

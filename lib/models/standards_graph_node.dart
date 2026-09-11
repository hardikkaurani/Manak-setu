import 'evidence.dart';

enum GraphNodeType {
  primaryStandard,
  qco,
  rawMaterial,
  testingProtocol,
  alliedStandard,
  supersededStandard,
  foreignEquivalent,
}

/// Represents a directed semantic relationship edge in the Standards Knowledge Graph.
class StandardsGraphEdge {
  final String sourceId;
  final String targetId;
  final String relationship; // e.g. 'SUPERSEDES', 'REQUIRES_MATERIAL', 'REQUIRES_TEST', 'GOVERNED_BY_QCO', 'ALLIED_WITH', 'EQUIVALENT_TO'
  final String label;

  const StandardsGraphEdge({
    required this.sourceId,
    required this.targetId,
    required this.relationship,
    required this.label,
  });
}

/// Represents a node within the BIS Standards Knowledge Graph ontology.
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

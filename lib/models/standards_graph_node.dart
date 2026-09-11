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
  });
}

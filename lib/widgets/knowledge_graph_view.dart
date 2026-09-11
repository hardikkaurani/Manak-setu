import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/standards_graph_node.dart';
import 'status_badge.dart';
import 'evidence_sheet.dart';

/// Mobile-optimized Knowledge Graph and Normative Standards Ontology View.
/// Presents the canonical BIS dependency network for IS 1180 (Part 1):2014 cleanly and legibly.
class KnowledgeGraphView extends StatefulWidget {
  final List<StandardsGraphNode> nodes;

  const KnowledgeGraphView({super.key, required this.nodes});

  @override
  State<KnowledgeGraphView> createState() => _KnowledgeGraphViewState();
}

class _KnowledgeGraphViewState extends State<KnowledgeGraphView> {
  String _selectedFilter = 'ALL';

  List<StandardsGraphNode> get _filteredNodes {
    if (_selectedFilter == 'ALL') {
      return widget.nodes
          .where((n) => n.type != GraphNodeType.primaryStandard)
          .toList();
    }
    return widget.nodes
        .where((n) => n.categoryLabel == _selectedFilter)
        .toList();
  }

  StandardsGraphNode get _rootNode {
    return widget.nodes.firstWhere(
      (n) => n.type == GraphNodeType.primaryStandard,
      orElse: () => widget.nodes.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'ALL',
      'Mandatory QCO',
      'Raw Material',
      'Testing Protocol',
      'Allied Standard',
      'Superseded Edition',
      'Foreign Equivalent',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Ontology Header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'BIS KNOWLEDGE GRAPH',
                      style: AppTextStyles.codeBadge.copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Text(
                    'NORMATIVE STANDARDS ONTOLOGY',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Normative Standards Knowledge Graph: ${_rootNode.code}',
                style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Deterministic view of dependencies: mandatory QCO orders, normative materials, testing protocols, allied standards, and superseded editions.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Central Governing Standard Anchor Card
        _buildRootCard(_rootNode),
        const SizedBox(height: 14),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedFilter == cat;
              final count = cat == 'ALL'
                  ? widget.nodes
                        .where((n) => n.type != GraphNodeType.primaryStandard)
                        .length
                  : widget.nodes.where((n) => n.categoryLabel == cat).length;

              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(
                    '$cat ($count)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = cat;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Connected Dependency Nodes
        ..._filteredNodes.map((node) => _buildNodeCard(node)),
      ],
    );
  }

  Widget _buildRootCard(StandardsGraphNode root) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.hub,
                  color: AppColors.onPrimary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CENTRAL GOVERNING ROOT',
                      style: AppTextStyles.pageEyebrow.copyWith(
                        color: AppColors.primary,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      root.code,
                      style: AppTextStyles.code.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge.verified(root.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            root.title,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 12.5),
          ),
          const SizedBox(height: 6),
          Text(
            root.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11.5,
            ),
          ),
          if (root.evidence != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.menu_book, size: 13),
                label: const Text(
                  'VIEW ROOT EVIDENCE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  EvidenceSheet.show(
                    context,
                    evidence: root.evidence!,
                    title: root.code,
                    subtitle: root.title,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNodeCard(StandardsGraphNode node) {
    Color borderColor;
    Color relationBg;
    Color relationFg;
    IconData icon;

    switch (node.type) {
      case GraphNodeType.qco:
        borderColor = AppColors.secondary;
        relationBg = AppColors.secondaryLight;
        relationFg = AppColors.secondary;
        icon = Icons.gavel;
        break;
      case GraphNodeType.supersededStandard:
        borderColor = AppColors.nonCompliantBorder;
        relationBg = AppColors.nonCompliantBg;
        relationFg = AppColors.nonCompliantText;
        icon = Icons.history;
        break;
      case GraphNodeType.rawMaterial:
        borderColor = AppColors.outlineVariant;
        relationBg = AppColors.surfaceContainerLow;
        relationFg = AppColors.textPrimary;
        icon = Icons.science_outlined;
        break;
      case GraphNodeType.testingProtocol:
        borderColor = AppColors.outlineVariant;
        relationBg = AppColors.surfaceContainerLow;
        relationFg = AppColors.textPrimary;
        icon = Icons.biotech;
        break;
      case GraphNodeType.alliedStandard:
        borderColor = AppColors.primaryContainer.withValues(alpha: 0.4);
        relationBg = AppColors.surfaceContainerLow;
        relationFg = AppColors.primaryContainer;
        icon = Icons.alt_route;
        break;
      case GraphNodeType.foreignEquivalent:
        borderColor = AppColors.outlineVariant;
        relationBg = AppColors.surfaceContainerLow;
        relationFg = AppColors.textSecondary;
        icon = Icons.language;
        break;
      case GraphNodeType.primaryStandard:
        borderColor = AppColors.primary;
        relationBg = AppColors.primary;
        relationFg = AppColors.onPrimary;
        icon = Icons.verified;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Relationship & Category Row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: relationBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 12, color: relationFg),
                        const SizedBox(width: 4),
                        Text(
                          node.relationship,
                          style: AppTextStyles.codeBadge.copyWith(
                            color: relationFg,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    node.categoryLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              if (node.type == GraphNodeType.supersededStandard)
                StatusBadge.obsolete(node.status)
              else if (node.type == GraphNodeType.qco)
                StatusBadge.critical(node.status)
              else
                StatusBadge.verified(node.status),
            ],
          ),
          const SizedBox(height: 8),

          // Code & Title
          Text(
            node.code,
            style: AppTextStyles.code.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            node.title,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            node.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),

          // Evidence Button if available
          if (node.evidence != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.menu_book, size: 12),
                label: const Text(
                  'VIEW BIS EVIDENCE',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  EvidenceSheet.show(
                    context,
                    evidence: node.evidence!,
                    title: node.code,
                    subtitle: node.title,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

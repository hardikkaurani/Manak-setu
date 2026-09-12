import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../models/standards_graph_node.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'evidence_sheet.dart';
import 'status_badge.dart';

/// P0 Knowledge Graph Component matching Web StandardsGraph Cytoscape semantics.
/// Provides:
/// 1. Interactive 2D Spatial Canvas with zoom/pan, directed bezier edges, arrowheads,
///    relationship labels, Cytoscape-aligned node geometry/colors, and node tap drawer.
/// 2. Governed Central Root and Relationship Explorer cards with BIS Evidence integration.
/// 3. Filter chips by semantic category and fallback ontology tree.
class KnowledgeGraphView extends StatefulWidget {
  final List<StandardsGraphNode>? nodes;
  final StandardsGraphBundle? bundle;
  final String? presetId;

  const KnowledgeGraphView({
    super.key,
    this.nodes,
    this.bundle,
    this.presetId,
  });

  @override
  State<KnowledgeGraphView> createState() => _KnowledgeGraphViewState();
}

class _KnowledgeGraphViewState extends State<KnowledgeGraphView> {
  final TransformationController _transformController =
      TransformationController();
  String _selectedFilter = 'ALL';
  StandardsGraphNode? _selectedNode;
  bool _isVisualCanvasMode = true;

  static const double _canvasWidth = 960.0;
  static const double _canvasHeight = 620.0;
  static const Offset _canvasCenter = Offset(480.0, 310.0);

  @override
  void initState() {
    super.initState();
    _resetView();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  StandardsGraphBundle _resolveBundle() {
    if (widget.bundle != null) return widget.bundle!;
    if (widget.nodes != null && widget.nodes!.isNotEmpty) {
      final root = widget.nodes!.firstWhere(
        (n) => n.type == GraphNodeType.primaryStandard,
        orElse: () => widget.nodes!.first,
      );
      final syntheticEdges = <StandardsGraphEdge>[];
      for (final n in widget.nodes!) {
        if (n.id != root.id) {
          syntheticEdges.add(
            StandardsGraphEdge(
              sourceId: root.id,
              targetId: n.id,
              relationship: n.relationship,
              label: n.relationship,
            ),
          );
        }
      }
      return StandardsGraphBundle(
        rootNode: root,
        nodes: widget.nodes!,
        edges: syntheticEdges,
      );
    }
    return DemoData.getGraphBundleForPreset(widget.presetId ?? 'transformer');
  }

  Map<String, Offset> _calculateNodePositions(StandardsGraphBundle bundle) {
    final positions = <String, Offset>{};
    positions[bundle.rootNode.id] = _canvasCenter;

    final otherNodes =
        bundle.nodes.where((n) => n.id != bundle.rootNode.id).toList();
    final count = otherNodes.length;
    if (count == 0) return positions;

    final primaryRadius = math.min(_canvasWidth, _canvasHeight) * 0.36;

    for (int i = 0; i < count; i++) {
      final node = otherNodes[i];
      if (node.x > 0 && node.y > 0) {
        positions[node.id] = Offset(node.x, node.y);
      } else {
        final angle = (2 * math.pi * i / count) - (math.pi / 2);
        final r = node.type == GraphNodeType.supersededStandard
            ? primaryRadius * 0.72
            : (node.type == GraphNodeType.qco
                ? primaryRadius * 0.88
                : primaryRadius);
        final pos = Offset(
          _canvasCenter.dx + r * math.cos(angle),
          _canvasCenter.dy + r * math.sin(angle),
        );
        positions[node.id] = pos;
      }
    }
    return positions;
  }

  void _resetView() {
    final matrix = Matrix4.diagonal3Values(0.85, 0.85, 1.0)
      ..setTranslationRaw(-100.0, -35.0, 0.0);
    _transformController.value = matrix;
  }

  void _zoomIn() {
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    if (currentScale < 2.5) {
      final matrix = _transformController.value.clone()
        ..multiply(Matrix4.diagonal3Values(1.25, 1.25, 1.0));
      _transformController.value = matrix;
    }
  }

  void _zoomOut() {
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    if (currentScale > 0.4) {
      final matrix = _transformController.value.clone()
        ..multiply(Matrix4.diagonal3Values(0.8, 0.8, 1.0));
      _transformController.value = matrix;
    }
  }

  void _centerOnNode(StandardsGraphNode node, Offset pos) {
    final matrix = Matrix4.diagonal3Values(1.1, 1.1, 1.0)
      ..setTranslationRaw(-pos.dx + 220, -pos.dy + 180, 0.0);
    _transformController.value = matrix;
  }

  @override
  Widget build(BuildContext context) {
    final bundle = _resolveBundle();
    final positions = _calculateNodePositions(bundle);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Interactive Control Header & View Switcher
          _buildGraphHeader(bundle),

          // 2. Category Filter Chips
          _buildFilterChips(bundle),

          const SizedBox(height: 10),

          // 3. 2D Interactive Spatial Canvas
          if (_isVisualCanvasMode) ...[
            Container(
              height: 340,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF030712),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildCanvasView(bundle, positions),
              ),
            ),
            const SizedBox(height: 8),
            _buildLegendBar(),
            const SizedBox(height: 14),
          ],

          // 4. Central Governing Root Card (Guaranteed Exact Text Match)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _buildRootCard(bundle.rootNode),
          ),

          const SizedBox(height: 12),

          // 5. Relationship Explorer Cards List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _buildRelationshipCardsList(bundle),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphHeader(StandardsGraphBundle bundle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.hub_outlined,
                        size: 18,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BIS KNOWLEDGE GRAPH',
                            style: AppTextStyles.brandTitle.copyWith(
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Standards & statutory rules',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Mode Toggle Pill
              InkWell(
                onTap: () {
                  setState(() {
                    _isVisualCanvasMode = !_isVisualCanvasMode;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _isVisualCanvasMode
                        ? AppColors.primaryContainer
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isVisualCanvasMode
                            ? Icons.account_tree_outlined
                            : Icons.grid_view_rounded,
                        size: 13,
                        color: _isVisualCanvasMode
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isVisualCanvasMode ? '2D CANVAS' : 'LIST VIEW',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _isVisualCanvasMode
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(StandardsGraphBundle bundle) {
    final categories = <String>{};
    for (final node in bundle.nodes) {
      if (node.id != bundle.rootNode.id) {
        categories.add(node.categoryLabel);
      }
    }

    final chipList = ['ALL', ...categories];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chipList.map((cat) {
            final isSelected = _selectedFilter == cat;
            final count = cat == 'ALL'
                ? bundle.nodes.length - 1
                : bundle.nodes.where((n) => n.categoryLabel == cat).length;
            final label = cat == 'ALL' ? 'ALL ($count)' : '$cat ($count)';

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(label),
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceContainerLow,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.outlineVariant,
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
    );
  }

  Widget _buildCanvasView(
      StandardsGraphBundle bundle, Map<String, Offset> positions) {
    return Stack(
      children: [
        // 2D Gesture Interactive Viewer
        InteractiveViewer(
          transformationController: _transformController,
          boundaryMargin: const EdgeInsets.all(250),
          minScale: 0.35,
          maxScale: 2.5,
          child: SizedBox(
            width: _canvasWidth,
            height: _canvasHeight,
            child: Stack(
              children: [
                // 1. Grid Background & Directed Edges Painter
                CustomPaint(
                  size: const Size(_canvasWidth, _canvasHeight),
                  painter: _GraphCanvasPainter(
                    bundle: bundle,
                    positions: positions,
                    selectedNodeId: _selectedNode?.id,
                    activeFilter: _selectedFilter,
                  ),
                ),

                // 2. Positioned Interactive Nodes
                ...bundle.nodes.map((node) {
                  final pos = positions[node.id] ?? _canvasCenter;
                  final isSelected = _selectedNode?.id == node.id;
                  final isDimmed = _selectedFilter != 'ALL' &&
                      node.id != bundle.rootNode.id &&
                      node.categoryLabel != _selectedFilter;

                  return Positioned(
                    left: pos.dx -
                        (node.type == GraphNodeType.primaryStandard ? 42 : 34),
                    top: pos.dy -
                        (node.type == GraphNodeType.primaryStandard ? 42 : 34),
                    child: Opacity(
                      opacity: isDimmed ? 0.35 : 1.0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedNode = isSelected ? null : node;
                          });
                        },
                        child: _buildNodeWidget(node, isSelected),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Controls overlay: Zoom In, Zoom Out, Reset
        Positioned(
          right: 12,
          top: 12,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  tooltip: 'Zoom In',
                  onPressed: _zoomIn,
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
                const Divider(height: 1, color: Color(0xFF334155)),
                IconButton(
                  icon: const Icon(Icons.remove, size: 18, color: Colors.white),
                  tooltip: 'Zoom Out',
                  onPressed: _zoomOut,
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
                const Divider(height: 1, color: Color(0xFF334155)),
                IconButton(
                  icon: const Icon(Icons.restart_alt, size: 18, color: Color(0xFF38BDF8)),
                  tooltip: 'Reset View',
                  onPressed: _resetView,
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),

        // Floating Selected Node Inspector Drawer
        if (_selectedNode != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _buildSelectedNodeDrawer(
                _selectedNode!, positions[_selectedNode!.id]!),
          ),
      ],
    );
  }

  Widget _buildNodeWidget(StandardsGraphNode node, bool isSelected) {
    Color bg;
    Color border;
    IconData icon;
    double size;

    switch (node.type) {
      case GraphNodeType.primaryStandard:
        bg = const Color(0xFF0B2A4A);
        border = AppColors.secondary;
        icon = Icons.verified;
        size = 84;
        break;
      case GraphNodeType.qco:
        bg = const Color(0xFF78350F);
        border = const Color(0xFFF59E0B);
        icon = Icons.gavel;
        size = 72;
        break;
      case GraphNodeType.supersededStandard:
        bg = const Color(0xFF881337);
        border = const Color(0xFFF43F5E);
        icon = Icons.warning_amber_rounded;
        size = 68;
        break;
      case GraphNodeType.testingProtocol:
        bg = const Color(0xFF134E4A);
        border = const Color(0xFF14B8A6);
        icon = Icons.science_outlined;
        size = 66;
        break;
      case GraphNodeType.rawMaterial:
        bg = const Color(0xFF451A03);
        border = const Color(0xFFD97706);
        icon = Icons.inventory_2_outlined;
        size = 66;
        break;
      case GraphNodeType.alliedStandard:
        bg = const Color(0xFF1E1B4B);
        border = const Color(0xFF818CF8);
        icon = Icons.link;
        size = 66;
        break;
      case GraphNodeType.foreignEquivalent:
        bg = const Color(0xFF7C2D12);
        border = const Color(0xFFFB923C);
        icon = Icons.public;
        size = 70;
        break;
      case GraphNodeType.organization:
        bg = const Color(0xFF1E3A8A);
        border = const Color(0xFF60A5FA);
        icon = Icons.business_outlined;
        size = 68;
        break;
      case GraphNodeType.jurisdiction:
        bg = const Color(0xFF064E3B);
        border = const Color(0xFF34D399);
        icon = Icons.public;
        size = 68;
        break;
      case GraphNodeType.regulation:
        bg = const Color(0xFF581C87);
        border = const Color(0xFFA855F7);
        icon = Icons.policy_outlined;
        size = 68;
        break;
      case GraphNodeType.certification:
        bg = const Color(0xFF14532D);
        border = const Color(0xFF22C55E);
        icon = Icons.verified_user_outlined;
        size = 68;
        break;
      case GraphNodeType.product:
        bg = const Color(0xFF701A75);
        border = const Color(0xFFE879F9);
        icon = Icons.category_outlined;
        size = 66;
        break;
      case GraphNodeType.clause:
      case GraphNodeType.requirement:
        bg = const Color(0xFF312E81);
        border = const Color(0xFF818CF8);
        icon = Icons.article_outlined;
        size = 64;
        break;
      case GraphNodeType.amendment:
      case GraphNodeType.edition:
        bg = const Color(0xFF1F2937);
        border = const Color(0xFF9CA3AF);
        icon = Icons.history_outlined;
        size = 64;
        break;
      default:
        bg = const Color(0xFF1E293B);
        border = const Color(0xFF94A3B8);
        icon = Icons.hub_outlined;
        size = 64;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.secondary : border,
          width: isSelected ? 3.5 : 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSelected ? AppColors.secondary : border).withValues(
              alpha: isSelected ? 0.6 : 0.25,
            ),
            blurRadius: isSelected ? 12 : 6,
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: border, size: size * 0.26),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              node.type == GraphNodeType.qco ? 'QCO 2014' : node.code,
              style: TextStyle(
                fontSize: node.type == GraphNodeType.primaryStandard ? 9 : 8,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedNodeDrawer(StandardsGraphNode node, Offset pos) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF38BDF8)),
                ),
                child: Text(
                  node.categoryLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF38BDF8),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
                onPressed: () => setState(() => _selectedNode = null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            node.code,
            style: AppTextStyles.cardTitle.copyWith(
              color: Colors.white,
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            node.title,
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFFCBD5E1),
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (node.equivalenceDegree != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFB923C).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFFB923C)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sync_alt, size: 12, color: Color(0xFFFB923C)),
                  const SizedBox(width: 4),
                  Text(
                    node.equivalenceDegree!.displayName,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFB923C),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              if (node.evidence != null)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                    ),
                    icon: const Icon(Icons.description_outlined, size: 14),
                    label: const Text(
                      'VIEW EVIDENCE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {
                      EvidenceSheet.show(
                        context,
                        evidence: node.evidence!,
                        title: '${node.code} Statutory Evidence',
                      );
                    },
                  ),
                ),
              if (node.evidence != null) const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF38BDF8),
                    side: const BorderSide(color: Color(0xFF38BDF8)),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                  ),
                  icon: const Icon(Icons.filter_center_focus, size: 14),
                  label: const Text(
                    'CENTER ON NODE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () => _centerOnNode(node, pos),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildLegendItem(AppColors.secondary, 'Primary Standard'),
            const SizedBox(width: 12),
            _buildLegendItem(const Color(0xFFF43F5E), 'Superseded Edition'),
            const SizedBox(width: 12),
            _buildLegendItem(const Color(0xFFF59E0B), 'Mandatory QCO'),
            const SizedBox(width: 12),
            _buildLegendItem(const Color(0xFF14B8A6), 'Testing Protocol'),
            const SizedBox(width: 12),
            _buildLegendItem(const Color(0xFFD97706), 'Raw Material'),
            const SizedBox(width: 12),
            _buildLegendItem(const Color(0xFF818CF8), 'Allied Standard'),
            const SizedBox(width: 12),
            _buildLegendItem(const Color(0xFFFB923C), 'Foreign Standard'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRootCard(StandardsGraphNode root) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CENTRAL GOVERNING ROOT',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w800,
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

  Widget _buildRelationshipCardsList(StandardsGraphBundle bundle) {
    final filteredNodes = bundle.nodes.where((node) {
      if (node.id == bundle.rootNode.id) return false;
      if (_selectedFilter == 'ALL') return true;
      return node.categoryLabel == _selectedFilter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'RELATED STANDARDS (${filteredNodes.length})',
                style: AppTextStyles.pageEyebrow.copyWith(
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Filter: $_selectedFilter',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...filteredNodes.map((node) => _buildNodeCard(node)),
      ],
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
      default:
        borderColor = AppColors.outlineVariant;
        relationBg = AppColors.surfaceContainerLow;
        relationFg = AppColors.textPrimary;
        icon = Icons.hub_outlined;
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
                        Flexible(
                          child: Text(
                            node.relationship,
                            style: AppTextStyles.codeBadge.copyWith(
                              color: relationFg,
                              fontSize: 9.0,
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
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

/// Custom Painter that renders grid backdrop and directed semantic relationship edges.
class _GraphCanvasPainter extends CustomPainter {
  final StandardsGraphBundle bundle;
  final Map<String, Offset> positions;
  final String? selectedNodeId;
  final String activeFilter;

  _GraphCanvasPainter({
    required this.bundle,
    required this.positions,
    required this.selectedNodeId,
    required this.activeFilter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintGridBackground(canvas, size);
    _paintEdges(canvas);
  }

  void _paintGridBackground(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.45)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _paintEdges(Canvas canvas) {
    for (final edge in bundle.edges) {
      final p1 = positions[edge.sourceId];
      final p2 = positions[edge.targetId];
      if (p1 == null || p2 == null) continue;

      final isEdgeSelected =
          edge.sourceId == selectedNodeId || edge.targetId == selectedNodeId;

      final color = _getEdgeColor(edge.relationship);
      final edgePaint = Paint()
        ..color = isEdgeSelected ? Colors.white : color.withValues(alpha: 0.75)
        ..strokeWidth = isEdgeSelected ? 2.5 : 1.6
        ..style = PaintingStyle.stroke;

      // Curved Bezier Path
      final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      final dx = p2.dx - p1.dx;
      final dy = p2.dy - p1.dy;
      final normal = Offset(-dy * 0.12, dx * 0.12);
      final controlPoint = Offset(mid.dx + normal.dx, mid.dy + normal.dy);

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, p2.dx, p2.dy);

      canvas.drawPath(path, edgePaint);

      // Arrowhead at 80% mark along curve
      final t = 0.82;
      final arrowX =
          (1 - t) * (1 - t) * p1.dx + 2 * (1 - t) * t * controlPoint.dx + t * t * p2.dx;
      final arrowY =
          (1 - t) * (1 - t) * p1.dy + 2 * (1 - t) * t * controlPoint.dy + t * t * p2.dy;
      final tangentX = 2 * (1 - t) * (controlPoint.dx - p1.dx) + 2 * t * (p2.dx - controlPoint.dx);
      final tangentY = 2 * (1 - t) * (controlPoint.dy - p1.dy) + 2 * t * (p2.dy - controlPoint.dy);
      final angle = math.atan2(tangentY, tangentX);

      _paintArrowHead(canvas, Offset(arrowX, arrowY), angle, isEdgeSelected ? Colors.white : color);

      // Edge relationship label pill
      _paintEdgeLabel(canvas, Offset(controlPoint.dx, controlPoint.dy), edge.label, color);
    }
  }

  void _paintArrowHead(Canvas canvas, Offset point, double angle, Color color) {
    const arrowLength = 9.0;
    const arrowWidth = 5.0;

    final path = Path();
    final p1 = Offset(
      point.dx - arrowLength * math.cos(angle) + arrowWidth * math.sin(angle),
      point.dy - arrowLength * math.sin(angle) - arrowWidth * math.cos(angle),
    );
    final p2 = Offset(
      point.dx - arrowLength * math.cos(angle) - arrowWidth * math.sin(angle),
      point.dy - arrowLength * math.sin(angle) + arrowWidth * math.cos(angle),
    );

    path.moveTo(point.dx, point.dy);
    path.lineTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  void _paintEdgeLabel(Canvas canvas, Offset pos, String text, Color baseColor) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 7.5,
        fontWeight: FontWeight.w700,
        fontFamily: 'monospace',
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: pos,
        width: textPainter.width + 8,
        height: textPainter.height + 4,
      ),
      const Radius.circular(3),
    );

    final bgPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.7)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(bgRect, bgPaint);
    canvas.drawRRect(bgRect, borderPaint);

    textPainter.paint(
      canvas,
      Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
    );
  }

  Color _getEdgeColor(String relationship) {
    final rel = relationship.toUpperCase();
    if (rel.contains('QCO')) {
      return const Color(0xFFF59E0B);
    } else if (rel.contains('SUPERSED') || rel.contains('OBSOLETE')) {
      return const Color(0xFFF43F5E);
    } else if (rel.contains('TEST')) {
      return const Color(0xFF14B8A6);
    } else if (rel.contains('MATERIAL') || rel.contains('OIL') || rel.contains('CORE')) {
      return const Color(0xFFD97706);
    } else if (rel.contains('ALLIED') || rel.contains('BUSHING') || rel.contains('FITTING')) {
      return const Color(0xFF818CF8);
    } else if (rel.contains('FOREIGN') || rel.contains('EQUIVALENT') || rel.contains('IEC') || rel.contains('ASTM')) {
      return const Color(0xFFFB923C);
    } else {
      return const Color(0xFF38BDF8);
    }
  }

  @override
  bool shouldRepaint(covariant _GraphCanvasPainter oldDelegate) {
    return oldDelegate.selectedNodeId != selectedNodeId ||
        oldDelegate.activeFilter != activeFilter ||
        oldDelegate.bundle != bundle;
  }
}

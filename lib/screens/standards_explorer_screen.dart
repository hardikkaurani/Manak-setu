import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/qco_order.dart';
import '../models/standard.dart';
import '../models/knowledge_state.dart';
import '../repositories/standards_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/knowledge_graph_view.dart';
import '../widgets/status_badge.dart';
import '../widgets/knowledge_state_badge.dart';
import '../widgets/standards_comparison_sheet.dart';
import '../widgets/why_this_standard_sheet.dart';
import '../widgets/amendment_diff_sheet.dart';

/// Standards & Quality Control Orders (QCO) Library and Explorer.
/// P0 Workbench providing:
/// 1. Indian Standards catalog with lifecycle verification, normative bundles,
///    testing methods, raw material specs, and graph linkages.
/// 2. Statutory Quality Control Orders (QCO) gazette registry.
class StandardsExplorerScreen extends StatefulWidget {
  const StandardsExplorerScreen({super.key});

  @override
  State<StandardsExplorerScreen> createState() =>
      _StandardsExplorerScreenState();
}

class _StandardsExplorerScreenState extends State<StandardsExplorerScreen> {
  final StandardsRepository _repo = const DemoStandardsRepository();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qcoSearchController = TextEditingController();

  int _activeTabIndex = 0;
  String _activeFilter = 'ALL';
  List<Standard> _displayedStandards = [];
  List<QcoOrder> _displayedQcoOrders = [];
  final Set<String> _selectedStandardCodesForComparison = {};

  final List<String> _filters = [
    'ALL',
    'CURRENT',
    'OBSOLETE',
    'MANDATORY QCO',
    'ELECTROTECHNICAL',
    'CIVIL',
    'MECHANICAL',
  ];

  void _toggleStandardComparison(String code) {
    setState(() {
      if (_selectedStandardCodesForComparison.contains(code)) {
        _selectedStandardCodesForComparison.remove(code);
      } else {
        if (_selectedStandardCodesForComparison.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 3 standards can be compared simultaneously.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          _selectedStandardCodesForComparison.add(code);
        }
      }
    });
  }

  void _openComparisonSheet() {
    if (_selectedStandardCodesForComparison.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least 2 standards to compare (up to 3).'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final selectedStandards = _selectedStandardCodesForComparison
        .map((code) => _repo.getStandardByCode(code))
        .whereType<Standard>()
        .toList();
    StandardsComparisonSheet.show(context, standards: selectedStandards);
  }

  @override
  void initState() {
    super.initState();
    _displayedStandards = _repo.getAllStandards();
    _displayedQcoOrders = _repo.getAllQcoOrders();
    _searchController.addListener(_onSearchChanged);
    _qcoSearchController.addListener(_onQcoSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _qcoSearchController.removeListener(_onQcoSearchChanged);
    _qcoSearchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _displayedStandards = _repo.searchStandards(
        query: _searchController.text,
        filter: _activeFilter,
      );
    });
  }

  void _onQcoSearchChanged() {
    setState(() {
      _displayedQcoOrders = _repo.searchQcoOrders(_qcoSearchController.text);
    });
  }

  void _selectFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      _displayedStandards = _repo.searchStandards(
        query: _searchController.text,
        filter: _activeFilter,
      );
    });
  }

  void _showStandardDetail(Standard std) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildStandardDetailSheet(std),
    );
  }

  void _openGraphModal(Standard std) {
    final bundle = _repo.getGraphBundleForStandard(std.code);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFF030712),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.hub_outlined, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${std.code} KNOWLEDGE GRAPH',
                      style: AppTextStyles.brandTitle.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF1E293B)),
            Expanded(
              child: KnowledgeGraphView(bundle: bundle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardDetailSheet(Standard std) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INDIAN STANDARD DETAILS',
                        style: AppTextStyles.pageEyebrow.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        std.code,
                        style: AppTextStyles.brandTitle.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Status Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      KnowledgeStateBadge(
                        state: std.status == 'CURRENT'
                            ? KnowledgeState.verified
                            : (std.isObsolete
                                ? KnowledgeState.conflicting
                                : KnowledgeState.inferred),
                      ),
                      StatusBadge(
                        label: std.status,
                        type: std.status == 'CURRENT'
                            ? BadgeType.verified
                            : BadgeType.obsolete,
                      ),
                      if (std.isQcoMandatory)
                        StatusBadge(
                          label: 'MANDATORY QCO',
                          type: BadgeType.critical,
                        ),
                      if (std.harmonized != null)
                        StatusBadge(
                          label: 'HARMONIZED (${std.harmonized!})',
                          type: BadgeType.verified,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(std.title, style: AppTextStyles.cardTitle.copyWith(fontSize: 14)),
                  const SizedBox(height: 14),

                  // Technical Division, Edition & Year
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetaField('TECHNICAL DIVISION', std.division),
                      ),
                      if (std.edition != null)
                        Expanded(
                          child: _buildMetaField('EDITION / REVISION', std.edition!),
                        ),
                      if (std.year != null)
                        Expanded(
                          child: _buildMetaField('YEAR', '${std.year!}'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Committee if available
                  if (std.committee != null) ...[
                    _buildMetaField('SECTIONAL COMMITTEE', std.committee!),
                    const SizedBox(height: 14),
                  ],

                  // Scope & Applicability
                  if (std.scope != null) ...[
                    Text('SCOPE & APPLICABILITY', style: AppTextStyles.sectionEyebrow),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(std.scope!, style: AppTextStyles.bodySmall),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Mandatory Quality Control Order (QCO)
                  if (std.mandatoryQco != null) ...[
                    Text('STATUTORY QUALITY CONTROL ORDER', style: AppTextStyles.sectionEyebrow),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.reviewBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.reviewBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.verified, size: 16, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  std.mandatoryQco!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Mandatory BIS standard under statutory QCO. Uncertified procurement violates GFR-144.',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 10.5,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Raw Material Standards
                  if (std.rawMaterials.isNotEmpty) ...[
                    Text('MANDATED RAW MATERIALS (${std.rawMaterials.length})', style: AppTextStyles.sectionEyebrow),
                    const SizedBox(height: 6),
                    ...std.rawMaterials.map((mat) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xFFD97706)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  mat,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 14),
                  ],

                  // Testing Protocols & Methods
                  if (std.testingMethods.isNotEmpty) ...[
                    Text('MANDATED TESTING METHODS (${std.testingMethods.length})', style: AppTextStyles.sectionEyebrow),
                    const SizedBox(height: 6),
                    ...std.testingMethods.map((test) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.science_outlined, size: 14, color: Color(0xFF14B8A6)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  test,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 14),
                  ],

                  // Gazetted Amendments
                  if (std.amendments.isNotEmpty) ...[
                    Text('GAZETTED AMENDMENTS (${std.amendments.length})', style: AppTextStyles.sectionEyebrow),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: std.amendments.map((amd) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Text(
                            amd,
                            style: AppTextStyles.codeBadge.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Allied & Related Standards
                  if (std.relatedStandards.isNotEmpty) ...[
                    Text('ALLIED STANDARDS & CROSS-REFERENCES', style: AppTextStyles.sectionEyebrow),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: std.relatedStandards.map((rel) {
                        return Chip(
                          label: Text(rel, style: AppTextStyles.codeBadge.copyWith(fontSize: 10)),
                          backgroundColor: AppColors.surfaceContainerLow,
                          side: const BorderSide(color: AppColors.outlineVariant),
                          padding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Analytical Actions: Why this standard & What changed
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryContainer,
                            side: const BorderSide(color: AppColors.primaryContainer),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          icon: const Icon(Icons.help_outline, size: 15),
                          label: const Text(
                            'WHY THIS STANDARD?',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            final rationale = _repo.getWhyThisStandard(std.code);
                            WhyThisStandardSheet.show(context, rationale: rationale);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            side: const BorderSide(color: AppColors.secondary),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          icon: const Icon(Icons.history_toggle_off, size: 15),
                          label: const Text(
                            'WHAT CHANGED?',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            final diff = _repo.getAmendmentDiff(std.code);
                            AmendmentDiffSheet.show(context, diff: diff);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Authoritative Actions: Open in Graph & Use in Spec
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          icon: const Icon(Icons.hub_outlined, size: 16),
                          label: const Text(
                            'OPEN IN GRAPH',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _openGraphModal(std);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          icon: const Icon(Icons.edit_note, size: 16),
                          label: const Text(
                            'USE IN SPEC',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            final preset = std.code.contains('1180')
                                ? 'transformer'
                                : (std.code.contains('4984') ? 'pipe' : 'steel');
                            context.go('/specification-builder?preset=$preset');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.sectionEyebrow),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.cardTitle.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: Container(
          color: AppColors.surface,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _activeTabIndex = 0),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _activeTabIndex == 0
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      'INDIAN STANDARDS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _activeTabIndex == 0
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: _activeTabIndex == 0
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _activeTabIndex = 1),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _activeTabIndex == 1
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      'QUALITY CONTROL ORDERS (QCO)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: _activeTabIndex == 1
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: _activeTabIndex == 1
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _activeTabIndex == 0
          ? _buildStandardsTab()
          : _buildQcoOrdersTab(),
    );
  }

  Widget _buildStandardsTab() {
    return Column(
      children: [
        // Search & Filter Header
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by standard number, keyword, or QCO...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),

              // Category & Status Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((f) {
                    final isSelected = _activeFilter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(
                          f,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceContainerLow,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                        ),
                        onSelected: (_) => _selectFilter(f),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.outlineVariant),

        // Standards List
        Expanded(
          child: _displayedStandards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 40, color: AppColors.outline),
                      const SizedBox(height: 10),
                      Text('No Indian Standards found', style: AppTextStyles.cardTitle),
                      const SizedBox(height: 4),
                      Text(
                        'Try searching for "IS 1180", "Transformers", or "Pipes"',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _displayedStandards.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final std = _displayedStandards[index];
                    return InkWell(
                      onTap: () => _showStandardDetail(std),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: std.isObsolete
                                ? AppColors.obsoleteBorder
                                : AppColors.outlineVariant,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    std.code,
                                    style: AppTextStyles.code.copyWith(
                                      fontSize: 13,
                                      color: std.isObsolete
                                          ? AppColors.obsoleteText
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Wrap(
                                  spacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () => _toggleStandardComparison(std.code),
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _selectedStandardCodesForComparison.contains(std.code)
                                              ? AppColors.secondary.withValues(alpha: 0.2)
                                              : AppColors.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: _selectedStandardCodesForComparison.contains(std.code)
                                                ? AppColors.secondary
                                                : AppColors.outlineVariant,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _selectedStandardCodesForComparison.contains(std.code)
                                                  ? Icons.check_box
                                                  : Icons.check_box_outline_blank,
                                              size: 13,
                                              color: _selectedStandardCodesForComparison.contains(std.code)
                                                  ? AppColors.secondary
                                                  : AppColors.textMuted,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'COMPARE',
                                              style: TextStyle(
                                                fontSize: 9.5,
                                                fontWeight: _selectedStandardCodesForComparison.contains(std.code)
                                                    ? FontWeight.w800
                                                    : FontWeight.w600,
                                                color: _selectedStandardCodesForComparison.contains(std.code)
                                                    ? AppColors.textPrimary
                                                    : AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    StatusBadge(
                                      label: std.status,
                                      type: std.status == 'CURRENT'
                                          ? BadgeType.verified
                                          : BadgeType.obsolete,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (std.replacementCode != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Replace with: ${std.replacementCode!}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.verifiedText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              std.title,
                              style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    std.division,
                                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                                  ),
                                ),
                                if (std.isQcoMandatory)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.qcoBadgeBg,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.qcoBadgeBorder),
                                    ),
                                    child: Text(
                                      'MANDATORY QCO',
                                      style: AppTextStyles.codeBadge.copyWith(
                                        color: AppColors.qcoBadgeText,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1, color: AppColors.outlineVariant),
                            const SizedBox(height: 8),
                            // Quick Action Buttons on Card
                            Row(
                              children: [
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    foregroundColor: AppColors.primaryContainer,
                                  ),
                                  icon: const Icon(Icons.hub_outlined, size: 13),
                                  label: const Text(
                                    'GRAPH',
                                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                                  ),
                                  onPressed: () => _openGraphModal(std),
                                ),
                                const Spacer(),
                                const Text(
                                  'VIEW DETAILS →',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Standards Comparison Bottom Dock
        if (_selectedStandardCodesForComparison.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_selectedStandardCodesForComparison.length}/3 SELECTED',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedStandardCodesForComparison.join(', '),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () => setState(() => _selectedStandardCodesForComparison.clear()),
                    child: const Text('CLEAR', style: TextStyle(fontSize: 10)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.compare_arrows, size: 16),
                    label: const Text(
                      'COMPARE',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                    onPressed: _openComparisonSheet,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQcoOrdersTab() {
    return Column(
      children: [
        // QCO Search Header
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            controller: _qcoSearchController,
            decoration: InputDecoration(
              hintText: 'Search gazetted QCO orders, ministries, standards...',
              prefixIcon: const Icon(Icons.gavel, size: 20),
              suffixIcon: _qcoSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => _qcoSearchController.clear(),
                    )
                  : null,
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.outlineVariant),

        // Statutory Notice Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFFFEF3C7),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'QCOs are issued under Section 16 of the BIS Act, 2016. Non-compliant procurement is non-cognizable violation under GFR Rule 144(xi).',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF92400E),
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // QCO Orders List
        Expanded(
          child: _displayedQcoOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 40, color: AppColors.outline),
                      const SizedBox(height: 10),
                      Text('No Quality Control Orders found', style: AppTextStyles.cardTitle),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _displayedQcoOrders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final qco = _displayedQcoOrders[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF59E0B)),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  qco.scheme.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ),
                              StatusBadge.critical('STATUTORY MANDATE'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            qco.orderName,
                            style: AppTextStyles.cardTitle.copyWith(fontSize: 13.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gazette No: ${qco.gazetteNo}',
                            style: AppTextStyles.code.copyWith(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            qco.ministry,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.event_available, size: 13, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Enforced: ${qco.enforcementDate}',
                                      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'MSME Policy: ${qco.msmeConcession}',
                                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'GOVERNED INDIAN STANDARDS:',
                            style: AppTextStyles.sectionEyebrow.copyWith(fontSize: 10),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: qco.standards.map((s) {
                              return ActionChip(
                                label: Text(
                                  s,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                backgroundColor: AppColors.surfaceContainerLow,
                                side: const BorderSide(color: AppColors.outlineVariant),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  final match = _repo.getStandardByCode(s);
                                  if (match != null) {
                                    _showStandardDetail(match);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

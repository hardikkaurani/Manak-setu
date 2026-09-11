import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../repositories/standards_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/knowledge_graph_view.dart';

/// Standalone Knowledge Graph Screen with standard selector and deep linking.
/// Displays interactive 2D spatial canvas, Cytoscape-aligned nodes, directed edges,
/// and relationship explorer for any specified Indian Standard.
class KnowledgeGraphScreen extends StatefulWidget {
  final String? standardCode;
  final String? presetId;

  const KnowledgeGraphScreen({
    super.key,
    this.standardCode,
    this.presetId,
  });

  @override
  State<KnowledgeGraphScreen> createState() => _KnowledgeGraphScreenState();
}

class _KnowledgeGraphScreenState extends State<KnowledgeGraphScreen> {
  final StandardsRepository _repo = const DemoStandardsRepository();
  late String _selectedStandard;

  final List<Map<String, String>> _availableStandards = [
    {
      'code': 'IS 1180 (Part 1):2014',
      'title': 'Distribution Transformers',
      'preset': 'transformer',
    },
    {
      'code': 'IS 4984:2016',
      'title': 'HDPE Water Supply Pipes',
      'preset': 'pipe',
    },
    {
      'code': 'IS 1786:2008',
      'title': 'TMT Reinforcement Steel',
      'preset': 'steel',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.standardCode != null && widget.standardCode!.isNotEmpty) {
      _selectedStandard = widget.standardCode!;
    } else if (widget.presetId != null) {
      final match = _availableStandards.firstWhere(
        (s) => s['preset'] == widget.presetId,
        orElse: () => _availableStandards.first,
      );
      _selectedStandard = match['code']!;
    } else {
      _selectedStandard = 'IS 1180 (Part 1):2014';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bundle = _repo.getGraphBundleForStandard(_selectedStandard);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Selector & Subheader
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 20),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/standards');
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STANDARDS ONTOLOGY & KNOWLEDGE GRAPH',
                            style: AppTextStyles.pageEyebrow.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            _selectedStandard,
                            style: AppTextStyles.brandTitle.copyWith(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.edit_note, size: 14),
                      label: const Text(
                        'SPEC BUILDER',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        final currentMatch = _availableStandards.firstWhere(
                          (s) => s['code'] == _selectedStandard,
                          orElse: () => _availableStandards.first,
                        );
                        context.go('/specification-builder?preset=${currentMatch['preset']}');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Standard Selector Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _availableStandards.map((std) {
                      final isSelected = _selectedStandard == std['code'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(std['code']!),
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
                              _selectedStandard = std['code']!;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),

          // Knowledge Graph View
          Expanded(
            child: KnowledgeGraphView(
              bundle: bundle,
            ),
          ),
        ],
      ),
    );
  }
}

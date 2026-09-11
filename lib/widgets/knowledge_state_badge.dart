import 'package:flutter/material.dart';

import '../models/knowledge_state.dart';
import '../theme/app_text_styles.dart';

/// Institutional Badge representing an explicit Knowledge State:
/// VERIFIED, INFERRED, UNKNOWN, CONFLICTING, OUT-OF-COVERAGE.
class KnowledgeStateBadge extends StatelessWidget {
  final KnowledgeState state;
  final bool showIcon;
  final bool isCompact;

  const KnowledgeStateBadge({
    super.key,
    required this.state,
    this.showIcon = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: state.description,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 6 : 8,
          vertical: isCompact ? 2 : 3,
        ),
        decoration: BoxDecoration(
          color: state.backgroundColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: state.borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showIcon) ...[
              Icon(
                state.icon,
                size: isCompact ? 10 : 12,
                color: state.textColor,
              ),
              SizedBox(width: isCompact ? 3 : 4),
            ],
            Text(
              state.label,
              style: AppTextStyles.caption.copyWith(
                color: state.textColor,
                fontWeight: FontWeight.w800,
                fontSize: isCompact ? 9 : 10,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

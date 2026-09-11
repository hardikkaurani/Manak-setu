import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum BadgeType {
  verified,
  reviewRequired,
  nonCompliant,
  obsolete,
  critical,
  high,
  info,
  ready,
}

/// Restrained, institutional status badge used for verification states and regulatory tags.
class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final bool isMonospace;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.isMonospace = true,
    this.icon,
  });

  factory StatusBadge.verified([String label = 'VERIFIED']) => StatusBadge(
    label: label,
    type: BadgeType.verified,
    icon: Icons.check_circle_outline,
  );

  factory StatusBadge.review([String label = 'REVIEW REQUIRED']) => StatusBadge(
    label: label,
    type: BadgeType.reviewRequired,
    icon: Icons.warning_amber_outlined,
  );

  factory StatusBadge.nonCompliant([String label = 'NON-COMPLIANT']) =>
      StatusBadge(
        label: label,
        type: BadgeType.nonCompliant,
        icon: Icons.cancel_outlined,
      );

  factory StatusBadge.obsolete([String label = 'OBSOLETE']) =>
      StatusBadge(label: label, type: BadgeType.obsolete);

  factory StatusBadge.critical([String label = 'CRITICAL']) => StatusBadge(
    label: label,
    type: BadgeType.critical,
    icon: Icons.error_outline,
  );

  factory StatusBadge.high([String label = 'HIGH']) =>
      StatusBadge(label: label, type: BadgeType.high);

  factory StatusBadge.ready([String label = 'GFR-144 & BIS READY']) =>
      StatusBadge(
        label: label,
        type: BadgeType.ready,
        icon: Icons.verified_outlined,
      );

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (type) {
      case BadgeType.verified:
        bg = AppColors.verifiedBg;
        fg = AppColors.verifiedText;
        border = AppColors.verifiedBorder;
        break;
      case BadgeType.reviewRequired:
        bg = AppColors.reviewBg;
        fg = AppColors.reviewText;
        border = AppColors.reviewBorder;
        break;
      case BadgeType.nonCompliant:
      case BadgeType.critical:
        bg = AppColors.nonCompliantBg;
        fg = AppColors.nonCompliantText;
        border = AppColors.nonCompliantBorder;
        break;
      case BadgeType.high:
        bg = AppColors.secondaryLight;
        fg = AppColors.secondary;
        border = AppColors.secondaryContainer;
        break;
      case BadgeType.obsolete:
        bg = AppColors.obsoleteBg;
        fg = AppColors.obsoleteText;
        border = AppColors.obsoleteBorder;
        break;
      case BadgeType.info:
      case BadgeType.ready:
        bg = AppColors.surfaceContainerLow;
        fg = AppColors.primaryContainer;
        border = AppColors.primaryContainer.withValues(alpha: 0.3);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style:
                  (isMonospace
                          ? AppTextStyles.codeBadge
                          : AppTextStyles.caption)
                      .copyWith(color: fg, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

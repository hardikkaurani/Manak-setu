import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Institutional card container with crisp borders and optional header.
class SectionCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final String? eyebrow;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final Color? borderColor;

  const SectionCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.eyebrow,
    this.icon,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 16),
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasHeader = title != null || eyebrow != null || trailing != null;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor ?? AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasHeader) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: AppColors.primaryContainer),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (eyebrow != null) ...[
                          Text(eyebrow!, style: AppTextStyles.sectionEyebrow),
                          const SizedBox(height: 2),
                        ],
                        if (title != null)
                          Text(title!, style: AppTextStyles.sectionTitle),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(subtitle!, style: AppTextStyles.caption),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.outlineVariant,
            ),
          ],
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

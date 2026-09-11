import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Explicit epistemic knowledge states for government procurement intelligence.
/// Distinguishes:
/// - "we know this" (verified)
/// - "we think this" (inferred)
/// - "we don't have enough evidence" (unknown)
/// - "authoritative information conflicts" (conflicting)
/// - "our dataset does not cover this case" (outOfCoverage)
enum KnowledgeState {
  verified,
  inferred,
  unknown,
  conflicting,
  outOfCoverage;

  String get label {
    switch (this) {
      case KnowledgeState.verified:
        return 'VERIFIED';
      case KnowledgeState.inferred:
        return 'INFERRED';
      case KnowledgeState.unknown:
        return 'UNKNOWN';
      case KnowledgeState.conflicting:
        return 'CONFLICTING';
      case KnowledgeState.outOfCoverage:
        return 'OUT-OF-COVERAGE';
    }
  }

  String get description {
    switch (this) {
      case KnowledgeState.verified:
        return 'Authoritative BIS standard & gazetted rule match with verbatim evidence.';
      case KnowledgeState.inferred:
        return 'Technical derivation from specification parameters and product scope.';
      case KnowledgeState.unknown:
        return 'Insufficient evidence in current index — mandatory human verification required.';
      case KnowledgeState.conflicting:
        return 'Contradictory candidate standards or incompatible parameters detected.';
      case KnowledgeState.outOfCoverage:
        return 'Product or regulation is outside indexed Indian Standards coverage.';
    }
  }

  Color get textColor {
    switch (this) {
      case KnowledgeState.verified:
        return AppColors.verifiedText;
      case KnowledgeState.inferred:
        return const Color(0xFF0369A1); // Sky-700
      case KnowledgeState.unknown:
        return const Color(0xFFB45309); // Amber-700
      case KnowledgeState.conflicting:
        return AppColors.nonCompliantText;
      case KnowledgeState.outOfCoverage:
        return const Color(0xFF475569); // Slate-600
    }
  }

  Color get backgroundColor {
    switch (this) {
      case KnowledgeState.verified:
        return AppColors.verifiedBg;
      case KnowledgeState.inferred:
        return const Color(0xFFE0F2FE); // Sky-100
      case KnowledgeState.unknown:
        return const Color(0xFFFEF3C7); // Amber-100
      case KnowledgeState.conflicting:
        return AppColors.nonCompliantBg;
      case KnowledgeState.outOfCoverage:
        return const Color(0xFFF1F5F9); // Slate-100
    }
  }

  Color get borderColor {
    switch (this) {
      case KnowledgeState.verified:
        return AppColors.verifiedBorder;
      case KnowledgeState.inferred:
        return const Color(0xFFBAE6FD); // Sky-200
      case KnowledgeState.unknown:
        return const Color(0xFFFDE68A); // Amber-200
      case KnowledgeState.conflicting:
        return AppColors.nonCompliantBorder;
      case KnowledgeState.outOfCoverage:
        return const Color(0xFFCBD5E1); // Slate-300
    }
  }

  IconData get icon {
    switch (this) {
      case KnowledgeState.verified:
        return Icons.verified;
      case KnowledgeState.inferred:
        return Icons.auto_awesome;
      case KnowledgeState.unknown:
        return Icons.help_outline;
      case KnowledgeState.conflicting:
        return Icons.error_outline;
      case KnowledgeState.outOfCoverage:
        return Icons.grid_off_outlined;
    }
  }
}

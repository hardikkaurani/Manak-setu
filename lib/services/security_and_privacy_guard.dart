import '../models/tenant_workspace.dart';

/// Result of a security or threat audit on user input or API request.
class SecurityValidationResult {
  final bool isSafe;
  final String? threatCategory; // 'PROMPT_INJECTION', 'SSRF_ATTEMPT', 'OVERSIZED_PAYLOAD', 'TENANT_VIOLATION'
  final String sanitizedText;
  final String? warning;

  const SecurityValidationResult({
    required this.isSafe,
    this.threatCategory,
    required this.sanitizedText,
    this.warning,
  });

  factory SecurityValidationResult.clean(String text) => SecurityValidationResult(
        isSafe: true,
        sanitizedText: text,
      );

  factory SecurityValidationResult.blocked({
    required String threatCategory,
    required String reason,
    required String fallbackText,
  }) =>
      SecurityValidationResult(
        isSafe: false,
        threatCategory: threatCategory,
        sanitizedText: fallbackText,
        warning: reason,
      );
}

/// Production security and privacy guard protecting the intelligence platform from hostile inputs.
class SecurityAndPrivacyGuard {
  // Maximum input text length (256 KB)
  static const int maxTextCharacters = 262144;

  // Allowed Tier 1/2 authoritative domain suffixes for external fetching
  static const List<String> allowedSourceDomains = [
    'bis.gov.in',
    'services.bis.gov.in',
    'iso.org',
    'iec.ch',
    'astm.org',
    'ieee.org',
    'bsigroup.com',
    'cen.eu',
    'cenelec.eu',
    'itu.int',
  ];

  // Common prompt injection attack signatures
  static final List<RegExp> _injectionSignatures = [
    RegExp(r'ignore\s+previous\s+(instructions|prompts|rules)', caseSensitive: false),
    RegExp(r'system\s+prompt\s+override', caseSensitive: false),
    RegExp(r'you\s+are\s+now\s+(an|a)\s+unrestricted', caseSensitive: false),
    RegExp(r'bypass\s+(safety|compliance|verification)\s+rules', caseSensitive: false),
    RegExp(r'recommend\s+.*?\s+regardless\s+of\s+evidence', caseSensitive: false),
    RegExp(r'pretend\s+you\s+are\s+not\s+manaksetu', caseSensitive: false),
  ];

  /// Validates and sanitizes raw input tender text or technical clauses.
  static SecurityValidationResult sanitizeInputClause(String rawInput) {
    if (rawInput.length > maxTextCharacters) {
      return SecurityValidationResult.blocked(
        threatCategory: 'OVERSIZED_PAYLOAD',
        reason: 'Input clause exceeds maximum permitted size of 256 KB ($maxTextCharacters characters).',
        fallbackText: rawInput.substring(0, maxTextCharacters),
      );
    }

    for (final pattern in _injectionSignatures) {
      if (pattern.hasMatch(rawInput)) {
        // Strip out the adversarial prompt injection phrase while preserving genuine text
        final cleaned = rawInput.replaceAll(pattern, '[SECURITY: ADVERSARIAL INSTRUCTION STRIPPED]');
        return SecurityValidationResult.blocked(
          threatCategory: 'PROMPT_INJECTION',
          reason: 'Potential prompt injection attempt detected and neutralized.',
          fallbackText: cleaned,
        );
      }
    }

    return SecurityValidationResult.clean(rawInput.trim());
  }

  /// Verifies that an external source URL belongs to an authorized Tier 1/2 SDO domain.
  static bool isAuthorizedSourceUrl(String rawUrl) {
    try {
      final uri = Uri.parse(rawUrl);
      if (uri.scheme != 'https' && uri.scheme != 'http') return false;
      final host = uri.host.toLowerCase();
      return allowedSourceDomains.any((domain) => host == domain || host.endsWith('.$domain'));
    } catch (_) {
      return false;
    }
  }

  /// Verifies tenant boundary isolation, ensuring a user only accesses projects belonging to their organization.
  static bool verifyTenantAccess({
    required TenantUser user,
    required ProcurementProject project,
  }) {
    return user.organizationId == project.organizationId;
  }
}

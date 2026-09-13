import 'package:flutter/foundation.dart';

/// User roles within an enterprise or government organization.
enum UserRole {
  owner('Owner', 'Full administrative authority and organization management'),
  admin('Administrator', 'Manages users, projects, and enterprise settings'),
  engineer('Technical Lead / Engineer', 'Authors specifications and performs deep technical analysis'),
  procurement('Procurement Officer', 'Manages tenders, BoQs, and compliance evaluations'),
  reviewer('Vigilance / Reviewer', 'Reviews, approves, flags, or overrides audit findings'),
  viewer('Auditor / Viewer', 'Read-only access to published analyses and audit trails');

  final String displayName;
  final String description;
  const UserRole(this.displayName, this.description);

  bool get canApprove => this == UserRole.owner || this == UserRole.admin || this == UserRole.reviewer;
  bool get canOverride => this == UserRole.owner || this == UserRole.reviewer;
  bool get canEdit => this != UserRole.viewer;
}

/// Represents an immutable audit trail event for compliance and legal accountability.
@immutable
class AuditEvent {
  final String id;
  final String tenantId;
  final String? projectId;
  final String? analysisId;
  final String userId;
  final String userName;
  final UserRole userRole;
  final String action; // e.g. 'OVERRIDE_DEFECT', 'ACCEPT_RECOMMENDATION', 'FLAG_FOR_LEGAL'
  final String details;
  final String? previousState;
  final String? newState;
  final DateTime timestamp;
  final String? clientIpHash;

  const AuditEvent({
    required this.id,
    required this.tenantId,
    this.projectId,
    this.analysisId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.details,
    this.previousState,
    this.newState,
    required this.timestamp,
    this.clientIpHash,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenant_id': tenantId,
        'project_id': projectId,
        'analysis_id': analysisId,
        'user_id': userId,
        'user_name': userName,
        'user_role': userRole.name,
        'action': action,
        'details': details,
        'previous_state': previousState,
        'new_state': newState,
        'timestamp': timestamp.toIso8601String(),
        'client_ip_hash': clientIpHash,
      };
}

/// Represents an enterprise or government tenant organization.
class Organization {
  final String id;
  final String name;
  final String jurisdictionId; // e.g. 'IN', 'US', 'EU'
  final String tier; // 'ENTERPRISE', 'GOVERNMENT', 'LABORATORY', 'CONSULTANCY'
  final DateTime createdAt;
  final Map<String, dynamic> settings;

  const Organization({
    required this.id,
    required this.name,
    this.jurisdictionId = 'IN',
    this.tier = 'ENTERPRISE',
    required this.createdAt,
    this.settings = const {},
  });
}

/// Represents an enterprise user.
class TenantUser {
  final String id;
  final String organizationId;
  final String email;
  final String fullName;
  final UserRole role;
  final bool isActive;

  const TenantUser({
    required this.id,
    required this.organizationId,
    required this.email,
    required this.fullName,
    required this.role,
    this.isActive = true,
  });
}

/// Container for a procurement initiative (e.g. 'Metro Rail Procurement', 'Substation Modernization').
class ProcurementProject {
  final String id;
  final String organizationId;
  final String title;
  final String department;
  final String description;
  final List<String> attachedTenderIds;
  final List<String> referencedStandardCodes;
  final List<String> analysisIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'ACTIVE', 'IN_REVIEW', 'ARCHIVED'

  const ProcurementProject({
    required this.id,
    required this.organizationId,
    required this.title,
    required this.department,
    required this.description,
    this.attachedTenderIds = const [],
    this.referencedStandardCodes = const [],
    this.analysisIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.status = 'ACTIVE',
  });

  ProcurementProject copyWith({
    String? title,
    String? department,
    String? description,
    List<String>? attachedTenderIds,
    List<String>? referencedStandardCodes,
    List<String>? analysisIds,
    DateTime? updatedAt,
    String? status,
  }) {
    return ProcurementProject(
      id: id,
      organizationId: organizationId,
      title: title ?? this.title,
      department: department ?? this.department,
      description: description ?? this.description,
      attachedTenderIds: attachedTenderIds ?? this.attachedTenderIds,
      referencedStandardCodes: referencedStandardCodes ?? this.referencedStandardCodes,
      analysisIds: analysisIds ?? this.analysisIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }
}

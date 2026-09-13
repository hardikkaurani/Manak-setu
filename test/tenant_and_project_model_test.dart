import 'package:flutter_test/flutter_test.dart';
import 'package:manaksetu/models/tenant_workspace.dart';
import 'package:manaksetu/models/multi_factor_confidence.dart';
import 'package:manaksetu/services/security_and_privacy_guard.dart';

void main() {
  group('Tenant, Project & RBAC Architecture Tests', () {
    test('Verifies RBAC permissions across enterprise user roles', () {
      expect(UserRole.owner.canApprove, isTrue);
      expect(UserRole.owner.canOverride, isTrue);
      expect(UserRole.reviewer.canApprove, isTrue);
      expect(UserRole.reviewer.canOverride, isTrue);
      expect(UserRole.engineer.canApprove, isFalse);
      expect(UserRole.engineer.canEdit, isTrue);
      expect(UserRole.viewer.canEdit, isFalse);
      expect(UserRole.viewer.canApprove, isFalse);
    });

    test('Verifies tenant boundary isolation preventing cross-tenant access', () {
      final userOrg1 = const TenantUser(
        id: 'usr-1',
        organizationId: 'org-delhi-metro',
        email: 'engineer@delhimetro.in',
        fullName: 'Chief Engineer DMRC',
        role: UserRole.engineer,
      );

      final projectOrg1 = ProcurementProject(
        id: 'proj-dmrc-1',
        organizationId: 'org-delhi-metro',
        title: 'Phase IV Traction Substation',
        department: 'Electrical Traction',
        description: '33 kV Traction transformers',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final projectOrg2 = ProcurementProject(
        id: 'proj-mws-1',
        organizationId: 'org-municipal-water',
        title: 'Water Supply Augmentation',
        department: 'Civil Engineering',
        description: 'HDPE pipelines',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Same tenant access allowed
      expect(SecurityAndPrivacyGuard.verifyTenantAccess(user: userOrg1, project: projectOrg1), isTrue);

      // Cross-tenant access strictly blocked
      expect(SecurityAndPrivacyGuard.verifyTenantAccess(user: userOrg1, project: projectOrg2), isFalse);
    });

    test('Verifies immutable AuditEvent creation on human review override', () {
      final audit = AuditEvent(
        id: 'audit-evt-1',
        tenantId: 'org-delhi-metro',
        projectId: 'proj-dmrc-1',
        analysisId: 'ana-8842',
        userId: 'usr-1',
        userName: 'Chief Engineer DMRC',
        userRole: UserRole.reviewer,
        action: 'OVERRIDE_NON_COMPLIANT_FINDING',
        details: 'Approved higher temperature rise variance based on site water-cooled heat exchangers.',
        previousState: 'NON_COMPLIANT',
        newState: 'ACCEPTED_WITH_VARIANCE',
        timestamp: DateTime.now(),
        clientIpHash: 'sha256:ip-hash-verified',
      );

      final json = audit.toJson();
      expect(json['user_role'], 'reviewer');
      expect(json['action'], 'OVERRIDE_NON_COMPLIANT_FINDING');
      expect(json['previous_state'], 'NON_COMPLIANT');
      expect(json['new_state'], 'ACCEPTED_WITH_VARIANCE');
    });

    test('MultiFactorConfidence properly decomposes certainty and maps decision state', () {
      // High confidence across all 4 orthogonal axes -> VERIFIED
      final verifiedConf = MultiFactorConfidence.evaluate(
        retrievalScore: 0.95,
        technicalScore: 0.90,
        lifecycleScore: 0.95,
        evidenceScore: 0.95,
      );
      expect(verifiedConf.overallDecisionState, OverallDecisionState.verified);
      expect(verifiedConf.overallDecisionState.isReliableForProcurement, isTrue);
      expect(verifiedConf.compositeScore, greaterThanOrEqualTo(0.90));

      // Out-of-coverage boundary flag
      final outOfCoverageConf = MultiFactorConfidence.evaluate(
        retrievalScore: 0.90,
        technicalScore: 0.85,
        lifecycleScore: 0.80,
        evidenceScore: 0.80,
        isOutOfCoverage: true,
      );
      expect(outOfCoverageConf.overallDecisionState, OverallDecisionState.outOfCoverage);

      // Conflicting state
      final conflictConf = MultiFactorConfidence.evaluate(
        retrievalScore: 0.90,
        technicalScore: 0.90,
        lifecycleScore: 0.20, // Obsolete / superseded conflict
        evidenceScore: 0.90,
        hasConflict: true,
      );
      expect(conflictConf.overallDecisionState, OverallDecisionState.conflicting);
    });
  });
}

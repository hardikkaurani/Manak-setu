import '../models/standard.dart';
import '../models/evidence.dart';
import '../models/compliance_finding.dart';
import '../models/tender_analysis.dart';
import '../models/specification.dart';
import '../models/standards_graph_node.dart';
import '../models/specification_build_step.dart';
import '../models/requirement.dart';
import '../models/boq_item.dart';
import '../models/review_action.dart';
import '../models/specification_parameter.dart';
import '../models/qco_order.dart';
import '../models/knowledge_state.dart';
import '../models/decision_trace.dart';
import '../models/why_this_standard.dart';
import '../models/amendment_diff.dart';

/// Single source of truth for all canonical mock data in the ManakSetu demo.
/// Strictly transcribed from `manaksetu_mock_data.md` and repo reference data
/// (standards_master.json, qco_master.json, cvc_rules.json).
abstract final class DemoData {
  // Officer Profile
  static const String officerName = 'Priya Rao';
  static const String officerRole = 'Procurement Officer';
  static const String officerId = 'DES-8842';

  // Authoritative Evaluation Presets
  static const List<Map<String, String>> presets = [
    {
      'id': 'pipe',
      'label': 'Preset 1: Water Supply HDPE Pipeline',
      'title': 'HDPE Water Supply Pipes',
      'department': 'Municipal Water Supply Directorate',
      'badge': 'Obsolete IS 4984:1995 + ASTM D3035 + Brand Lock-in',
      'clause': '''TECHNICAL SPECIFICATIONS FOR HDPE PIPELINE AUGMENTATION:
1. Pipes shall strictly conform to IS 4984:1995 (Fourth Revision) or ASTM D3035.
2. Only Supreme or Astral make pipes shall be accepted by the Engineer-in-Charge.
3. Pipe raw material grade shall be PE-80, pressure rating PN 10, SDR 11.
4. BIS ISI Mark under Pipes QCO 2020 is optional for imported consignments.
5. Minimum annual average financial turnover of bidder must be Rs 650 Crores.''',
    },
    {
      'id': 'transformer',
      'label': 'Preset 2: Substation Distribution Transformer',
      'title': 'Distribution Transformers',
      'department': 'Municipal Water Supply Directorate',
      'badge': 'IS 1180:1989 + Siemens/ABB Make + Transformers QCO',
      'clause':
          '''TECHNICAL SPECIFICATIONS FOR SUBSTATION DISTRIBUTION TRANSFORMERS:
1. Supply of 500 kVA, 11 kV / 433 V, 3-Phase 50 Hz outdoor oil-immersed distribution transformer.
2. Transformer design, manufacture and testing shall conform strictly to IS 1180:1989.
3. Proprietary OEM components: only ABB or Siemens high-voltage bushings permitted.
4. Testing of transformer insulating oil as per obsolete IS 335:1993.
5. Compliance with Electrical Transformers (Quality Control) Order is left to bidder declaration.''',
    },
    {
      'id': 'steel',
      'label': 'Preset 3: Civil Works TMT Rebars',
      'title': 'TMT Reinforcement Steel',
      'department': 'Central Public Works Department (CPWD)',
      'badge': 'ASTM A615 + Tata Tiscon/Jindal Panther Lock-in',
      'clause': '''TECHNICAL SPECIFICATIONS FOR CIVIL WORKS REINFORCEMENT STEEL:
1. Supply of 50 Metric Tonnes Thermo-Mechanically Treated (TMT) bars 16mm diameter.
2. Reinforcement steel shall strictly be Tata Tiscon or Jindal Panther make only.
3. Material shall conform to ASTM A615 Grade 60 without domestic Indian Standard equivalence.
4. Bidders must have sole authorized distributor certificate directly from primary producer.
5. Steel Quality Control Order (QCO) Scheme-I BIS certification may be submitted post-award.''',
    },
  ];

  // Statutory Checkpoints
  static const List<Map<String, String>> statutoryCheckpoints = [
    {
      'title': 'GFR 2017 Rule 144(vii)',
      'description':
          'Technical specifications must reference Indian Standards wherever formulated.',
    },
    {
      'title': 'Section 16 BIS Act, 2016',
      'description':
          '679+ QCO categories mandate compulsory ISI / CRS mark before public procurement.',
    },
    {
      'title': 'CVC Anti-Tailoring Directives',
      'description':
          'Prohibits citing proprietary OEM brand names without domestic equivalence.',
    },
  ];

  // ==========================================
  // PRESET 1: WATER SUPPLY HDPE PIPELINE
  // ==========================================
  static final TenderAnalysis pipeAnalysis = TenderAnalysis(
    id: 'NIT-MWS-4984',
    title: 'HDPE Water Supply Pipes',
    department: 'Municipal Water Supply Directorate',
    inputClause: presets[0]['clause']!,
    compliancePercentage: 8,
    status: 'NON_COMPLIANT',
    criticalDefects: 2,
    highRiskViolations: 3,
    summaryText:
        'Audited tender: 2 critical defects, 3 high-risk violations. Overall compliance evaluated at 8%. Immediate rectification required before tender publication.',
    detectedStandards: [
      Standard(
        code: 'IS 4984:1995',
        title:
            'High Density Polyethylene Pipes for Water Supply — Specification',
        status: 'OBSOLETE',
        replacementCode: 'IS 4984:2016',
        division: 'Civil Engineering',
        amendments: [
          'Amendment No. 1 (2018)',
          'Amendment No. 2 (2021)',
        ],
        mandatoryQco: 'Pipes and Fittings (Quality Control) Order, 2021',
        advisory:
            "OBSOLETE STANDARD CITATION: Standard 'IS 4984:1995' was superseded by 'IS 4984:2016'. Citing obsolete standards restricts competitive bidding and violates CVC / GFR 2017 guidelines. Replace with 'IS 4984:2016' and active amendments: Amendment No. 1 (2018), Amendment No. 2 (2021).",
        evidence: const Evidence(
          standardCode: 'IS 4984:2016',
          defectiveStandardCode: 'IS 4984:1995',
          replacementStandardCode: 'IS 4984:2016',
          clause: '1.1',
          page: '2',
          sourceFile: '4984_2016_hdpe_water_pipes.pdf',
          textExcerpt:
              'Pipes shall strictly conform to the latest active revision IS 4984:2016 along with all gazetted amendments.',
        ),
      ),
      Standard(
        code: 'ASTM D3035',
        title:
            'Standard Specification for Polyethylene (PE) Plastic Pipe (DR-PR) Based on Controlled Outside Diameter',
        status: 'OBSOLETE',
        replacementCode: 'IS 4984:2016',
        division: 'Civil Engineering',
        amendments: const [],
        advisory:
            "FOREIGN STANDARD CITATION: Foreign standard 'ASTM D3035' cited without domestic equivalence clause. GFR 2017 Rule 144(vii) prohibits mandating foreign standards when national standards exist. Convert to equivalent Indian Standard 'IS 4984:2016'.",
        evidence: const Evidence(
          standardCode: 'IS 4984:2016',
          defectiveStandardCode: 'ASTM D3035',
          replacementStandardCode: 'IS 4984:2016',
          clause: 'GFR Rule 144(vii)',
          page: '1',
          sourceFile: 'foreign_mapping.json',
          textExcerpt:
              'GFR 2017 Rule 144(vii) prohibits mandating foreign standard ASTM D3035 when national standard IS 4984:2016 is in force.',
        ),
      ),
    ],
    cvcFlags: [
      const ComplianceFinding(
        severity: FindingSeverity.critical,
        title:
            'Prohibition of Proprietary Brand Names in Tender Specifications',
        matchedEntity: 'Supreme / Astral',
        description:
            'Specific brand names without generic technical performance parameters qualify as tender tailoring under CVC anti-corruption guidelines.',
        statutoryAction:
            "Strip proprietary brand names. Replace with generic functional parameters and relevant Indian Standard (IS 4984:2016) with 'or equivalent certified to IS'.",
        standardCitation: 'IS 4984:2016',
        evidence: Evidence(
          standardCode: 'IS 4984:2016',
          defectiveStandardCode: 'Proprietary Brands: Supreme / Astral',
          replacementStandardCode: 'Generic Specification under IS 4984',
          clause: 'CVC OM 03-05-1-CTE-9',
          sourceFile: 'CVC_Anti_Tailoring_OM_03_05_1.pdf',
          textExcerpt:
              'Procuring authorities shall avoid brand names or specific trade makes in tenders. Functional specifications conforming to Indian Standards must be cited.',
        ),
      ),
      const ComplianceFinding(
        severity: FindingSeverity.critical,
        title:
            'Missing Mandatory BIS Quality Control Order (QCO) Statutory Clause',
        matchedEntity: 'Pipes QCO 2020 is optional',
        description:
            'Procuring items governed by mandatory QCOs without compulsory BIS certification is a criminal regulatory offense under the BIS Act, 2016.',
        statutoryAction:
            "Insert mandatory clause: 'The supplied goods must bear valid BIS Standard Mark (ISI mark) under Pipes and Fittings (Quality Control) Order, 2021 (S.O. 4321(E)) and the bidder must hold a valid BIS license on the date of bid submission.'",
        standardCitation: 'Section 16 BIS Act, 2016',
        evidence: Evidence(
          standardCode: 'Pipes and Fittings QCO 2021',
          clause: 'Notification S.O. 4321(E)',
          sourceFile: 'QCO_DPIIT_Plastic_Pipes_2021.pdf',
          textExcerpt:
              'No person shall manufacture, store for sale, sell or distribute pipes which do not conform to IS 4984 and bear the Standard Mark under a license from the Bureau.',
        ),
      ),
      const ComplianceFinding(
        severity: FindingSeverity.high,
        title: 'Citation of Obsolete, Superseded, or Withdrawn BIS Standards',
        matchedEntity: 'IS 4984:1995',
        description:
            'Citing obsolete revisions restricts bidder participation and violates statutory public procurement quality mandates.',
        statutoryAction:
            'Update standard to the latest active revision and ensure compliance with all gazetted amendments.',
        standardCitation: 'GFR 2017 Rule 144(vii)',
        evidence: Evidence(
          standardCode: 'IS 4984:2016',
          defectiveStandardCode: 'IS 4984:1995',
          replacementStandardCode: 'IS 4984:2016',
          clause: 'Foreword',
          sourceFile: '4984_2016_hdpe_water_pipes.pdf',
          textExcerpt:
              'The standard IS 4984:1995 was superseded by IS 4984:2016 (Fifth Revision). Citing superseded editions is not permissible for public procurement.',
        ),
      ),
      const ComplianceFinding(
        severity: FindingSeverity.high,
        title:
            'Foreign Standards Cited Without National Equivalence Clause',
        matchedEntity: 'ASTM D3035',
        description:
            'Mandating foreign standards when national standards exist unfairly discriminates against domestic Indian manufacturers and violates GFR 144(vii).',
        statutoryAction:
            'Convert foreign standard to the harmonized Indian Standard (IS 4984:2016) equivalent.',
        standardCitation: 'GFR 2017 Rule 144(vii)',
      ),
      const ComplianceFinding(
        severity: FindingSeverity.warning,
        title:
            'Excessive or Tailored Financial / Technical Pre-Qualification Criteria',
        matchedEntity: 'Rs 650 Crores',
        description:
            'Disproportionate financial turnover or restrictive single-vendor eligibility conditions unduly restrict fair competition.',
        statutoryAction:
            'Align turnover criteria with CVC formula (typically 30% to 50% of estimated annual tender value).',
        standardCitation: 'CVC PQC Guidelines',
      ),
    ],
    lifecycleStatus:
        'WITHDRAWN / SUPERSEDED (IS 4984:1995 superseded by IS 4984:2016)',
    regulatoryQcoSummary:
        'Pipes and Fittings (Quality Control) Order, 2021 mandates Scheme-I ISI mark. Self-declaration or exemption for imported items is prohibited.',
    recommendedActionSummary:
        'Upgrade to IS 4984:2016 PE-100, remove Supreme/Astral trade lock-in, enforce mandatory ISI mark CM/L operational license verification.',
    detectedRequirements: [
      Requirement(
        id: 'p-req-1',
        parameterName: 'Product Type',
        specifiedValue: 'HDPE Pressure Pipes for Water Supply',
        status: RequirementStatus.verified,
        statutoryCitation: 'IS 4984:2016 Clause 1.1',
      ),
      Requirement(
        id: 'p-req-2',
        parameterName: 'Design Standard',
        specifiedValue: 'IS 4984:1995 or ASTM D3035',
        status: RequirementStatus.obsoleteCitation,
        statutoryCitation: 'GFR 2017 Rule 144(vii)',
        recommendedValue: 'IS 4984:2016 (Fifth Revision)',
        reason:
            'Superseded edition and foreign standard without domestic equivalence.',
      ),
      Requirement(
        id: 'p-req-3',
        parameterName: 'Approved Brands',
        specifiedValue: 'Supreme or Astral make only',
        status: RequirementStatus.brandLockIn,
        statutoryCitation: 'CVC OM No. 03-05-01',
        recommendedValue: 'Generic specification with valid BIS ISI license',
        reason: 'Restricts public procurement competition.',
      ),
      Requirement(
        id: 'p-req-4',
        parameterName: 'Raw Material Grade & SDR',
        specifiedValue: 'PE-80, PN 10, SDR 11',
        status: RequirementStatus.reviewRequired,
        statutoryCitation: 'IS 4984:2016 Table 2',
        recommendedValue: 'PE-100, PN 10, SDR 11',
        reason:
            'PE-100 provides superior long-term hydrostatic strength (MRS 10.0 MPa).',
      ),
      Requirement(
        id: 'p-req-5',
        parameterName: 'BIS ISI Certification',
        specifiedValue: 'Optional for imported consignments',
        status: RequirementStatus.obsoleteCitation,
        statutoryCitation: 'Section 16 BIS Act 2016',
        recommendedValue: 'Compulsory Scheme-I Standard Mark',
        reason:
            'QCO 2021 mandates ISI certification without import exemptions.',
      ),
    ],
    specificationGaps: [
      'Missing internal hydrostatic pressure test requirements (100h at 20°C and 165h at 80°C per IS 4984 Table 4).',
      'Missing melt flow index (MFI) and carbon black content testing per IS 2530:1963.',
      'Missing mandatory third-party inspection (RITES / CIPET) protocol for NABL laboratory testing.',
    ],
    relatedStandards: [
      Standard(
        code: 'IS 2530:1963',
        title: 'Methods for Testing Plastics — Polyethylene',
        status: 'CURRENT',
        division: 'Chemical',
      ),
      Standard(
        code: 'IS 4984:2016',
        title:
            'High Density Polyethylene Pipes for Water Supply — Specification',
        status: 'CURRENT',
        division: 'Civil Engineering',
      ),
    ],
  );

  // ==========================================
  // PRESET 2: SUBSTATION DISTRIBUTION TRANSFORMER
  // ==========================================
  static final TenderAnalysis transformerAnalysis = TenderAnalysis(
    id: 'NIT-DES-8842',
    title: 'Distribution Transformers',
    department: 'Municipal Water Supply Directorate',
    inputClause: presets[1]['clause']!,
    compliancePercentage: 5,
    status: 'NON_COMPLIANT',
    criticalDefects: 2,
    highRiskViolations: 3,
    summaryText:
        'Audited tender: 2 critical defects, 3 high-risk violations. Overall compliance evaluated at 5%. Immediate rectification required before tender publication.',
    detectedStandards: [
      Standard(
        code: 'IS 1180:1989',
        title:
            'Outdoor Type Three-Phase Distribution Transformers Up to and Including 2500 kVA, 33 kV – Specification',
        status: 'OBSOLETE',
        replacementCode: 'IS 1180 (Part 1):2014',
        division: 'Electrotechnical',
        amendments: [
          'Amendment No. 1 (2016)',
          'Amendment No. 2 (2019)',
          'Amendment No. 3 (2021)',
          'Amendment No. 4 (2023)',
        ],
        mandatoryQco: 'Distribution Transformers (Quality Control) Order, 2014',
        advisory:
            "OBSOLETE STANDARD CITATION: Standard 'IS 1180:1989' was superseded by 'IS 1180 (Part 1):2014'. Citing obsolete standards restricts competitive bidding and violates CVC / GFR 2017 guidelines. Replace with 'IS 1180 (Part 1):2014' and active amendments: Amendment No. 1 (2016), Amendment No. 2 (2019), Amendment No. 3 (2021), Amendment No. 4 (2023).",
        evidence: const Evidence(
          standardCode: 'IS 1180 (Part 1):2014',
          defectiveStandardCode: 'IS 1180:1989',
          replacementStandardCode: 'IS 1180 (Part 1):2014',
          clause: '1.1',
          page: '3',
          sourceFile: '1180_part1_2014_amd4.pdf',
          textExcerpt:
              'The materials, components, and finished goods supplied under this contract shall strictly conform to the latest active revision of IS 1180 (Part 1):2014 along with all gazetted amendments.',
        ),
      ),
      Standard(
        code: 'IS 335:1993',
        title: 'New Insulating Oils – Specification',
        status: 'OBSOLETE',
        replacementCode: 'IS 335:2018',
        division: 'Electrotechnical',
        amendments: ['Amendment No. 1 (2020)'],
        mandatoryQco: 'Transformers QCO 2014',
        advisory:
            "OBSOLETE STANDARD CITATION: Standard 'IS 335:1993' was superseded by 'IS 335:2018'. Citing obsolete standards restricts competitive bidding and violates CVC / GFR 2017 guidelines. Replace with 'IS 335:2018' and active amendments: Amendment No. 1 (2020).",
        evidence: const Evidence(
          standardCode: 'IS 335:2018',
          defectiveStandardCode: 'IS 335:1993',
          replacementStandardCode: 'IS 335:2018',
          clause: '4.2',
          page: '5',
          sourceFile: '335_2018_insulating_oils.pdf',
          textExcerpt:
              'Testing of transformer insulating oil shall conform to the latest active requirements specified under IS 335:2018.',
        ),
      ),
    ],
    cvcFlags: [
      const ComplianceFinding(
        severity: FindingSeverity.critical,
        title:
            'Prohibition of Proprietary Brand Names in Tender Specifications',
        matchedEntity: 'ABB',
        description:
            'Specific brand names without generic technical performance parameters qualify as tender tailoring under CVC anti-corruption guidelines.',
        statutoryAction:
            "Strip proprietary brand names. Replace with generic functional parameters and relevant Indian Standard (IS) with 'or equivalent certified to IS'.",
        standardCitation: 'IS 1180 (Part 1):2014',
        evidence: Evidence(
          standardCode: 'IS 1180 (Part 1):2014',
          defectiveStandardCode: 'Proprietary Brand: ABB',
          replacementStandardCode: 'Generic Specification under IS 1180',
          clause: 'General Requirements',
          sourceFile: 'CVC_Anti_Tailoring_OM_03_05_1.pdf',
          textExcerpt:
              'Procuring authorities shall avoid brand names or specific trade makes in tenders. Functional specifications conforming to Indian Standards must be cited.',
        ),
      ),
      const ComplianceFinding(
        severity: FindingSeverity.critical,
        title:
            'Prohibition of Proprietary Brand Names in Tender Specifications',
        matchedEntity: 'Siemens',
        description:
            'Specific brand names without generic technical performance parameters qualify as tender tailoring under CVC anti-corruption guidelines.',
        statutoryAction:
            "Strip proprietary brand names. Replace with generic functional parameters and relevant Indian Standard (IS) with 'or equivalent certified to IS'.",
        standardCitation: 'IS 1180 (Part 1):2014',
        evidence: Evidence(
          standardCode: 'IS 1180 (Part 1):2014',
          defectiveStandardCode: 'Proprietary Brand: Siemens',
          replacementStandardCode: 'Generic Specification under IS 1180',
          clause: 'General Requirements',
          sourceFile: 'CVC_Anti_Tailoring_OM_03_05_1.pdf',
          textExcerpt:
              'Stipulation of vendor-specific proprietary bushings restricts competitive bidding and violates GFR 2017 Rule 144.',
        ),
      ),
      const ComplianceFinding(
        severity: FindingSeverity.high,
        title: 'Citation of Obsolete, Superseded, or Withdrawn BIS Standards',
        matchedEntity: 'IS 1180:1989 & IS 335:1993',
        description:
            'Citing obsolete revisions restricts bidder participation and violates statutory public procurement quality mandates.',
        statutoryAction:
            'Update standard to the latest active revision and ensure compliance with all gazetted amendments.',
        standardCitation: 'GFR 2017 Rule 144(vii)',
        evidence: Evidence(
          standardCode: 'IS 1180 (Part 1):2014',
          defectiveStandardCode: 'IS 1180:1989',
          replacementStandardCode: 'IS 1180 (Part 1):2014',
          clause: '1.1',
          page: '3',
          sourceFile: '1180_part1_2014_amd4.pdf',
          textExcerpt:
              'The standard IS 1180:1989 was superseded by IS 1180 (Part 1):2014. Citing superseded editions is not permissible for public procurement.',
        ),
      ),
    ],
    lifecycleStatus:
        'SUPERSEDED (IS 1180:1989 superseded by IS 1180 (Part 1):2014 Amd 1-4)',
    regulatoryQcoSummary:
        'Distribution Transformers (Quality Control) Order, 2014 (S.O. 1621(E)) mandates compulsory Scheme-I (ISI Mark) license before technical bid opening.',
    recommendedActionSummary:
        'Replace obsolete IS 1180:1989 with IS 1180 (Part 1):2014, strip ABB/Siemens lock-in, inject mandatory QCO CM/L qualification requirement, update insulating oil to IS 335:2018.',
    detectedRequirements: [
      Requirement(
        id: 't-req-1',
        parameterName: 'Nominal Rating & Voltage',
        specifiedValue: '500 kVA, 11 kV / 433 V, 3-Phase 50 Hz',
        status: RequirementStatus.verified,
        statutoryCitation: 'IS 1180 (Part 1):2014 Table 1',
      ),
      Requirement(
        id: 't-req-2',
        parameterName: 'Governing Standard',
        specifiedValue: 'IS 1180:1989',
        status: RequirementStatus.obsoleteCitation,
        statutoryCitation: 'GFR 2017 Rule 144(vii)',
        recommendedValue: 'IS 1180 (Part 1):2014 + Amendments 1-4',
        reason:
            'Superseded by Bureau of Indian Standards; restricts competitive bidding.',
      ),
      Requirement(
        id: 't-req-3',
        parameterName: 'High Voltage Bushings',
        specifiedValue: 'ABB or Siemens make only',
        status: RequirementStatus.brandLockIn,
        statutoryCitation: 'CVC OM No. 03-05-01',
        recommendedValue: 'Conforming to IS 2099 / IS 3347 (Brand-neutral)',
        reason:
            'Tailored vendor clause restricting competitive domestic procurement.',
      ),
      Requirement(
        id: 't-req-4',
        parameterName: 'Insulating Oil Standard',
        specifiedValue: 'IS 335:1993',
        status: RequirementStatus.obsoleteCitation,
        statutoryCitation: 'IS 335:2018',
        recommendedValue: 'IS 335:2018 (New Insulating Oils)',
        reason: 'Superseded standard cited for dielectric fluid.',
      ),
      Requirement(
        id: 't-req-5',
        parameterName: 'QCO Compliance Declaration',
        specifiedValue: 'Left to bidder self-declaration',
        status: RequirementStatus.reviewRequired,
        statutoryCitation: 'Section 16 BIS Act, 2016',
        recommendedValue: 'Compulsory valid CM/L ISI license at bid opening',
        reason: 'Summary rejection mandated for non-certified supplies.',
      ),
    ],
    specificationGaps: [
      'Missing maximum total loss limits at 50% and 100% loading as per IS 1180 (Part 1):2014 Table 3 / BEE Energy Efficiency Star-1 Level.',
      'Missing Type Test certification for Short Circuit Withstand Test from an accredited test laboratory (CPRI / ERDA).',
      'Missing temperature rise limits (40°C in oil, 45°C by resistance) per IS 1180 Clause 7.',
    ],
    relatedStandards: [
      Standard(
        code: 'IS 335:2018',
        title: 'New Insulating Oils — Specification',
        status: 'CURRENT',
        division: 'Electrotechnical',
      ),
      Standard(
        code: 'IS 2099:2018',
        title:
            'Bushings for Alternating Voltages Above 1000 V — Specification',
        status: 'CURRENT',
        division: 'Electrotechnical',
      ),
      Standard(
        code: 'IS 2026 (Part 1):2011',
        title: 'Power Transformers — Part 1: General',
        status: 'CURRENT',
        division: 'Electrotechnical',
      ),
    ],
  );

  // ==========================================
  // PRESET 3: CIVIL WORKS TMT REBARS
  // ==========================================
  static final TenderAnalysis steelAnalysis = TenderAnalysis(
    id: 'NIT-CPWD-1786',
    title: 'TMT Reinforcement Steel',
    department: 'Central Public Works Department (CPWD)',
    inputClause: presets[2]['clause']!,
    compliancePercentage: 12,
    status: 'NON_COMPLIANT',
    criticalDefects: 2,
    highRiskViolations: 3,
    summaryText:
        'Audited tender: 2 critical defects, 3 high-risk violations. Overall compliance evaluated at 12%. Immediate rectification required before tender publication.',
    detectedStandards: [
      Standard(
        code: 'ASTM A615 Grade 60',
        title:
            'Standard Specification for Deformed and Plain Carbon-Steel Bars for Concrete Reinforcement',
        status: 'OBSOLETE',
        replacementCode: 'IS 1786:2008',
        division: 'Civil & Structural Engineering',
        amendments: [
          'Amendment No. 1 (2012)',
          'Amendment No. 2 (2017)',
          'Amendment No. 3 (2019)',
        ],
        mandatoryQco: 'Steel and Steel Products (Quality Control) Order, 2012',
        advisory:
            "FOREIGN STANDARD CITATION: Foreign standard 'ASTM A615' cited without domestic equivalence clause. GFR 2017 Rule 144(vii) prohibits mandating foreign standard ASTM A615 when national standard IS 1786:2008 (High strength deformed steel bars Fe500D) is in force. Convert to equivalent Indian Standard 'IS 1786:2008'.",
        evidence: const Evidence(
          standardCode: 'IS 1786:2008',
          defectiveStandardCode: 'ASTM A615 Grade 60',
          replacementStandardCode: 'IS 1786:2008',
          clause: 'Scope & Cl. 1.1',
          page: '1',
          sourceFile: '1786_2008_tmt_rebars.pdf',
          textExcerpt:
              'High strength deformed steel bars and wires for concrete reinforcement shall conform strictly to IS 1786:2008 Grade Fe 500D.',
        ),
      ),
    ],
    cvcFlags: [
      const ComplianceFinding(
        severity: FindingSeverity.critical,
        title:
            'Prohibition of Proprietary Brand Names in Tender Specifications',
        matchedEntity: 'Tata Tiscon / Jindal Panther',
        description:
            'Specific brand names without generic technical performance parameters qualify as tender tailoring under CVC anti-corruption guidelines.',
        statutoryAction:
            "Strip proprietary brand names. Replace with generic functional parameters and relevant Indian Standard (IS 1786:2008 Grade Fe 500D) with 'or equivalent certified to IS'.",
        standardCitation: 'IS 1786:2008',
        evidence: Evidence(
          standardCode: 'IS 1786:2008',
          defectiveStandardCode:
              'Proprietary Brands: Tata Tiscon / Jindal Panther',
          replacementStandardCode:
              'Generic Specification Fe 500D per IS 1786:2008',
          clause: 'CVC OM 03-05-1-CTE-9',
          sourceFile: 'CVC_Anti_Tailoring_OM_03_05_1.pdf',
          textExcerpt:
              'Procuring authorities shall avoid brand names or specific trade makes in tenders. Functional specifications conforming to Indian Standards must be cited.',
        ),
      ),
      const ComplianceFinding(
        severity: FindingSeverity.critical,
        title:
            'Missing Mandatory BIS Quality Control Order (QCO) Statutory Clause',
        matchedEntity: 'QCO certification may be submitted post-award',
        description:
            'Under the Steel and Steel Products (Quality Control) Order, procuring non-BIS certified TMT rebars is a punishable regulatory offense under Section 16 of the BIS Act, 2016. Post-award deferral is strictly illegal.',
        statutoryAction:
            "Insert mandatory clause: 'Valid BIS license number (CM/L) under Scheme-I for IS 1786:2008 must be submitted with the technical bid.'",
        standardCitation: 'Section 16 BIS Act, 2016',
        evidence: Evidence(
          standardCode: 'Steel and Steel Products QCO 2012',
          clause: 'Notification S.O. 463(E) / S.O. 2400(E)',
          sourceFile: 'QCO_Ministry_of_Steel_2012.pdf',
          textExcerpt:
              'No person shall manufacture, store for sale, sell or distribute steel products which do not conform to IS 1786 and bear the Standard Mark under a license from the Bureau.',
        ),
      ),
      const ComplianceFinding(
        severity: FindingSeverity.high,
        title:
            'Foreign Standards Cited Without National Equivalence Clause',
        matchedEntity: 'ASTM A615 Grade 60',
        description:
            'Mandating foreign standards when national standards exist unfairly discriminates against domestic Indian manufacturers and violates GFR 144(vii).',
        statutoryAction:
            'Mandate IS 1786:2008 Grade Fe 500D with mandatory BIS license under Steel QCO 2012.',
        standardCitation: 'GFR 2017 Rule 144(vii)',
      ),
      const ComplianceFinding(
        severity: FindingSeverity.warning,
        title:
            'Restrictive Single-Vendor Pre-Qualification Criteria',
        matchedEntity: 'sole authorized distributor certificate',
        description:
            'Disproportionate or restrictive single-vendor eligibility conditions unduly restrict fair competition.',
        statutoryAction:
            'Remove exclusive distributor stipulation per CVC guidelines; allow all authorized stockists and secondary re-rollers using BIS-certified billets.',
        standardCitation: 'CVC PQC Guidelines',
      ),
    ],
    lifecycleStatus:
        'FOREIGN CITATION (ASTM A615 cited without domestic IS 1786 equivalence)',
    regulatoryQcoSummary:
        'Steel and Steel Products (Quality Control) Order, 2020 mandates Scheme-I BIS license for all TMT reinforcement bars before tender bid opening.',
    recommendedActionSummary:
        'Specify IS 1786:2008 Grade Fe 500D, eliminate Tata/Jindal brand monopoly, remove single-distributor barrier, mandate active ISI license at bid opening.',
    detectedRequirements: [
      Requirement(
        id: 's-req-1',
        parameterName: 'Product Nomenclature',
        specifiedValue: '50 MT Thermo-Mechanically Treated (TMT) bars 16mm',
        status: RequirementStatus.verified,
        statutoryCitation: 'IS 1786:2008 Clause 1.1',
      ),
      Requirement(
        id: 's-req-2',
        parameterName: 'Governing Standard',
        specifiedValue: 'ASTM A615 Grade 60',
        status: RequirementStatus.obsoleteCitation,
        statutoryCitation: 'GFR 2017 Rule 144(vii)',
        recommendedValue: 'IS 1786:2008 Grade Fe 500D',
        reason:
            'Foreign standard cited without mandatory domestic Indian Standard equivalence.',
      ),
      Requirement(
        id: 's-req-3',
        parameterName: 'Primary Make / Brands',
        specifiedValue: 'Tata Tiscon or Jindal Panther only',
        status: RequirementStatus.brandLockIn,
        statutoryCitation: 'CVC OM No. 03-05-01',
        recommendedValue:
            'Primary/secondary producers with BIS license (Brand-neutral)',
        reason: 'Explicit brand citation violates CVC anti-tailoring directives.',
      ),
      Requirement(
        id: 's-req-4',
        parameterName: 'Vendor PQC Condition',
        specifiedValue: 'Sole authorized distributor certificate',
        status: RequirementStatus.brandLockIn,
        statutoryCitation: 'CVC PQC Guidelines',
        recommendedValue: 'Open to verified authorized distributors and stockists',
        reason: 'Creates vendor lock-in restricting fair competition.',
      ),
      Requirement(
        id: 's-req-5',
        parameterName: 'Steel QCO Verification',
        specifiedValue: 'Scheme-I BIS certificate may be submitted post-award',
        status: RequirementStatus.reviewRequired,
        statutoryCitation: 'Section 16 BIS Act, 2016',
        recommendedValue: 'Compulsory active BIS license on date of bid opening',
        reason: 'Post-award submission is unlawful under mandatory Steel QCO.',
      ),
    ],
    specificationGaps: [
      'Missing minimum yield strength (500 MPa) and total elongation (16.0%) test standards under IS 1786 Table 3.',
      'Missing chemical limits on maximum Carbon (0.25%), Sulphur (0.040%), and Phosphorus (0.040%).',
      'Missing 0.2 percent proof stress verification and bend/rebend test protocol per IS 1786 Clause 9.',
    ],
    relatedStandards: [
      Standard(
        code: 'IS 1786:2008',
        title:
            'High Strength Deformed Steel Bars and Wires for Concrete Reinforcement — Specification (Fe 500D)',
        status: 'CURRENT',
        division: 'Civil Engineering',
      ),
      Standard(
        code: 'IS 432 (Part 1):1982',
        title:
            'Mild Steel and Medium Tensile Steel Bars and Hard-Drawn Steel Wire for Concrete Reinforcement',
        status: 'CURRENT',
        division: 'Civil Engineering',
      ),
    ],
  );

  // ==========================================
  // UNKNOWN / OUT-OF-COVERAGE DEMO ANALYSIS
  // (Failure Mode Hardening & Explicit Knowledge State)
  // ==========================================
  static final TenderAnalysis outOfCoverageAnalysis = TenderAnalysis(
    id: 'NIT-UNKNOWN-000',
    title: 'Unindexed Commodity / Specification',
    department: 'General Procurement Directorate',
    inputClause: 'Unindexed tender specification',
    compliancePercentage: 0,
    status: 'UNKNOWN',
    criticalDefects: 0,
    highRiskViolations: 0,
    summaryText:
        'COMMODITY OUT-OF-COVERAGE: The submitted technical parameters do not match any indexed Indian Standard in the local offline engineering catalog. Statutory compliance cannot be verified without authoritative BIS portal lookup or manual standards committee review.',
    detectedStandards: const [],
    cvcFlags: const [
      ComplianceFinding(
        severity: FindingSeverity.warning,
        title: 'Out-Of-Coverage Commodity / Insufficient Evidence',
        matchedEntity: 'Unrecognized Clause Text',
        description:
            'No matching BIS Gazette Schedule or QCO order could be conclusively retrieved. Statutory verification requires authoritative manual submission.',
        statutoryAction:
            'Initiate formal inquiry on BIS Manakonline (manakonline.in) or reference central government procurement schedule.',
        standardCitation: 'BIS Act 2016 Section 16 & CVC Guidelines',
      ),
    ],
    lifecycleStatus:
        'OUT-OF-COVERAGE / UNKNOWN: No applicable Indian Standard currently mapped in offline database.',
    regulatoryQcoSummary:
        'QCO status unknown — product category is not present in the current offline demo gazette registry.',
    recommendedActionSummary:
        'Perform manual scrutiny via BIS Manakonline portal or consult the relevant Sectional Committee (CED/ETD/MED).',
    detectedRequirements: const [
      Requirement(
        id: 'u-req-1',
        parameterName: 'Category Classification',
        specifiedValue: 'Unindexed Commodity / Clause',
        status: RequirementStatus.reviewRequired,
        reason:
            'Statutory coverage is currently limited to civil, electrotechnical, and mechanical infrastructure presets.',
      ),
    ],
    relatedStandards: const [],
    specificationGaps: const [
      'Commodity specification not mapped to any Bureau of Indian Standards Sectional Committee schedule.',
      'Mandatory QCO enforcement cannot be evaluated offline for unindexed goods.'
    ],
  );


  // ==========================================
  // PROGRESSIVE BUILD STEPS PER PRESET
  // (Authoritative scores: scoreBefore and scoreAfter)
  // ==========================================
  static final List<SpecificationBuildStep> transformerBuildSteps = [
    const SpecificationBuildStep(
      id: 'T1',
      stepNumber: 1,
      title: 'Obsolete Standard Replacement: IS 1180:1989 ➔ IS 1180 (Part 1):2014',
      problem:
          'Tender mandates compliance with superseded standard IS 1180:1989, violating GFR 2017 Rule 144.',
      defectiveSnippet:
          'Transformer design, manufacture and testing shall conform strictly to IS 1180:1989.',
      replacementSnippet:
          'Transformer design, manufacture and testing shall strictly conform to the latest active revision of IS 1180 (Part 1):2014 along with Amendments 1, 2, 3 & 4 and BEE Energy Efficiency Star Labeling.',
      explanation:
          'Mandates active Indian Standard under GFR 144(vii) and enforces active Amendments 1 to 4.',
      scoreBefore: 5,
      scoreAfter: 30,
      targetSectionId: 'sec-2',
      evidence: Evidence(
        standardCode: 'IS 1180 (Part 1):2014',
        defectiveStandardCode: 'IS 1180:1989',
        replacementStandardCode: 'IS 1180 (Part 1):2014',
        clause: '1.1',
        page: '3',
        sourceFile: '1180_part1_2014_amd4.pdf',
        textExcerpt:
            'The materials, components, and finished goods supplied under this contract shall strictly conform to the latest active revision of IS 1180 (Part 1):2014 along with all gazetted amendments.',
      ),
    ),
    const SpecificationBuildStep(
      id: 'T2',
      stepNumber: 2,
      title: 'Insulating Oil Standard Upgrade: IS 335:1993 ➔ IS 335:2018',
      problem:
          'Testing of transformer insulating oil cites withdrawn standard IS 335:1993.',
      defectiveSnippet:
          'Testing of transformer insulating oil as per obsolete IS 335:1993.',
      replacementSnippet:
          'Testing of transformer insulating oil strictly as per active standard IS 335:2018 (breakdown voltage ≥ 60 kV and moisture content ≤ 15 ppm).',
      explanation:
          'Aligns dielectric testing with active IS 335:2018 requirements.',
      scoreBefore: 30,
      scoreAfter: 55,
      targetSectionId: 'sec-4',
      evidence: Evidence(
        standardCode: 'IS 335:2018',
        defectiveStandardCode: 'IS 335:1993',
        replacementStandardCode: 'IS 335:2018',
        clause: '4.2',
        page: '5',
        sourceFile: '335_2018_insulating_oils.pdf',
        textExcerpt:
            'Testing of transformer insulating oil shall conform to active standard IS 335:2018.',
      ),
    ),
    const SpecificationBuildStep(
      id: 'T3',
      stepNumber: 3,
      title:
          'CVC Brand Neutrality: Remove Proprietary ABB / Siemens Bushings',
      problem:
          'Mandating ABB or Siemens high-voltage bushings constitutes restrictive tender tailoring under CVC OM 03-05-1.',
      defectiveSnippet:
          'Proprietary OEM components: only ABB or Siemens high-voltage bushings permitted.',
      replacementSnippet:
          'High-voltage and low-voltage porcelain bushings shall conform generically to IS 3347 (Parts 1 to 8). Tender specification is strictly generic and manufacturer-neutral.',
      explanation:
          'Eliminates proprietary brand restriction per CVC anti-tailoring guidelines and cites generic IS 3347.',
      scoreBefore: 55,
      scoreAfter: 75,
      targetSectionId: 'sec-5',
      evidence: Evidence(
        standardCode: 'CVC OM 03-05-1-CTE-9',
        defectiveStandardCode: 'Proprietary ABB / Siemens Bushings',
        replacementStandardCode: 'Generic Bushings per IS 3347',
        clause: 'Para 2.1 Anti-Tailoring',
        page: '1',
        sourceFile: 'CVC_Anti_Tailoring_OM_03_05_1.pdf',
        textExcerpt:
            'Tender conditions should be generic and not tailored to favor any particular firm. Brand names or proprietary trade makes shall not be specified.',
      ),
    ),
    const SpecificationBuildStep(
      id: 'T4',
      stepNumber: 4,
      title: 'Statutory QCO Enforcement: Mandatory Scheme-I ISI Mark',
      problem:
          'Leaving QCO compliance to bidder declaration violates Section 16 of the BIS Act, 2016.',
      defectiveSnippet:
          'Compliance with Electrical Transformers (Quality Control) Order is left to bidder declaration.',
      replacementSnippet:
          'Pursuant to Distribution Transformers (Quality Control) Order, 2014 (S.O. 1621(E)), all units must compulsorily bear the Standard Mark (Scheme-I ISI Mark) with active BIS CM/L license at bid opening.',
      explanation:
          'Enforces statutory BIS license (CM/L) and summary technical rejection for non-compliance under Section 16 BIS Act.',
      scoreBefore: 75,
      scoreAfter: 100,
      targetSectionId: 'sec-3',
      evidence: Evidence(
        standardCode: 'Distribution Transformers QCO 2014',
        clause: 'Section 16 & 29 BIS Act 2016',
        page: 'Gazette S.O. 1621(E)',
        sourceFile: 'QCO_DPIIT_Transformers_2014.pdf',
        textExcerpt:
            'No person shall manufacture, store for sale, sell or distribute distribution transformers which do not conform to IS 1180 (Part 1) and bear the Standard Mark under a license from the Bureau.',
      ),
    ),
  ];

  static final List<SpecificationBuildStep> pipeBuildSteps = [
    const SpecificationBuildStep(
      id: 'W1',
      stepNumber: 1,
      title:
          'Obsolete Standard & Foreign Code Replacement: IS 4984:1995 & ASTM D3035 ➔ IS 4984:2016',
      problem:
          'Tender cites superseded IS 4984:1995 and foreign ASTM D3035 without national equivalence, violating GFR Rule 144.',
      defectiveSnippet:
          'Pipes shall strictly conform to IS 4984:1995 (Fourth Revision) or ASTM D3035.',
      replacementSnippet:
          'Pipes shall strictly conform to the latest active revision IS 4984:2016 (Fifth Revision) with Amendments 1 (2018) and 2 (2021). Foreign standard citations are harmonized to IS 4984:2016.',
      explanation:
          'Harmonizes foreign ASTM code to primary Indian Standard IS 4984:2016 and updates obsolete revision.',
      scoreBefore: 8,
      scoreAfter: 40,
      targetSectionId: 'sec-2',
      evidence: Evidence(
        standardCode: 'IS 4984:2016',
        defectiveStandardCode: 'IS 4984:1995 / ASTM D3035',
        replacementStandardCode: 'IS 4984:2016',
        clause: '1.1',
        page: '2',
        sourceFile: '4984_2016_hdpe_water_pipes.pdf',
        textExcerpt:
            'Pipes shall strictly conform to the latest active revision IS 4984:2016 for potable water distribution.',
      ),
    ),
    const SpecificationBuildStep(
      id: 'W2',
      stepNumber: 2,
      title:
          'CVC Anti-Tailoring: Remove Supreme / Astral Brand Bias & Specify Generic PE-100',
      problem:
          'Restricting supply to Supreme or Astral make pipes constitutes illegal brand tailoring under CVC OM 03-05-1.',
      defectiveSnippet:
          'Only Supreme or Astral make pipes shall be accepted by the Engineer-in-Charge. Pipe raw material grade shall be PE-80, pressure rating PN 10, SDR 11.',
      replacementSnippet:
          'Specification is strictly manufacturer-neutral. Raw material shall be 100% virgin generic PE-100 polymer conforming to IS 7328:2020 under pressure rating PN 10 (SDR 11). Any qualified manufacturer certified under IS 4984:2016 is eligible.',
      explanation:
          'Excises brand names, upgrades resin to PE-100 per IS 7328:2020, and opens competition to all certified manufacturers.',
      scoreBefore: 40,
      scoreAfter: 70,
      targetSectionId: 'sec-5',
      evidence: Evidence(
        standardCode: 'CVC OM 03-05-1-CTE-9',
        defectiveStandardCode: 'Proprietary Brands: Supreme / Astral',
        replacementStandardCode: 'Generic PE-100 Specification',
        clause: 'Para 2.1 Anti-Tailoring',
        page: '1',
        sourceFile: 'CVC_Anti_Tailoring_OM_03_05_1.pdf',
        textExcerpt:
            'Tender conditions should be generic and not tailored to favor any particular firm. Brand names or proprietary trade makes shall not be specified.',
      ),
    ),
    const SpecificationBuildStep(
      id: 'W3',
      stepNumber: 3,
      title:
          'Statutory QCO Enforcement: Compulsory Scheme-I ISI Mark under Pipes QCO 2021',
      problem:
          'Allowing optional BIS ISI Mark for imported consignments is a statutory offense under Section 16 BIS Act 2016.',
      defectiveSnippet:
          'BIS ISI Mark under Pipes QCO 2020 is optional for imported consignments. Minimum annual average financial turnover of bidder must be Rs 650 Crores.',
      replacementSnippet:
          'Pursuant to Pipes and Fittings (Quality Control) Order, 2021 (S.O. 4321(E)), all HDPE pipes must compulsorily bear the BIS Standard Mark (Scheme-I ISI Mark). Bidders must hold active BIS CM/L license at bid submission. Turnover criteria aligned with CVC guidelines.',
      explanation:
          'Enforces compulsory ISI mark under S.O. 4321(E) and eliminates illegal exemption.',
      scoreBefore: 70,
      scoreAfter: 100,
      targetSectionId: 'sec-3',
      evidence: Evidence(
        standardCode: 'Pipes and Fittings QCO 2021',
        clause: 'Notification S.O. 4321(E)',
        sourceFile: 'QCO_DPIIT_Plastic_Pipes_2021.pdf',
        textExcerpt:
            'No person shall manufacture, store for sale, sell or distribute pipes which do not conform to IS 4984 and bear the Standard Mark under a license from the Bureau.',
      ),
    ),
  ];

  static final List<SpecificationBuildStep> steelBuildSteps = [
    const SpecificationBuildStep(
      id: 'S1',
      stepNumber: 1,
      title:
          'Foreign Standard Conversion: ASTM A615 Grade 60 ➔ IS 1786:2008 Grade Fe 500D',
      problem:
          'Mandating foreign standard ASTM A615 without domestic equivalence violates GFR 2017 Rule 144(vii).',
      defectiveSnippet:
          'Material shall conform to ASTM A615 Grade 60 without domestic Indian Standard equivalence.',
      replacementSnippet:
          'Reinforcement steel shall strictly conform to primary Indian Standard IS 1786:2008 (Fourth Revision) Grade Fe 500D with Amendments 1, 2 & 3. Minimum yield stress 500 N/mm² and elongation ≥ 16%.',
      explanation:
          'Harmonizes foreign ASTM code to governing national standard IS 1786:2008 Fe 500D per GFR 144(vii).',
      scoreBefore: 12,
      scoreAfter: 45,
      targetSectionId: 'sec-2',
      evidence: Evidence(
        standardCode: 'IS 1786:2008',
        defectiveStandardCode: 'ASTM A615 Grade 60',
        replacementStandardCode: 'IS 1786:2008',
        clause: 'Scope & Cl. 1.1',
        page: '1',
        sourceFile: '1786_2008_tmt_rebars.pdf',
        textExcerpt:
            'High strength deformed steel bars and wires for concrete reinforcement shall conform strictly to IS 1786:2008.',
      ),
    ),
    const SpecificationBuildStep(
      id: 'S2',
      stepNumber: 2,
      title:
          'CVC Anti-Tailoring: Strip Tata Tiscon / Jindal Panther & Exclusive Distributor Stipulation',
      problem:
          'Citing proprietary steel brands and mandating sole distributor certificates restricts competition and violates CVC directives.',
      defectiveSnippet:
          'Reinforcement steel shall strictly be Tata Tiscon or Jindal Panther make only. Bidders must have sole authorized distributor certificate directly from primary producer.',
      replacementSnippet:
          'Specification is 100% manufacturer-neutral. Any primary producer or secondary re-roller producing TMT bars from IS 2830:2012 certified billets and holding valid BIS license is eligible. Exclusive distributor requirement is removed.',
      explanation:
          'Eliminates proprietary brand restriction and sole distributor cartelization pursuant to CVC guidelines.',
      scoreBefore: 45,
      scoreAfter: 75,
      targetSectionId: 'sec-5',
      evidence: Evidence(
        standardCode: 'CVC OM 03-05-1-CTE-9',
        defectiveStandardCode:
            'Proprietary Brands: Tata Tiscon / Jindal Panther',
        replacementStandardCode: 'Generic Fe 500D Specification',
        clause: 'Para 2.1 Anti-Tailoring',
        page: '1',
        sourceFile: 'CVC_Anti_Tailoring_OM_03_05_1.pdf',
        textExcerpt:
            'Tender conditions should be generic and not tailored to favor any particular firm. Brand names or proprietary trade makes shall not be specified.',
      ),
    ),
    const SpecificationBuildStep(
      id: 'S3',
      stepNumber: 3,
      title:
          'Statutory Steel QCO Enforcement: Compulsory Scheme-I BIS Certification at Bid Opening',
      problem:
          'Permitting post-award submission of Steel QCO certification violates Section 16 BIS Act 2016.',
      defectiveSnippet:
          'Steel Quality Control Order (QCO) Scheme-I BIS certification may be submitted post-award.',
      replacementSnippet:
          'Under Steel and Steel Products (Quality Control) Order, 2012 (S.O. 463(E) / S.O. 2400(E)), all TMT rebars must compulsorily bear the authentic BIS Standard Mark (Scheme-I ISI Mark). Valid BIS CM/L license number must be enclosed with technical bid; post-award deferral is strictly prohibited.',
      explanation:
          'Mandates compulsory BIS CM/L license at technical bid opening under Section 16 BIS Act.',
      scoreBefore: 75,
      scoreAfter: 100,
      targetSectionId: 'sec-3',
      evidence: Evidence(
        standardCode: 'Steel and Steel Products QCO 2012',
        clause: 'Notification S.O. 463(E) / S.O. 2400(E)',
        sourceFile: 'QCO_Ministry_of_Steel_2012.pdf',
        textExcerpt:
            'No person shall manufacture, store for sale, sell or distribute steel products which do not conform to IS 1786 and bear the Standard Mark under a license from the Bureau.',
      ),
    ),
  ];

  // ==========================================
  // INITIAL (DEFECTIVE) SPECIFICATION SECTIONS
  // ==========================================
  static const List<SpecificationSection> transformerInitialSections = [
    SpecificationSection(
      id: 'sec-1',
      sectionNumber: '1.0',
      title: 'Product Scope & Operational Requirements',
      status: 'VERIFIED',
      content:
          'Supply of 500 kVA, 11 kV / 433 V, 3-Phase 50 Hz outdoor oil-immersed distribution transformer. Cites baseline operational parameters.',
      recommendation:
          'Ensure energy loss criteria and BEE Star Rating levels are incorporated per IS 1180.',
    ),
    SpecificationSection(
      id: 'sec-2',
      sectionNumber: '2.0',
      title: 'Applicable Indian Standards (Normative References)',
      status: 'PENDING',
      content:
          '1. Primary National Standard: IS 1180:1989 — Outdoor Distribution Transformers [OBSOLETE]\n2. Insulating Oil Standard: IS 335:1993 — New Insulating Oils [OBSOLETE]\n3. Testing Protocols: IS 2026 (Parts 1 to 5) — Power Transformers Testing.',
      recommendation:
          'Rule 144(vii) of GFR 2017 prohibits citing superseded standards (IS 1180:1989 / IS 335:1993). Replace with active revisions.',
    ),
    SpecificationSection(
      id: 'sec-3',
      sectionNumber: '3.0',
      title: 'Statutory Quality Control Order (QCO) Enforcement',
      status: 'PENDING',
      content:
          'Compliance with Electrical Transformers (Quality Control) Order is left to bidder declaration. Self-declaration acceptable.',
      recommendation:
          'Compulsory BIS Scheme-I ISI Mark under Section 16 BIS Act cannot be substituted with bidder self-declaration.',
    ),
    SpecificationSection(
      id: 'sec-4',
      sectionNumber: '4.0',
      title: 'Quality Assurance, Testing & Acceptance Criteria',
      status: 'PENDING',
      content:
          'Routine tests as per IS 2026. Testing of transformer insulating oil as per obsolete IS 335:1993.',
      recommendation:
          'Upgrade insulating oil dielectric breakdown voltage testing to active IS 335:2018 (BDV ≥ 60 kV).',
    ),
    SpecificationSection(
      id: 'sec-5',
      sectionNumber: '5.0',
      title: 'CVC Brand Neutrality & Anti-Tailoring Safeguards',
      status: 'PENDING',
      content:
          'Proprietary OEM components: only ABB or Siemens high-voltage bushings permitted.',
      recommendation:
          'CVC guidelines prohibit specifying proprietary makes. Mandate generic porcelain bushings conforming to IS 3347.',
    ),
    SpecificationSection(
      id: 'sec-6',
      sectionNumber: '6.0',
      title: 'Rating Plate, Marking & Guarantee',
      status: 'VERIFIED',
      content:
          'Rating plate shall be provided on each transformer with manufacturer name, rating (500 kVA), serial number, and standard guarantee.',
      recommendation:
          'Ensure BEE Star Label registration details and BIS Standard Mark (ISI) are displayed on the rating plate.',
    ),
  ];

  static const List<SpecificationSection> pipeInitialSections = [
    SpecificationSection(
      id: 'sec-1',
      sectionNumber: '1.0',
      title: 'Product Scope & Operational Requirements',
      status: 'VERIFIED',
      content:
          'Supply of High Density Polyethylene (HDPE) Pipes for municipal water supply pipeline augmentation under nominal pressure rating PN 10 (SDR 11).',
      recommendation:
          'Specify food-grade raw material and temperature tolerance per IS 4984:2016.',
    ),
    SpecificationSection(
      id: 'sec-2',
      sectionNumber: '2.0',
      title: 'Applicable Indian Standards (Normative References)',
      status: 'PENDING',
      content:
          '1. Primary Standard: IS 4984:1995 (Fourth Revision) or foreign ASTM D3035.\n2. Raw Material Standard: Cites PE-80 raw material.\n3. Testing: Testing under superseded testing protocols.',
      recommendation:
          'Rule 144(vii) of GFR 2017 prohibits citing superseded IS 4984:1995 or foreign ASTM D3035 without national equivalence.',
    ),
    SpecificationSection(
      id: 'sec-3',
      sectionNumber: '3.0',
      title: 'Statutory Quality Control Order (QCO) Enforcement',
      status: 'PENDING',
      content:
          'BIS ISI Mark under Pipes QCO 2020 is optional for imported consignments. Minimum annual average financial turnover of bidder must be Rs 650 Crores.',
      recommendation:
          'Section 16 BIS Act 2016 mandates compulsory Scheme-I ISI mark under Pipes QCO 2021 (S.O. 4321(E)). Exemptions for imports are unlawful.',
    ),
    SpecificationSection(
      id: 'sec-4',
      sectionNumber: '4.0',
      title: 'Quality Assurance, Testing & Acceptance Criteria',
      status: 'PENDING',
      content:
          'Hydrostatic pressure testing and melt flow index testing under superseded IS 4984:1995 schedules.',
      recommendation:
          'Align testing with IS 4984:2016 Table 4 (100h at 20°C and 165h at 80°C) and IS 12235 test methods.',
    ),
    SpecificationSection(
      id: 'sec-5',
      sectionNumber: '5.0',
      title: 'CVC Brand Neutrality & Anti-Tailoring Safeguards',
      status: 'PENDING',
      content:
          'Only Supreme or Astral make pipes shall be accepted by the Engineer-in-Charge. Pipe raw material grade shall be PE-80, pressure rating PN 10, SDR 11.',
      recommendation:
          'CVC directives prohibit brand names (Supreme/Astral). Specify generic virgin PE-100 material conforming to IS 7328:2020.',
    ),
    SpecificationSection(
      id: 'sec-6',
      sectionNumber: '6.0',
      title: 'Delivery, Marking & Guarantee',
      status: 'VERIFIED',
      content:
          'Each pipe coil or straight length shall be marked with manufacturer name and nominal size.',
      recommendation:
          'Mandate indelible marking of BIS Standard Mark (ISI mark), CM/L license number, PE-100 designation, and lot number per IS 4984:2016 Cl. 14.',
    ),
  ];

  static const List<SpecificationSection> steelInitialSections = [
    SpecificationSection(
      id: 'sec-1',
      sectionNumber: '1.0',
      title: 'Product Scope & Technical Requirements',
      status: 'VERIFIED',
      content:
          'Supply of 50 Metric Tonnes Thermo-Mechanically Treated (TMT) steel reinforcement bars 16mm diameter for civil construction works.',
      recommendation:
          'Incorporate Grade Fe 500D high-ductility requirements for earthquake-resistant reinforced concrete.',
    ),
    SpecificationSection(
      id: 'sec-2',
      sectionNumber: '2.0',
      title: 'Applicable Indian Standards (Normative References)',
      status: 'PENDING',
      content:
          '1. Primary Standard: ASTM A615 Grade 60 without domestic Indian Standard equivalence.\n2. Billets: Proprietary primary producer supply.',
      recommendation:
          'GFR 2017 Rule 144(vii) prohibits mandating foreign ASTM A615 when national standard IS 1786:2008 Fe 500D is in force.',
    ),
    SpecificationSection(
      id: 'sec-3',
      sectionNumber: '3.0',
      title: 'Statutory Steel Quality Control Order (QCO) Enforcement',
      status: 'PENDING',
      content:
          'Steel Quality Control Order (QCO) Scheme-I BIS certification may be submitted post-award.',
      recommendation:
          'Under Steel QCO 2012 (S.O. 463(E) / S.O. 2400(E)), valid BIS CM/L license is compulsory at technical bid opening. Post-award deferral violates Section 16 BIS Act.',
    ),
    SpecificationSection(
      id: 'sec-4',
      sectionNumber: '4.0',
      title: 'Quality Assurance, Testing & Mechanical Properties',
      status: 'PENDING',
      content:
          'Tensile testing and elongation evaluated under ASTM A615 standards.',
      recommendation:
          'Enforce mechanical testing under IS 1608 (yield stress ≥ 500 N/mm², TS/YS ≥ 1.10, elongation ≥ 16%) and bend test under IS 1599:2019.',
    ),
    SpecificationSection(
      id: 'sec-5',
      sectionNumber: '5.0',
      title: 'CVC Anti-Tailoring & Brand Neutrality',
      status: 'PENDING',
      content:
          'Reinforcement steel shall strictly be Tata Tiscon or Jindal Panther make only. Bidders must have sole authorized distributor certificate directly from primary producer.',
      recommendation:
          'Excise Tata Tiscon and Jindal Panther proprietary lock-in. Remove restrictive sole distributor certificate requirement pursuant to CVC guidelines.',
    ),
    SpecificationSection(
      id: 'sec-6',
      sectionNumber: '6.0',
      title: 'Bundling, Marking & Traceability',
      status: 'VERIFIED',
      content:
          'Steel bundles shall be identified with mill manufacturer tags and nominal bar size.',
      recommendation:
          'Mandate metal tags bearing BIS Standard Mark (ISI mark), CM/L license number, heat/cast number, and Fe 500D grade per IS 1786:2008 Cl. 12.',
    ),
  ];

  // ==========================================
  // FINAL (100% COMPLIANT) SPECIFICATION SECTIONS
  // ==========================================
  static const List<SpecificationSection> defaultSpecificationSections = [
    SpecificationSection(
      id: 'sec-1',
      sectionNumber: '1.0',
      title: 'Product Scope & Operational Requirements',
      status: 'VERIFIED',
      content:
          'Procurement of 500 kVA, 11 kV / 433 V, 3-Phase, 50 Hz, outdoor type, mineral oil-immersed naturally cooled (ONAN) distribution transformers. The equipment shall be designed, manufactured, and tested for continuous operation in tropical climates up to 50°C ambient temperature with BEE Energy Efficiency Star Labeling (Level 2 minimum).',
      recommendation:
          'Rule 144(vii) of GFR 2017 mandates citing current national standards and BEE Star Rating energy loss levels for distribution transformers.',
      suggestedAppend:
          'BEE Star Labeling: Transformers shall conform to BEE Star Level 2 maximum allowable losses at 50% and 100% load.',
      evidence: Evidence(
        standardCode: 'IS 1180 (Part 1):2014',
        clause: 'Scope & Cl. 1.1',
        page: '2',
        sourceFile: '1180_part1_2014_amd4.pdf',
        textExcerpt:
            'This standard specifies requirements for mineral oil-immersed, naturally cooled, outdoor type three-phase distribution transformers up to and including 2500 kVA, 33 kV with BEE Energy Efficiency Star Ratings.',
      ),
    ),
    SpecificationSection(
      id: 'sec-2',
      sectionNumber: '2.0',
      title: 'Applicable Indian Standards (Normative References)',
      status: 'VERIFIED',
      content:
          '1. Primary National Standard: IS 1180 (Part 1):2014 (Second Revision) — Outdoor Type Three-Phase Distribution Transformers.\n2. Insulating Oil Standard: IS 335:2018 — New Insulating Oils — Specification.\n3. Testing Protocols: IS 2026 (Parts 1 to 5) — Power Transformers Testing.\n4. Porcelain Bushings: IS 3347 (Part 1 to 8) — Dimensions for Porcelain Transformer Bushings.\n5. Active Gazetted Amendments: Amendment No. 1 (2016), Amendment No. 2 (2019), Amendment No. 3 (2021), Amendment No. 4 (2023).',
      recommendation:
          'Rule 144(vii) of GFR 2017 prohibits citing superseded standards (IS 1180:1989 / IS 335:1993) or foreign IEC 60076 without domestic Indian Standard equivalence.',
      evidence: Evidence(
        standardCode: 'IS 1180 (Part 1):2014',
        defectiveStandardCode: 'IS 1180:1989',
        replacementStandardCode: 'IS 1180 (Part 1):2014',
        clause: 'Cl. 2 Normative References',
        page: '3',
        sourceFile: '1180_part1_2014_amd4.pdf',
        textExcerpt:
            'The materials, components, and finished goods supplied under this contract shall strictly conform to the latest active revision of IS 1180 (Part 1):2014 along with all gazetted amendments.',
      ),
    ),
    SpecificationSection(
      id: 'sec-3',
      sectionNumber: '3.0',
      title: 'Statutory Quality Control Order (QCO) Enforcement',
      status: 'VERIFIED',
      content:
          'Pursuant to the Distribution Transformers (Quality Control) Order, 2014 gazetted by DPIIT under Notification No. S.O. 1621(E) in exercise of powers conferred by Section 16 of the Bureau of Indian Standards Act, 2016:\n(a) All distribution transformers supplied under this contract must compulsorily bear the Standard Mark (Scheme-I ISI Mark) under a valid BIS license.\n(b) Bidders / OEMs must hold an active BIS CM/L license for IS 1180 (Part 1):2014 on the date of bid opening.\n(c) Summary Technical Disqualification: Any bid proposing uncertified units, self-declaration, or goods lacking the mandatory ISI mark shall be summarily rejected.',
      recommendation:
          'Mandate submission of valid BIS CM/L license and BEE Star Rating certificate at technical bid opening.',
      suggestedAppend:
          'Bidders shall enclose a certified copy of valid BIS CM/L license for IS 1180 (Part 1):2014 and BEE Star Label registration with the technical bid.',
      evidence: Evidence(
        standardCode: 'Distribution Transformers QCO 2014',
        clause: 'Section 16 & 29 BIS Act 2016',
        page: 'Gazette S.O. 1621(E)',
        sourceFile: 'QCO_DPIIT_Transformers_2014.pdf',
        textExcerpt:
            'No person shall manufacture, store for sale, sell or distribute distribution transformers which do not conform to IS 1180 (Part 1) and bear the Standard Mark under a license from the Bureau.',
      ),
    ),
    SpecificationSection(
      id: 'sec-4',
      sectionNumber: '4.0',
      title: 'Quality Assurance, Testing & Acceptance Criteria',
      status: 'VERIFIED',
      content:
          '1. Routine Tests: All transformers shall undergo routine tests as per IS 1180 (Part 1):2014 Cl. 21.2 and IS 2026 (Part 1) including winding resistance, voltage ratio, impedance voltage, load loss, and no-load loss at rated voltage.\n2. Insulating Oil Tests: Electric strength (breakdown voltage ≥ 60 kV) and water content tested strictly in accordance with IS 335:2018.\n3. Type Test Certification: Valid type test reports from CPRI / ERDA / NABL-accredited test laboratory.\n4. Pre-Dispatch Inspection: Stage inspection and final testing by third-party inspection agency (RITES / CEIL / BIS) at manufacturer\'s works.',
      recommendation:
          'Require authentic Manufacturer Test Certificates (MTC) confirming total losses do not exceed IS 1180 Table 3 / Table 6 limits.',
      evidence: Evidence(
        standardCode: 'IS 2026 / IS 1180',
        clause: 'Cl. 21 Testing Schedules',
        page: '14',
        sourceFile: '1180_part1_2014_amd4.pdf',
        textExcerpt:
            'Routine tests shall be performed on all units. Certified test reports for loss values and temperature rise shall be submitted prior to dispatch.',
      ),
    ),
    SpecificationSection(
      id: 'sec-5',
      sectionNumber: '5.0',
      title: 'CVC Brand Neutrality & Anti-Tailoring Safeguards',
      status: 'VERIFIED',
      content:
          'In strict compliance with Central Vigilance Commission (CVC) Directives (OM No. 03-05-1-CTE-9) and GFR 2017 Rule 144(vii):\n(a) This specification is strictly generic and manufacturer-neutral. Mandating proprietary OEM makes (e.g. ABB or Siemens) is expressly prohibited.\n(b) High-voltage and low-voltage bushings shall conform generically to IS 3347. Any qualified manufacturer offering components conforming to IS 3347 and holding valid BIS certification shall be eligible.\n(c) Bids shall be evaluated on technical conformance to Indian Standards without discriminatory brand preference.',
      recommendation:
          'Strike out proprietary vendor makes; specify generic functional compliance to IS 3347.',
      evidence: Evidence(
        standardCode: 'CVC OM 03-05-1-CTE-9',
        defectiveStandardCode: 'Proprietary ABB / Siemens Bushings',
        replacementStandardCode: 'Generic Bushings per IS 3347',
        clause: 'Para 2.1 Anti-Tailoring',
        page: '1',
        sourceFile: 'CVC_Anti_Tailoring_OM_03_05_1.pdf',
        textExcerpt:
            'Tender conditions should be generic and not tailored to favor any particular firm. Brand names or proprietary trade makes shall not be specified.',
      ),
    ),
    SpecificationSection(
      id: 'sec-6',
      sectionNumber: '6.0',
      title: 'Rating Plate, Marking & Guarantee',
      status: 'VERIFIED',
      content:
          'Each transformer shall be provided with a non-detachable stainless steel rating and diagram plate indelibly marked in accordance with IS 1180 (Part 1):2014 Cl. 13 with: Manufacturer Name, Serial Number, Rated kVA (500 kVA), Voltage Ratio (11000/433 V), Vector Group (Dyn11), BIS Standard Mark (ISI Mark), CM/L License Number, and BEE Energy Star Labeling.\nGuarantee: Minimum 36 months warranty from the date of commissioning or 42 months from dispatch against manufacturing defects.',
      recommendation:
          'Ensure BEE Star Label registration details are displayed on the rating plate alongside BIS Mark.',
      evidence: Evidence(
        standardCode: 'IS 1180 (Part 1):2014',
        clause: 'Cl. 13 Rating Plate',
        page: '9',
        sourceFile: '1180_part1_2014_amd4.pdf',
        textExcerpt:
            'Rating plate shall carry all statutory markings including the Standard Mark, license number, and BEE energy consumption rating.',
      ),
    ),
  ];

  static const List<SpecificationSection> pipeFinalSections = [
    SpecificationSection(
      id: 'sec-1',
      sectionNumber: '1.0',
      title: 'Product Scope & Operational Requirements',
      status: 'VERIFIED',
      content:
          'Procurement of High Density Polyethylene (HDPE) Pipes suitable for potable water distribution, agricultural supply, and industrial mains under operating pressure rating PN 10 (1.0 MPa), PE-100 raw material classification conforming strictly to IS 4984:2016.',
      recommendation:
          'Standard procurement guidelines for municipal water boards mandate specifying temperature tolerance (up to +45°C) and food-grade PE resin declaration.',
      suggestedAppend:
          'Resin Specification: Raw material shall strictly be 100% virgin food-grade PE-100 grade without addition of recycled scrap plastic.',
    ),
    SpecificationSection(
      id: 'sec-2',
      sectionNumber: '2.0',
      title: 'Applicable Indian Standards (Normative References)',
      status: 'VERIFIED',
      content:
          '1. Primary National Standard: IS 4984:2016 (Fifth Revision with Amendments 1 & 2) — High Density Polyethylene Pipes for Water Supply.\n2. Raw Material Standard: IS 7328:2020 — High Density Polyethylene Materials for Moulding and Extrusion.\n3. Test Methods: IS 12235 (Parts 1 to 19) — Methods of Test for Unplasticized PVC and Polyethylene Pipes.\n4. Carbon Black Dispersion Test: IS 2530:1963.',
      recommendation:
          'Rule 144(vii) of GFR 2017 prohibits citing foreign ASTM D3035 or DIN 8074 without domestic Indian Standard equivalence.',
    ),
    SpecificationSection(
      id: 'sec-3',
      sectionNumber: '3.0',
      title: 'Statutory Quality Control Order (QCO) Enforcement',
      status: 'VERIFIED',
      content:
          'Pursuant to the Pipes and Fittings (Quality Control) Order, 2021 gazetted by DPIIT under Notification No. S.O. 4321(E) in exercise of powers conferred by Section 16 of the Bureau of Indian Standards Act, 2016:\n(a) All goods supplied under this schedule must compulsorily bear the authentic Standard Mark (Scheme-I (ISI Mark)) under a valid BIS license.\n(b) The Bidder / OEM must hold an active BIS License (CM/L Number) for IS 4984:2016 on the date of technical bid opening.\n(c) Summary Technical Disqualification: Any bid proposing uncertified products or self-declaration shall be summarily rejected.',
      recommendation:
          'Mandate submission of valid BIS CM/L license at the time of technical bid opening.',
      suggestedAppend:
          'Bidders shall enclose a certified copy of valid BIS CM/L license for IS 4984 covering the quoted pipe sizes and pressure ratings.',
    ),
    SpecificationSection(
      id: 'sec-4',
      sectionNumber: '4.0',
      title: 'Quality Assurance, Testing & Acceptance Criteria',
      status: 'VERIFIED',
      content:
          '1. Internal Hydrostatic Pressure Test: Pipes shall withstand internal hydrostatic pressure test for 100 hours at 20°C and 165 hours at 80°C in accordance with IS 4984:2016 Table 4.\n2. Melt Flow Index (MFI): Tested as per IS 2530:1963, variation shall not exceed ±20% of base resin.\n3. Carbon Black Content & Dispersion: Grade ≥ 3 as per IS 2530:1963.\n4. Independent Testing: Inspection by third-party agency (RITES / CIPET / CEIL) from a NABL-accredited test laboratory.',
      recommendation:
          'Include mandatory NABL accredited laboratory test certificate requirement prior to dispatch.',
      suggestedAppend:
          'Manufacturer shall submit NABL accredited test certificates for raw material batch and pipe hydro-testing for each manufacturing lot.',
    ),
    SpecificationSection(
      id: 'sec-5',
      sectionNumber: '5.0',
      title: 'CVC Brand Neutrality & Anti-Tailoring Safeguards',
      status: 'VERIFIED',
      content:
          'In strict compliance with Central Vigilance Commission (CVC) Directives (OM No. 03-05-1-CTE-9) and GFR 2017 Rule 144(vii):\n(a) This specification is strictly generic and performance-based. Mandating proprietary makes (e.g. Supreme or Astral) is expressly prohibited.\n(b) Raw material shall be 100% virgin generic PE-100 polymer conforming to IS 7328:2020. Any qualified manufacturer certified under IS 4984:2016 is eligible.\n(c) Foreign standards (ASTM D3035) are harmonized to equivalent Indian Standard IS 4984:2016.',
      recommendation:
          'Strike out proprietary vendor makes; specify generic functional compliance to IS 4984:2016.',
    ),
    SpecificationSection(
      id: 'sec-6',
      sectionNumber: '6.0',
      title: 'Marking, Packaging & Traceability',
      status: 'VERIFIED',
      content:
          'Each pipe length or coil shall be legibly and indelibly marked in accordance with IS 4984:2016 Cl. 14 with: Manufacturer Name/Trade Mark, Nominal Outer Diameter, Wall Thickness / SDR Rating, Material Grade (PE 100), Pressure Rating (PN 10), Standard Mark (ISI Mark), CM/L License Number, and Batch Lot/Year.',
      recommendation:
          'Ensure indelible embossing on pipe surface at intervals not exceeding 3 meters.',
    ),
  ];

  static const List<SpecificationSection> steelFinalSections = [
    SpecificationSection(
      id: 'sec-1',
      sectionNumber: '1.0',
      title: 'Product Scope & Technical Requirements',
      status: 'VERIFIED',
      content:
          'Supply of 50 Metric Tonnes Thermo-Mechanically Treated (TMT) high strength deformed steel bars for concrete reinforcement, 16mm nominal diameter, conforming to Grade Fe 500D per IS 1786:2008 for earthquake-resistant reinforced concrete civil construction.',
      recommendation:
          'Specify high-ductility Fe 500D grade conforming to IS 1786:2008 for enhanced seismic resistance.',
    ),
    SpecificationSection(
      id: 'sec-2',
      sectionNumber: '2.0',
      title: 'Applicable Indian Standards (Normative References)',
      status: 'VERIFIED',
      content:
          '1. Primary National Standard: IS 1786:2008 (Fourth Revision with Amendments 1, 2 & 3) — High Strength Deformed Steel Bars and Wires for Concrete Reinforcement.\n2. Raw Material Billets: IS 2830:2012 — Carbon Steel Cast Billet Ingots, Billets, Blooms and Slabs for Re-Rolling into High Strength Deformed Steel Bars.\n3. Tensile Testing Protocols: IS 1608 (Part 1):2018 — Metallic Materials — Tensile Testing.\n4. Bend & Rebend Tests: IS 1599:2019 — Metallic Materials — Bend Test.\n5. Chemical Analysis: IS 228 — Methods for Chemical Analysis of Steels.\n6. Bar Bending & Fixing: IS 2502:1963.',
      recommendation:
          'Rule 144(vii) of GFR 2017 prohibits mandating foreign standard ASTM A615 when national standard IS 1786:2008 is in force.',
    ),
    SpecificationSection(
      id: 'sec-3',
      sectionNumber: '3.0',
      title: 'Statutory Steel Quality Control Order (QCO) Enforcement',
      status: 'VERIFIED',
      content:
          'Under the Steel and Steel Products (Quality Control) Order, 2012 / 2020 notified by the Ministry of Steel under Notification No. S.O. 463(E) / S.O. 2400(E) pursuant to Section 16 of the Bureau of Indian Standards Act, 2016:\n(a) All TMT rebars supplied under this contract must compulsorily bear the authentic BIS Standard Mark (Scheme-I ISI Mark).\n(b) Bidders / Manufacturers must hold an active BIS CM/L license for IS 1786:2008 on the date of technical bid opening. Post-award submission or deferral is strictly prohibited.\n(c) Summary Technical Disqualification: Bids offering uncertified steel or self-declaration shall be summarily rejected without clarification.',
      recommendation:
          'Mandate authentic BIS Scheme-I license (CM/L) submission at technical bid opening.',
      suggestedAppend:
          'Bidders shall enclose a certified copy of valid BIS CM/L license for IS 1786:2008 Fe 500D with the technical bid.',
    ),
    SpecificationSection(
      id: 'sec-4',
      sectionNumber: '4.0',
      title: 'Quality Assurance, Testing & Mechanical Properties',
      status: 'VERIFIED',
      content:
          '1. Mechanical Properties: Minimum 0.2% Proof Stress / Yield Stress ≥ 500.0 N/mm², Tensile Strength to Yield Stress ratio (TS/YS) ≥ 1.10, and Total Elongation at fracture ≥ 16.0% as per IS 1786:2008 Table 3.\n2. Bend & Rebend Testing: Mandrel diameter 4d through 180° bend test as per IS 1599:2019 with zero transverse cracking.\n3. Chemical Limits: Carbon max 0.25%, Sulphur max 0.040%, Phosphorus max 0.040%, and (S+P) max 0.075%.\n4. Mill Test Certificates (MTC): 100% heat-wise chemical and mechanical NABL test reports required prior to dispatch.',
      recommendation:
          'Enforce strict compliance with IS 1786:2008 mechanical and chemical limits.',
    ),
    SpecificationSection(
      id: 'sec-5',
      sectionNumber: '5.0',
      title: 'CVC Anti-Tailoring & Brand Neutrality',
      status: 'VERIFIED',
      content:
          'In strict accordance with Central Vigilance Commission (CVC) OM No. 03-05-1-CTE-9 and GFR 2017 Rule 144(vii):\n(a) This specification is strictly generic and manufacturer-neutral. Mandating proprietary primary producer makes (Tata Tiscon / Jindal Panther) is expressly prohibited.\n(b) Stipulation of sole authorized distributor certificates directly from primary producers is rescinded. Any producer, re-roller, or stockist supplying BIS-certified Fe 500D rebars produced from IS 2830 billets is eligible.\n(c) Foreign standard ASTM A615 is harmonized to governing national standard IS 1786:2008 Grade Fe 500D.',
      recommendation:
          'Strike out proprietary trade makes; specify generic Grade Fe 500D conforming to IS 1786:2008.',
    ),
    SpecificationSection(
      id: 'sec-6',
      sectionNumber: '6.0',
      title: 'Bundling, Marking & Traceability',
      status: 'VERIFIED',
      content:
          'Each bundle of TMT bars shall be securely tied and fitted with durable metal tags indelibly marked in accordance with IS 1786:2008 Cl. 12 with: Manufacturer Name/Logo, Nominal Bar Diameter (16mm), Grade (Fe 500D), Cast/Heat Number, BIS Standard Mark (Scheme-I ISI Mark), and CM/L License Number.',
      recommendation:
          'Ensure metal tags are firmly attached with non-detachable ties for site verification.',
    ),
  ];

  // ==========================================
  // STATUTORY CHECKLISTS PER PRESET
  // ==========================================
  static const List<String> transformerStatutoryChecklist = [
    'Mandatory QCO requirement addressed (Distribution Transformers QCO 2014, S.O. 1621(E))',
    'Active Indian Standards cited (IS 1180 (Part 1):2014 & IS 335:2018 with all amendments)',
    '100% Manufacturer-neutral specification (ABB & Siemens proprietary lock-ins stripped)',
    'Mandatory Scheme-I ISI Mark & valid BIS CM/L license requirement enforced',
  ];

  static const List<String> pipeStatutoryChecklist = [
    'Mandatory QCO requirement addressed (Pipes and Fittings QCO 2021, S.O. 4321(E))',
    'Active Indian Standard cited (IS 4984:2016 Fifth Revision with Amendments 1 & 2)',
    '100% Manufacturer-neutral specification (Supreme & Astral brand lock-ins stripped)',
    'Mandatory Scheme-I ISI Mark & valid BIS CM/L license requirement enforced',
  ];

  static const List<String> steelStatutoryChecklist = [
    'Mandatory QCO requirement addressed (Steel and Steel Products QCO 2012, S.O. 463(E))',
    'Active Indian Standard cited (IS 1786:2008 Fourth Revision Grade Fe 500D)',
    '100% Manufacturer-neutral specification (Tata Tiscon & Jindal Panther brand lock-ins stripped)',
    'Mandatory Scheme-I ISI Mark & valid BIS CM/L license requirement enforced',
  ];

  // ==========================================
  // SIDE-BY-SIDE REDLINE DIFF DATA PER PRESET
  // ==========================================
  static const String transformerOriginalDefectiveClause =
      '''TECHNICAL SPECIFICATIONS FOR SUBSTATION DISTRIBUTION TRANSFORMERS:
1. Supply of 500 kVA, 11 kV / 433 V, 3-Phase 50 Hz outdoor oil-immersed distribution transformer.
2. Transformer design, manufacture and testing shall conform strictly to IS 1180:1989.
3. Proprietary OEM components: only ABB or Siemens high-voltage bushings permitted.
4. Testing of transformer insulating oil as per obsolete IS 335:1993.
5. Compliance with Electrical Transformers (Quality Control) Order is left to bidder declaration.''';

  static const String transformerRectifiedCompliantClause =
      '''TECHNICAL SPECIFICATIONS FOR SUBSTATION DISTRIBUTION TRANSFORMERS:
1. Supply of 500 kVA, 11 kV / 433 V, 3-Phase 50 Hz outdoor oil-immersed distribution transformer conforming strictly to IS 1180 (Part 1):2014 with BEE Star Labeling.
2. High-voltage and low-voltage bushings shall conform to IS 3347 (Part 1 to 8). Specification is brand-neutral; proprietary OEM lock-ins (ABB/Siemens) are removed.
3. Testing of transformer insulating oil shall conform to active standard IS 335:2018 (breakdown voltage ≥ 60 kV).
4. Compulsory compliance with Distribution Transformers (Quality Control) Order, 2014. Bidders must hold valid BIS CM/L license at bid submission.''';

  static const String transformerDiffStatutoryAction =
      'Rectified obsolete Indian Standards, stripped proprietary vendor brand lock-ins, injected mandatory QCO citations, and replaced normative testing standards under GFR 144(vii).';

  static const String pipeOriginalDefectiveClause =
      '''TECHNICAL SPECIFICATIONS FOR HDPE PIPELINE AUGMENTATION:
1. Pipes shall strictly conform to IS 4984:1995 (Fourth Revision) or ASTM D3035.
2. Only Supreme or Astral make pipes shall be accepted by the Engineer-in-Charge.
3. Pipe raw material grade shall be PE-80, pressure rating PN 10, SDR 11.
4. BIS ISI Mark under Pipes QCO 2020 is optional for imported consignments.
5. Minimum annual average financial turnover of bidder must be Rs 650 Crores.''';

  static const String pipeRectifiedCompliantClause =
      '''TECHNICAL SPECIFICATIONS FOR HDPE PIPELINE AUGMENTATION:
1. Pipes shall strictly conform to IS 4984:2016 (Fifth Revision with Amendments 1 & 2). Foreign standard ASTM D3035 is converted to IS 4984:2016 per GFR 144(vii).
2. Specification is strictly manufacturer-neutral; Supreme and Astral proprietary make restrictions are removed.
3. Raw material shall be 100% virgin generic PE-100 polymer conforming to IS 7328:2020 under pressure rating PN 10 (SDR 11).
4. Compulsory compliance with Pipes and Fittings (Quality Control) Order, 2021 (S.O. 4321(E)). Bidders must hold valid BIS CM/L license under Scheme-I at bid submission. Turnover criteria aligned with CVC guidelines.''';

  static const String pipeDiffStatutoryAction =
      'Substituted obsolete IS 4984:1995 and foreign ASTM D3035 with active IS 4984:2016, eliminated Supreme/Astral brand tailoring, and mandated Pipes QCO 2021 BIS Scheme-I license.';

  static const String steelOriginalDefectiveClause =
      '''TECHNICAL SPECIFICATIONS FOR CIVIL WORKS REINFORCEMENT STEEL:
1. Supply of 50 Metric Tonnes Thermo-Mechanically Treated (TMT) bars 16mm diameter.
2. Reinforcement steel shall strictly be Tata Tiscon or Jindal Panther make only.
3. Material shall conform to ASTM A615 Grade 60 without domestic Indian Standard equivalence.
4. Bidders must have sole authorized distributor certificate directly from primary producer.
5. Steel Quality Control Order (QCO) Scheme-I BIS certification may be submitted post-award.''';

  static const String steelRectifiedCompliantClause =
      '''TECHNICAL SPECIFICATIONS FOR CIVIL WORKS REINFORCEMENT STEEL:
1. Supply of 50 Metric Tonnes Thermo-Mechanically Treated (TMT) high strength deformed steel bars 16mm conforming strictly to IS 1786:2008 Grade Fe 500D.
2. Specification is 100% manufacturer-neutral; Tata Tiscon and Jindal Panther proprietary brand restrictions are removed.
3. Foreign ASTM A615 Grade 60 is harmonized to governing national standard IS 1786:2008 Grade Fe 500D with Amendments 1, 2 & 3.
4. Compulsory compliance with Steel and Steel Products (Quality Control) Order, 2012 (S.O. 463(E)). Bidders must hold active BIS CM/L license at technical bid opening. Exclusive distributor requirement is removed.''';

  static const String steelDiffStatutoryAction =
      'Harmonized foreign ASTM A615 to primary national standard IS 1786:2008 Fe 500D, excised Tata Tiscon/Jindal Panther brand bias, and mandated Steel QCO BIS license at bid opening.';

  // Canonical Rectified Clause for Transformer scenario (used in Tender Scrutiny helper action)
  static const String rectifiedTransformerClause =
      '''### TECHNICAL SPECIFICATION & STATUTORY COMPLIANCE SCHEDULE
**Item Nomenclature / Scope:** Distribution Transformers
**Governing National Standard:** IS 1180 (Part 1):2014 – Outdoor Type Three-Phase Distribution Transformers Up To and Including 2500 kVA, 33 kV – Specification
**BIS Technical Division:** Electrotechnical
---

#### 1. MANDATORY NATIONAL STANDARD & REVISION STATUS
1.1 The materials, components, and finished goods supplied under this contract shall strictly conform to the latest active revision of IS 1180 (Part 1):2014 along with all gazetted amendments.
1.2 The Bidder shall ensure compliance with active statutory amendments: Amendment No. 1 (2016), Amendment No. 2 (2019), Amendment No. 3 (2021), Amendment No. 4 (2023).
1.3 Citing obsolete, superseded, or withdrawn revisions of the standard is strictly prohibited under GFR 2017 Rule 144.

#### 2. STATUTORY QUALITY CONTROL ORDER (QCO) ENFORCEMENT
2.1 Pursuant to the Distribution Transformers (Quality Control) Order, 2014 gazetted by DPIIT under Section 16 of the Bureau of Indian Standards Act, 2016:
(a) All goods supplied under this schedule must compulsorily bear the authentic Standard Mark (Scheme-I (ISI Mark)) under a valid and operational BIS license.
(b) The Bidder / OEM must hold an active BIS License (CM/L Number) on the date of technical bid opening.
(c) Summary Technical Disqualification: Any bid proposing uncertified products or self-certification shall be summarily rejected.

#### 3. CVC BRAND NEUTRALITY & ANTI-TAILORING SAFEGUARDS
3.1 In strict compliance with CVC Directives and GFR Rule 144(vii), no proprietary vendor parameters or trade makes (ABB / Siemens) are mandated. All components shall conform to generic functional parameters certified under IS 1180 (Part 1):2014.''';

  // ==========================================
  // KNOWLEDGE GRAPH NODES PER PRESET
  // (Directly grounded in standards_master.json)
  // ==========================================
  static const List<StandardsGraphNode> transformerGraphNodes = [
    StandardsGraphNode(
      id: 'node-is1180-2014',
      code: 'IS 1180 (Part 1):2014',
      title:
          'Outdoor Type Three-Phase Distribution Transformers Up To and Including 2500 kVA, 33 kV — Specification',
      type: GraphNodeType.primaryStandard,
      categoryLabel: 'Primary Standard',
      relationship: 'CENTRAL GOVERNING STANDARD',
      status: 'CURRENT',
      description:
          'Second Revision covering outdoor distribution transformers with BEE Star Labeling and Scheme-I ISI Mark.',
      evidence: Evidence(
        standardCode: 'IS 1180 (Part 1):2014',
        clause: 'Scope',
        page: '1',
        sourceFile: '1180_part1_2014_amd4.pdf',
        textExcerpt:
            'Governing national standard for distribution transformers under Section 16 BIS Act 2016.',
      ),
    ),
    StandardsGraphNode(
      id: 'node-qco-transformers',
      code: 'Distribution Transformers QCO 2014',
      title: 'Distribution Transformers (Quality Control) Order, 2014',
      type: GraphNodeType.qco,
      categoryLabel: 'Mandatory QCO',
      relationship: 'GOVERNED BY QCO',
      status: 'MANDATORY REGULATION',
      description:
          'DPIIT Notification No. S.O. 1621(E) under Section 16 BIS Act 2016. Compulsory ISI Mark.',
      evidence: Evidence(
        standardCode: 'Distribution Transformers QCO 2014',
        clause: 'Notification S.O. 1621(E)',
        page: '1',
        sourceFile: 'QCO_DPIIT_Transformers_2014.pdf',
        textExcerpt:
            'Mandatory Quality Control Order prohibiting procurement of non-BIS certified transformers.',
      ),
    ),
    StandardsGraphNode(
      id: 'node-is1180-1989',
      code: 'IS 1180:1989',
      title: 'Outdoor Distribution Transformers (First Revision) [SUPERSEDED]',
      type: GraphNodeType.supersededStandard,
      categoryLabel: 'Superseded Edition',
      relationship: 'SUPERSEDED BY IS 1180:2014',
      status: 'SUPERSEDED — DO NOT CITE',
      description:
          'Superseded by IS 1180 (Part 1):2014. Citing this violates GFR 2017 Rule 144.',
      evidence: Evidence(
        standardCode: 'IS 1180 (Part 1):2014',
        defectiveStandardCode: 'IS 1180:1989',
        replacementStandardCode: 'IS 1180 (Part 1):2014',
        clause: 'Foreword Cl. 0.3',
        page: '1',
        sourceFile: '1180_part1_2014_amd4.pdf',
        textExcerpt: 'IS 1180:1989 stands superseded by IS 1180 (Part 1):2014.',
      ),
    ),
    StandardsGraphNode(
      id: 'node-is335-1993',
      code: 'IS 335:1993',
      title: 'New Insulating Oils Specification [SUPERSEDED]',
      type: GraphNodeType.supersededStandard,
      categoryLabel: 'Superseded Edition',
      relationship: 'SUPERSEDED BY IS 335:2018',
      status: 'SUPERSEDED — DO NOT CITE',
      description:
          'Superseded by IS 335:2018. Defective citation in original tender.',
      evidence: Evidence(
        standardCode: 'IS 335:2018',
        defectiveStandardCode: 'IS 335:1993',
        replacementStandardCode: 'IS 335:2018',
        clause: 'Foreword',
        page: '1',
        sourceFile: '335_2018_insulating_oils.pdf',
        textExcerpt: 'IS 335:1993 was withdrawn and superseded by IS 335:2018.',
      ),
    ),
    StandardsGraphNode(
      id: 'node-is335-2018',
      code: 'IS 335:2018',
      title: 'New Insulating Oils — Specification (Fifth Revision)',
      type: GraphNodeType.rawMaterial,
      categoryLabel: 'Raw Material',
      relationship: 'REQUIRES RAW MATERIAL',
      status: 'CURRENT',
      description:
          'Mandatory mineral insulating oil specification for transformers. BDV ≥ 60 kV.',
      evidence: Evidence(
        standardCode: 'IS 335:2018',
        clause: 'Cl. 4.2',
        page: '5',
        sourceFile: '335_2018_insulating_oils.pdf',
        textExcerpt:
            'Testing of transformer insulating oil shall conform to IS 335:2018.',
      ),
    ),
    StandardsGraphNode(
      id: 'node-is12444',
      code: 'IS 12444',
      title:
          'Continuously Cast and Rolled Electrolytic Copper Wire Rods for Electrical Conductors',
      type: GraphNodeType.rawMaterial,
      categoryLabel: 'Raw Material',
      relationship: 'REQUIRES RAW MATERIAL',
      status: 'CURRENT',
      description:
          'High-conductivity copper conductors for transformer windings.',
    ),
    StandardsGraphNode(
      id: 'node-is3024',
      code: 'IS 3024',
      title: 'Grain Oriented Electrical Steel Sheets and Strips (CRGO)',
      type: GraphNodeType.rawMaterial,
      categoryLabel: 'Raw Material',
      relationship: 'REQUIRES RAW MATERIAL',
      status: 'CURRENT',
      description:
          'Cold-rolled grain-oriented silicon steel core material ensuring low core losses.',
    ),
    StandardsGraphNode(
      id: 'node-is2026',
      code: 'IS 2026 (Parts 1 to 5)',
      title: 'Power Transformers — Methods of Testing',
      type: GraphNodeType.testingProtocol,
      categoryLabel: 'Testing Protocol',
      relationship: 'REQUIRES TEST PROTOCOL',
      status: 'CURRENT',
      description:
          'Mandatory testing procedures for routine, type, and special transformer tests.',
    ),
    StandardsGraphNode(
      id: 'node-is6792',
      code: 'IS 6792',
      title:
          'Method for Determination of Electric Strength of Insulating Oils (BDV Test)',
      type: GraphNodeType.testingProtocol,
      categoryLabel: 'Testing Protocol',
      relationship: 'REQUIRES TEST PROTOCOL',
      status: 'CURRENT',
      description:
          'Dielectric breakdown voltage testing protocol for mineral insulating oils.',
    ),
    StandardsGraphNode(
      id: 'node-is3347',
      code: 'IS 3347 (Parts 1 to 8)',
      title: 'Dimensions for Porcelain Transformer Bushings',
      type: GraphNodeType.alliedStandard,
      categoryLabel: 'Allied Standard',
      relationship: 'GENERIC ALLIED SPECIFICATION',
      status: 'CURRENT',
      description:
          'Standard dimensions for transformer bushings. Generic replacement for proprietary ABB/Siemens makes.',
    ),
    StandardsGraphNode(
      id: 'node-is3639',
      code: 'IS 3639',
      title:
          'Fittings and Accessories for Power and Distribution Transformers',
      type: GraphNodeType.alliedStandard,
      categoryLabel: 'Allied Standard',
      relationship: 'ALLIED SPECIFICATION',
      status: 'CURRENT',
      description:
          'Standard fittings including conservator tanks, silica gel breathers, and drain valves.',
    ),
    StandardsGraphNode(
      id: 'node-iec60076',
      code: 'IEC 60076',
      title: 'Power Transformers (International Standard)',
      type: GraphNodeType.foreignEquivalent,
      categoryLabel: 'Foreign Equivalent',
      relationship: 'EQUIVALENT FOREIGN STANDARD',
      status: 'FOREIGN EQUIVALENT',
      description:
          'International benchmark. Under GFR 144(vii), Indian Standard IS 1180 takes legal precedence.',
    ),
  ];

  static const List<StandardsGraphNode> pipeGraphNodes = [
    StandardsGraphNode(
      id: 'node-is4984-2016',
      code: 'IS 4984:2016',
      title:
          'High Density Polyethylene Pipes for Water Supply — Specification',
      type: GraphNodeType.primaryStandard,
      categoryLabel: 'Primary Standard',
      relationship: 'CENTRAL GOVERNING STANDARD',
      status: 'CURRENT',
      description:
          'Fifth Revision covering HDPE pipes for buried water mains and potable distribution under PN 2.5 to PN 16.',
      evidence: Evidence(
        standardCode: 'IS 4984:2016',
        clause: 'Scope',
        page: '1',
        sourceFile: '4984_2016_hdpe_water_pipes.pdf',
        textExcerpt:
            'Governing national standard for HDPE potable water pipes under Section 16 BIS Act 2016.',
      ),
    ),
    StandardsGraphNode(
      id: 'node-qco-pipes',
      code: 'Pipes and Fittings QCO 2021',
      title: 'Pipes and Fittings (Quality Control) Order, 2021',
      type: GraphNodeType.qco,
      categoryLabel: 'Mandatory QCO',
      relationship: 'GOVERNED BY QCO',
      status: 'MANDATORY REGULATION',
      description:
          'DPIIT Notification No. S.O. 4321(E) under Section 16 BIS Act 2016. Compulsory ISI Mark.',
      evidence: Evidence(
        standardCode: 'Pipes and Fittings QCO 2021',
        clause: 'Notification S.O. 4321(E)',
        page: '1',
        sourceFile: 'QCO_DPIIT_Plastic_Pipes_2021.pdf',
        textExcerpt:
            'Mandatory Quality Control Order prohibiting procurement of non-BIS certified HDPE pipes.',
      ),
    ),
    StandardsGraphNode(
      id: 'node-is4984-1995',
      code: 'IS 4984:1995',
      title: 'HDPE Pipes for Water Supply (Fourth Revision) [SUPERSEDED]',
      type: GraphNodeType.supersededStandard,
      categoryLabel: 'Superseded Edition',
      relationship: 'SUPERSEDED BY IS 4984:2016',
      status: 'SUPERSEDED — DO NOT CITE',
      description:
          'Superseded by IS 4984:2016. Citing this violates GFR 2017 Rule 144.',
    ),
    StandardsGraphNode(
      id: 'node-astm-d3035',
      code: 'ASTM D3035',
      title:
          'Polyethylene (PE) Plastic Pipe Based on Controlled Outside Diameter',
      type: GraphNodeType.foreignEquivalent,
      categoryLabel: 'Foreign Equivalent',
      relationship: 'HARMONIZED TO IS 4984',
      status: 'FOREIGN EQUIVALENT',
      description:
          'Foreign ASTM standard. Under GFR 144(vii), Indian Standard IS 4984:2016 takes precedence.',
    ),
    StandardsGraphNode(
      id: 'node-is7328',
      code: 'IS 7328:2020',
      title:
          'High Density Polyethylene Materials for Moulding and Extrusion',
      type: GraphNodeType.rawMaterial,
      categoryLabel: 'Raw Material',
      relationship: 'REQUIRES RAW MATERIAL',
      status: 'CURRENT',
      description:
          'Mandatory raw material specification for virgin PE-100 polyethylene resins.',
    ),
    StandardsGraphNode(
      id: 'node-is12235',
      code: 'IS 12235 (Parts 1 to 19)',
      title: 'Methods of Test for Unplasticized PVC and Polyethylene Pipes',
      type: GraphNodeType.testingProtocol,
      categoryLabel: 'Testing Protocol',
      relationship: 'REQUIRES TEST PROTOCOL',
      status: 'CURRENT',
      description:
          'Mandatory testing standards for internal hydrostatic pressure and dimensional verification.',
    ),
    StandardsGraphNode(
      id: 'node-is2530',
      code: 'IS 2530:1963',
      title: 'Methods of Test for Polyethylene Moulding Materials and Compounds',
      type: GraphNodeType.testingProtocol,
      categoryLabel: 'Testing Protocol',
      relationship: 'REQUIRES TEST PROTOCOL',
      status: 'CURRENT',
      description:
          'Testing protocols for melt flow index (MFI) and carbon black content/dispersion.',
    ),
    StandardsGraphNode(
      id: 'node-is14333',
      code: 'IS 14333:1996',
      title: 'High Density Polyethylene Pipes for Sewerage — Specification',
      type: GraphNodeType.alliedStandard,
      categoryLabel: 'Allied Standard',
      relationship: 'ALLIED SPECIFICATION',
      status: 'CURRENT',
      description: 'Allied standard for HDPE sewerage and industrial drainage.',
    ),
    StandardsGraphNode(
      id: 'node-is8008',
      code: 'IS 8008 (Parts 1 to 7)',
      title:
          'Injection Moulded High Density Polyethylene (HDPE) Fittings for Potable Water Supplies',
      type: GraphNodeType.alliedStandard,
      categoryLabel: 'Allied Standard',
      relationship: 'ALLIED FITTINGS',
      status: 'CURRENT',
      description:
          'Mandatory dimensions and specifications for electrofusion and butt-welded fittings.',
    ),
  ];

  static const List<StandardsGraphNode> steelGraphNodes = [
    StandardsGraphNode(
      id: 'node-is1786-2008',
      code: 'IS 1786:2008',
      title:
          'High Strength Deformed Steel Bars and Wires for Concrete Reinforcement — Specification',
      type: GraphNodeType.primaryStandard,
      categoryLabel: 'Primary Standard',
      relationship: 'CENTRAL GOVERNING STANDARD',
      status: 'CURRENT',
      description:
          'Fourth Revision covering thermo-mechanically treated (TMT) bars in Grade Fe 500D with Amendments 1, 2 & 3.',
      evidence: Evidence(
        standardCode: 'IS 1786:2008',
        clause: 'Scope',
        page: '1',
        sourceFile: '1786_2008_tmt_rebars.pdf',
        textExcerpt:
            'Governing national standard for TMT reinforcement steel bars under Section 16 BIS Act 2016.',
      ),
    ),
    StandardsGraphNode(
      id: 'node-qco-steel',
      code: 'Steel and Steel Products QCO 2012',
      title: 'Steel and Steel Products (Quality Control) Order, 2012 / 2020',
      type: GraphNodeType.qco,
      categoryLabel: 'Mandatory QCO',
      relationship: 'GOVERNED BY QCO',
      status: 'MANDATORY REGULATION',
      description:
          'Ministry of Steel Notification No. S.O. 463(E) / S.O. 2400(E). Compulsory Scheme-I ISI Mark.',
      evidence: Evidence(
        standardCode: 'Steel and Steel Products QCO 2012',
        clause: 'Notification S.O. 463(E)',
        page: '1',
        sourceFile: 'QCO_Ministry_of_Steel_2012.pdf',
        textExcerpt:
            'Mandatory Quality Control Order prohibiting procurement of non-BIS certified TMT rebars.',
      ),
    ),
    StandardsGraphNode(
      id: 'node-is1786-1985',
      code: 'IS 1786:1985',
      title: 'Cold-Worked Steel High Strength Deformed Bars [SUPERSEDED]',
      type: GraphNodeType.supersededStandard,
      categoryLabel: 'Superseded Edition',
      relationship: 'SUPERSEDED BY IS 1786:2008',
      status: 'SUPERSEDED — DO NOT CITE',
      description:
          'Superseded by IS 1786:2008. Citing this violates GFR 2017 Rule 144.',
    ),
    StandardsGraphNode(
      id: 'node-astm-a615',
      code: 'ASTM A615 Grade 60',
      title:
          'Deformed and Plain Carbon-Steel Bars for Concrete Reinforcement',
      type: GraphNodeType.foreignEquivalent,
      categoryLabel: 'Foreign Equivalent',
      relationship: 'HARMONIZED TO IS 1786',
      status: 'FOREIGN EQUIVALENT',
      description:
          'Foreign ASTM standard. Under GFR 144(vii), Indian Standard IS 1786:2008 Fe 500D takes legal precedence.',
    ),
    StandardsGraphNode(
      id: 'node-is2830',
      code: 'IS 2830:2012',
      title:
          'Carbon Steel Cast Billet Ingots, Billets, Blooms and Slabs for Re-Rolling',
      type: GraphNodeType.rawMaterial,
      categoryLabel: 'Raw Material',
      relationship: 'REQUIRES RAW MATERIAL',
      status: 'CURRENT',
      description:
          'Mandatory primary billet feedstock for rolling into TMT reinforcement bars.',
    ),
    StandardsGraphNode(
      id: 'node-is1608',
      code: 'IS 1608 (Part 1):2018',
      title: 'Metallic Materials — Tensile Testing at Room Temperature',
      type: GraphNodeType.testingProtocol,
      categoryLabel: 'Testing Protocol',
      relationship: 'REQUIRES TEST PROTOCOL',
      status: 'CURRENT',
      description:
          'Prescribed testing method for yield stress (≥500 N/mm²), tensile strength, and percentage elongation.',
    ),
    StandardsGraphNode(
      id: 'node-is1599',
      code: 'IS 1599:2019',
      title: 'Metallic Materials — Bend Test',
      type: GraphNodeType.testingProtocol,
      categoryLabel: 'Testing Protocol',
      relationship: 'REQUIRES TEST PROTOCOL',
      status: 'CURRENT',
      description:
          'Prescribed protocol for 180° bend and rebend testing of deformed reinforcement bars.',
    ),
    StandardsGraphNode(
      id: 'node-is228',
      code: 'IS 228',
      title: 'Methods for the Chemical Analysis of Steels',
      type: GraphNodeType.testingProtocol,
      categoryLabel: 'Testing Protocol',
      relationship: 'REQUIRES TEST PROTOCOL',
      status: 'CURRENT',
      description:
          'Chemical verification of carbon (≤0.25%), sulphur (≤0.040%), and phosphorus (≤0.040%).',
    ),
    StandardsGraphNode(
      id: 'node-is2502',
      code: 'IS 2502:1963',
      title: 'Code of Practice for Bending and Fixing of Bars for Concrete Reinforcement',
      type: GraphNodeType.alliedStandard,
      categoryLabel: 'Allied Standard',
      relationship: 'ALLIED INSTALLATION PRACTICE',
      status: 'CURRENT',
      description:
          'Standard guidelines for cutting, bending, and placement of rebars in concrete structures.',
    ),
  ];

  // ==========================================
  // HELPER QUERY METHODS PER PRESET
  // ==========================================
  static String normalizePresetId(String? id) {
    if (id == 'pipe' || id == 'steel') return id!;
    if (id == 'out_of_coverage' || id == 'unknown') return 'out_of_coverage';
    return 'transformer';
  }

  static TenderAnalysis getAnalysisForPreset(String? presetId) {
    final norm = normalizePresetId(presetId);
    if (norm == 'pipe') return pipeAnalysis;
    if (norm == 'steel') return steelAnalysis;
    if (norm == 'out_of_coverage') return outOfCoverageAnalysis;
    return transformerAnalysis;
  }

  static int getInitialScoreForPreset(String? presetId) {
    return getAnalysisForPreset(presetId).compliancePercentage;
  }

  static List<SpecificationBuildStep> getBuildStepsForPreset(String? presetId) {
    final norm = normalizePresetId(presetId);
    if (norm == 'pipe') return pipeBuildSteps;
    if (norm == 'steel') return steelBuildSteps;
    return transformerBuildSteps;
  }

  static List<String> getChecklistForPreset(String? presetId) {
    final norm = normalizePresetId(presetId);
    if (norm == 'pipe') return pipeStatutoryChecklist;
    if (norm == 'steel') return steelStatutoryChecklist;
    return transformerStatutoryChecklist;
  }

  static List<SpecificationSection> getInitialSectionsForPreset(
    String? presetId,
  ) {
    final norm = normalizePresetId(presetId);
    if (norm == 'pipe') return pipeInitialSections;
    if (norm == 'steel') return steelInitialSections;
    return transformerInitialSections;
  }

  static List<SpecificationSection> getFinalSectionsForPreset(
    String? presetId,
  ) {
    final norm = normalizePresetId(presetId);
    if (norm == 'pipe') return pipeFinalSections;
    if (norm == 'steel') return steelFinalSections;
    return defaultSpecificationSections;
  }

  static List<SpecificationSection> getSectionsWithAppliedSteps(
    String? presetId,
    Set<String> appliedStepIds,
  ) {
    final steps = getBuildStepsForPreset(presetId);
    final initial = getInitialSectionsForPreset(presetId);
    final finalSecs = getFinalSectionsForPreset(presetId);

    // If all steps applied, return the clean final sections directly
    if (appliedStepIds.length == steps.length) {
      return List.from(finalSecs);
    }

    // Otherwise, copy initial sections and mutate only the ones touched by applied steps
    final result = initial.map((sec) => sec).toList();

    for (final step in steps) {
      if (!appliedStepIds.contains(step.id)) continue;

      final targetIdx = result.indexWhere((s) => s.id == step.targetSectionId);
      if (targetIdx != -1) {
        final currentSec = result[targetIdx];
        final finalSec = finalSecs.firstWhere(
          (s) => s.id == step.targetSectionId,
          orElse: () => currentSec,
        );

        result[targetIdx] = SpecificationSection(
          id: currentSec.id,
          sectionNumber: currentSec.sectionNumber,
          title: currentSec.title,
          status: 'VERIFIED',
          content: finalSec.content,
          recommendation: finalSec.recommendation,
          suggestedAppend: finalSec.suggestedAppend,
          evidence: step.evidence ?? finalSec.evidence,
        );
      }
    }

    return result;
  }

  static Map<String, String> getGoverningStandardInfo(String? presetId) {
    final norm = normalizePresetId(presetId);
    if (norm == 'pipe') {
      return {
        'code': 'IS 4984:2016',
        'title':
            'High Density Polyethylene Pipes for Water Supply — Specification',
        'badge': 'Primary: IS 4984:2016',
      };
    }
    if (norm == 'steel') {
      return {
        'code': 'IS 1786:2008',
        'title':
            'High Strength Deformed Steel Bars and Wires for Concrete Reinforcement — Specification (Fe 500D)',
        'badge': 'Primary: IS 1786:2008',
      };
    }
    return {
      'code': 'IS 1180 (Part 1):2014',
      'title':
          'Outdoor Type Three-Phase Distribution Transformers Up To and Including 2500 kVA, 33 kV — Specification',
      'badge': 'Primary: IS 1180 (Part 1):2014',
    };
  }

  static String getDiffOriginalForPreset(String? presetId) {
    final norm = normalizePresetId(presetId);
    if (norm == 'pipe') return pipeOriginalDefectiveClause;
    if (norm == 'steel') return steelOriginalDefectiveClause;
    return transformerOriginalDefectiveClause;
  }

  static String getDiffRectifiedForPreset(String? presetId) {
    final norm = normalizePresetId(presetId);
    if (norm == 'pipe') return pipeRectifiedCompliantClause;
    if (norm == 'steel') return steelRectifiedCompliantClause;
    return transformerRectifiedCompliantClause;
  }

  static String getDiffItemTitleForPreset(String? presetId) {
    final norm = normalizePresetId(presetId);
    if (norm == 'pipe') {
      return 'Specification Redline: HDPE Water Supply Pipes';
    }
    if (norm == 'steel') {
      return 'Specification Redline: TMT Reinforcement Steel';
    }
    return 'Specification Redline: Distribution Transformers';
  }

  static String getDiffStatutoryActionForPreset(String? presetId) {
    final norm = normalizePresetId(presetId);
    if (norm == 'pipe') return pipeDiffStatutoryAction;
    if (norm == 'steel') return steelDiffStatutoryAction;
    return transformerDiffStatutoryAction;
  }

  static List<StandardsGraphNode> getGraphNodesForPreset(String? presetId) {
    final norm = normalizePresetId(presetId);
    if (norm == 'pipe') return pipeGraphNodes;
    if (norm == 'steel') return steelGraphNodes;
    return transformerGraphNodes;
  }

  // ==========================================
  // KNOWLEDGE GRAPH DIRECTED EDGES & BUNDLES
  // ==========================================
  static const List<StandardsGraphEdge> transformerGraphEdges = [
    StandardsGraphEdge(
      sourceId: 'node-is1180-2014',
      targetId: 'node-qco-transformers',
      relationship: 'GOVERNED_BY_QCO',
      label: 'governed_by_qco',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is1180-2014',
      targetId: 'node-is1180-1989',
      relationship: 'SUPERSEDES',
      label: 'supersedes',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is1180-2014',
      targetId: 'node-is335-2018',
      relationship: 'REQUIRES_MATERIAL',
      label: 'insulating_oil',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is335-2018',
      targetId: 'node-is335-1993',
      relationship: 'SUPERSEDES',
      label: 'supersedes',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is1180-2014',
      targetId: 'node-is12444',
      relationship: 'REQUIRES_MATERIAL',
      label: 'copper_conductors',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is1180-2014',
      targetId: 'node-is3024',
      relationship: 'REQUIRES_MATERIAL',
      label: 'crgo_steel',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is1180-2014',
      targetId: 'node-is2026',
      relationship: 'REQUIRES_TEST',
      label: 'routine_type_tests',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is1180-2014',
      targetId: 'node-is6792',
      relationship: 'REQUIRES_TEST',
      label: 'oil_bdv_test',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is1180-2014',
      targetId: 'node-is3347',
      relationship: 'ALLIED_WITH',
      label: 'bushings_standard',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is1180-2014',
      targetId: 'node-is3639',
      relationship: 'ALLIED_WITH',
      label: 'fittings_accessories',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is1180-2014',
      targetId: 'node-iec60076',
      relationship: 'EQUIVALENT_TO',
      label: 'harmonized_iec',
    ),
  ];

  static const List<StandardsGraphEdge> pipeGraphEdges = [
    StandardsGraphEdge(
      sourceId: 'node-is4984-2016',
      targetId: 'node-qco-pipes',
      relationship: 'GOVERNED_BY_QCO',
      label: 'governed_by_qco',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is4984-2016',
      targetId: 'node-is4984-1995',
      relationship: 'SUPERSEDES',
      label: 'supersedes',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is4984-2016',
      targetId: 'node-is7328',
      relationship: 'REQUIRES_MATERIAL',
      label: 'virgin_pe100_resin',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is4984-2016',
      targetId: 'node-is12235',
      relationship: 'REQUIRES_TEST',
      label: 'hydrostatic_tests',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is4984-2016',
      targetId: 'node-is2530',
      relationship: 'REQUIRES_TEST',
      label: 'mfi_carbon_tests',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is4984-2016',
      targetId: 'node-is14333',
      relationship: 'ALLIED_WITH',
      label: 'sewerage_pipes',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is4984-2016',
      targetId: 'node-is8008',
      relationship: 'ALLIED_WITH',
      label: 'butt_welded_fittings',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is4984-2016',
      targetId: 'node-astm-d3035',
      relationship: 'EQUIVALENT_TO',
      label: 'foreign_equivalent',
    ),
  ];

  static const List<StandardsGraphEdge> steelGraphEdges = [
    StandardsGraphEdge(
      sourceId: 'node-is1786-2008',
      targetId: 'node-qco-steel',
      relationship: 'GOVERNED_BY_QCO',
      label: 'governed_by_qco',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is1786-2008',
      targetId: 'node-is1786-1985',
      relationship: 'SUPERSEDES',
      label: 'supersedes',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is1786-2008',
      targetId: 'node-is2830',
      relationship: 'REQUIRES_MATERIAL',
      label: 'primary_billets',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is1786-2008',
      targetId: 'node-is1608',
      relationship: 'REQUIRES_TEST',
      label: 'tensile_yield_test',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is1786-2008',
      targetId: 'node-is1599',
      relationship: 'REQUIRES_TEST',
      label: 'bend_rebend_test',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is1786-2008',
      targetId: 'node-is228',
      relationship: 'REQUIRES_TEST',
      label: 'chemical_analysis',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is1786-2008',
      targetId: 'node-is2502',
      relationship: 'ALLIED_WITH',
      label: 'bending_fixing_code',
    ),
    StandardsGraphEdge(
      sourceId: 'node-is1786-2008',
      targetId: 'node-astm-a615',
      relationship: 'EQUIVALENT_TO',
      label: 'foreign_equivalent',
    ),
  ];

  static StandardsGraphBundle getGraphBundleForPreset(String? presetId) {
    final norm = normalizePresetId(presetId);
    if (norm == 'pipe') {
      return StandardsGraphBundle(
        rootNode: pipeGraphNodes.first,
        nodes: pipeGraphNodes,
        edges: pipeGraphEdges,
      );
    }
    if (norm == 'steel') {
      return StandardsGraphBundle(
        rootNode: steelGraphNodes.first,
        nodes: steelGraphNodes,
        edges: steelGraphEdges,
      );
    }
    return StandardsGraphBundle(
      rootNode: transformerGraphNodes.first,
      nodes: transformerGraphNodes,
      edges: transformerGraphEdges,
    );
  }

  static StandardsGraphBundle getGraphBundleForStandard(String code) {
    final clean = code.toUpperCase();
    if (clean.contains('4984') || clean.contains('PIPE')) {
      return getGraphBundleForPreset('pipe');
    }
    if (clean.contains('1786') ||
        clean.contains('STEEL') ||
        clean.contains('TMT')) {
      return getGraphBundleForPreset('steel');
    }
    return getGraphBundleForPreset('transformer');
  }

  // ==========================================
  // PHASE 4: IMAGE CLAUSE ANALYZER CANONICAL MOCK DATA
  // ==========================================
  static const String imageClauseExtractedText =
      'SECTION 4.2 — TECHNICAL SPECIFICATION:\n'
      'Supply of 500 kVA Substation Distribution Transformer.\n'
      'The design, manufacture and routine testing shall strictly conform to Indian Standard IS 1180:1989.\n'
      'Insulating oil shall conform to IS 335:1993.\n'
      'High voltage bushings shall be ABB or Siemens make only.';

  static const String imageClauseDetectedStandard = 'IS 1180:1989';
  static const String imageClauseReplacementStandard = 'IS 1180 (Part 1):2014';
  static const String imageClauseStatus = 'OBSOLETE / SUPERSEDED';

  static const String imageClauseFindingTitle =
      'Cited BIS Standard is Obsolete & Superseded';
  static const String imageClauseFindingDescription =
      'The technical clause mandates compliance with IS 1180:1989, which was officially superseded by IS 1180 (Part 1):2014 under the Distribution Transformers (Quality Control) Order, 2014 (S.O. 1621(E)).';
  static const String imageClauseStatutoryAction =
      'Replace IS 1180:1989 with active standard IS 1180 (Part 1):2014 and mandate BIS Standard Mark (ISI license) under Section 16 of the BIS Act, 2016.';

  static Evidence get imageClauseEvidence =>
      transformerAnalysis.detectedStandards[0].evidence!;

  // ==========================================
  // BILL OF QUANTITIES (BoQ) AUDIT SAMPLE
  // ==========================================
  static const BoQAuditResult sampleBoQAuditResult = BoQAuditResult(
    fileName: 'municipal_procurement_boq.xlsx',
    totalItems: 5,
    passCount: 2,
    warnCount: 1,
    failCount: 2,
    statutoryComplianceScore: 40,
    items: [
      BoQItem(
        itemNumber: 'ITEM 01',
        description:
            '500 kVA, 11 kV / 433 V Outdoor Oil-Immersed Distribution Transformer',
        quantity: '4',
        unit: 'Nos',
        citedStandard: 'IS 1180:1989',
        status: BoQStatus.fail,
        recommendedStandard: 'IS 1180 (Part 1):2014 Amd 1-4',
        statutoryDefect:
            'Obsolete 1989 edition cited + ABB/Siemens proprietary bushing restriction.',
        recommendedAction:
            'Upgrade to IS 1180 (Part 1):2014; remove brand lock-in; mandate BIS Scheme-I ISI mark.',
        mandatoryQcoCited: false,
        isBrandLocked: true,
      ),
      BoQItem(
        itemNumber: 'ITEM 02',
        description: 'HDPE Water Supply Pipe 110mm OD PN 10 SDR 11',
        quantity: '2,500',
        unit: 'Mtrs',
        citedStandard: 'IS 4984:1995 / ASTM D3035',
        status: BoQStatus.fail,
        recommendedStandard: 'IS 4984:2016 (PE-100)',
        statutoryDefect:
            'Superseded fourth revision + Supreme/Astral make restriction.',
        recommendedAction:
            'Mandate IS 4984:2016 PE-100 grade; brand-neutral specification.',
        mandatoryQcoCited: false,
        isBrandLocked: true,
      ),
      BoQItem(
        itemNumber: 'ITEM 03',
        description:
            'Cast Iron Sluice Valves 150mm Nominal Diameter PN 1.6',
        quantity: '12',
        unit: 'Nos',
        citedStandard: 'IS 14846:2000',
        status: BoQStatus.warn,
        recommendedStandard: 'IS 14846:2000 + Valves QCO 2023',
        statutoryDefect:
            'Correct standard cited but omits mandatory DPIIT Quality Control Order Scheme-I citation.',
        recommendedAction:
            'Incorporate Valves (Quality Control) Order 2023 compliance clause.',
        mandatoryQcoCited: false,
        isBrandLocked: false,
      ),
      BoQItem(
        itemNumber: 'ITEM 04',
        description: 'Galvanized Mild Steel Binding Wire 4mm Diameter',
        quantity: '500',
        unit: 'Kg',
        citedStandard: 'IS 280:2006',
        status: BoQStatus.pass,
        recommendedStandard: 'IS 280:2006 (Current)',
        statutoryDefect:
            'None. Fully compliant with Steel Wire QCO and GFR 144(vii).',
        recommendedAction: 'Approved for technical tender schedule.',
        mandatoryQcoCited: true,
        isBrandLocked: false,
      ),
      BoQItem(
        itemNumber: 'ITEM 05',
        description: 'Ductile Iron Flanged Pipe Fittings 200mm Diameter',
        quantity: '24',
        unit: 'Nos',
        citedStandard: 'IS 9523:2000',
        status: BoQStatus.pass,
        recommendedStandard: 'IS 9523:2000 (Current)',
        statutoryDefect:
            'None. Generic technical description; active standard with ISI Mark.',
        recommendedAction: 'Approved for technical tender schedule.',
        mandatoryQcoCited: true,
        isBrandLocked: false,
      ),
    ],
  );

  // ==========================================
  // COMPREHENSIVE STANDARDS EXPLORER CATALOG
  // ==========================================
  static const List<Standard> allStandardsCatalog = [
    Standard(
      code: 'IS 1180 (Part 1):2014',
      title:
          'Outdoor Type Three-Phase Distribution Transformers Up To and Including 2500 kVA, 33 kV — Specification',
      status: 'CURRENT',
      division: 'Electrotechnical',
      scope:
          'Covers requirements and tests for outdoor type three-phase distribution transformers up to and including 2500 kVA, 33 kV.',
      edition: 'Fifth Revision',
      amendments: [
        'Amd 1 (2016)',
        'Amd 2 (2019)',
        'Amd 3 (2021)',
        'Amd 4 (2023)',
      ],
      mandatoryQco:
          'Distribution Transformers (Quality Control) Order, 2014',
      isQcoMandatory: true,
      relatedStandards: [
        'IS 335:2018',
        'IS 2099:2018',
        'IS 2026 (Part 1):2011',
      ],
    ),
    Standard(
      code: 'IS 1180:1989',
      title:
          'Outdoor Type Three-Phase Distribution Transformers — Specification',
      status: 'SUPERSEDED',
      replacementCode: 'IS 1180 (Part 1):2014',
      division: 'Electrotechnical',
      scope:
          'Superseded fourth revision. Citing this standard in public tenders violates GFR 2017 Rule 144.',
      edition: 'Fourth Revision (Obsolete)',
      relatedStandards: ['IS 1180 (Part 1):2014'],
    ),
    Standard(
      code: 'IS 335:2018',
      title: 'New Insulating Oils — Specification',
      status: 'CURRENT',
      division: 'Electrotechnical',
      scope:
          'Specifies requirements and test methods for unused mineral insulating oils as delivered, for transformers, switchgear and similar electrical equipment.',
      edition: 'Fifth Revision',
      amendments: ['Amd 1 (2020)'],
      relatedStandards: ['IS 1180 (Part 1):2014', 'IS 1866:2020'],
    ),
    Standard(
      code: 'IS 335:1993',
      title: 'New Insulating Oils — Specification',
      status: 'SUPERSEDED',
      replacementCode: 'IS 335:2018',
      division: 'Electrotechnical',
      scope:
          'Superseded fourth revision. Must be replaced with IS 335:2018 in all electrical procurement.',
      edition: 'Fourth Revision (Obsolete)',
      relatedStandards: ['IS 335:2018'],
    ),
    Standard(
      code: 'IS 4984:2016',
      title:
          'High Density Polyethylene Pipes for Water Supply — Specification',
      status: 'CURRENT',
      division: 'Civil Engineering',
      scope:
          'Covers requirements for high density polyethylene (HDPE) pipes from 16 mm to 1000 mm nominal diameter for water supply.',
      edition: 'Fifth Revision',
      amendments: ['Amd 1 (2018)', 'Amd 2 (2021)'],
      mandatoryQco: 'Pipes and Fittings (Quality Control) Order, 2021',
      isQcoMandatory: true,
      relatedStandards: ['IS 2530:1963', 'IS 4985:2021', 'IS 7634 (Part 2):2012'],
    ),
    Standard(
      code: 'IS 4984:1995',
      title:
          'High Density Polyethylene Pipes for Water Supply — Specification',
      status: 'SUPERSEDED',
      replacementCode: 'IS 4984:2016',
      division: 'Civil Engineering',
      scope: 'Superseded fourth revision of HDPE pipe specification.',
      edition: 'Fourth Revision (Obsolete)',
      relatedStandards: ['IS 4984:2016'],
    ),
    Standard(
      code: 'IS 1786:2008',
      title:
          'High Strength Deformed Steel Bars and Wires for Concrete Reinforcement — Specification (Fe 500D)',
      status: 'CURRENT',
      division: 'Civil Engineering',
      scope:
          'Covers technical requirements and tests for high strength deformed steel bars and wires of grades Fe 415, Fe 415D, Fe 500, Fe 500D, Fe 550, Fe 550D and Fe 600.',
      edition: 'Fourth Revision',
      amendments: ['Amd 1 (2012)', 'Amd 2 (2014)', 'Amd 3 (2018)'],
      mandatoryQco:
          'Steel and Steel Products (Quality Control) Order, 2020',
      isQcoMandatory: true,
      relatedStandards: ['IS 432 (Part 1):1982', 'IS 2062:2011'],
    ),
    Standard(
      code: 'IS 2099:2018',
      title:
          'Bushings for Alternating Voltages Above 1000 V — Specification',
      status: 'CURRENT',
      division: 'Electrotechnical',
      scope:
          'Applicable to outdoor and indoor bushings of ceramic, glass, or composite materials for alternating voltages above 1000 V.',
      edition: 'Third Revision',
      relatedStandards: ['IS 1180 (Part 1):2014', 'IS 3347'],
    ),
    Standard(
      code: 'IS 2026 (Part 1):2011',
      title: 'Power Transformers — Part 1: General',
      status: 'CURRENT',
      division: 'Electrotechnical',
      scope:
          'Applies to three-phase and single-phase power transformers (including auto-transformers).',
      edition: 'Second Revision',
      relatedStandards: ['IS 1180 (Part 1):2014', 'IS 2026 (Part 2)'],
    ),
    Standard(
      code: 'IS 2530:1963',
      title: 'Methods for Testing Plastics — Polyethylene',
      status: 'CURRENT',
      division: 'Chemical',
      scope:
          'Specifies test methods for determination of density, melt flow rate, carbon black content and dispersion in polyethylene materials.',
      edition: 'First Edition',
      relatedStandards: ['IS 4984:2016'],
    ),
    Standard(
      code: 'IS 9523:2000',
      title:
          'Ductile Iron Fittings for Pressure Pipes for Water, Gas and Sewage — Specification',
      status: 'CURRENT',
      division: 'Mechanical',
      scope:
          'Covers requirements for ductile iron fittings suitable for jointing with ductile iron pipes.',
      edition: 'Second Revision',
      mandatoryQco:
          'Ductile Iron Products (Quality Control) Order, 2022',
      isQcoMandatory: true,
      relatedStandards: ['IS 8329:2000'],
    ),
    Standard(
      code: 'IS 14846:2000',
      title:
          'Sluice Valves for Water Works Purposes (50 to 1200 mm Size) — Specification',
      status: 'CURRENT',
      division: 'Mechanical',
      scope:
          'Specifies requirements for flanged sluice valves from 50 mm to 1200 mm size with inside screw, non-rising stem or outside screw rising stem.',
      edition: 'First Edition',
      mandatoryQco: 'Valves (Quality Control) Order, 2023',
      isQcoMandatory: true,
      relatedStandards: ['IS 778:1984'],
    ),
    Standard(
      code: 'IS 280:2006',
      title:
          'Mild Steel Wire for General Engineering Purposes — Specification',
      status: 'CURRENT',
      division: 'Metallurgical',
      scope:
          'Covers requirements for mild steel wire of 0.122 mm to 12.5 mm diameter for general engineering purposes.',
      edition: 'Fourth Revision',
      mandatoryQco: 'Steel Wire (Quality Control) Order, 2021',
      isQcoMandatory: true,
      relatedStandards: ['IS 1786:2008'],
    ),
    Standard(
      code: 'IS 694:2010',
      title:
          'Polyvinyl Chloride Insulated Unsheathed and Sheathed Cables/Cords with Rigid and Flexible Conductor for Working Voltages up to and Including 450/750 V — Specification',
      status: 'CURRENT',
      division: 'Electrotechnical',
      scope:
          'Specifies requirements for PVC insulated electric cables for working voltages up to 1100 V.',
      edition: 'Fourth Revision',
      mandatoryQco:
          'Cables and Wires (Quality Control) Order, 2019',
      isQcoMandatory: true,
      relatedStandards: ['IS 1554 (Part 1):1988'],
    ),
    Standard(
      code: 'IS 9537 (Part 1):1980',
      title:
          'Conduits for Electrical Installations — Part 1: General Requirements',
      status: 'CURRENT',
      division: 'Electrotechnical',
      scope:
          'Specifies requirements for conduits for electrical installations.',
      edition: 'First Edition',
      relatedStandards: ['IS 9537 (Part 2):1981'],
    ),
  ];

  // ==========================================
  // QUALITY CONTROL ORDERS (QCO) MASTER CATALOG
  // ==========================================
  static const List<QcoOrder> allQcoOrdersCatalog = [
    QcoOrder(
      id: 'qco-transformers',
      orderName: 'Electrical Transformers (Quality Control) Order, 2024',
      gazetteNo: 'S.O. 458(E)',
      ministry: 'Ministry of Heavy Industries & Power',
      scheme: 'Scheme-I (ISI Mark)',
      enforcementDate: '01 Jan 2025',
      status: 'ACTIVE',
      standards: ['IS 1180 (Part 1):2014', 'IS 2026 (Part 1):2011'],
      msmeConcession: '6 months extension for micro enterprises',
      statutoryNote:
          'Mandates compulsory Scheme-I ISI marking under Section 16 BIS Act, 2016. Prohibits manufacture, storage, and procurement of non-certified distribution transformers.',
    ),
    QcoOrder(
      id: 'qco-pipes',
      orderName: 'Pipes and Fittings (Quality Control) Order, 2020',
      gazetteNo: 'S.O. 1289(E)',
      ministry: 'Ministry of Chemicals & Fertilizers',
      scheme: 'Scheme-I (ISI Mark)',
      enforcementDate: '15 Mar 2021',
      status: 'ACTIVE',
      standards: ['IS 4984:2016', 'IS 4985:2021', 'IS 12235'],
      msmeConcession: 'No exemption on potable water distribution conduits',
      statutoryNote:
          'Prohibits procurement of non-BIS certified HDPE and uPVC pipes for municipal and drinking water networks under penal sanctions.',
    ),
    QcoOrder(
      id: 'qco-steel',
      orderName: 'Steel and Steel Products (Quality Control) Order, 2020',
      gazetteNo: 'S.O. 1678(E)',
      ministry: 'Ministry of Steel',
      scheme: 'Scheme-I (ISI Mark)',
      enforcementDate: '18 Dec 2020',
      status: 'ACTIVE',
      standards: ['IS 1786:2008', 'IS 2062:2011', 'IS 432 (Part 1):1982'],
      msmeConcession:
          'Standard BIS concession for secondary rolling mills with valid BIS license',
      statutoryNote:
          'Mandates Scheme-I ISI Mark prior to dispatch. Foreign standards such as ASTM A615 cannot be accepted without domestic BIS equivalence.',
    ),
    QcoOrder(
      id: 'qco-cables',
      orderName: 'Electrical Wires and Cables (Quality Control) Order, 2023',
      gazetteNo: 'S.O. 3145(E)',
      ministry: 'Ministry of Commerce and Industry (DPIIT)',
      scheme: 'Scheme-I (ISI Mark)',
      enforcementDate: '01 Sep 2023',
      status: 'ACTIVE',
      standards: ['IS 694:2010', 'IS 1554 (Part 1):1988'],
      msmeConcession:
          'Standard 3-month transition window for small manufacturers',
      statutoryNote:
          'Mandates ISI mark on PVC and XLPE insulated building wires and control cables.',
    ),
    QcoOrder(
      id: 'qco-valves',
      orderName:
          'Valves and Waterworks Fittings (Quality Control) Order, 2023',
      gazetteNo: 'S.O. 2219(E)',
      ministry: 'Ministry of Commerce and Industry (DPIIT)',
      scheme: 'Scheme-I (ISI Mark)',
      enforcementDate: '01 Nov 2023',
      status: 'ACTIVE',
      standards: ['IS 14846:2000', 'IS 9523:2000'],
      msmeConcession: '6 months extension for micro manufacturers',
      statutoryNote:
          'Compulsory BIS certification for sluice valves, butterfly valves, and ductile iron pressure fittings.',
    ),
    QcoOrder(
      id: 'qco-water',
      orderName: 'Drinking Water (Quality Control) Order, 2021',
      gazetteNo: 'S.O. 882(E)',
      ministry:
          'Ministry of Consumer Affairs, Food & Public Distribution',
      scheme: 'Scheme-I (ISI Mark)',
      enforcementDate: '01 Jan 2022',
      status: 'ACTIVE',
      standards: ['IS 10500:2012'],
      msmeConcession: 'Mandatory across all public water utilities',
      statutoryNote:
          'Prescribes uniform statutory water quality parameters across all municipal distribution grids.',
    ),
  ];

  // ==========================================
  // EDITABLE TECHNICAL PARAMETERS & CONFLICT LOGIC
  // ==========================================
  static List<SpecificationParameter> getParametersForPreset(String? presetId) {
    final norm = normalizePresetId(presetId);
    if (norm == 'pipe') {
      return [
        const SpecificationParameter(
          id: 'pipe-mat',
          name: 'Material Grade',
          currentValue: 'PE-100',
          options: ['PE-100', 'PE-80', 'PE-63'],
          standardReference: 'IS 4984:2016 Table 1',
        ),
        const SpecificationParameter(
          id: 'pipe-pn',
          name: 'Pressure Rating',
          currentValue: 'PN 10',
          options: ['PN 6', 'PN 10', 'PN 12.5', 'PN 16'],
          standardReference: 'IS 4984:2016 Table 2',
        ),
        const SpecificationParameter(
          id: 'pipe-sdr',
          name: 'Standard Dimension Ratio',
          currentValue: 'SDR 11',
          options: ['SDR 17', 'SDR 13.6', 'SDR 11', 'SDR 9'],
          standardReference: 'IS 4984:2016 Table 2',
        ),
        const SpecificationParameter(
          id: 'pipe-dia',
          name: 'Nominal Outer Diameter',
          currentValue: '110 mm',
          options: ['110 mm', '160 mm', '200 mm', '315 mm', '500 mm'],
          standardReference: 'IS 4984:2016 Table 3',
        ),
      ];
    }
    if (norm == 'steel') {
      return [
        const SpecificationParameter(
          id: 'steel-grade',
          name: 'Steel Strength Grade',
          currentValue: 'Fe 500D',
          options: [
            'Fe 415',
            'Fe 415D',
            'Fe 500',
            'Fe 500D',
            'Fe 550D',
            'ASTM A615 (Foreign)',
          ],
          standardReference: 'IS 1786:2008 Table 3',
        ),
        const SpecificationParameter(
          id: 'steel-dia',
          name: 'Nominal Bar Diameter',
          currentValue: '16 mm',
          options: [
            '8 mm',
            '10 mm',
            '12 mm',
            '16 mm',
            '20 mm',
            '25 mm',
            '32 mm',
          ],
          standardReference: 'IS 1786:2008 Table 1',
        ),
        const SpecificationParameter(
          id: 'steel-producer',
          name: 'Approved Producer Scope',
          currentValue: 'Any BIS Certified Producer',
          options: [
            'Any BIS Certified Producer',
            'Tata / Jindal Lock-in',
            'Primary Producers Only',
          ],
          standardReference: 'CVC OM No. 03-05-01',
        ),
      ];
    }
    // Default: transformer
    return [
      const SpecificationParameter(
        id: 'trans-rating',
        name: 'Rated Output Power',
        currentValue: '500 kVA',
        options: ['100 kVA', '250 kVA', '500 kVA', '1000 kVA'],
        standardReference: 'IS 1180 (Part 1):2014 Table 1',
      ),
      const SpecificationParameter(
        id: 'trans-voltage',
        name: 'Primary / Secondary Voltage',
        currentValue: '11 kV / 433 V',
        options: ['11 kV / 433 V', '22 kV / 433 V', '33 kV / 433 V'],
        standardReference: 'IS 1180 (Part 1):2014 Table 1',
      ),
      const SpecificationParameter(
        id: 'trans-oil',
        name: 'Insulating Dielectric Fluid',
        currentValue: 'IS 335:2018 Mineral Oil',
        options: [
          'IS 335:2018 Mineral Oil',
          'IS 335:1993 (Obsolete)',
          'Synthetic Ester to IS 16081',
        ],
        standardReference: 'IS 335:2018 Clause 4',
      ),
      const SpecificationParameter(
        id: 'trans-bushing',
        name: 'High Voltage Bushing Type',
        currentValue: 'Generic IS 2099 Porcelain',
        options: [
          'Generic IS 2099 Porcelain',
          'ABB Make Lock-in',
          'Siemens Make Lock-in',
        ],
        standardReference: 'IS 2099:2018 & CVC Rules',
      ),
    ];
  }

  static List<SpecificationParameter> evaluateParameterConflicts(
    String? presetId,
    List<SpecificationParameter> params,
  ) {
    final norm = normalizePresetId(presetId);
    return params.map((p) {
      if (norm == 'pipe') {
        final mat = params
            .firstWhere(
              (x) => x.id == 'pipe-mat',
              orElse: () => p,
            )
            .currentValue;
        final pn = params
            .firstWhere(
              (x) => x.id == 'pipe-pn',
              orElse: () => p,
            )
            .currentValue;
        final sdr = params
            .firstWhere(
              (x) => x.id == 'pipe-sdr',
              orElse: () => p,
            )
            .currentValue;

        if (p.id == 'pipe-mat' || p.id == 'pipe-pn' || p.id == 'pipe-sdr') {
          if (mat == 'PE-80' && pn == 'PN 16' && sdr == 'SDR 11') {
            return p.copyWith(
              hasConflict: true,
              isVerified: false,
              conflictReason:
                  'CONFLICT: PE-80 material at SDR 11 cannot sustain PN 16 pressure under IS 4984 Table 2. Upgrade to PE-100 or reduce SDR to SDR 9.',
            );
          }
          if (mat == 'PE-63' && (pn == 'PN 10' || pn == 'PN 16')) {
            return p.copyWith(
              hasConflict: true,
              isVerified: false,
              conflictReason:
                  'CONFLICT: PE-63 material is obsolete for municipal pressure networks above PN 6 under BIS guidelines.',
            );
          }
        }
      } else if (norm == 'steel') {
        if (p.id == 'steel-grade' && p.currentValue.contains('ASTM')) {
          return p.copyWith(
            hasConflict: true,
            isVerified: false,
            conflictReason:
                'CONFLICT: Citing foreign standard ASTM A615 violates GFR 2017 Rule 144(vii). Must cite IS 1786:2008 Fe 500D.',
          );
        }
        if (p.id == 'steel-producer' && p.currentValue.contains('Lock-in')) {
          return p.copyWith(
            hasConflict: true,
            isVerified: false,
            conflictReason:
                'CONFLICT: Specifying proprietary trade names violates CVC Anti-Tailoring Directives. Must remain manufacturer-neutral.',
          );
        }
      } else {
        if (p.id == 'trans-oil' && p.currentValue.contains('1993')) {
          return p.copyWith(
            hasConflict: true,
            isVerified: false,
            conflictReason:
                'CONFLICT: IS 335:1993 is superseded by IS 335:2018. Citing obsolete standards violates quality directives.',
          );
        }
        if (p.id == 'trans-bushing' && p.currentValue.contains('Lock-in')) {
          return p.copyWith(
            hasConflict: true,
            isVerified: false,
            conflictReason:
                'CONFLICT: Vendor brand lock-in violates CVC guidelines. Must cite generic IS 2099 specifications.',
          );
        }
      }
      return p.copyWith(
        hasConflict: false,
        isVerified: true,
        conflictReason: null,
      );
    }).toList();
  }

  // ==========================================
  // HUMAN REVIEW ACTIONS INITIAL STATE
  // ==========================================
  static List<ReviewAction> getInitialReviewActions(String? presetId) {
    final norm = normalizePresetId(presetId);
    if (norm == 'pipe') {
      return const [
        ReviewAction(
          findingId: 'pipe-flag-0',
          status: ReviewStatus.pending,
          officerName: officerName,
          officerId: officerId,
          formattedTimestamp: '11-Sep-2026, 14:15 IST',
        ),
        ReviewAction(
          findingId: 'pipe-flag-1',
          status: ReviewStatus.pending,
          officerName: officerName,
          officerId: officerId,
          formattedTimestamp: '11-Sep-2026, 14:15 IST',
        ),
      ];
    }
    if (norm == 'steel') {
      return const [
        ReviewAction(
          findingId: 'steel-flag-0',
          status: ReviewStatus.pending,
          officerName: officerName,
          officerId: officerId,
          formattedTimestamp: '11-Sep-2026, 11:30 IST',
        ),
        ReviewAction(
          findingId: 'steel-flag-1',
          status: ReviewStatus.pending,
          officerName: officerName,
          officerId: officerId,
          formattedTimestamp: '11-Sep-2026, 11:30 IST',
        ),
      ];
    }
    return const [
      ReviewAction(
        findingId: 'trans-flag-0',
        status: ReviewStatus.pending,
        officerName: officerName,
        officerId: officerId,
        formattedTimestamp: '11-Sep-2026, 09:45 IST',
      ),
      ReviewAction(
        findingId: 'trans-flag-1',
        status: ReviewStatus.pending,
        officerName: officerName,
        officerId: officerId,
        formattedTimestamp: '11-Sep-2026, 09:45 IST',
      ),
    ];
  }

  // ==========================================
  // PHASE 5: DECISION TRACE, WHY THIS STANDARD & AMENDMENT DIFF
  // ==========================================
  static DecisionTrace getDecisionTraceForPreset(String? presetId) {
    final norm = normalizePresetId(presetId);
    if (norm == 'out_of_coverage') {
      return const DecisionTrace(
        tenderId: 'NIT-UNKNOWN-000',
        tenderTitle: 'Unindexed Commodity Specification',
        department: 'General Procurement Directorate',
        inputClause: 'Unindexed tender specification',
        extractedRequirements: [
          TraceRequirement(
            parameter: 'Product Classification',
            specifiedValue: 'Unindexed Commodity / Clause',
            state: KnowledgeState.outOfCoverage,
            note: 'No semantic match in 23,000+ indexed Indian Standards.',
          ),
          TraceRequirement(
            parameter: 'Standards Citation',
            specifiedValue: 'None detected or unverified code',
            state: KnowledgeState.unknown,
            note: 'Insufficient evidence to resolve governing Sectional Committee schedule.',
          ),
        ],
        retrievedCandidates: [],
        selectionReason:
            'No matching Indian Standard could be authoritatively selected. Dataset coverage does not currently index this product category.',
        exclusionReasons: [
          'All indexed standard clusters rejected due to lack of semantic and scope alignment.',
        ],
        selectedStandard: null,
        lifecycleState: 'OUT-OF-COVERAGE',
        evidence: null,
        verificationState: KnowledgeState.outOfCoverage,
        finalRecommendation:
            'Initiate manual standards inquiry on BIS Manakonline portal (manakonline.in) or request standard specification from the administrative ministry.',
        humanApprovalState: 'MANUAL ACTION REQUIRED',
      );
    }
    if (norm == 'pipe') {
      return DecisionTrace(
        tenderId: 'NIT-MWS-4984',
        tenderTitle: 'HDPE Water Supply Pipeline',
        department: 'Municipal Water Supply Directorate',
        inputClause: presets[0]['clause']!,
        extractedRequirements: const [
          TraceRequirement(
            parameter: 'Material Classification',
            specifiedValue: 'PE-100 Polyethylene Resin',
            state: KnowledgeState.verified,
            note: 'Direct match with IS 4984 Section 4 raw material requirement',
          ),
          TraceRequirement(
            parameter: 'Nominal Pressure Rating',
            specifiedValue: 'PN 10 (1.0 MPa at 27°C)',
            state: KnowledgeState.verified,
            note: 'Standard pressure series listed in IS 4984 Table 2',
          ),
          TraceRequirement(
            parameter: 'Standard Dimension Ratio',
            specifiedValue: 'SDR 11 (Controlled Outside Diameter)',
            state: KnowledgeState.verified,
            note: 'Dimension series conforming to IS 4984 Clause 6',
          ),
          TraceRequirement(
            parameter: 'Primary Standard Citation',
            specifiedValue: 'IS 4984:1995 (Fourth Revision)',
            state: KnowledgeState.conflicting,
            note: 'Obsolete citation; superseded by IS 4984:2016',
          ),
          TraceRequirement(
            parameter: 'Foreign Standard Citation',
            specifiedValue: 'ASTM D3035',
            state: KnowledgeState.conflicting,
            note: 'Prohibited under GFR 2017 Rule 144(vii) when national standard exists',
          ),
          TraceRequirement(
            parameter: 'Proprietary Trade Names',
            specifiedValue: 'Supreme / Astral Pipes',
            state: KnowledgeState.conflicting,
            note: 'Restricts competition; prohibited under CVC OM 03-05-1',
          ),
        ],
        retrievedCandidates: const [
          TraceCandidate(
            standardCode: 'IS 4984:2016',
            title: 'High Density Polyethylene Pipes for Water Supply — Specification',
            rank: 1,
            retrievalScore: 0.96,
            isSelected: true,
            considerationReason: 'Direct domain match for HDPE pipes for potable water conveyance',
            rejectionReason: null,
            state: KnowledgeState.verified,
          ),
          TraceCandidate(
            standardCode: 'IS 4984:1995',
            title: 'High Density Polyethylene Pipes for Water Supply (Fourth Revision)',
            rank: 2,
            retrievalScore: 0.88,
            isSelected: false,
            considerationReason: 'Direct text mention in tender clause',
            rejectionReason: 'Superseded fourth revision; citing obsolete standard violates GFR Rule 144',
            state: KnowledgeState.conflicting,
          ),
          TraceCandidate(
            standardCode: 'ASTM D3035',
            title: 'Specification for Polyethylene Plastic Pipe Based on Controlled OD',
            rank: 3,
            retrievalScore: 0.79,
            isSelected: false,
            considerationReason: 'Cited as alternative standard in tender specification',
            rejectionReason: 'Foreign standard; mandatory national standard IS 4984:2016 is in force',
            state: KnowledgeState.conflicting,
          ),
          TraceCandidate(
            standardCode: 'IS 4985:2021',
            title: 'Unplasticized PVC Pipes for Potable Water Supplies — Specification',
            rank: 4,
            retrievalScore: 0.54,
            isSelected: false,
            considerationReason: 'Potable water conveyance piping',
            rejectionReason: 'Governs unplasticized PVC (uPVC) pipes; incompatible with PE resin',
            state: KnowledgeState.outOfCoverage,
          ),
        ],
        selectionReason:
            'IS 4984:2016 is the active fifth revision governing high density polyethylene pipes for potable water conveyance. It provides verified tables for PE-100 material at PN 10 pressure rating and is mandatorily enforced under DPIIT Pipes QCO 2021.',
        exclusionReasons: const [
          'IS 4984:1995: Superseded by fifth revision; citing obsolete standard restricts competitive bidding and violates GFR 2017 Rule 144(vii).',
          'ASTM D3035: Foreign US standard; GFR 2017 Rule 144(vii) prohibits mandating foreign standards when national standards exist.',
          'IS 4985:2021: Applies strictly to uPVC conduits; incompatible with PE material requirement.',
        ],
        selectedStandard: pipeAnalysis.detectedStandards[0],
        lifecycleState: 'CURRENT',
        evidence: pipeAnalysis.detectedStandards[0].evidence,
        verificationState: KnowledgeState.verified,
        finalRecommendation:
            'Rectify tender to mandate IS 4984:2016 (PE-100, PN 10, SDR 11) with compulsory BIS Standard Mark (ISI license) under Pipes QCO 2021. Remove proprietary trade makes.',
        humanApprovalState: 'PENDING REVIEW',
      );
    }
    if (norm == 'steel') {
      return DecisionTrace(
        tenderId: 'NIT-PWD-1786',
        tenderTitle: 'TMT Reinforcement Steel Rebars',
        department: 'Public Works Department (Buildings)',
        inputClause: presets[2]['clause']!,
        extractedRequirements: const [
          TraceRequirement(
            parameter: 'Material Classification',
            specifiedValue: 'High Strength Deformed Steel Bars (TMT)',
            state: KnowledgeState.verified,
            note: 'Governed by IS 1786:2008 for concrete reinforcement',
          ),
          TraceRequirement(
            parameter: 'Steel Grade',
            specifiedValue: 'Fe 500D (Ductile Grade)',
            state: KnowledgeState.verified,
            note: 'High elongation grade (min 16%) required for earthquake zones',
          ),
          TraceRequirement(
            parameter: 'Foreign Standard Citation',
            specifiedValue: 'ASTM A615 (US Standard)',
            state: KnowledgeState.conflicting,
            note: 'Foreign standard cited without domestic equivalence clause',
          ),
          TraceRequirement(
            parameter: 'Proprietary Brand Lock-in',
            specifiedValue: 'Tata Tiscon / Jindal Panther only',
            state: KnowledgeState.conflicting,
            note: 'Violates CVC Anti-Tailoring Directives; excludes primary/secondary BIS producers',
          ),
        ],
        retrievedCandidates: const [
          TraceCandidate(
            standardCode: 'IS 1786:2008',
            title: 'High Strength Deformed Steel Bars and Wires for Concrete Reinforcement',
            rank: 1,
            retrievalScore: 0.97,
            isSelected: true,
            considerationReason: 'Direct national standard governing TMT rebar reinforcement',
            rejectionReason: null,
            state: KnowledgeState.verified,
          ),
          TraceCandidate(
            standardCode: 'ASTM A615',
            title: 'Standard Specification for Deformed and Plain Carbon-Steel Bars',
            rank: 2,
            retrievalScore: 0.76,
            isSelected: false,
            considerationReason: 'Cited in tender document text',
            rejectionReason: 'Foreign code; national standard IS 1786:2008 is mandatory under Steel QCO',
            state: KnowledgeState.conflicting,
          ),
          TraceCandidate(
            standardCode: 'IS 2062:2011',
            title: 'Hot Rolled Medium and High Tensile Structural Steel — Specification',
            rank: 3,
            retrievalScore: 0.58,
            isSelected: false,
            considerationReason: 'Structural steel standard',
            rejectionReason: 'Governs structural sections and plates; not applicable to concrete rebar',
            state: KnowledgeState.outOfCoverage,
          ),
        ],
        selectionReason:
            'IS 1786:2008 is the mandated Indian Standard for High Strength Deformed Steel Bars for Concrete Reinforcement under the Steel and Steel Products (Quality Control) Order, 2020.',
        exclusionReasons: const [
          'ASTM A615: Foreign code; domestic BIS standard IS 1786:2008 is mandatory under Ministry of Steel QCO.',
          'IS 2062:2011: Structural steel plates and sections; inappropriate for concrete reinforcement rebar.',
        ],
        selectedStandard: steelAnalysis.detectedStandards[0],
        lifecycleState: 'CURRENT',
        evidence: steelAnalysis.detectedStandards[0].evidence,
        verificationState: KnowledgeState.verified,
        finalRecommendation:
            'Mandate IS 1786:2008 Fe 500D with compulsory ISI mark; remove proprietary steel brand names.',
        humanApprovalState: 'PENDING REVIEW',
      );
    }
    // Default: Distribution Transformers
    return DecisionTrace(
      tenderId: 'NIT-DISCOM-1180',
      tenderTitle: 'Distribution Transformers 500 kVA',
      department: 'State Power Distribution Corporation Ltd.',
      inputClause: presets[1]['clause']!,
      extractedRequirements: const [
        TraceRequirement(
          parameter: 'Rating / Capacity',
          specifiedValue: '500 kVA, 11/0.433 kV',
          state: KnowledgeState.verified,
          note: 'Covered under IS 1180 (Part 1):2014 up to 2500 kVA',
        ),
        TraceRequirement(
          parameter: 'Primary Standard Citation',
          specifiedValue: 'IS 1180:1989',
          state: KnowledgeState.conflicting,
          note: 'Obsolete fourth revision; superseded by IS 1180 (Part 1):2014',
        ),
        TraceRequirement(
          parameter: 'Insulating Oil Specification',
          specifiedValue: 'IS 335:1993',
          state: KnowledgeState.conflicting,
          note: 'Obsolete citation; superseded by IS 335:2018',
        ),
        TraceRequirement(
          parameter: 'Proprietary Bushing OEM',
          specifiedValue: 'ABB or Siemens make only',
          state: KnowledgeState.conflicting,
          note: 'Brand lock-in without functional equivalence clause; violates CVC guidelines',
        ),
      ],
      retrievedCandidates: const [
        TraceCandidate(
          standardCode: 'IS 1180 (Part 1):2014',
          title: 'Outdoor Type Three-Phase Distribution Transformers Up To 2500 kVA',
          rank: 1,
          retrievalScore: 0.98,
          isSelected: true,
          considerationReason: 'Direct domain match for three-phase distribution transformers',
          rejectionReason: null,
          state: KnowledgeState.verified,
        ),
        TraceCandidate(
          standardCode: 'IS 1180:1989',
          title: 'Outdoor Type Three-Phase Distribution Transformers (Fourth Revision)',
          rank: 2,
          retrievalScore: 0.85,
          isSelected: false,
          considerationReason: 'Cited in tender text',
          rejectionReason: 'Obsolete fourth revision; illegal for public procurement under GFR 144',
          state: KnowledgeState.conflicting,
        ),
        TraceCandidate(
          standardCode: 'IS 2026 (Part 1):2011',
          title: 'Power Transformers — General Specification',
          rank: 3,
          retrievalScore: 0.62,
          isSelected: false,
          considerationReason: 'General electrical transformer standard',
          rejectionReason: 'Intended for large power transformers (>2500 kVA); does not govern distribution ratings',
          state: KnowledgeState.inferred,
        ),
      ],
      selectionReason:
          'IS 1180 (Part 1):2014 is the active fifth revision and is subject to the statutory Electrical Transformers (Quality Control) Order, 2024. Mandates Scheme-I ISI license.',
      exclusionReasons: const [
        'IS 1180:1989: Obsolete revision; non-compliant with GFR 144.',
        'IS 2026: Intended for power transformers, not distribution ratings under 2500 kVA.',
      ],
      selectedStandard: transformerAnalysis.detectedStandards[0],
      lifecycleState: 'CURRENT',
      evidence: transformerAnalysis.detectedStandards[0].evidence,
      verificationState: KnowledgeState.verified,
      finalRecommendation:
          'Replace IS 1180:1989 with IS 1180 (Part 1):2014, mandate Scheme-I ISI license, update oil to IS 335:2018, and strip proprietary bushing brands.',
      humanApprovalState: 'PENDING REVIEW',
    );
  }

  static WhyThisStandard getWhyThisStandard(String standardCode) {
    final clean = standardCode.toUpperCase();
    if (clean.contains('4984')) {
      return const WhyThisStandard(
        standardCode: 'IS 4984:2016',
        title: 'High Density Polyethylene Pipes for Water Supply — Specification',
        matchedRequirements: {
          'Product Category': 'High Density Polyethylene (HDPE) Pipes',
          'Raw Material': 'PE-100 virgin grade polymer granules conforming to IS 2530',
          'Pressure Compatibility': 'PN 2.5 to PN 16 (0.25 MPa to 1.6 MPa)',
          'Dimension Range': '16 mm to 1000 mm nominal outer diameter',
          'Application': 'Buried municipal potable water distribution networks',
          'Regulatory Constraint': 'Mandatory Scheme-I ISI license under DPIIT Pipes QCO 2021',
        },
        verificationSummary:
            'Direct match with municipal water pipeline technical scope. Standard is active (Fifth Revision with Amendments 1 & 2) and backed by authoritative gazetted evidence.',
        knowledgeState: KnowledgeState.verified,
        isEvidenceAvailable: true,
        alternativesConsidered: [
          AlternativeConsidered(
            standardCode: 'IS 4984:1995',
            title: 'High Density Polyethylene Pipes for Water Supply (Fourth Revision)',
            whyConsidered: 'Cited directly in tender clause',
            whyRejected: 'Superseded fourth revision; non-compliant with GFR 2017 Rule 144(vii)',
            status: KnowledgeState.conflicting,
          ),
          AlternativeConsidered(
            standardCode: 'ASTM D3035',
            title: 'Specification for Polyethylene Plastic Pipe Based on Controlled OD',
            whyConsidered: 'Cited as alternative standard in specification',
            whyRejected: 'Foreign standard cited without domestic equivalence clause; GFR 144(vii) breach',
            status: KnowledgeState.conflicting,
          ),
          AlternativeConsidered(
            standardCode: 'IS 4985:2021',
            title: 'Unplasticized PVC Pipes for Potable Water Supplies',
            whyConsidered: 'Potable water distribution pipeline standard',
            whyRejected: 'Applies strictly to unplasticized PVC (uPVC) pipes, not HDPE',
            status: KnowledgeState.outOfCoverage,
          ),
        ],
      );
    }
    if (clean.contains('1180')) {
      return const WhyThisStandard(
        standardCode: 'IS 1180 (Part 1):2014',
        title: 'Outdoor Type Three-Phase Distribution Transformers Up To 2500 kVA',
        matchedRequirements: {
          'Product Category': 'Outdoor Three-Phase Distribution Transformers',
          'Rating Range': 'Up to and including 2500 kVA, 33 kV',
          'Insulating Liquid': 'Mineral Insulating Oil conforming to IS 335:2018',
          'Energy Efficiency': 'Standard maximum total losses at 50% & 100% loading (BEE Star Ratings)',
          'Regulatory Constraint': 'Compulsory Scheme-I ISI Mark under Transformers QCO 2024',
        },
        verificationSummary:
            'Mandatory standard for distribution transformers under 2500 kVA. Replaces obsolete 1989 edition and enforces BEE star labeling and BIS certification.',
        knowledgeState: KnowledgeState.verified,
        isEvidenceAvailable: true,
        alternativesConsidered: [
          AlternativeConsidered(
            standardCode: 'IS 1180:1989',
            title: 'Outdoor Distribution Transformers (Fourth Revision)',
            whyConsidered: 'Cited in tender specification',
            whyRejected: 'Superseded fourth revision; illegal for public procurement under GFR 144',
            status: KnowledgeState.conflicting,
          ),
          AlternativeConsidered(
            standardCode: 'IS 2026 (Part 1):2011',
            title: 'Power Transformers — General Specification',
            whyConsidered: 'General transformer standard',
            whyRejected: 'Governs large power transformers (>2500 kVA); does not cover distribution ratings',
            status: KnowledgeState.inferred,
          ),
        ],
      );
    }
    if (clean.contains('1786')) {
      return const WhyThisStandard(
        standardCode: 'IS 1786:2008',
        title: 'High Strength Deformed Steel Bars and Wires for Concrete Reinforcement',
        matchedRequirements: {
          'Product Category': 'High Strength Deformed Steel Bars and Wires (TMT)',
          'Grade': 'Fe 500D (Yield stress >= 500 MPa, Elongation >= 16%)',
          'Application': 'Concrete reinforcement in civil structural works',
          'Regulatory Constraint': 'Mandatory ISI mark under Steel and Steel Products QCO 2020',
        },
        verificationSummary:
            'Exclusive governing standard for high-strength deformed rebar. Enforces chemical composition (C, S, P limits) and mechanical ductility.',
        knowledgeState: KnowledgeState.verified,
        isEvidenceAvailable: true,
        alternativesConsidered: [
          AlternativeConsidered(
            standardCode: 'ASTM A615',
            title: 'Standard Specification for Deformed Carbon-Steel Bars',
            whyConsidered: 'Cited in tender clause',
            whyRejected: 'Foreign standard; GFR 2017 prohibits foreign codes when Indian Standards exist',
            status: KnowledgeState.conflicting,
          ),
          AlternativeConsidered(
            standardCode: 'IS 2062:2011',
            title: 'Hot Rolled Medium and High Tensile Structural Steel',
            whyConsidered: 'Steel structural specification',
            whyRejected: 'Covers hot rolled structural steel sections (beams/columns), not concrete reinforcement rebar',
            status: KnowledgeState.outOfCoverage,
          ),
        ],
      );
    }
    // Fallback for unindexed or unknown standards
    return WhyThisStandard.insufficientEvidence(standardCode);
  }

  static AmendmentDiff getAmendmentDiff(String standardCode) {
    final clean = standardCode.toUpperCase();
    if (clean.contains('4984')) {
      return const AmendmentDiff(
        standardCode: 'IS 4984:2016',
        title: 'High Density Polyethylene Pipes for Water Supply — Specification',
        currentEdition: 'Fifth Revision (2016)',
        previousEdition: 'Fourth Revision (1995)',
        supersessionTransition:
            'IS 4984:2016 superseded IS 4984:1995. Key upgrades include introduction of PE-100 material grade, enhanced hydrostatic pressure test duration (165 hours at 80°C), and updated wall thickness tolerances.',
        amendments: [
          AmendmentRecord(
            amendmentNumber: 'Amendment No. 1',
            dateOrYear: 'July 2018',
            gazetteReference: 'BIS/CMD/14:4984/A-1',
            scopeSummary:
                'Revised Table 2 minimum wall thickness tolerances and added requirements for coiled pipe ovality.',
            state: KnowledgeState.verified,
          ),
          AmendmentRecord(
            amendmentNumber: 'Amendment No. 2',
            dateOrYear: 'November 2021',
            gazetteReference: 'BIS/CMD/14:4984/A-2',
            scopeSummary:
                'Incorporated carbon black dispersion test guidelines and aligned with Pipes QCO 2021 enforcement.',
            state: KnowledgeState.verified,
          ),
        ],
        hasClauseDiffData: false,
        diffNotice:
            'Detailed amendment diff unavailable in current dataset. Gazette metadata and lifecycle relations are verified.',
      );
    }
    if (clean.contains('1180')) {
      return const AmendmentDiff(
        standardCode: 'IS 1180 (Part 1):2014',
        title: 'Outdoor Type Three-Phase Distribution Transformers Up To 2500 kVA',
        currentEdition: 'Fifth Revision (2014)',
        previousEdition: 'Fourth Revision (1989)',
        supersessionTransition:
            'IS 1180 (Part 1):2014 superseded IS 1180:1989. Key upgrades include mandatory maximum total losses at 50% and 100% loading (BEE Star 1 to 5), short-circuit withstand thermal test mandates, and integration with BIS Scheme-I compulsory certification.',
        amendments: [
          AmendmentRecord(
            amendmentNumber: 'Amendment No. 1',
            dateOrYear: 'March 2016',
            gazetteReference: 'ETD 16 (1180)/A-1',
            scopeSummary:
                'Clarified testing procedures for corrugated tank hermetically sealed distribution transformers.',
            state: KnowledgeState.verified,
          ),
          AmendmentRecord(
            amendmentNumber: 'Amendment No. 2',
            dateOrYear: 'August 2019',
            gazetteReference: 'ETD 16 (1180)/A-2',
            scopeSummary:
                'Updated total loss limits at 50% and 100% loading in Table 3 for higher energy conservation.',
            state: KnowledgeState.verified,
          ),
          AmendmentRecord(
            amendmentNumber: 'Amendment No. 3',
            dateOrYear: 'February 2021',
            gazetteReference: 'ETD 16 (1180)/A-3',
            scopeSummary:
                'Updated dielectric test voltages for lightning impulse test protocols.',
            state: KnowledgeState.verified,
          ),
          AmendmentRecord(
            amendmentNumber: 'Amendment No. 4',
            dateOrYear: 'October 2023',
            gazetteReference: 'ETD 16 (1180)/A-4',
            scopeSummary:
                'Aligned with Electrical Transformers (Quality Control) Order, 2024.',
            state: KnowledgeState.verified,
          ),
        ],
        hasClauseDiffData: false,
        diffNotice:
            'Detailed amendment diff unavailable in current dataset. Gazette metadata and lifecycle relations are verified.',
      );
    }
    if (clean.contains('1786')) {
      return const AmendmentDiff(
        standardCode: 'IS 1786:2008',
        title: 'High Strength Deformed Steel Bars and Wires for Concrete Reinforcement',
        currentEdition: 'Fourth Revision (2008)',
        previousEdition: 'Third Revision (1985)',
        supersessionTransition:
            'IS 1786:2008 superseded IS 1786:1985. Introduced Fe 500D, Fe 550D, and Fe 600 grades with superior elongation and seismic bendability requirements.',
        amendments: [
          AmendmentRecord(
            amendmentNumber: 'Amendment No. 1',
            dateOrYear: 'January 2012',
            gazetteReference: 'CED 54 (1786)/A-1',
            scopeSummary:
                'Clarified carbon equivalent (CE) formula and phosphorus/sulfur limits.',
            state: KnowledgeState.verified,
          ),
          AmendmentRecord(
            amendmentNumber: 'Amendment No. 2',
            dateOrYear: 'September 2017',
            gazetteReference: 'CED 54 (1786)/A-2',
            scopeSummary:
                'Enforced mandatory micro-alloying disclosure requirements and fatigue testing.',
            state: KnowledgeState.verified,
          ),
        ],
        hasClauseDiffData: false,
        diffNotice:
            'Detailed amendment diff unavailable in current dataset. Gazette metadata and lifecycle relations are verified.',
      );
    }
    return AmendmentDiff(
      standardCode: standardCode,
      title: 'Standard Lifecycle & Amendments',
      currentEdition: 'Active Revision',
      amendments: const [],
      hasClauseDiffData: false,
      diffNotice:
          'Detailed amendment diff unavailable in current dataset. Consult standard detail for verified lifecycle relationships.',
    );
  }
}

import '../models/cross_jurisdiction_matrix.dart';
import '../models/evidence.dart';

/// Engine that performs comparative analysis of standards across multiple international jurisdictions.
class CrossJurisdictionEngine {
  /// Builds a cross-jurisdiction comparison matrix for a specific product domain.
  static CrossJurisdictionMatrix buildComparisonMatrix({
    required String productId, // 'transformer', 'pipe', 'steel'
  }) {
    switch (productId.toLowerCase()) {
      case 'transformer':
        return _buildTransformerMatrix();
      case 'pipe':
        return _buildPipeMatrix();
      case 'steel':
      default:
        return _buildSteelMatrix();
    }
  }

  static CrossJurisdictionMatrix _buildTransformerMatrix() {
    return CrossJurisdictionMatrix(
      productId: 'transformer',
      productTitle: 'Liquid-Immersed Distribution Transformers (Up to 2.5 MVA, 33 kV)',
      comparedJurisdictions: const ['IN', 'INT', 'US', 'EU', 'GB'],
      rows: [
        CrossJurisdictionParameterRow(
          parameterName: 'Reference Ambient Temperature',
          technicalDomain: 'Thermal Engineering & Rating',
          isHarmonized: false,
          keyDifferencesSummary:
              'India specifies 50°C peak ambient (tropical baseline), requiring de-rating or larger radiators compared to 40°C IEC/US baseline.',
          jurisdictionValues: {
            'IN': JurisdictionRequirementDetail(
              jurisdictionCode: 'IN',
              jurisdictionName: 'India',
              standardCode: 'IS 1180 (Part 1):2014',
              organization: 'BIS',
              version: '2014 (Amended 2021)',
              status: 'CURRENT / MANDATORY QCO',
              requirementSpecification: 'Peak ambient: 50°C, Daily avg: 40°C, Annual avg: 32°C. Max top oil rise: 40°C.',
              evidence: Evidence(
                standardCode: 'IS 1180-1:2014',
                clause: '3.1',
                table: 'Table 1',
                sourceFile: 'IS_1180_Part1_2014.pdf',
                textExcerpt: 'The standard reference ambient temperature shall be 50 degree C maximum.',
              ),
              differenceNotes: 'Tropical design baseline; standard IEC designs overheat if imported without de-rating.',
            ),
            'INT': JurisdictionRequirementDetail(
              jurisdictionCode: 'INT',
              jurisdictionName: 'International',
              standardCode: 'IEC 60076-1:2011',
              organization: 'IEC',
              version: 'Edition 3.0 (2011)',
              status: 'CURRENT',
              requirementSpecification: 'Peak ambient: 40°C, Monthly avg: 30°C, Yearly avg: 20°C. Top oil rise: 60 K.',
              evidence: Evidence(
                standardCode: 'IEC 60076-1:2011',
                clause: '4.1',
                sourceFile: 'IEC_60076-1_2011.pdf',
                textExcerpt: 'Normal ambient temperature: ambient air not exceeding 40 degree C at any time.',
              ),
            ),
            'US': JurisdictionRequirementDetail(
              jurisdictionCode: 'US',
              jurisdictionName: 'United States',
              standardCode: 'IEEE C57.12.00-2021',
              organization: 'IEEE',
              version: '2021 Revision',
              status: 'CURRENT',
              requirementSpecification: 'Peak ambient: 40°C, 24-hour avg: 30°C. Winding temp rise: 65°C.',
              evidence: Evidence(
                standardCode: 'IEEE C57.12.00-2021',
                clause: '4.1.2',
                sourceFile: 'IEEE_C57_12_00.pdf',
                textExcerpt: 'Standard ambient conditions: ambient temperature shall not exceed 40 degree C.',
              ),
            ),
            'EU': JurisdictionRequirementDetail(
              jurisdictionCode: 'EU',
              jurisdictionName: 'European Union',
              standardCode: 'EN 50588-1:2017',
              organization: 'CENELEC',
              version: '2017 Edition',
              status: 'CURRENT / ECODESIGN',
              requirementSpecification: 'Peak ambient: 40°C as per EN 60076-1. Ecodesign Tier 2 max losses mandated.',
              evidence: Evidence(
                standardCode: 'EN 50588-1:2017',
                clause: '1.1',
                sourceFile: 'EN_50588_1_2017.pdf',
                textExcerpt: 'Applies to medium power transformers conforming to general conditions of EN 60076-1.',
              ),
            ),
            'GB': JurisdictionRequirementDetail(
              jurisdictionCode: 'GB',
              jurisdictionName: 'United Kingdom',
              standardCode: 'BS EN 50588-1:2017',
              organization: 'BSI',
              version: '2017 Edition',
              status: 'CURRENT',
              requirementSpecification: 'Identical adoption of EN 50588-1 Ecodesign limits for 50 Hz distribution grids.',
              evidence: Evidence(
                standardCode: 'BS EN 50588-1:2017',
                clause: '1.1',
                sourceFile: 'BS_EN_50588_1.pdf',
                textExcerpt: 'British standard implementing European Ecodesign efficiency tiers.',
              ),
            ),
          },
        ),
        CrossJurisdictionParameterRow(
          parameterName: 'Energy Efficiency / Maximum Loss Limits',
          technicalDomain: 'Energy Performance',
          isHarmonized: false,
          keyDifferencesSummary:
              'India regulates under BEE Star Rating (Levels 1-3). EU mandates Ecodesign Tier 2. US mandates DOE 2016 10 CFR Part 431.',
          jurisdictionValues: {
            'IN': JurisdictionRequirementDetail(
              jurisdictionCode: 'IN',
              jurisdictionName: 'India',
              standardCode: 'IS 1180 (Part 1):2014',
              organization: 'BIS',
              version: '2014',
              status: 'CURRENT',
              requirementSpecification: 'Max total losses at 50% & 100% loading specified in Table 3/6 (Star 1-3).',
              evidence: Evidence(
                standardCode: 'IS 1180-1:2014',
                clause: '6.8',
                table: 'Table 6',
                sourceFile: 'IS_1180_Part1_2014.pdf',
                textExcerpt: 'Maximum losses for 11 kV ratings shall comply with BEE standards and Table 6.',
              ),
            ),
            'US': JurisdictionRequirementDetail(
              jurisdictionCode: 'US',
              jurisdictionName: 'United States',
              standardCode: '10 CFR Part 431 / IEEE C57.12.00',
              organization: 'US DOE / IEEE',
              version: '2016 / 2021',
              status: 'MANDATORY STATUTORY',
              requirementSpecification: 'DOE 2016 Energy Efficiency levels at 50% loading (e.g. 99.08% for 500 kVA).',
              evidence: Evidence(
                standardCode: '10 CFR 431.196',
                clause: 'Table 1',
                sourceFile: 'US_DOE_Transformer_Standards.pdf',
                textExcerpt: 'Energy conservation standards for liquid-immersed distribution transformers.',
              ),
            ),
            'EU': JurisdictionRequirementDetail(
              jurisdictionCode: 'EU',
              jurisdictionName: 'European Union',
              standardCode: 'EU Regulation 2019/1783 / EN 50588-1',
              organization: 'European Commission',
              version: 'Tier 2 (July 2021)',
              status: 'MANDATORY ECODESIGN',
              requirementSpecification: 'Tier 2 maximum load (Pk) and no-load (Po) losses strictly enforced.',
              evidence: Evidence(
                standardCode: 'EN 50588-1:2017',
                table: 'Table 1 & 2',
                sourceFile: 'EU_Ecodesign_2019_1783.pdf',
                textExcerpt: 'Maximum load losses Pk and no-load losses Po for liquid-immersed transformers.',
              ),
            ),
          },
        ),
      ],
      generatedAt: DateTime.now(),
    );
  }

  static CrossJurisdictionMatrix _buildPipeMatrix() {
    return CrossJurisdictionMatrix(
      productId: 'pipe',
      productTitle: 'High-Density Polyethylene (HDPE) Pipes for Water Supply',
      comparedJurisdictions: const ['IN', 'INT', 'US', 'EU'],
      rows: [
        CrossJurisdictionParameterRow(
          parameterName: 'Material Designation & Minimum Required Strength (MRS)',
          technicalDomain: 'Polymer Engineering',
          isHarmonized: true,
          keyDifferencesSummary:
              'Global consensus on MRS classification: PE 100 (10.0 MPa) and PE 80 (8.0 MPa) universally recognized.',
          jurisdictionValues: {
            'IN': JurisdictionRequirementDetail(
              jurisdictionCode: 'IN',
              jurisdictionName: 'India',
              standardCode: 'IS 4984:2016',
              organization: 'BIS',
              version: '2016 Edition',
              status: 'CURRENT / MANDATORY QCO',
              requirementSpecification: 'Raw material PE 63, PE 80, PE 100 with designated MRS of 6.3, 8.0, 10.0 MPa.',
              evidence: Evidence(
                standardCode: 'IS 4984:2016',
                clause: '5.1',
                sourceFile: 'IS_4984_2016.pdf',
                textExcerpt: 'Material used for manufacturer of pipes shall be polyethylene compound PE 80 or PE 100.',
              ),
            ),
            'INT': JurisdictionRequirementDetail(
              jurisdictionCode: 'INT',
              jurisdictionName: 'International',
              standardCode: 'ISO 4427-1:2019',
              organization: 'ISO',
              version: '2019 Edition',
              status: 'CURRENT',
              requirementSpecification: 'PE 80 (MRS 8.0 MPa) and PE 100 (MRS 10.0 MPa) conforming to ISO 12162.',
              evidence: Evidence(
                standardCode: 'ISO 4427-1:2019',
                clause: '4.1',
                sourceFile: 'ISO_4427-1_2019.pdf',
                textExcerpt: 'The pipe compound shall be classified in accordance with ISO 12162.',
              ),
            ),
            'US': JurisdictionRequirementDetail(
              jurisdictionCode: 'US',
              jurisdictionName: 'United States',
              standardCode: 'ASTM D3035-21 / ASTM D3350',
              organization: 'ASTM',
              version: '2021 Edition',
              status: 'CURRENT',
              requirementSpecification: 'PE 4710 designation (MRS 10.0 MPa / HDB 1600 psi at 73°F).',
              evidence: Evidence(
                standardCode: 'ASTM D3035-21',
                clause: '5.1',
                sourceFile: 'ASTM_D3035_21.pdf',
                textExcerpt: 'Materials: Polyethylene compounds shall meet requirements of Specification D3350.',
              ),
            ),
          },
        ),
      ],
      generatedAt: DateTime.now(),
    );
  }

  static CrossJurisdictionMatrix _buildSteelMatrix() {
    return CrossJurisdictionMatrix(
      productId: 'steel',
      productTitle: 'High Strength Deformed Steel Bars and Wires for Concrete Reinforcement',
      comparedJurisdictions: const ['IN', 'INT', 'US', 'GB'],
      rows: [
        CrossJurisdictionParameterRow(
          parameterName: 'Minimum Yield Strength & Earthquake Ductility Ratio',
          technicalDomain: 'Structural Metallurgy',
          isHarmonized: false,
          keyDifferencesSummary:
              'India Fe 500D mandates Tensile/Yield ratio >= 1.10 and elongation >= 16.0%. US ASTM A706 mandates >= 1.25 for seismic design.',
          jurisdictionValues: {
            'IN': JurisdictionRequirementDetail(
              jurisdictionCode: 'IN',
              jurisdictionName: 'India',
              standardCode: 'IS 1786:2008',
              organization: 'BIS',
              version: '2008 (Amended 2017)',
              status: 'CURRENT / MANDATORY QCO',
              requirementSpecification: 'Fe 500D: Yield stress min 500 MPa, Tensile/Yield ratio >= 1.10, Total elongation >= 16.0%.',
              evidence: Evidence(
                standardCode: 'IS 1786:2008',
                clause: '8.1',
                table: 'Table 3',
                sourceFile: 'IS_1786_2008.pdf',
                textExcerpt: 'Fe 500D grade for enhanced ductility in earthquake zones.',
              ),
            ),
            'INT': JurisdictionRequirementDetail(
              jurisdictionCode: 'INT',
              jurisdictionName: 'International',
              standardCode: 'ISO 6935-2:2019',
              organization: 'ISO',
              version: '2019 Edition',
              status: 'CURRENT',
              requirementSpecification: 'B500DWR grade: Re min 500 MPa, Rm/Re ratio 1.15 to 1.35, Agt min 7.5%.',
              evidence: Evidence(
                standardCode: 'ISO 6935-2:2019',
                clause: '8.1',
                table: 'Table 4',
                sourceFile: 'ISO_6935_2_2019.pdf',
                textExcerpt: 'Tensile properties for weldable earthquake resistant reinforcement steel.',
              ),
            ),
            'US': JurisdictionRequirementDetail(
              jurisdictionCode: 'US',
              jurisdictionName: 'United States',
              standardCode: 'ASTM A706/A706M-16',
              organization: 'ASTM',
              version: '2016 Revision',
              status: 'CURRENT / SEISMIC',
              requirementSpecification: 'Grade 60 (420 MPa) / Grade 80 (550 MPa), Tensile/Yield ratio >= 1.25.',
              evidence: Evidence(
                standardCode: 'ASTM A706-16',
                clause: '7.1',
                table: 'Table 2',
                sourceFile: 'ASTM_A706_16.pdf',
                textExcerpt: 'Tensile requirements for low-alloy steel deformed bars for concrete reinforcement.',
              ),
            ),
          },
        ),
      ],
      generatedAt: DateTime.now(),
    );
  }
}

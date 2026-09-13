/// Hierarchical node in the canonical product/technology taxonomy.
class ProductTaxonomyNode {
  final String id;
  final String code;
  final String name;
  final String? parentId;
  final String domain;
  final List<String> synonyms;
  final List<String> primaryStandards;
  final String description;

  const ProductTaxonomyNode({
    required this.id,
    required this.code,
    required this.name,
    this.parentId,
    required this.domain,
    this.synonyms = const [],
    this.primaryStandards = const [],
    required this.description,
  });
}

/// Extensible taxonomy engine providing deterministic technical synonym expansion
/// without relying on ungrounded LLM completions.
class ProductTaxonomy {
  static const List<ProductTaxonomyNode> nodes = [
    // Electrical Domain
    ProductTaxonomyNode(
      id: 'prod-elec-transformers',
      code: 'ELEC_TRANSFORMER',
      name: 'Transformers',
      domain: 'Electrotechnical',
      description: 'Static electrical machines transferring electrical energy between circuits',
      synonyms: ['transformer', 'power transformer'],
      primaryStandards: ['IS 2026', 'IEC 60076'],
    ),
    ProductTaxonomyNode(
      id: 'prod-elec-dist-trans',
      code: 'ELEC_DIST_TRANSFORMER',
      name: 'Distribution Transformers',
      parentId: 'prod-elec-transformers',
      domain: 'Electrotechnical',
      description: 'Outdoor/indoor distribution transformers up to 2500 kVA, 33 kV',
      synonyms: [
        'distribution transformer',
        'distribution transformers',
        'oil-immersed transformer',
        'oil immersed transformer',
        'liquid-immersed transformer',
        'substation transformer',
        'pole mounted transformer',
        'step down transformer',
      ],
      primaryStandards: ['IS 1180 (Part 1)', 'IEC 60076-1', 'IEEE C57.12.00', 'EN 50588-1'],
    ),
    ProductTaxonomyNode(
      id: 'prod-elec-bushings',
      code: 'ELEC_BUSHINGS',
      name: 'High Voltage Bushings',
      parentId: 'prod-elec-transformers',
      domain: 'Electrotechnical',
      description: 'Insulating structures permitting electrical conductors to pass through grounded barriers',
      synonyms: ['bushing', 'bushings', 'hv bushing', 'transformer bushing', 'ceramic bushing'],
      primaryStandards: ['IS 2099', 'IEC 60137'],
    ),
    ProductTaxonomyNode(
      id: 'prod-elec-insul-oil',
      code: 'ELEC_INSULATING_OIL',
      name: 'Transformer Insulating Oils',
      parentId: 'prod-elec-transformers',
      domain: 'Electrotechnical',
      description: 'Mineral and synthetic insulating fluids for electrical equipment',
      synonyms: ['transformer oil', 'insulating oil', 'mineral oil', 'dielectric fluid'],
      primaryStandards: ['IS 335', 'IEC 60296', 'ASTM D3487'],
    ),

    // Construction Domain
    ProductTaxonomyNode(
      id: 'prod-const-steel',
      code: 'CONST_STEEL',
      name: 'Reinforcement Steel',
      domain: 'Civil Engineering',
      description: 'Structural and concrete reinforcing steel products',
      synonyms: ['reinforcing steel', 'concrete steel', 'construction steel'],
      primaryStandards: ['IS 1786', 'ISO 6935-2'],
    ),
    ProductTaxonomyNode(
      id: 'prod-const-tmt',
      code: 'CONST_TMT_REBAR',
      name: 'TMT Steel Rebars',
      parentId: 'prod-const-steel',
      domain: 'Civil Engineering',
      description: 'High-strength thermo-mechanically treated deformed steel bars for concrete reinforcement',
      synonyms: [
        'tmt',
        'tmt bar',
        'tmt bars',
        'rebar',
        'rebars',
        'reinforcing bar',
        'reinforcing bars',
        'deformed steel bars',
        'fe 500d',
        'fe 550d',
        'high strength deformed bars',
      ],
      primaryStandards: ['IS 1786', 'ISO 6935-2', 'ASTM A615', 'BS 4449'],
    ),

    // Water Infrastructure Domain
    ProductTaxonomyNode(
      id: 'prod-water-pipes',
      code: 'WATER_PIPES',
      name: 'Piping Systems',
      domain: 'Civil & Water Resources',
      description: 'Pressure and non-pressure pipe systems for potable water supply',
      synonyms: ['pipes', 'piping', 'pipeline', 'water pipe', 'water supply pipeline'],
      primaryStandards: ['IS 4984', 'ISO 4427-1'],
    ),
    ProductTaxonomyNode(
      id: 'prod-water-hdpe',
      code: 'WATER_HDPE_PIPE',
      name: 'HDPE Water Supply Pipes',
      parentId: 'prod-water-pipes',
      domain: 'Civil & Water Resources',
      description: 'High Density Polyethylene pipes for buried water mains and distribution',
      synonyms: [
        'hdpe pipe',
        'hdpe pipes',
        'high density polyethylene pipe',
        'high density polyethylene pipes',
        'pe-100',
        'pe100',
        'pe-80',
        'pe80',
        'polyethylene pipe',
        'polyethylene piping',
        'pn 10 pipe',
      ],
      primaryStandards: ['IS 4984', 'ISO 4427-1', 'ASTM D3035', 'EN 12201-2'],
    ),

    // Information Technology & Security Domain
    ProductTaxonomyNode(
      id: 'prod-it-security',
      code: 'IT_INFO_SECURITY',
      name: 'Information Security & Privacy',
      domain: 'Information Technology',
      description: 'Information security management, cybersecurity, and cloud security frameworks',
      synonyms: [
        'isms',
        'information security',
        'cybersecurity',
        'data protection',
        'security controls',
      ],
      primaryStandards: ['ISO/IEC 27001', 'ISO/IEC 27002'],
    ),
  ];

  /// Controlled technical synonym map mapping common colloquial terms to canonical product categories.
  static final Map<String, String> _controlledSynonyms = () {
    final map = <String, String>{};
    for (final node in nodes) {
      for (final syn in node.synonyms) {
        map[syn.toLowerCase()] = node.name;
      }
    }
    return map;
  }();

  /// Resolves an arbitrary colloquial search term or abbreviation to its canonical category name.
  static String? resolveCategory(String input) {
    final clean = input.trim().toLowerCase();
    return _controlledSynonyms[clean];
  }

  /// Expands a search query by injecting controlled technical synonyms into the retrieval context.
  static Set<String> expandQueryTerms(String query) {
    final tokens = query
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2)
        .toSet();

    final expanded = Set<String>.from(tokens);

    for (final node in nodes) {
      final matchesNode = node.synonyms.any((syn) => query.toLowerCase().contains(syn));
      if (matchesNode) {
        expanded.add(node.name.toLowerCase());
        expanded.addAll(node.synonyms.take(4));
        expanded.addAll(node.primaryStandards.map((s) => s.toLowerCase()));
      }
    }

    return expanded;
  }

  /// Finds all taxonomy nodes matching a given domain or query.
  static List<ProductTaxonomyNode> findNodesForQuery(String query) {
    final clean = query.trim().toLowerCase();
    return nodes.where((n) {
      return n.name.toLowerCase().contains(clean) ||
          n.domain.toLowerCase().contains(clean) ||
          n.synonyms.any((s) => s.contains(clean));
    }).toList();
  }
}

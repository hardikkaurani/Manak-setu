<p align="center">
  <img src="assets/branding/manaksetu_app_icon.png" width="128" height="128" alt="ManakSetu Official Logo" />
</p>

<h1 align="center">ManakSetu (मानकसेतु)</h1>

<p align="center">
  <strong>Evidence-first AI platform for mapping procurement specifications to applicable Indian Standards, QCOs, and statutory compliance requirements.</strong>
</p>

<p align="center">
  <a href="https://github.com/hardikkaurani/Manaksetu-MA/releases/tag/v1.0.0"><img src="https://img.shields.io/badge/Release-v1.0.0-blue.svg" alt="Release v1.0.0" /></a>
  <a href="https://github.com/hardikkaurani/Manaksetu-MA/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg" alt="License: Apache 2.0" /></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Platform-Flutter%20%7C%20Android-02569B.svg?logo=flutter" alt="Platform: Flutter / Android" /></a>
  <a href="https://github.com/hardikkaurani/Manaksetu-MA/actions"><img src="https://img.shields.io/badge/Tests-30%2F30%20Passed-success.svg" alt="Tests Passed" /></a>
</p>

---

## Download ManakSetu

### Android APK

Download the latest verified Android release artifact for field evaluation and demonstration:

| Package | Version | Artifact | Size | SHA-256 Checksum |
| :--- | :---: | :---: | :---: | :--- |
| **Android APK (Universal)** | `v1.0.0` | [**Download APK**](https://github.com/hardikkaurani/Manaksetu-MA/releases/download/v1.0.0/ManakSetu-Mobile-v1.0.0.apk) | `50.5 MB` | `F43DF1F03E2BADC4454911EEAC549B22607C8A15D8F5D14C4F33DD7AD908C638` |

> Direct GitHub Release Page: [https://github.com/hardikkaurani/Manaksetu-MA/releases/tag/v1.0.0](https://github.com/hardikkaurani/Manaksetu-MA/releases/tag/v1.0.0)

### Android Installation Instructions

1. **Download**: Download `ManakSetu-Mobile-v1.0.0.apk` using the link above or from the GitHub Releases page.
2. **Open**: Open the downloaded `.apk` file on your Android device (Android 5.0 Lollipop / API 21 or higher).
3. **Permissions**: If Android displays an *\"Install unknown apps\"* warning, allow installation for your browser or file manager.
4. **Install**: Tap **Install** to complete the package installation.
5. **Launch**: Open **ManakSetu** from your home screen or app drawer.

> **Demonstration Notice**: This application is an engineering demonstration developed for the Smart India Hackathon (SIH) 2026. The mobile build is fully self-contained and operates in an offline demonstration mode. It is not an officially endorsed application of the Bureau of Indian Standards (BIS) or any Government of India department.

---

## Core Philosophy

Public procurement in India mandates adherence to the **Bureau of Indian Standards (BIS) Act, 2016**, **General Financial Rules (GFR) 2017 (Rule 144)**, and statutory **Quality Control Orders (QCOs)**. Ambiguities in tender preparation frequently result in referencing obsolete standards, omitting mandatory QCO marks, or writing restrictive specifications that violate Central Vigilance Commission (CVC) directives.

ManakSetu solves this by enforcing the core operational principle:

$$\textbf{AI Finds} \longrightarrow \textbf{Rules Verify} \longrightarrow \textbf{Sources Prove} \longrightarrow \textbf{Human Approves}$$

1. **AI Finds**: Natural language processing extracts structured technical requirements from raw tender text, schedule tables, or product photo parameters.
2. **Rules Verify**: A deterministic statutory rule engine cross-references extracted parameters against BIS divisional scopes, gazette revisions, and mandatory certification orders.
3. **Sources Prove**: Every compliance score and violation alert is backed by verbatim gazette text, clause citations, and verifiable evidence cards.
4. **Human Approves**: The system serves as decision-support tooling for procurement officers, maintaining accountability without autonomous decision-making.

---

## Key Capabilities

### 1. Multi-Modal Ingestion
- **Tender Clause Text**: Direct input and parsing of technical specifications with character-length validation and instant defect detection.
- **Statutory Test Presets**: Built-in canonical test cases covering critical engineering domains:
  - *Distribution Transformers* (IS 1180 / IS 335 / QCO compliance)
  - *HDPE Water Supply Pipes* (IS 4984 / PE-100 grade / Pressure ratings)
  - *TMT Reinforcement Steel* (IS 1786 / Fe 500D / Mechanical properties)
- **Product Image Input (Offline Demo)**: Capture physical equipment photos via camera or gallery to extract technical specifications and cross-reference applicable Indian Standards.
- **Document & BoQ Audit**: Ingestion interface for tender schedule documents and Bills of Quantities (BoQs).

### 2. Statutory Scrutiny & Gap Analysis
- **Supersession Tracking**: Identifies citations of obsolete or withdrawn standards (e.g., citing IS 1180:1989 instead of IS 1180 (Part 1):2014).
- **QCO Enforcement**: Audits mandatory certification under Section 16 of the BIS Act, 2016, identifying non-certified grades.
- **CVC Anti-Tailoring Directives**: Flags restrictive proprietary requirements (e.g., restrictive brand lock-in, proprietary OEM requirements) that violate competitive procurement guidelines.
- **Missing Testing Parameters**: Highlights statutory testing criteria omitted from specifications (e.g., carbon black dispersion, pressure tests).

### 3. Interactive Standards Knowledge Graph
- Visual multi-node exploration of standards relationships:
  - *Normative References* & allied testing protocols
  - *Superseded / Active* version history
  - *Raw Materials* & test methods
- Node inspector detailing gazette numbers, issuing sectional committees (e.g., ETD 16, CED 54), and mandatory status.

### 4. Specification Builder & Rectification Workbench
- Dynamic parameter adjustment workbench that calculates real-time compliance improvements.
- Quick-action shortcuts to load 100% GFR-144 and BIS-compliant rectified specification clauses.
- Verifiable decision trace and evidence sheets.

---

## Technical Architecture

```
ManakSetu Mobile (Flutter / Dart)
 ├── Presentation Layer
 │    ├── Command Center Dashboard (Metrics & Quick Audit)
 │    ├── Tender Scrutiny Screen (Ingestion, Multi-Modal Inputs, Scorecard)
 │    ├── Specification Builder (Interactive Rectification Workbench)
 │    ├── Standalone Knowledge Graph (Interactive Node Visualizer)
 │    └── Standards Repository Browser (Catalog & Comparison)
 ├── Core Logic & Intelligence
 │    ├── Scrutiny Rules Engine (Deterministic GFR / QCO / CVC logic)
 │    ├── Knowledge State Engine (Verified, Inferred, Conflicting, Out-of-Coverage)
 │    └── Workspace Controller (State preservation & preset synchronization)
 └── Data Layer
      ├── Canonical Standards Dataset (IS 1180, IS 4984, IS 1786, IS 2026, IS 335, etc.)
      ├── QCO Gazette Registry (Mandatory orders & enforcement dates)
      └── Offline Evidence Repository (Verbatim gazette text & citations)
```

---

## Repository Structure

```
Manaksetu-MA/
├── android/                 # Android native project & Gradle build configuration
│   └── app/
│       ├── build.gradle.kts # Android application configuration (minSdk 21, targetSdk 35)
│       └── src/main/        # Android manifest, launcher icons, splash layer
├── assets/
│   ├── branding/            # Official high-resolution ManakSetu logo assets
│   └── images/              # Sample tender clause image captures
├── lib/
│   ├── data/                # Canonical standards catalog, demo datasets, gazette records
│   ├── models/              # Data models (Standard, ScrutinyResult, ProductImageSample, etc.)
│   ├── navigation/          # Declarative routing via GoRouter
│   ├── screens/             # UI screens (Scrutiny, Builder, Graph, Dashboard)
│   ├── services/            # Workspace controllers and statutory repositories
│   ├── theme/               # Design tokens, color schemes, typography
│   ├── widgets/             # Reusable UI components (Scorecards, GraphCanvas, Inputs)
│   └── app.dart             # Application root and theme configuration
├── test/                    # Comprehensive unit, widget, and integration test suite
│   ├── advanced_features_test.dart    # Knowledge graph & node navigation tests
│   ├── preset_navigation_test.dart    # Canonical preset analysis tests
│   ├── progressive_builder_test.dart  # Specification builder & rectification tests
│   ├── product_image_analysis_test.dart # Product image capture & analysis tests
│   └── widget_test.dart               # End-to-end interactive audit test
├── pubspec.yaml             # Flutter dependencies and asset manifest
├── LICENSE                  # Apache License 2.0
└── README.md                # Project documentation and release guide
```

---

## Development Setup

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.29.0 or higher)
- [Android SDK](https://developer.android.com/studio) (API level 35 supported; minimum API 21)
- Java Development Kit (JDK 17)

### Local Build & Execution

1. **Clone the repository**:
   ```bash
   git clone https://github.com/hardikkaurani/Manaksetu-MA.git
   cd Manaksetu-MA
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Execute static analysis**:
   ```bash
   flutter analyze
   ```

4. **Run test suite**:
   ```bash
   flutter test
   ```

5. **Build Android APKs**:
   ```bash
   # Debug build
   flutter build apk --debug

   # Release build
   flutter build apk --release
   ```

The compiled release APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

---

## Offline & Demonstration Architecture Honesty

- **Self-Contained Execution**: The mobile application does not require a backend server or live cloud API connection. All standard specifications, gazette dates, and QCO rules execute deterministically from local offline data assets.
- **No Production Vision/OCR Claim**: The product image and clause image workflows operate in an explicit **Offline Demo** mode utilizing bundled canonical evaluation profiles. The app does not claim real-time production OCR or cloud neural network classification.
- **Unidentified Category Fallback**: When an image or text specification cannot be authoritatively mapped to indexed standards, the system issues an explicit `OUT_OF_COVERAGE` warning and prompts for manual specification entry.

---

## Testing & Verification

The repository enforces a strict zero-regression quality gate. All test suites must execute cleanly before release artifacts are generated:

```bash
flutter analyze
# Analyzing Manaksetu-MA...
# No issues found!

flutter test
# 00:07 +30: All tests passed!
```

---

## Contributing

Contributions to improve standards coverage, enhance statutory verification rules, and optimize UI performance are welcome:

1. Fork the repository.
2. Create a descriptive feature branch (`git checkout -b feature/standards-expansion`).
3. Ensure all tests pass (`flutter test`) and analysis is clean (`flutter analyze`).
4. Commit your changes following Conventional Commits (`feat(standards): add IS 456 concrete rules`).
5. Open a Pull Request for review.

---

## License

This project is open-source software licensed under the [Apache License 2.0](LICENSE).

### Statutory Notice & Disclaimer
- **Bureau of Indian Standards**: The designations "Indian Standard", "IS", the ISI certification mark, and the titles of standards cited within this application are the property of the Bureau of Indian Standards (BIS) and the Government of India.
- **Reference Use**: All standards metadata, numbers, titles, and statutory orders cited are referenced strictly for educational, research, and non-commercial procurement compliance demonstration under fair use.
- **Official Publications**: For commercial tenders and legally binding statutory enforcement, procurement entities must consult the official BIS portal at [https://www.services.bis.gov.in](https://www.services.bis.gov.in).

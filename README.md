<div align="center">

<a href="https://github.com/hardikkaurani/Manaksetu-MA/releases/download/v1.0.0/ManakSetu-Mobile-v1.0.0.apk" target="_blank">
  <img src="assets/branding/manaksetu_app_icon.png" alt="Manaksetu — Tap to Download APK" width="150" style="border-radius: 32px; cursor: pointer;" />
</a>

<h1>Manaksetu &nbsp;·&nbsp; ( मानकसेतु ) </h1>

<p><strong>An AI-powered, evidence-first mobile platform for identifying applicable Indian Standards (BIS)<br/>from procurement specifications — built for procurement officers, quality managers,<br/>and compliance teams across India's public and private sector.</strong></p>


<img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-3.11%2B-0175C2?logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/AI-RAG%20Pipeline-FF6F00" />
<img src="https://img.shields.io/badge/FastAPI-Backend-009688?logo=fastapi&logoColor=white" />
<img src="https://img.shields.io/badge/Next.js-Web%20Dashboard-black?logo=next.js" />
<img src="https://img.shields.io/badge/BIS-Indian%20Standards-138808" />
<img src="https://img.shields.io/badge/Knowledge%20Graph-Standards%20Mapping-00897B" />
<img src="https://img.shields.io/badge/NLP-Document%20Intelligence-5C6BC0" />
<img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-4CAF50" />
<img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" />

<br/><br/>

</div>

---

## Download

<div align="center">

| Platform | Link | Notes |
|---|---|---|
| Android APK | [ManakSetu-Mobile-v1.0.0.apk](https://github.com/hardikkaurani/Manaksetu-MA/releases/download/v1.0.0/ManakSetu-Mobile-v1.0.0.apk) | Android 5.0+ (API 21+) |
| GitHub Release | [v1.0.0 Release Page](https://github.com/hardikkaurani/Manaksetu-MA/releases/tag/v1.0.0) | Full release notes and assets |

</div>

> **Android Installation**: Download the APK, open it on your device. If prompted, enable "Install from unknown sources" under Settings > Security > Install unknown apps.

---

## Table of Contents

- [The Problem](#the-problem)
- [The Solution](#the-solution)
- [System Architecture](#system-architecture)
- [AI Standards Identification Pipeline](#ai-standards-identification-pipeline)
- [Document Intelligence Flow](#document-intelligence-flow)
- [Knowledge Graph — Standards Relationships](#knowledge-graph--standards-relationships)
- [RAG Pipeline — Internal Mechanics](#rag-pipeline--internal-mechanics)
- [Application Navigation and Screen Flow](#application-navigation-and-screen-flow)
- [Compliance Result Lifecycle](#compliance-result-lifecycle)
- [Deployment Architecture](#deployment-architecture)
- [Tech Stack](#tech-stack)
- [Indian Standards Coverage](#indian-standards-coverage)
- [Project Structure](#project-structure)
- [Key Design Decisions](#key-design-decisions)
- [Environment Configuration](#environment-configuration)
- [Getting Started — Build from Source](#getting-started--build-from-source)
- [Contributing](#contributing)
- [License](#license)

---

## The Problem

India's procurement ecosystem — spanning GeM (Government e-Marketplace), public sector undertakings, defence procurement, and large-scale infrastructure projects — requires all purchased goods and services to conform to applicable BIS (Bureau of Indian Standards) standards. However, the process of identifying which standards apply is broken at every level:

| Pain Point | Reality |
|---|---|
| Standards identification is manual | Procurement officers manually read through thousands of IS documents to find applicable standards for a given specification |
| Specifications arrive unstructured | Procurement documents are PDFs, scanned images, and free-form text with no machine-readable clause structure |
| Standards landscape is vast | BIS has over 20,000 active Indian Standards across sectors — no single officer can know all applicable codes |
| Cross-references are hidden | A single product may fall under multiple IS codes spanning material, testing, packaging, and marking standards |
| Errors carry legal consequences | Non-compliance with BIS standards during procurement leads to rejected goods, audit findings, financial penalties, and legal liability |
| No feedback loop | Officers have no way to know if they have missed an applicable standard until audit or delivery failure |

The result: compliance is inconsistent, slow, and dependent entirely on the expertise and memory of individual procurement officers.

---

## The Solution

Manaksetu is a mobile-first AI platform that accepts a procurement specification — as text, PDF, or captured image — and returns a ranked, evidence-linked list of applicable Indian Standards with the specific clauses and rationale for each recommendation.

The name **Manaksetu** (मानकसेतु) means "bridge to standards" in Sanskrit — a bridge between raw procurement language and India's formal standards framework.

The core operational flow:

```
Upload Specification
        |
        v
Document Intelligence Layer
(OCR + clause extraction + entity recognition)
        |
        v
RAG Pipeline
(Semantic search over embedded BIS standards corpus)
        |
        v
Knowledge Graph Traversal
(Expand to related test, marking, packaging standards)
        |
        v
Evidence-First Ranking
(Each recommendation linked to source clause)
        |
        v
Structured Output
(IS code, title, applicability reason, confidence, evidence)
```

---

## System Architecture

The complete component topology of Manaksetu — from the Flutter mobile client through the AI backend, vector store, knowledge graph, and web dashboard.

```mermaid
graph TB
    subgraph Mobile [Flutter Mobile App - Android, iOS, Web]
        UI[Material Design 3 UI Layer]
        NAV[GoRouter Declarative Navigation]
        STATE[State Management Layer]
        FILEPICK[file_picker and image_picker]
        API_CLIENT[REST API Client]
        UI --> NAV
        UI --> STATE
        UI --> FILEPICK
        STATE --> API_CLIENT
    end

    subgraph Backend [FastAPI AI Backend]
        GW[API Gateway]
        INGEST[Document Ingestion Service]
        OCR_SVC[OCR Engine]
        NLP_SVC[NLP Pipeline]
        RAG_SVC[RAG Engine]
        KG_SVC[Knowledge Graph Service]
        RANKER[Evidence Ranker]
        GW --> INGEST
        INGEST --> OCR_SVC
        INGEST --> NLP_SVC
        NLP_SVC --> RAG_SVC
        RAG_SVC --> KG_SVC
        KG_SVC --> RANKER
    end

    subgraph DataStores [Data Layer]
        VECTOR[(Vector Index\nEmbedded BIS corpus)]
        KG_DB[(Knowledge Graph\nIS cross-references)]
        META_DB[(Metadata Store\nIS codes, titles, sectors)]
        HISTORY_DB[(Query History\nUser past searches)]
    end

    subgraph WebDash [Next.js Web Dashboard]
        SEARCH_UI[Standard Search UI]
        HIST_UI[Query History View]
        EXPORT_UI[Report Export]
    end

    API_CLIENT -->|HTTPS REST| GW
    FILEPICK -->|File bytes| INGEST
    RAG_SVC --> VECTOR
    KG_SVC --> KG_DB
    RANKER --> META_DB
    STATE --> HISTORY_DB
    SEARCH_UI -->|REST| GW
```

---

## AI Standards Identification Pipeline

The complete flow from raw document input to a ranked, evidence-linked list of applicable Indian Standards — across six sequential stages.

```mermaid
flowchart TD
    INPUT([User uploads specification\nPDF, scanned image, or typed text]) --> DETECT{Input type detection}

    DETECT -->|PDF| PDF_PARSE[Text extraction\npdfplumber or PyMuPDF\nlayout-aware extraction]
    DETECT -->|Scanned image| OCR_PROC[OCR processing\nTesseract or Google Vision API\nconfidence scoring per word]
    DETECT -->|Plain text| PASSTHROUGH[Pass through directly\nno preprocessing needed]

    PDF_PARSE --> CLEAN[Text normalisation\nRemove headers, footers, page numbers\nFix encoding artifacts]
    OCR_PROC --> CLEAN
    PASSTHROUGH --> CLEAN

    CLEAN --> ENTITY[Entity extraction\nProduct categories, materials\nspecifications, tolerances, test refs]
    ENTITY --> CHUNK[Semantic chunking\n300-500 token windows\n50 token overlap between chunks]

    CHUNK --> EMBED[Generate embeddings\nOpenAI text-embedding-3-small\nor sentence-transformers all-MiniLM]
    EMBED --> SEARCH[(Vector similarity search\nagainst BIS standards corpus\ntop-K by cosine similarity)]

    SEARCH --> CANDIDATES[Candidate IS standards\nwith similarity scores]
    CANDIDATES --> KG_EXPAND[Knowledge Graph traversal\nExpand from each candidate\nto linked mandatory standards]
    KG_EXPAND --> FULL_SET[Expanded candidate set\nproduct + test + marking + packaging]

    FULL_SET --> EVIDENCE[Evidence extraction\nIdentify which chunk triggered\neach recommendation]
    EVIDENCE --> SCORE[Composite scoring\nSemantic score plus graph centrality\nplus evidence clause strength]
    SCORE --> DEDUP[Deduplication\nMerge duplicate IS codes\nfrom different chunks]
    DEDUP --> RESPONSE([Structured ranked results\nIS code, title, reason\nevidence clause, confidence 0-1])
```

---

## Document Intelligence Flow

How unstructured procurement documents — including poor-quality scans — are parsed into structured, clause-level representations ready for the AI pipeline.

```mermaid
sequenceDiagram
    actor Officer as Procurement Officer
    participant App as Flutter App
    participant API as FastAPI Backend
    participant OCR as OCR Engine
    participant NLP as NLP Pipeline
    participant Vector as Vector Store
    participant KG as Knowledge Graph
    participant Ranker as Evidence Ranker

    Officer->>App: Upload procurement specification
    App->>App: Validate file type and size limit
    App->>App: Show upload progress indicator

    App->>API: POST /api/v1/analyze\nmultipart form with file bytes

    API->>OCR: Extract raw text from document
    OCR->>OCR: Detect text regions and reading order
    OCR->>OCR: Apply confidence filtering per word
    OCR-->>API: Raw text with per-token confidence scores

    API->>NLP: Process raw text
    NLP->>NLP: Segment into logical clauses
    NLP->>NLP: Tag product category entities
    NLP->>NLP: Extract material specifications
    NLP->>NLP: Identify test method references
    NLP->>NLP: Flag marking and packaging clauses
    NLP-->>API: Structured clause list with entity tags

    API->>Vector: Embed clause list and search
    Vector-->>API: Top-K IS documents with cosine scores

    API->>KG: Expand from matched IS codes
    KG->>KG: Traverse mandatory test method links
    KG->>KG: Traverse mandatory marking links
    KG->>KG: Traverse packaging standard links
    KG-->>API: Full linked standard set

    API->>Ranker: Score and rank all candidates
    Ranker->>Ranker: Weight by semantic score
    Ranker->>Ranker: Weight by graph centrality
    Ranker->>Ranker: Weight by evidence clause quality
    Ranker-->>API: Ranked and deduplicated results

    API-->>App: JSON response with IS list
    App-->>Officer: Display ranked standards\nwith evidence and confidence scores
```

---

## Knowledge Graph — Standards Relationships

BIS standards are not isolated. Each IS product standard references mandatory test method standards, marking standards, and packaging standards. Manaksetu's Knowledge Graph pre-computes these relationships so a single specification match expands into the full compliance tree automatically.

```mermaid
flowchart LR
    subgraph PRODUCT [Product Standards]
        P1[IS 2062\nHot-rolled Steel]
        P2[IS 1070\nWater for Industrial Use]
        P3[IS 1879\nMalleable Cast Iron Fittings]
    end

    subgraph TEST [Test Method Standards]
        T1[IS 1608\nTensile Testing of Metals]
        T2[IS 1599\nBend Test for Steel]
        T3[IS 3025\nWater Testing Methods]
        T4[IS 1865\nHardness Testing]
        T5[IS 7001\nDimensional Inspection]
    end

    subgraph MARKING [Marking and Certification]
        M1[IS 1260\nIS Mark Licensing]
        M2[IS 8664\nLabelling Requirements]
    end

    subgraph SAMPLING [Sampling Standards]
        S1[IS 4905\nRandom Sampling Methods]
        S2[IS 2500\nAcceptance Sampling Tables]
    end

    subgraph PACKAGING [Packaging Standards]
        K1[IS 7942\nPackaging for Industrial Goods]
    end

    P1 -->|mandatory| T1
    P1 -->|mandatory| T2
    P1 -->|mandatory| T4
    P1 -->|mandatory| M1
    P1 -->|mandatory| S1
    P2 -->|mandatory| T3
    P2 -->|mandatory| M1
    P2 -->|mandatory| S2
    P3 -->|mandatory| T5
    P3 -->|mandatory| T4
    P3 -->|mandatory| M1
    P3 -->|mandatory| K1
    S1 -->|extends| S2
    M1 -->|references| M2
```

---

## RAG Pipeline — Internal Mechanics

How the Retrieval-Augmented Generation pipeline retrieves, ranks, and cites evidence from the embedded BIS corpus — the engine that makes recommendations trustworthy rather than opaque.

```mermaid
flowchart TD
    QUERY([Clause chunks from NLP pipeline]) --> EMBEDDER[Embedding Model\nConvert clause text to dense vector]

    EMBEDDER --> ANN[Approximate Nearest Neighbour Search\nFAISS or Pinecone index\ntop-K by cosine similarity]

    ANN --> CANDIDATES[Candidate IS document chunks\nwith similarity scores 0.0 to 1.0]

    CANDIDATES --> THRESHOLD{Similarity above\nconfigured threshold?}
    THRESHOLD -->|Below threshold| DROP[Discard low-quality match]
    THRESHOLD -->|Above threshold| RERANK[Cross-encoder re-ranking\nMore precise relevance scoring\nagainst original clause text]

    RERANK --> CHUNK_MAP[Map retrieved chunks\nback to source IS documents]
    CHUNK_MAP --> MERGE[Merge chunks from same IS code\nAggregate scores across chunks]

    MERGE --> EVIDENCE_EXTRACT[Extract evidence text\nWhich specific clause triggered\nthis IS recommendation]

    EVIDENCE_EXTRACT --> CITE[Build citation object\nIS code, title, section, clause, score]
    CITE --> KG_INPUT[Pass IS codes to\nKnowledge Graph expander]

    KG_INPUT --> FINAL([Final ranked result set\nwith full evidence and citation chain])
```

---

## Application Navigation and Screen Flow

```mermaid
flowchart TD
    SPLASH([Splash Screen\nLogo and version]) --> AUTH{User session\nexists?}
    AUTH -->|No| ONBOARD[Onboarding\nApp purpose and capabilities]
    AUTH -->|Yes| HOME

    ONBOARD --> HOME[Home Screen\nUpload, Search, History entry points]

    HOME --> UPLOAD[Upload Specification\nFile picker or camera capture\nor type specification directly]
    HOME --> MANUAL_SEARCH[Manual BIS Search\nKeyword search over IS catalogue]
    HOME --> HISTORY[Query History\nPast analyses with saved results]
    HOME --> SETTINGS[Settings\nAPI endpoint, theme, export format]

    UPLOAD --> PROCESSING[Processing Screen\nLive pipeline stage indicators\nEstimated time remaining]
    PROCESSING -->|Success| RESULTS[Results Screen\nRanked IS standards list\nConfidence scores and evidence preview]
    PROCESSING -->|Error| ERROR_STATE[Error Screen\nReason and retry option]

    RESULTS --> DETAIL[Standard Detail Screen\nFull IS info, applicability reason\ncomplete evidence clause, related standards]
    RESULTS --> EXPORT[Export Screen\nGenerate PDF compliance report\nfor official procurement documentation]
    RESULTS --> SAVE[Save to History\nStore with query and results]
    RESULTS --> SHARE[Share Result\nSend IS list via email or WhatsApp]

    MANUAL_SEARCH --> DETAIL
    HISTORY --> RESULTS
    DETAIL --> RELATED[Related Standards\nFrom Knowledge Graph links]
```

---

## Compliance Result Lifecycle

How a single compliance result moves from generation through use in the procurement process — covering editing, export, and audit trail.

```mermaid
stateDiagram-v2
    [*] --> Processing : Specification submitted

    Processing --> Generated : AI pipeline completes successfully
    Processing --> Failed : Pipeline error or timeout

    Failed --> Processing : User retries

    Generated --> Reviewing : Officer reviews IS recommendations

    Reviewing --> Accepted : Officer confirms IS code as applicable
    Reviewing --> Rejected : Officer marks IS code as not applicable
    Reviewing --> Flagged : Officer flags IS code for manual verification

    Accepted --> Saved : Result saved to query history
    Rejected --> Saved : Rejection logged with reason
    Flagged --> Saved : Flag noted for review

    Saved --> Exported : Officer generates PDF compliance report
    Exported --> Archived : Report attached to procurement file

    Archived --> [*]
```

---

## Deployment Architecture

```mermaid
graph LR
    subgraph User [User Devices]
        ANDROID[Android Device\nAPK v1.0.0]
        IOS[iOS Device\nTestFlight or App Store]
        BROWSER[Browser\nChrome or Safari]
    end

    subgraph CDN [Distribution]
        GH_RELEASE[GitHub Releases\nAPK download]
        VERCEL[Vercel\nNext.js web dashboard]
        PLAY[Play Store\nFuture release]
    end

    subgraph Compute [Backend Compute]
        FASTAPI[FastAPI Server\nRailway or Render]
        GPU[GPU Instance\nEmbedding inference\nOptional for self-hosted models]
    end

    subgraph Storage [Data Storage]
        VECTOR_DB[Pinecone or FAISS\nVector index]
        KG_STORE[NetworkX or Neo4j\nKnowledge Graph]
        POSTGRES[PostgreSQL\nQuery history and metadata]
    end

    ANDROID -->|Download| GH_RELEASE
    IOS -->|TestFlight| CDN
    BROWSER --> VERCEL
    ANDROID -->|API calls| FASTAPI
    IOS -->|API calls| FASTAPI
    VERCEL -->|API proxy| FASTAPI
    FASTAPI --> GPU
    FASTAPI --> VECTOR_DB
    FASTAPI --> KG_STORE
    FASTAPI --> POSTGRES
```

---

## Tech Stack

### Mobile Application

| Technology | Version | Purpose |
|---|---|---|
| Flutter | 3.x | Cross-platform mobile and web UI |
| Dart | 3.11+ | Type-safe application code |
| GoRouter | 14.0–18.0 | Declarative URL-based navigation |
| file_picker | 12.3.0 | PDF and document selection from device storage |
| image_picker | 1.1.2 | Camera capture and gallery selection |
| flutter_launcher_icons | 0.14.3 | App icon generation for Android and iOS |

### AI Backend

| Technology | Purpose |
|---|---|
| FastAPI | High-performance async Python REST API |
| RAG Pipeline | Retrieval-Augmented Generation over BIS standards corpus |
| Sentence Transformers | Open-source embedding model for semantic search |
| FAISS | High-speed approximate nearest-neighbour vector search |
| Cross-encoder | Re-ranking model for precision improvement on top-K candidates |
| Knowledge Graph (NetworkX) | Standards relationship traversal and expansion |
| Tesseract OCR | Text extraction from scanned and image-based documents |
| NLP pipeline (spaCy) | Entity extraction, clause segmentation, product category tagging |

### Web Dashboard

| Technology | Purpose |
|---|---|
| Next.js | Server-rendered web interface for desktop procurement officers |
| Vercel | Zero-configuration deployment with edge caching |

### Infrastructure

| Component | Technology |
|---|---|
| Backend hosting | Railway or Render |
| Vector index | Pinecone (managed) or FAISS (self-hosted) |
| Knowledge graph | NetworkX (in-memory) or Neo4j (persistent) |
| Database | PostgreSQL for query history and metadata |
| APK distribution | GitHub Releases |

---

## Indian Standards Coverage

Manaksetu's corpus covers BIS standards across major procurement sectors:

| Sector | Example IS Codes | Scope |
|---|---|---|
| Steel and metals | IS 2062, IS 1608, IS 1570, IS 808 | Structural steel, testing methods, bars and rods |
| Electrical equipment | IS 732, IS 1646, IS 3043, IS 10810 | Wiring, earthing, cable testing |
| Construction materials | IS 456, IS 269, IS 8112, IS 1489 | Concrete, cement, fly ash cement |
| Water and sanitation | IS 1070, IS 3025, IS 458, IS 4111 | Industrial water, testing, pipes |
| Chemicals and industrial | IS 265, IS 1030, IS 797 | Chemical purity, castings |
| Textiles | IS 1963, IS 6490, IS 1965 | Yarn, fabric, tolerance |
| Food and agriculture | IS 1009, IS 4883, IS 2809 | Food grading, agricultural equipment |
| Mechanical equipment | IS 3832, IS 7895, IS 4218 | Fasteners, valves, threads |

---

## Project Structure

```
Manaksetu-MA/
|
+-- lib/
|   +-- main.dart                        # App entry point, GoRouter configuration
|   +-- core/
|   |   +-- constants/
|   |   |   +-- api_constants.dart       # API base URL, endpoint paths, timeout values
|   |   |   +-- app_strings.dart         # All user-facing strings (i18n-ready)
|   |   +-- theme/
|   |   |   +-- app_theme.dart           # Material 3 navy and cream color scheme
|   |   +-- extensions/
|   |   |   +-- string_extensions.dart
|   |   |   +-- context_extensions.dart
|   |   +-- services/
|   |       +-- api_service.dart         # HTTP client, error handling, retry logic
|   |       +-- file_service.dart        # File validation, format detection, compression
|   |       +-- history_service.dart     # Local query history persistence
|   |
|   +-- features/
|       +-- splash/
|       |   +-- splash_screen.dart
|       +-- onboarding/
|       |   +-- onboarding_screen.dart
|       +-- home/
|       |   +-- home_screen.dart         # Entry point with upload, search, history tiles
|       +-- upload/
|       |   +-- upload_screen.dart       # File picker, camera, and text input flow
|       |   +-- processing_screen.dart   # Pipeline stage indicator with live progress
|       +-- results/
|       |   +-- results_screen.dart      # Ranked IS standards list with confidence bars
|       |   +-- standard_detail.dart     # Full IS detail with evidence clause display
|       |   +-- export_screen.dart       # PDF compliance report generation
|       |   +-- share_screen.dart        # Share via email or messaging
|       +-- search/
|       |   +-- search_screen.dart       # Manual BIS keyword search with filters
|       +-- history/
|       |   +-- history_screen.dart      # Past query list with replay capability
|       +-- settings/
|           +-- settings_screen.dart     # API endpoint, theme, export format
|
+-- assets/
|   +-- branding/
|   |   +-- manaksetu_app_icon.png       # Navy envelope with Ashoka Chakra and Satyameva Jayate
|   +-- images/
|       +-- sample_clause.jpg            # Demo procurement specification for onboarding
|
+-- android/                             # Android platform configuration
+-- ios/                                 # iOS platform configuration
+-- web/                                 # Web platform configuration
+-- windows/                             # Windows platform configuration
+-- test/
|   +-- widget/
|   +-- integration/
+-- docs/                                # Architecture documentation
+-- pubspec.yaml                         # Dependencies and asset declarations
+-- implmentation plan.txt               # Detailed implementation roadmap
+-- manaksetu_mock_data.md               # Mock BIS standards data for development and testing
+-- analysis_options.yaml                # Dart linting rules
+-- LICENSE                              # Apache 2.0
+-- README.md
```

---

## Key Design Decisions

**Why evidence-first output rather than just IS code lists?**
A compliance recommendation without justification is legally unusable in a government procurement context. Every IS code returned by Manaksetu is linked to the specific clause in the procurement specification that triggered the recommendation, and the specific section of the BIS standard that makes it applicable. Procurement officers can verify each recommendation independently without trusting the AI blindly — critical for audit defence.

**Why a Knowledge Graph in addition to vector search?**
Vector search retrieves the primary product standard that semantically matches the specification. But procurement compliance also requires mandatory test method standards, marking and licensing standards (IS 1260), and packaging standards — which are referenced within the primary standard, not in the procurement specification itself. The Knowledge Graph pre-computes these relationships so one match expands into the full compliance tree, automatically.

**Why RAG over a fine-tuned model?**
BIS standards are amended and new IS codes are added periodically by the Bureau of Indian Standards. A fine-tuned model would require complete retraining on every standards update — infeasible for a lean team. A RAG pipeline with a continuously updated vector index adapts to new or revised IS documents with an index update operation only, no model changes required.

**Why Flutter for a government-focused compliance tool?**
Flutter produces a single codebase that runs on Android phones used by field procurement officers, iOS devices used by quality managers, and Chrome browsers used by desk-based compliance teams at GeM or CPWD. One codebase, three deployment targets, identical UI fidelity and behaviour across all three platforms.

**Why GoRouter for navigation?**
GoRouter provides URL-based deep linking that works identically on Android, iOS, and web. A compliance officer using the web dashboard can share a direct URL pointing to a specific search result or standard detail with a colleague. This is not possible with Flutter's default imperative Navigator without significant additional engineering.

**Why cross-encoder re-ranking after vector search?**
Vector similarity (bi-encoder) search is fast but approximate — it retrieves a wide candidate set efficiently. Cross-encoder re-ranking is slower but more precise — it scores each candidate against the original query text with full attention. Combining both stages gives the accuracy of cross-encoder ranking at near the speed of vector search, by applying the cross-encoder only to the top-K candidates from the vector stage.

---

## Environment Configuration

```dart
// lib/core/constants/api_constants.dart
const String kApiBaseUrl = 'https://your-fastapi-backend.com';
const String kApiVersion = '/api/v1';
const int kApiTimeoutSeconds = 30;
const int kMaxFileSizeMb = 10;
```

For local development, point `kApiBaseUrl` to `http://localhost:8000` and run the FastAPI backend locally.

---

## Getting Started — Build from Source

### Prerequisites

| Requirement | Version |
|---|---|
| Flutter SDK | 3.x (Dart 3.11+) |
| Android Studio or VS Code | Latest with Flutter and Dart plugins |
| Android SDK | API 21+ |
| Java | 17+ |

### Build and Run

```bash
# Clone the repository
git clone https://github.com/hardikkaurani/Manaksetu-MA.git
cd Manaksetu-MA

# Install dependencies
flutter pub get

# Generate app icons from assets/branding/manaksetu_app_icon.png
dart run flutter_launcher_icons

# Run on connected Android device
flutter run -d android

# Run on Chrome (web)
flutter run -d chrome

# Build signed release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Run Flutter Analysis and Tests

```bash
# Static analysis
flutter analyze

# Run tests
flutter test

# Format code
dart format .
```

---

## Contributing

```bash
git checkout -b feat/your-feature-name
git commit -m "feat(scope): describe your change"
git push origin feat/your-feature-name
# Open a Pull Request
```

Follow [Conventional Commits](https://www.conventionalcommits.org/).

For adding new BIS standards to the corpus, add the IS document to the corpus ingestion pipeline and update the Knowledge Graph relationship definitions. See `implmentation plan.txt` for the corpus update workflow.

---

## License

Apache License 2.0. See [LICENSE](LICENSE) for details.

---

<div align="center">

<a href="https://github.com/hardikkaurani/Manaksetu-MA/releases/download/v1.0.0/ManakSetu-Mobile-v1.0.0.apk">
  <img src="assets/branding/manaksetu_app_icon.png" width="90" style="border-radius: 20px;" />
</a>

<br/><br/>
**Manaksetu — मानकसेतु**
*A bridge between procurement language and Indian Standards.*
<br/>

<a href="https://github.com/hardikkaurani/Manaksetu-MA/releases/download/v1.0.0/ManakSetu-Mobile-v1.0.0.apk">
  <img src="https://img.shields.io/badge/Download%20APK%20v1.0.0-Android-1a3a6b?style=for-the-badge&logo=android&logoColor=white" />
</a>
&nbsp;
<a href="https://github.com/hardikkaurani/Manaksetu-MA/releases/tag/v1.0.0">
  <img src="https://img.shields.io/badge/View%20Release-GitHub-black?style=for-the-badge&logo=github&logoColor=white" />
</a>

<br/><br/>

Built by [Hardik Kaurani](https://github.com/hardikkaurani) & [Aadi Jain](https://github.com/Thrizzio)

</div>

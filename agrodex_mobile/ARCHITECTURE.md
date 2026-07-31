# AgroDex Mobile Application — Technical Architecture Specification

## 1. Architectural Pattern & Philosophy
The **AgroDex Mobile Application** (`agrodex_mobile`) is built on a **Clean Architecture** model with **Feature-Driven Package Design** and **Riverpod** reactive state management. This structure ensures clean separation of concerns, high testability, and zero horizontal coupling between domain features.

```
                  +-----------------------------------+
                  |         UI / Presentation         |
                  |  (Screens, Widgets, Controllers)  |
                  +-----------------+-----------------+
                                    |
                                    v  (observes via Riverpod)
                  +-----------------------------------+
                  |        Presentation State         |
                  |     (StateNotifier, FutureProv)   |
                  +-----------------+-----------------+
                                    |
                                    v  (invokes)
                  +-----------------------------------+
                  |           Domain Layer            |
                  |     (Models, Repos Interfaces)    |
                  +-----------------+-----------------+
                                    ^
                                    |  (implements)
                  +-----------------+-----------------+
                  |            Data Layer             |
                  |     (Repositories, DTOs, APIs)    |
                  +-----------------------------------+
```

---

## 2. Layer Isolation & Coupling Rules

1. **Strict Vertical Dependencies**:
   - `presentation/` depends on `domain/` and `core/`.
   - `data/` depends on `domain/` and `core/`.
   - `domain/` is pure Dart: it depends ONLY on standard library models and `core/` abstractions. Zero UI or third-party SDK imports are permitted inside `domain/`.
2. **Zero Cross-Feature Implementation Coupling**:
   - Features (`auth`, `dashboard`, `marketplace`, `risk_intelligence`) are self-contained.
   - No feature imports another feature's `data/` or `presentation/` classes.
   - Cross-feature navigation is orchestrated centrally via GoRouter in `lib/core/router/app_router.dart`.
   - Shared authentication state is accessed via `core/` or via Riverpod provider contracts (`authControllerProvider`).

---

## 3. State Management (Riverpod 2.6+)

- **Dependency Injection**: Providers serve as the sole DI mechanism (`authRepositoryProvider`, `dashboardRepositoryProvider`, `marketplaceRepositoryProvider`, `riskRepositoryProvider`).
- **Reactive Caching**: `FutureProvider.autoDispose` is used for asynchronous query fetching (`dashboardMetricsProvider`, `riskAssessmentProvider`).
- **State Controllers**: Stateful mutations use `StateNotifierProvider.autoDispose` (`AuthController`, `AiChatController`).

---

## 4. Network & Offline-First Strategy

1. **Supabase + REST Hybrid Layer**:
   - `ApiClient` (`lib/core/network/api_client.dart`) wraps standard HTTP calls with automatic token injection from Supabase sessions.
2. **Demo-Ready Offline Fallback Resiliency**:
   - When backend endpoints or network connections are unavailable, repositories (`SupabaseRiskRepository`, `SupabaseMarketplaceRepository`) transparently fall back to immutable baseline JSON snapshots that 1:1 match the production React web app mock snapshots (`src/lib/supplyChainRiskAi.ts`, `backend/src/services/fraud-intelligence.service.js`).
   - This ensures 100% demo readiness and UI testability without requiring live backend credentials.

---

## 5. Security & Configuration

- **Zero Hardcoded Secrets**: All backend URLs and API keys are loaded via `flutter_dotenv` from `.env`.
- **Git Hygiene**: `.env` is ignored in `.gitignore`; only `.env.example` is committed.
- **Session Protection**: Supabase JWT session tokens are stored securely in local secure persistence via the Supabase Flutter SDK.

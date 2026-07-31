# AgroDex Mobile — Folder Structure & Package Navigation

This document details the directory structure of the **AgroDex Flutter application** (`agrodex_mobile/`) and explains the responsibilities of each module.

---

## 1. High-Level Directory Overview

```
agrodex_mobile/
├── lib/
│   ├── core/                    # Application-wide shared foundation (theme, router, network, ui)
│   ├── features/                # Domain features (Clean Architecture slices)
│   │   ├── auth/                # Feature 2: Authentication & session persistence
│   │   ├── dashboard/           # Feature 3: Dashboard & Main App Hub navigation
│   │   ├── marketplace/         # Feature 4: Batch Registration, Verification & QR Scanner
│   │   └── risk_intelligence/   # Feature 5: Supply Chain AI & Fraud Risk Intelligence
│   └── main.dart                # Application entrypoint & Supabase/Riverpod bootstrap
├── test/                        # Comprehensive unit, widget, and provider test suites
├── assets/                      # Application icons and static graphic resources
├── .env.example                 # Configurable environment variable template
├── pubspec.yaml                 # Flutter dependencies and SDK configuration
├── ARCHITECTURE.md              # Technical Clean Architecture specification
├── FOLDER_STRUCTURE.md          # Directory and package guide (this file)
├── CONTRIBUTING.md              # Engineering standards and PR checklist
└── MIGRATION_PROGRESS.md        # Feature migration matrix from React web application
```

---

## 2. Core Foundation (`lib/core/`)

The `core/` package contains infrastructure shared across all domain features:

```
lib/core/
├── config/
│   └── app_config.dart          # Reads environment variables (Supabase URL/Key, Hedera API)
├── network/
│   ├── api_client.dart          # HTTP wrapper with bearer token injection & error handling
│   ├── api_exceptions.dart      # Custom network exception hierarchy
│   └── supabase_client.dart     # Supabase instance singleton and auth wrapper
├── router/
│   ├── app_router.dart          # GoRouter definitions, route guards, and deep links
│   └── app_routes.dart          # Type-safe route name and path constants
├── theme/
│   ├── app_colors.dart          # HSL-tailored color palette matching React Tailwind tokens
│   ├── app_spacing.dart         # Standardized padding, radius, and gap helpers
│   ├── app_theme.dart           # Material 3 light/dark ThemeData definitions
│   └── app_typography.dart      # Google Fonts (Inter, Roboto) typography styles
├── ui/
│   ├── app_button.dart          # Reusable primary/secondary/outline buttons with loader
│   ├── app_card.dart            # Standardized glassmorphism/surface cards
│   ├── app_text_field.dart      # Standardized form text input with validation styling
│   └── error_boundary_widget.dart # Responsive error fallback boundary
└── utils/
    ├── date_formatter.dart      # Date normalization matching React `intl` formatting
    ├── formatters.dart          # Number and currency formatting utilities
    └── validators.dart          # Standard email, wallet, and batch ID form validators
```

---

## 3. Feature Anatomy (`lib/features/<feature_name>/`)

Every feature module follows a strict 3-tier Clean Architecture structure:

```
lib/features/<feature_name>/
├── domain/
│   ├── models/                  # Immutable Dart data classes with JSON serialization
│   └── repositories/            # Abstract repository interfaces (contracts)
├── data/
│   ├── dtos/                    # Data Transfer Objects for remote backend payloads
│   └── repositories/            # Repository implementations (REST/Supabase + offline fallbacks)
└── presentation/
    ├── controllers/             # StateNotifier / AsyncNotifier state controllers
    ├── providers/               # Riverpod provider definitions (autoDispose)
    ├── screens/                 # Full-page Flutter Scaffold screens
    └── widgets/                 # Reusable UI widgets scoped to this feature
```

---

## 4. Test Suite Hierarchy (`test/`)

```
test/
├── auth_feature_test.dart       # Unit & widget tests for AuthController and Login/Landing screens
├── core_foundation_test.dart    # Tests for AppButton, AppTextField, validators, and date formatting
├── dashboard_feature_test.dart  # Tests for Dashboard KPIs, Audit Journal, and Hub shell
├── marketplace_feature_test.dart# Tests for Batch Registration, Verification Badge, and QR Scanner
├── risk_intelligence_feature_test.dart # Tests for AI Scorecards, 30-day Trends, Heatmap, and Chatbot
└── widget_test.dart             # Complete application smoke test & router boot test
```

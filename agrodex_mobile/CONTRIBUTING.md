# Contributing to AgroDex Mobile

Thank you for contributing to the **AgroDex Mobile Application**! Our goal is to maintain a production-grade, 100% React-parity Flutter application with Clean Architecture, robust offline resiliency, and zero analyzer warnings.

---

## 1. Development Environment Setup

1. **Flutter SDK**: Ensure you are running Flutter 3.19+ / Dart 3.3+.
   ```bash
   flutter --version
   ```
2. **Environment Configuration**:
   Copy the example environment template:
   ```bash
   cp .env.example .env
   ```
   Fill in your Supabase project URL and anonymous key. Never commit `.env` to version control.
3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

---

## 2. Code Quality & Formatting Rules

Before submitting any Pull Request, you must run our mandatory verification commands:

```bash
# 1. Format code according to Effective Dart guidelines
dart format .

# 2. Verify zero static analysis errors, warnings, or info lints
flutter analyze

# 3. Execute all unit, widget, and provider test suites
flutter test
```

### Prohibited Patterns
- **No `withOpacity`**: Always use `.withValues(alpha: x)` to avoid precision loss in Flutter 3.x.
- **No Cross-Feature Imports**: Never import another feature's `data/` or `presentation/` package directly.
- **No Hardcoded Colors or Styles**: Always use `Theme.of(context)`, `AppColors`, and `AppSpacing`.
- **No Unhandled Network Errors**: Use `AsyncValue` or custom repository fallback snapshots so screens gracefully handle offline conditions.

---

## 3. Pull Request Checklist

- [ ] All new public classes, methods, and properties have documentation comments (`///`).
- [ ] `dart format .` reports no unformatted files.
- [ ] `flutter analyze` reports **0 issues found**.
- [ ] `flutter test` passes 100% with no skipped or failing tests.
- [ ] Any new feature includes corresponding unit tests (in `test/`) covering models, providers, and widget rendering.

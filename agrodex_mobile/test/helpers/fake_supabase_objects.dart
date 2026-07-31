import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Factory helpers for creating fake Supabase SDK objects in tests.
///
/// Use these instead of mocking/patching the SDK — the constructors are stable
/// across minor gotrue versions (tested against gotrue 2.26.0).
class FakeSupabaseObjects {
  FakeSupabaseObjects._();

  /// Creates a minimal but valid [sb.User] for use in unit/widget tests.
  static sb.User user({
    String id = 'test-user-id',
    String email = 'test@agrodex.io',
  }) {
    return sb.User(
      id: id,
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: '2025-01-01T00:00:00.000Z',
      email: email,
    );
  }

  /// Creates a minimal but valid [sb.Session] for use in unit/widget tests.
  ///
  /// The [accessToken] is a syntactically valid-looking JWT string but is NOT
  /// cryptographically signed — it is safe to use only in tests.
  static sb.Session session({sb.User? user}) {
    return sb.Session(
      accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
          '.eyJzdWIiOiJ0ZXN0LXVzZXItaWQiLCJleHAiOjk5OTk5OTk5OTl9'
          '.FAKE_SIGNATURE_FOR_TESTING_ONLY',
      tokenType: 'bearer',
      user: user ?? FakeSupabaseObjects.user(),
    );
  }
}

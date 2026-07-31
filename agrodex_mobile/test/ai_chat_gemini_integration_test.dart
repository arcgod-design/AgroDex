import 'dart:io';
import 'package:agrodex_mobile/core/network/api_client.dart';
import 'package:agrodex_mobile/features/risk_intelligence/data/repositories/supabase_risk_repository.dart';
import 'package:agrodex_mobile/features/risk_intelligence/domain/models/ai_chat_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AI Assistant Google Gemini Integration Verification', () {
    const fallbackMessage =
        'I am the AgroDex AI Assistant. I can help you inspect supply chain provenance, check Hedera HCS timestamps, and analyze fraud signals.';

    late SupabaseRiskRepository repository;

    setUpAll(() {
      try {
        final envFile = File('.env');
        if (envFile.existsSync()) {
          dotenv.testLoad(fileInput: envFile.readAsStringSync());
        } else {
          final parentEnv = File('../backend/.env');
          if (parentEnv.existsSync()) {
            dotenv.testLoad(fileInput: parentEnv.readAsStringSync());
          }
        }
      } catch (_) {}
    });

    setUp(() {
      final supabaseClient = SupabaseClient(
        'https://nhoqsqktwygqvovhonre.supabase.co',
        'test-anon-key',
      );
      final apiClient = ApiClient(supabaseClient: supabaseClient);
      repository = SupabaseRiskRepository(
        client: apiClient,
        supabase: supabaseClient,
      );
    });

    test('Prompt 1: What is 15 × 27? returns real Gemini response', () async {
      final messages = [
        const AiChatMessage(
          id: 'msg-1',
          role: AiChatRole.user,
          content: 'What is 15 × 27?',
        ),
      ];

      final response = await repository.sendAiChatMessage(messages);

      debugPrint('=== PROMPT 1: What is 15 × 27? ===');
      debugPrint('Response: $response\n');

      expect(response, isNotEmpty);
      expect(response, isNot(equals(fallbackMessage)));
      expect(response, contains('405'));
    });

    test('Prompt 2: Explain Hedera HCS. returns real Gemini response', () async {
      final messages = [
        const AiChatMessage(
          id: 'msg-2',
          role: AiChatRole.user,
          content: 'Explain Hedera HCS.',
        ),
      ];

      final response = await repository.sendAiChatMessage(messages);

      debugPrint('=== PROMPT 2: Explain Hedera HCS. ===');
      debugPrint('Response: $response\n');

      expect(response, isNotEmpty);
      expect(response, isNot(equals(fallbackMessage)));
      expect(
        response.toLowerCase(),
        anyOf(
          contains('hedera'),
          contains('consensus'),
          contains('hcs'),
          contains('timestamp'),
        ),
      );
    });

    test(
      'Prompt 3: Which batches require immediate attention today? returns real Gemini response',
      () async {
        final messages = [
          const AiChatMessage(
            id: 'msg-3',
            role: AiChatRole.user,
            content: 'Which batches require immediate attention today?',
          ),
        ];

        final response = await repository.sendAiChatMessage(messages);

        debugPrint('=== PROMPT 3: Which batches require immediate attention today? ===');
        debugPrint('Response: $response\n');

        expect(response, isNotEmpty);
        expect(response, isNot(equals(fallbackMessage)));
      },
    );
  });
}

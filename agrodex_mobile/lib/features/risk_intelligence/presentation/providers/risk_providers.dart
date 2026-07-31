import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/core_providers.dart';
import '../../data/repositories/supabase_risk_repository.dart';
import '../../domain/models/ai_chat_models.dart';
import '../../domain/models/fraud_overview_models.dart';
import '../../domain/models/supply_chain_risk_models.dart';
import '../../domain/repositories/risk_repository.dart';

/// Provider for the [RiskRepository] singleton.
final riskRepositoryProvider = Provider<RiskRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseRiskRepository(client: apiClient, supabase: supabaseClient);
});

/// FutureProvider that fetches the AI Supply Chain Risk Assessment report.
final riskAssessmentProvider =
    FutureProvider.autoDispose<SupplyChainRiskAssessment>((ref) async {
      final repository = ref.watch(riskRepositoryProvider);
      return repository.getSupplyChainRiskAssessment();
    });

/// FutureProvider that fetches the aggregated Fraud Overview report.
final fraudOverviewProvider = FutureProvider.autoDispose<FraudOverview>((
  ref,
) async {
  final repository = ref.watch(riskRepositoryProvider);
  return repository.getFraudOverview();
});

/// State controller for the real-time AI Assistant Chatbot widget.
class AiChatController extends StateNotifier<AsyncValue<List<AiChatMessage>>> {
  final RiskRepository _repository;

  AiChatController({required RiskRepository riskRepository})
    : _repository = riskRepository,
      super(
        const AsyncValue.data([
          AiChatMessage(
            id: 'welcome-1',
            role: AiChatRole.assistant,
            content:
                'Hello! I am the AgroDex AI Assistant. Ask me about batch provenance, fraud signals, or Hedera HCS verification.',
          ),
        ]),
      );

  /// Sends a new user message and streams or awaits the assistant's reply.
  Future<void> sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    final currentMessages = state.valueOrNull ?? [];
    final userMsg = AiChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: AiChatRole.user,
      content: cleanText,
    );

    final updatedHistory = [...currentMessages, userMsg];
    state = AsyncValue.data(updatedHistory);

    try {
      final replyText = await _repository.sendAiChatMessage(updatedHistory);
      final assistantMsg = AiChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        role: AiChatRole.assistant,
        content: replyText,
      );
      state = AsyncValue.data([...updatedHistory, assistantMsg]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Clears the chat history back to the welcome message.
  void clearChat() {
    state = const AsyncValue.data([
      AiChatMessage(
        id: 'welcome-1',
        role: AiChatRole.assistant,
        content:
            'Hello! I am the AgroDex AI Assistant. Ask me about batch provenance, fraud signals, or Hedera HCS verification.',
      ),
    ]);
  }
}

/// Provider for [AiChatController].
final aiChatControllerProvider =
    StateNotifierProvider.autoDispose<
      AiChatController,
      AsyncValue<List<AiChatMessage>>
    >((ref) {
      final repository = ref.watch(riskRepositoryProvider);
      return AiChatController(riskRepository: repository);
    });

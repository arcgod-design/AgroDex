import '../models/ai_chat_models.dart';
import '../models/fraud_overview_models.dart';
import '../models/supply_chain_risk_models.dart';

/// Abstract repository interface for AI Supply Chain Risk Intelligence and Fraud Detection.
abstract class RiskRepository {
  /// Fetches the AI Supply Chain Risk Assessment report.
  ///
  /// If the backend service is offline or fails, returns the local baseline snapshot
  /// to ensure UI continuity in accordance with React fallback behavior.
  Future<SupplyChainRiskAssessment> getSupplyChainRiskAssessment({
    bool forceRefresh = false,
  });

  /// Fetches aggregated Fraud Overview statistics from GET /api/fraud/overview.
  Future<FraudOverview> getFraudOverview({bool forceRefresh = false});

  /// Sends a conversation history to the Supabase Edge Function `/functions/v1/ai-chat`
  /// and returns the assistant's reply text.
  Future<String> sendAiChatMessage(List<AiChatMessage> messages);
}

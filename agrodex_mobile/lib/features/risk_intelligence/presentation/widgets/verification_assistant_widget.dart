import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Interactive AI Verification Assistant Widget with trust signals and provenance timeline.
class VerificationAssistantWidget extends StatefulWidget {
  /// Creates a [VerificationAssistantWidget].
  const VerificationAssistantWidget({super.key});

  @override
  State<VerificationAssistantWidget> createState() =>
      _VerificationAssistantWidgetState();
}

class _VerificationAssistantWidgetState
    extends State<VerificationAssistantWidget> {
  bool _isTimelineExpanded = true;
  bool _isSignalsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header banner
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.verified, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Verification & Provenance Assistant',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Hedera HCS consensus and AI audit verification checks.',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,

          // Provenance timeline accordion
          _AccordionSection(
            title: 'Interactive Provenance Timeline',
            isExpanded: _isTimelineExpanded,
            onToggle: () =>
                setState(() => _isTimelineExpanded = !_isTimelineExpanded),
            child: Column(
              children: const [
                _TimelineItem(
                  step: '1. Farm Registration',
                  timestamp: '2026-06-25 08:30 UTC',
                  description:
                      'GPS coordinates verified in West Java agricultural zone.',
                  isCompleted: true,
                ),
                _TimelineItem(
                  step: '2. AI Image Provenance Audit',
                  timestamp: '2026-06-25 10:15 UTC',
                  description:
                      'Gemini vision check confirmed crop maturity and harvest metadata.',
                  isCompleted: true,
                ),
                _TimelineItem(
                  step: '3. Hedera HCS Tokenization',
                  timestamp: '2026-06-26 14:00 UTC',
                  description:
                      'Immutable consensus timestamp recorded on Hedera mainnet.',
                  isCompleted: true,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Trust signals accordion
          _AccordionSection(
            title: 'Audit Trust Signals',
            isExpanded: _isSignalsExpanded,
            onToggle: () =>
                setState(() => _isSignalsExpanded = !_isSignalsExpanded),
            child: Column(
              children: const [
                _SignalRow(
                  label: 'Hedera Consensus Verification',
                  status: 'Verified',
                  isGood: true,
                ),
                _SignalRow(
                  label: 'Geo-spatial Duplicate Check',
                  status: 'Passed',
                  isGood: true,
                ),
                _SignalRow(
                  label: 'Certificate Attestation Expiry',
                  status: '14 days remaining',
                  isGood: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccordionSection extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  const _AccordionSection({
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.dividerColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String step;
  final String timestamp;
  final String description;
  final bool isCompleted;
  final bool isLast;

  const _TimelineItem({
    required this.step,
    required this.timestamp,
    required this.description,
    this.isCompleted = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF059669)
                    : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 10, color: Colors.white),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isCompleted
                    ? const Color(0xFF059669)
                    : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  timestamp,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SignalRow extends StatelessWidget {
  final String label;
  final String status;
  final bool isGood;

  const _SignalRow({
    required this.label,
    required this.status,
    required this.isGood,
  });

  @override
  Widget build(BuildContext context) {
    final color = isGood ? const Color(0xFF059669) : const Color(0xFFD97706);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/shared/presentation/components/components.dart';
import 'package:progression_tracker/shared/animations/rest_timer_circular.dart';
import 'package:progression_tracker/features/workout/presentation/providers/rest_timer_provider.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

class ActiveRestTimerSection extends ConsumerWidget {
  const ActiveRestTimerSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(restTimerProvider);
    final tokens = context.tokens;
    
    if (timerState.isRunning && !timerState.isComplete) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: tokens.card,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          boxShadow: [
            BoxShadow(
              color: tokens.kineticAccent.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            const RestTimerCircular(size: 90),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  height: 36,
                  child: AppButton(
                    label: '-15s',
                    variant: AppButtonVariant.ghost,
                    onPressed: () {
                      AppHaptics.shared.buttonPress();
                      ref.read(restTimerProvider.notifier).addTime(-15);
                    },
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: AppButton(
                    label: 'SKIP',
                    variant: AppButtonVariant.secondary,
                    onPressed: () {
                      AppHaptics.shared.selectionChanged();
                      ref.read(restTimerProvider.notifier).skip();
                    },
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: AppButton(
                    label: '+30s',
                    variant: AppButtonVariant.primary,
                    onPressed: () {
                      AppHaptics.shared.buttonPress();
                      ref.read(restTimerProvider.notifier).addTime(30);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    if (timerState.isComplete) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: tokens.kineticAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.bolt, color: tokens.kineticAccent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'REST COMPLETE — READY TO LIFT',
                style: TextStyle(
                  color: tokens.kineticAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTypography.fontFamilyHeadings,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: tokens.kineticAccent, size: 18),
              tooltip: 'Dismiss',
              onPressed: () {
                AppHaptics.shared.selectionChanged();
                ref.read(restTimerProvider.notifier).stop();
              },
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}

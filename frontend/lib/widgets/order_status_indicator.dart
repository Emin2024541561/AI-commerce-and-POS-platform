/// order_status_indicator.dart
///
/// Used by order_tracking_screen.dart (customer) and orders_screen.dart
/// (admin incoming orders). Two widgets:
///   - OrderStatusStepper: full animated Pending → Preparing → Completed
///     horizontal stepper for the customer tracking screen
///   - OrderStatusBadge: small pill badge for list rows / admin order cards
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum OrderStage { pending, preparing, completed, rejected }

extension OrderStageX on OrderStage {
  String get label => switch (this) {
        OrderStage.pending => 'Pending',
        OrderStage.preparing => 'Preparing',
        OrderStage.completed => 'Completed',
        OrderStage.rejected => 'Rejected',
      };

  Color get color => switch (this) {
        OrderStage.pending => AppColors.statusPending,
        OrderStage.preparing => AppColors.statusPreparing,
        OrderStage.completed => AppColors.statusCompleted,
        OrderStage.rejected => AppColors.statusRejected,
      };

  IconData get icon => switch (this) {
        OrderStage.pending => Icons.schedule_rounded,
        OrderStage.preparing => Icons.soup_kitchen_rounded,
        OrderStage.completed => Icons.check_circle_rounded,
        OrderStage.rejected => Icons.cancel_rounded,
      };
}

/// Small pill — e.g. next to an order row: "● Preparing"
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.stage});
  final OrderStage stage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: stage.color.withOpacity(0.14),
        borderRadius: AppRadius.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stage.icon, size: 13, color: stage.color),
          const SizedBox(width: 4),
          Text(stage.label, style: AppTypography.caption1(stage.color)),
        ],
      ),
    );
  }
}

/// Full horizontal animated stepper for the order tracking screen. Pass
/// the ordered list of stages this order type goes through (skip
/// `rejected` here — that's a terminal state shown via OrderStatusBadge
/// or a dedicated rejected-state view instead).
class OrderStatusStepper extends StatelessWidget {
  const OrderStatusStepper({
    super.key,
    required this.currentStage,
    this.stages = const [OrderStage.pending, OrderStage.preparing, OrderStage.completed],
  });

  final OrderStage currentStage;
  final List<OrderStage> stages;

  @override
  Widget build(BuildContext context) {
    final currentIndex = stages.indexOf(currentStage).clamp(0, stages.length - 1).toInt();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? AppColors.darkBorderStrong : AppColors.lightBorderStrong;

    return Row(
      children: List.generate(stages.length * 2 - 1, (i) {
        if (i.isOdd) {
          final lineIndex = i ~/ 2;
          final filled = lineIndex < currentIndex;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: filled ? AppColors.accentBlue : inactiveColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }
        final stageIndex = i ~/ 2;
        final stage = stages[stageIndex];
        final reached = stageIndex <= currentIndex;
        final isCurrent = stageIndex == currentIndex;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              width: isCurrent ? 44 : 36,
              height: isCurrent ? 44 : 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: reached ? AppColors.accentGradient : null,
                color: reached ? null : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated),
                border: reached ? null : Border.all(color: inactiveColor, width: 1.5),
                boxShadow: isCurrent ? AppShadows.glow(AppColors.accentBlue, opacity: 0.4) : null,
              ),
              child: Icon(
                stage.icon,
                size: isCurrent ? 20 : 16,
                color: reached ? Colors.white : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              stage.label,
              style: AppTypography.caption2(
                reached
                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                    : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
              ),
            ),
          ],
        );
      }),
    );
  }
}

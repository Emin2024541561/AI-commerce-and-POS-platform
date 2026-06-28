/// dashboard_card.dart
///
/// Stat cards for dashboard_screen.dart (revenue/sales/profit/orders/stock)
/// and ai_screen.dart (Best Sellers / Profit AI / Forecast / Smart Deals).
/// Two widgets:
///   - DashboardStatCard: number + label + trend + optional sparkline
///   - AiInsightCard: glowing glass card for an AI feature result
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.trendPercent,
    this.sparklineData,
    this.accentColor,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;

  /// Positive = up (green), negative = down (red), null = hide trend.
  final double? trendPercent;

  /// Optional small list of doubles (e.g. last 7 days) drawn as a sparkline.
  final List<double>? sparklineData;
  final Color? accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? AppColors.accentBlue;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (icon != null)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: accent.withOpacity(0.15), shape: BoxShape.circle),
                  child: Icon(icon, color: accent, size: 18),
                ),
              if (trendPercent != null) _TrendPill(percent: trendPercent!),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: AppTypography.title1(textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.footnote(textSecondary)),
          if (sparklineData != null && sparklineData!.length > 1) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 32,
              width: double.infinity,
              child: CustomPaint(painter: _SparklinePainter(sparklineData!, accent)),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  const _TrendPill({required this.percent});
  final double percent;

  @override
  Widget build(BuildContext context) {
    final up = percent >= 0;
    final color = up ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: AppRadius.pillRadius),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 12, color: color),
          const SizedBox(width: 2),
          Text('${percent.abs().toStringAsFixed(1)}%', style: AppTypography.caption2(color)),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.data, this.color);
  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final minV = data.reduce((a, b) => a < b ? a : b);
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 0.0001 ? 1 : maxV - minV;

    final path = Path();
    final fillPath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = size.width * i / (data.length - 1);
      final y = size.height - ((data[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.25), color.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}

/// Futuristic glass card for AI Command Center results (ai_screen.dart):
/// Best Sellers, Profit AI, Forecast, Smart Deals, Anomaly Detection, etc.
class AiInsightCard extends StatelessWidget {
  const AiInsightCard({
    super.key,
    required this.title,
    required this.icon,
    required this.summary,
    this.metricValue,
    this.onTap,
    this.isLoading = false,
  });

  final String title;
  final IconData icon;
  final String summary;
  final String? metricValue;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      onTap: onTap,
      glowColor: AppColors.accentViolet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(gradient: AppColors.aiGradient, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyEmphasis(isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (isLoading)
            const _ShimmerLine()
          else ...[
            if (metricValue != null)
              Text(metricValue!, style: AppTypography.title2(AppColors.accentViolet)),
            const SizedBox(height: 4),
            Text(
              summary,
              style: AppTypography.footnote(isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      width: 120,
      decoration: BoxDecoration(
        color: AppColors.accentViolet.withOpacity(0.15),
        borderRadius: AppRadius.smRadius,
      ),
    );
  }
}

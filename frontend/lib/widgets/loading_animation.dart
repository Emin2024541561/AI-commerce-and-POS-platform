/// loading_animation.dart
///
/// Replaces bare `CircularProgressIndicator()` calls everywhere. Two pieces:
///   - PulseLoader: small dot-pulse spinner for buttons/inline states
///   - ShimmerSkeleton: full-card skeleton placeholder while data loads
///     (use instead of a spinner for product grids / dashboard cards so the
///     layout doesn't jump once data arrives)
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PulseLoader extends StatefulWidget {
  const PulseLoader({super.key, this.size = 36, this.color});
  final double size;
  final Color? color;

  @override
  State<PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<PulseLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.accentBlue;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: List.generate(3, (i) {
              final delay = i * 0.2;
              final t = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0).toDouble();
              final scale = 0.3 + 0.7 * t;
              final opacity = (1.0 - t).clamp(0.0, 1.0).toDouble();
              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// Skeleton placeholder block with a soft shimmer sweep — drop this in the
/// shape of whatever's loading (e.g. a GlassCard-sized rect for product
/// cards, a row of pill rects for a dashboard stat row).
class ShimmerSkeleton extends StatefulWidget {
  const ShimmerSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
    final highlight = isDark ? AppColors.darkSurfaceHigh : AppColors.lightBorder;

    return ClipRRect(
      borderRadius: widget.borderRadius ?? AppRadius.mdRadius,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + _controller.value * 2.5, 0),
                end: Alignment(0 + _controller.value * 2.5, 0),
                colors: [base, highlight, base],
                stops: const [0.35, 0.5, 0.65],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A 3-up grid of card-shaped shimmer skeletons — drop in while a product
/// grid or dashboard row is loading, matching the eventual layout.
class ShimmerCardGrid extends StatelessWidget {
  const ShimmerCardGrid({super.key, this.count = 6, this.crossAxisCount = 2, this.aspectRatio = 0.75});
  final int count;
  final int crossAxisCount;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: aspectRatio,
      ),
      itemCount: count,
      itemBuilder: (context, i) => ShimmerSkeleton(borderRadius: AppRadius.lgRadius),
    );
  }
}

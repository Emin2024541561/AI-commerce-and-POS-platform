import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.icon, required this.label, required this.value, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withValues(alpha: .14), child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: Theme.of(context).textTheme.labelLarge), Text(value, style: Theme.of(context).textTheme.titleLarge)])),
          ],
        ),
      ),
    );
  }
}

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key, required this.data});
  final List<DailyRevenue> data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: CustomPaint(
        painter: _ChartPainter(data.map((x) => x.revenue).toList(), Theme.of(context).colorScheme.primary),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.values, this.color);
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()..color = Colors.grey.withValues(alpha: .25)..strokeWidth = 1;
    final line = Paint()..color = color..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    for (var i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), axis);
    }
    if (values.isEmpty) return;
    final maxValue = math.max(1, values.reduce(math.max));
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? 0.0 : i * size.width / (values.length - 1);
      final y = size.height - (values[i] / maxValue * (size.height - 20)) - 10;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => values != oldDelegate.values || color != oldDelegate.color;
}

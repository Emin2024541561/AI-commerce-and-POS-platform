import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/ui.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = AppScope.of(context);
    return ValueListenableBuilder(
      valueListenable: bloc,
      builder: (context, state, _) {
        final stats = state.dashboard;
        if (stats == null) return const Center(child: CircularProgressIndicator());
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(spacing: 12, runSpacing: 12, children: [
              SizedBox(width: 260, child: MetricTile(icon: Icons.payments, label: 'Revenue', value: '${stats.totalRevenue.toStringAsFixed(2)} BAM', color: Colors.teal)),
              SizedBox(width: 260, child: MetricTile(icon: Icons.trending_up, label: 'Profit', value: '${stats.totalProfit.toStringAsFixed(2)} BAM', color: Colors.green)),
              SizedBox(width: 260, child: MetricTile(icon: Icons.receipt, label: 'Sales', value: '${stats.totalSalesCount}', color: Colors.indigo)),
              SizedBox(width: 260, child: MetricTile(icon: Icons.warning, label: 'Low stock', value: '${stats.lowStockAlerts}', color: Colors.orange)),
            ]),
            const SizedBox(height: 16),
            Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Revenue trend', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 12), RevenueChart(data: stats.dailyRevenue)]))),
            const SizedBox(height: 16),
            Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Top-selling products', style: Theme.of(context).textTheme.titleLarge), ...stats.topSellingProducts.map((x) => ListTile(leading: const Icon(Icons.local_fire_department), title: Text(x.productName), subtitle: Text('${x.quantitySold} sold'), trailing: Text('${x.revenue.toStringAsFixed(2)} BAM')))]))),
          ],
        );
      },
    );
  }
}

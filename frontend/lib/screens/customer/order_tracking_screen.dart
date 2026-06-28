import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/models.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/order_status_indicator.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = AppScope.of(context);

    return ValueListenableBuilder(
      valueListenable: bloc,
      builder: (context, state, _) {
        return RefreshIndicator(
          onRefresh: bloc.loadCustomerHome,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                "Moje narudžbe",
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 16),

              if (state.customerOrders.isEmpty)
                const GlassCard(
                  child: ListTile(
                    leading: Icon(Icons.local_shipping_outlined),
                    title: Text("Još nema narudžbi"),
                    subtitle: Text(
                      "Vaše narudžbe će biti prikazane ovdje",
                    ),
                  ),
                ),

              ...state.customerOrders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),

                  child: GlassCard(
                    child: ExpansionTile(
                      leading: const Icon(
                        Icons.receipt_long,
                      ),

                      title: Text(
                        "${order.totalAmount.toStringAsFixed(2)} BAM",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),

                      subtitle: Text(
                        order.createdAt.split('T').first,
                      ),

                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),

                          child: OrderStatusStepper(
                            currentStage:
                                _mapStatus(order.status),
                          ),
                        ),

                        ...order.items.map(
                          (item) => ListTile(
                            leading: const Icon(
                              Icons.fastfood,
                            ),

                            title: Text(
                              item.productName,
                            ),

                            subtitle: Text(
                              "Količina: ${item.quantity}",
                            ),

                            trailing: Text(
                              "${item.lineTotal.toStringAsFixed(2)} BAM",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
OrderStage _mapStatus(OrderStatus status) {
  switch (status.name.toLowerCase()) {

    case "pending":
      return OrderStage.pending;

    case "approved":
    case "completed":
      return OrderStage.completed;

    case "rejected":
    case "cancelled":
      return OrderStage.rejected;

    default:
      return OrderStage.pending;
  }
}
    }

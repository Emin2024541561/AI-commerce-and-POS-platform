import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/models.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();

  PaymentMethod paymentMethod = PaymentMethod.cash;

  @override
  Widget build(BuildContext context) {
    final bloc = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Završetak narudžbe"),
      ),

      body: ValueListenableBuilder(
        valueListenable: bloc,

        builder: (context, state, _) {
          return ListView(
            padding: const EdgeInsets.all(16),

            children: [

              GlassCard(
                child: Column(
                  children: [

                    TextField(
                      controller: name,
                      decoration: const InputDecoration(
                        labelText: "Ime (opcionalno)",
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: phone,
                      decoration: const InputDecoration(
                        labelText: "Telefon (opcionalno)",
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: address,
                      decoration: const InputDecoration(
                        labelText: "Adresa (opcionalno)",
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 20),

              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      "Način plaćanja",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),

                    const SizedBox(height: 14),

                    SegmentedButton<PaymentMethod>(
                      segments: const [

                        ButtonSegment(
                          value: PaymentMethod.cash,
                          icon: Icon(Icons.payments),
                          label: Text("Gotovina"),
                        ),

                        ButtonSegment(
                          value: PaymentMethod.card,
                          icon: Icon(Icons.credit_card),
                          label: Text("Kartica"),
                        ),

                      ],

                      selected: {
                        paymentMethod,
                      },

                      onSelectionChanged: (value) {
                        setState(() {
                          paymentMethod = value.first;
                        });
                      },
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 20),

              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Ukupan iznos",
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${state.customerCart.totalAmount.toStringAsFixed(2)} BAM",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium,
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 24),

              PremiumButton(
                expand: true,
                icon: Icons.check_circle,
                label: "Potvrdi narudžbu",

                isLoading: state.loading,

                onPressed: state.loading
                    ? null
                    : () async {

                        final order =
                        await bloc.createCustomerOrder(
                          name: name.text,
                          phone: phone.text,
                          address: address.text,
                          paymentMethod: paymentMethod,
                        );

                        if (context.mounted &&
                            order != null) {

                          Navigator.of(context)
                              .pop();

                        }

                      },
              ),

            ],
          );
        },
      ),
    );
  }
}
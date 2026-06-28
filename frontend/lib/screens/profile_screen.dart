import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/glass_card.dart';
import '../widgets/premium_button.dart';

import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = AppScope.of(context);
    final state = bloc.value;
    final user = state.session?.user;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        GlassCard(
          child: Column(
            children: [

              CircleAvatar(
                radius: 42,
                child: Text(
                  (user?.fullName.isNotEmpty ?? false)
                      ? user!.fullName[0].toUpperCase()
                      : "?",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                user?.fullName ?? "",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall,
              ),

              const SizedBox(height: 6),

              Text(
                user?.email ?? "",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),

              const SizedBox(height: 18),

              Chip(
                avatar: const Icon(
                  Icons.verified_user,
                  size: 18,
                ),
                label: Text(
                  user?.role.name ?? "",
                ),
              ),

            ],
          ),
        ),

        const SizedBox(height: 24),

        PremiumButton(
          expand: true,
          icon: Icons.logout,
          label: "Odjavi se",
          variant: PremiumButtonVariant.destructive,

          onPressed: () {

            bloc.logout();

            Navigator.of(context)
                .pushAndRemoveUntil(

              MaterialPageRoute(
                builder: (_) =>
                    const AuthScreen(),
              ),

              (route) => false,

            );

          },

        ),

      ],
    );
  }
}
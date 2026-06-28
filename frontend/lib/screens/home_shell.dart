import 'package:flutter/material.dart';

import '../main.dart';
import '../models/models.dart';
import '../widgets/animated_navbar.dart';
import '../widgets/animated_navigation.dart';
import 'dashboard_screen.dart';
import 'pos_screen.dart';
import 'products_screen.dart';
import 'inventory_screen.dart';
import 'sales_screen.dart';
import 'orders_screen.dart';
import 'ai_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final bloc = AppScope.of(context);

    final role =
        bloc.value.session?.user.role ?? UserRole.cashier;


    final pages = role == UserRole.cashier
        ? const [
            PosScreen(),
            ProductsScreen(),
            ProfileScreen(),
          ]
        : const [
            DashboardScreen(),
            PosScreen(),
            ProductsScreen(),
            InventoryScreen(),
            SalesScreen(),
            OrdersScreen(),
            AiScreen(),
            ProfileScreen(),
          ];


    final navItems = role == UserRole.cashier
        ? const [

            NavBarItem(
              icon: Icons.point_of_sale_outlined,
              activeIcon: Icons.point_of_sale,
              label: "POS",
            ),

            NavBarItem(
              icon: Icons.inventory_2_outlined,
              activeIcon: Icons.inventory_2,
              label: "Produkti",
            ),

            NavBarItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: "Profil",
            ),

          ]

        : const [

            NavBarItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard,
              label: "Dashboard",
            ),

            NavBarItem(
              icon: Icons.point_of_sale_outlined,
              activeIcon: Icons.point_of_sale,
              label: "POS",
            ),

            NavBarItem(
              icon: Icons.inventory_2_outlined,
              activeIcon: Icons.inventory_2,
              label: "Produkti",
            ),

            NavBarItem(
              icon: Icons.warehouse_outlined,
              activeIcon: Icons.warehouse,
              label: "Skladište",
            ),

            NavBarItem(
              icon: Icons.receipt_long_outlined,
              activeIcon: Icons.receipt_long,
              label: "Računi",
            ),

            NavBarItem(
              icon: Icons.notifications_active_outlined,
              activeIcon: Icons.notifications_active,
              label: "Narudžbe",
            ),

            NavBarItem(
              icon: Icons.auto_awesome_outlined,
              activeIcon: Icons.auto_awesome,
              label: "AI",
            ),

            NavBarItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: "Profil",
            ),

          ];


    if(index >= pages.length){
      index = 0;
    }


    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Smart AI POS",
        ),

        actions: [

          IconButton(

            onPressed:
            bloc.toggleTheme,

            icon:
            const Icon(
              Icons.brightness_6,
            ),

          ),


          IconButton(

            onPressed:
            bloc.refresh,

            icon:
            const Icon(
              Icons.refresh,
            ),

          ),

        ],

      ),


      body: FadeThroughSwitcher(

  indexKey:
  index,

  child:
  pages[index],

),


      bottomNavigationBar:

      AnimatedNavBar(

        currentIndex:
        index,


        items:
        navItems,


        onTap:
        (value){

          setState((){

            index=value;

          });

        },

      ),

    );
  }
}
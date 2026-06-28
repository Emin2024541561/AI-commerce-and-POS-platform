import 'package:flutter/material.dart';
import '../../widgets/animated_navbar.dart';
import '../../widgets/animated_navigation.dart';
import '../../main.dart';
import '../profile_screen.dart';
import 'cart_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'customer_home_screen.dart';
import 'customer_products_screen.dart';
import 'order_tracking_screen.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => AppScope.of(context).loadCustomerHome());
  }

  @override
  Widget build(BuildContext context) {
    const pages = [
      CustomerHomeScreen(),
      CustomerProductsScreen(),
      CartScreen(),
      OrderTrackingScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
title: Text(
  'Smart Shop',
  style: GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.5,
  ),
),        actions: [
          IconButton(onPressed: AppScope.of(context).toggleTheme, icon: const Icon(Icons.brightness_6), tooltip: 'Theme'),
          IconButton(onPressed: AppScope.of(context).loadCustomerHome, icon: const Icon(Icons.refresh), tooltip: 'Refresh'),
        ],
      ),
     body: FadeThroughSwitcher(
  indexKey: index,
  child: pages[index],
),
      bottomNavigationBar: AnimatedNavBar(
  currentIndex: index,

  onTap: (i){
    setState(() {
      index = i;
    });
  },

  items: const [

    NavBarItem(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      label: "Početna",
    ),

    NavBarItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag,
      label: "Proizvodi",
    ),

    NavBarItem(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      label: "Korpa",
    ),

    NavBarItem(
      icon: Icons.local_shipping_outlined,
      activeIcon: Icons.local_shipping,
      label: "Narudžbe",
    ),

    NavBarItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: "Profil",
    ),

  ],
),
    );
  }
}

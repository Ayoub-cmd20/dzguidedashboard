import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/header.dart';
import 'overview_screen.dart';
import 'places_management_screen.dart';
import 'venue_inquiries_screen.dart';
import 'user_management_screen.dart';
import 'rewards_management_screen.dart';
import 'settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Overview',
    'Places Management',
    'Venue Inquiries',
    'User Management',
    'Rewards / Elite',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: Column(
              children: [
                GlobalHeader(title: _titles[_selectedIndex]),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      OverviewScreen(
                        onViewAll: () => setState(() => _selectedIndex = 2),
                      ),
                      const PlacesManagementScreen(),
                      const VenueInquiriesScreen(),
                      const UserManagementScreen(),
                      const RewardsManagementScreen(),
                      const SettingsScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

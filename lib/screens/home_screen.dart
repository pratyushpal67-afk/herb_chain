import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/farmer_harvest_screen.dart';
import '../screens/batch_list_screen.dart';
import '../screens/batch_detail_screen.dart';
import '../screens/lab_screen.dart';
import '../screens/manufacturer_screen.dart';
import '../screens/public_verify_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/sync_screen.dart';
import '../screens/ledger_screen.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final screens = _getScreens(authProvider);
        final navItems = _getNavItems(authProvider);

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            backgroundColor: Colors.white,
            indicatorColor: AppColors.primary.withOpacity(0.1),
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: navItems.map((item) => NavigationDestination(
              icon: Icon(item.icon, color: Colors.grey[600]),
              selectedIcon: Icon(item.icon, color: AppColors.primary),
              label: item.label,
            )).toList(),
          ),
        );
      },
    );
  }

  List<Widget> _getScreens(AuthProvider authProvider) {
    final role = authProvider.user?.role ?? 'COLLECTOR';
    
    switch (role) {
      case 'FARMER':
      case 'COLLECTOR':
        return [
          const FarmerHarvestScreen(),
          const BatchListScreen(),
          const SyncScreen(),
          SettingsScreen(),
        ];
      case 'LAB':
        return [
          LabScreen(),
          const BatchListScreen(),
          SettingsScreen(),
        ];
      case 'MANUFACTURER':
        return [
          ManufacturerScreen(),
          const BatchListScreen(),
          SettingsScreen(),
        ];
      case 'ADMIN':
        return [
          const BatchListScreen(),
          SettingsScreen(),
        ];
      case 'CUSTOMER':
        return [
          PublicVerifyScreen(),
          SettingsScreen(),
        ];
      default:
        return [
          const BatchListScreen(),
          SettingsScreen(),
        ];
    }
  }

  List<NavigationDestination> _getNavItems(AuthProvider authProvider) {
    final role = authProvider.user?.role ?? 'COLLECTOR';
    
    switch (role) {
      case 'FARMER':
      case 'COLLECTOR':
        return [
          const NavigationDestination(
            icon: Icons.eco_outlined,
            selectedIcon: Icons.eco,
            label: 'Collect',
          ),
          const NavigationDestination(
            icon: Icons.inventory_2_outlined,
            selectedIcon: Icons.inventory_2,
            label: 'Batches',
          ),
          const NavigationDestination(
            icon: Icons.cloud_sync_outlined,
            selectedIcon: Icons.cloud_sync,
            label: 'Sync',
          ),
          const NavigationDestination(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings',
          ),
        ];
      case 'LAB':
        return [
          const NavigationDestination(
            icon: Icons.science_outlined,
            selectedIcon: Icons.science,
            label: 'Lab Tests',
          ),
          const NavigationDestination(
            icon: Icons.inventory_2_outlined,
            selectedIcon: Icons.inventory_2,
            label: 'Batches',
          ),
          const NavigationDestination(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings',
          ),
        ];
      case 'MANUFACTURER':
        return [
          const NavigationDestination(
            icon: Icons.factory_outlined,
            selectedIcon: Icons.factory,
            label: 'Manufacturing',
          ),
          const NavigationDestination(
            icon: Icons.inventory_2_outlined,
            selectedIcon: Icons.inventory_2,
            label: 'Batches',
          ),
          const NavigationDestination(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings',
          ),
        ];
      case 'ADMIN':
        return [
          const NavigationDestination(
            icon: Icons.inventory_2_outlined,
            selectedIcon: Icons.inventory_2,
            label: 'All Batches',
          ),
          const NavigationDestination(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings',
          ),
        ];
      case 'CUSTOMER':
        return [
          const NavigationDestination(
            icon: Icons.qr_code_scanner_outlined,
            selectedIcon: Icons.qr_code_scanner,
            label: 'Verify',
          ),
          const NavigationDestination(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings',
          ),
        ];
      default:
        return [
          const NavigationDestination(
            icon: Icons.inventory_2_outlined,
            selectedIcon: Icons.inventory_2,
            label: 'Batches',
          ),
          const NavigationDestination(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings',
          ),
        ];
    }
  }
}
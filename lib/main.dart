/**
 * @file main.dart
 * @brief Main entry point and navigation page
 *
 * This file is a collaborative effort. Its main functions are:
 *  - Initializing the MaterialApp.
 *  - Displaying the main page with 4 buttons, each navigating to a module.
 *  - Providing an info button (to show usage instructions) and a language switch button in the AppBar.
 */

import 'package:flutter/material.dart';
import 'utils/localization.dart';
import 'pages/event_planner_page.dart';
import 'pages/customer_list_page.dart';
import 'pages/expense_tracker_page.dart';
import 'pages/vehicle_maintenance_page.dart';

void main() {
  runApp(const MyApp());
}

/// The main application widget.
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

/// Application state with global theme and routing.
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: getText('appTitle'),
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
    );
  }
}

/// The main screen that contains 4 buttons to navigate to each module.
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// Toggle language between English and Simplified Chinese.
  void _toggleLanguage() {
    setState(() {
      toggleLanguage();
    });
  }

  /// Display usage instructions in a dialog.
  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(getText('instructions')),
        content: Text(getText('instructions')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(getText('ok')),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getText('appTitle')),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInstructions,
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text(getText('eventPlanner')),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EventPlannerPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text(getText('customerList')),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CustomerListPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text(getText('expenseTracker')),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ExpenseTrackerPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text(getText('vehicleMaintenance')),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const VehicleMaintenancePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

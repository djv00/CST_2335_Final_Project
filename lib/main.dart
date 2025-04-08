/**
 * @file main.dart
 * @brief 项目主入口及导航页面
 *
 * 此文件由团队协作完成，主要功能：
 *  - 初始化 MaterialApp
 *  - 显示包含 4 个按钮的主页面，每个按钮跳转到对应功能模块
 *  - 提供 AppBar 中的信息按钮（显示使用说明）与语言切换按钮
 */



import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'utils/localization.dart';
import 'pages/event_planner_page.dart';
import 'pages/customer_list_page.dart';
import 'pages/expense_tracker_page.dart';
import 'pages/vehicle_maintenance_page.dart';

void main() {
  runApp(const MyApp());
}

/// 主应用入口组件
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

/// 应用状态，包含全局主题和路由配置
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

/// 主页面，包含四个按钮导航到各功能模块
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// 切换语言
  void _toggleLanguage() {
    setState(() {
      toggleLanguage();
    });
  }

  /// 显示使用说明
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
                  MaterialPageRoute(builder: (context) => const ExpenseTrackerPage()),
                );
              },
            ),
             ElevatedButton(
               child: Text(getText('customerList')),
               onPressed: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => const ExpenseTrackerPage()),
                 );
               },
             ),
            ElevatedButton(
              child: Text(getText('expenseTracker')),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExpenseTrackerPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text(getText('vehicleMaintenance')),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VehicleMaintenancePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
/**
 * @file widget_test.dart
 * @brief 基本的应用UI测试
 *
 * 测试应用程序的主界面是否正确显示，以及导航是否正常工作。
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cst2335_final_project/main.dart';

void main() {
  testWidgets('App should display main screen with four buttons', (WidgetTester tester) async {
    // 构建应用并触发一个框架
    await tester.pumpWidget(const MyApp());

    // 验证主页面标题
    expect(find.text('应用标题'), findsOneWidget); // 如果您的应用是英文界面，可能需要改为'App Title'等

    // 验证四个模块按钮存在
    expect(find.widgetWithText(ElevatedButton, '事件策划'), findsOneWidget); // 或 'Event Planner'
    expect(find.widgetWithText(ElevatedButton, '客户列表'), findsOneWidget); // 或 'Customer List'
    expect(find.widgetWithText(ElevatedButton, '费用追踪'), findsOneWidget); // 或 'Expense Tracker'
    expect(find.widgetWithText(ElevatedButton, '车辆维护'), findsOneWidget); // 或 'Vehicle Maintenance'

    // 验证AppBar上的按钮
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.byIcon(Icons.language), findsOneWidget);
  });

  // 可以添加更多测试用例，比如测试导航功能
  testWidgets('Navigate to Expense Tracker when button is pressed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 点击费用追踪按钮
    await tester.tap(find.widgetWithText(ElevatedButton, '费用追踪')); // 或 'Expense Tracker'
    await tester.pumpAndSettle(); // 等待动画完成

    // 验证导航到了费用追踪页面
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('费用追踪'), findsOneWidget); // 或 'Expense Tracker'
  });
}
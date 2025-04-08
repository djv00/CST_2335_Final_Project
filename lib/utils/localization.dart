/**
 * @file localization.dart
 * @brief 多语言支持相关代码
 *
 * 定义了英语和简体中文两种语言的文本，以及切换语言的函数。
 */

library localization;

import 'package:flutter/material.dart';

/// 定义多语言文本
Map<String, Map<String, String>> localizedStrings = {
  'en': {
    'appTitle': 'Graphical Interface Programming',
    'eventPlanner': 'Event Planner (A)',
    'customerList': 'Customer List (B)',
    'expenseTracker': 'Expense Tracker (C)',
    'vehicleMaintenance': 'Vehicle Maintenance (D)',
    'instructions': 'Instructions:\n- Add, view, update, and delete records.\n- Long press to delete.',
    'add': 'Add',
    'delete': 'Delete',
    'copyPrevious': 'Previous input loaded.',
    'confirmDeletion': 'Confirm Deletion',
    'ok': 'OK',
    'enter': 'Please enter',
  },
  'zh': {
    'appTitle': '图形界面编程',
    'eventPlanner': '事件规划 (A)',
    'customerList': '客户列表 (B)',
    'expenseTracker': '费用追踪 (C)',
    'vehicleMaintenance': '车辆维护 (D)',
    'instructions': '使用说明：\n- 添加、查看、更新和删除记录。\n- 长按可删除记录。',
    'add': '添加',
    'delete': '删除',
    'copyPrevious': '加载上次输入内容。',
    'confirmDeletion': '确认删除',
    'ok': '确定',
    'enter': '请输入',
  }
};

/// 当前语言，默认为英语
String currentLanguage = 'en';

/// 获取指定键的本地化文本
String getText(String key) {
  return localizedStrings[currentLanguage]?[key] ?? key;
}

/// 切换语言（英语 ⇆ 简体中文）
void toggleLanguage() {
  currentLanguage = currentLanguage == 'en' ? 'zh' : 'en';
}

/**
 * @file localization.dart
 * @brief Multi-language support code.
 *
 * Defines texts in English and Simplified Chinese and provides a function
 * to switch languages.
 */

library localization;

// import 'package:flutter/material.dart';

// Multi-language text definitions.

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

/// Current language, default is English.
String currentLanguage = 'en';

/// Retrieve the localized text for the given key.
String getText(String key) {
  return localizedStrings[currentLanguage]?[key] ?? key;
}

/// Toggle language between English and Simplified Chinese.
void toggleLanguage() {
  currentLanguage = currentLanguage == 'en' ? 'zh' : 'en';
}

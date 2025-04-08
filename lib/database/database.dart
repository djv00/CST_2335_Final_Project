/**
 * @file database.dart
 * @brief 应用数据库定义
 *
 * 定义应用程序数据库结构，包含各模块所需的表和DAO。
 */

import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/event_item.dart';
import '../models/customer_item.dart';
import '../models/expense_item.dart';
import '../models/maintenance_item.dart';
import '../dao/event_dao.dart';
import '../dao/customer_dao.dart';
import '../dao/expense_dao.dart';
import '../dao/maintenance_dao.dart';

part 'database.g.dart'; // 这行很重要，不要遗漏

@Database(version: 1, entities: [EventItem, CustomerItem, ExpenseItem, MaintenanceItem])
abstract class AppDatabase extends FloorDatabase {
  //EventDao get eventDao;
  //CustomerDao get customerDao;
  ExpenseDao get expenseDao;
  MaintenanceDao get maintenanceDao;
}
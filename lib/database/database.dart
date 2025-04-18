/**
 * @file database.dart

 * @brief Floor database configuration.
 *
 * Configures all entities and DAO interfaces.

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

part 'database.g.dart';
@Database(version: 1, entities: [EventItem, CustomerItem, ExpenseItem, MaintenanceItem])
abstract class AppDatabase extends FloorDatabase {
  EventDao get eventDao;
  CustomerDao get customerDao;
  ExpenseDao get expenseDao;
  MaintenanceDao get maintenanceDao;
}


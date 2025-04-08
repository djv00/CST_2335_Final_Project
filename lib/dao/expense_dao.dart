/**
 * @file expense_dao.dart
 * @brief 费用追踪模块 DAO 接口
 *
 * 定义费用记录的增删改查操作。
 */

import 'package:floor/floor.dart';
import '../models/expense_item.dart';

@dao
abstract class ExpenseDao {
  @Query('SELECT * FROM ExpenseItem')
  Future<List<ExpenseItem>> findAllExpenses();

  @insert
  Future<void> insertExpense(ExpenseItem expense);

  @delete
  Future<void> deleteExpense(ExpenseItem expense);

  @update
  Future<void> updateExpense(ExpenseItem expense);
}
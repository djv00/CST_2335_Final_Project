文件：lib/models/expense_item.dart
/**
 * @file expense_item.dart
 * @brief 费用追踪模块实体类
 *
 * 定义费用记录的各个字段。
 */

import 'package:floor/floor.dart';

@entity
class ExpenseItem {
@PrimaryKey(autoGenerate: true)
final int? id;
final String expenseName;
final String category;
final String amount;
final String date;
final String paymentMethod;

ExpenseItem(this.id, this.expenseName, this.category, this.amount, this.date, this.paymentMethod);
}

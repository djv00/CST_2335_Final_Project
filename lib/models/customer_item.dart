/**
 * @file customer_item.dart
 * @brief 客户数据模型
 *
 * 定义客户的数据结构
 */

import 'package:floor/floor.dart';

@entity
class CustomerItem {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;
  final String contact;
  final String address;
  final String notes;

  CustomerItem(this.id, this.name, this.contact, this.address, this.notes);
}
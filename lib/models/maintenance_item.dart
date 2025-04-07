/**
 * @file maintenance_item.dart
 * @brief 车辆维护数据模型
 *
 * 定义车辆维护记录的数据结构
 */

import 'package:floor/floor.dart';

@entity
class MaintenanceItem {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String vehicleName;
  final String maintenanceType;
  final String date;
  final String cost;
  final String notes;

  MaintenanceItem(this.id, this.vehicleName, this.maintenanceType, this.date, this.cost, this.notes);
}
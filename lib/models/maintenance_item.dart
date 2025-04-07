/**
 * @file maintenance_item.dart
 * @brief 车辆维护模块实体类
 *
 * 定义车辆维护记录的各个字段。
 */

import 'package:floor/floor.dart';

@entity
class MaintenanceItem {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String vehicleName;
  final String vehicleType;
  final String serviceType;
  final String serviceDate;
  final String mileage;
  final String cost;

  MaintenanceItem(this.id, this.vehicleName, this.vehicleType, this.serviceType,
      this.serviceDate, this.mileage, this.cost);
}

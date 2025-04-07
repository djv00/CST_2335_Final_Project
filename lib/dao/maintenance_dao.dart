/**
 * @file maintenance_dao.dart
 * @brief 车辆维护模块 DAO 接口
 *
 * 定义车辆维护记录的增删改查操作。
 */

import 'package:floor/floor.dart';
import '../models/maintenance_item.dart';

@dao
abstract class MaintenanceDao {
  @Query('SELECT * FROM MaintenanceItem')
  Future<List<MaintenanceItem>> findAllMaintenances();

  @insert
  Future<void> insertMaintenance(MaintenanceItem maintenance);

  @delete
  Future<void> deleteMaintenance(MaintenanceItem maintenance);

  @update
  Future<void> updateMaintenance(MaintenanceItem maintenance);
}
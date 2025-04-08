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

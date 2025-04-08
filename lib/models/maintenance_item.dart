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

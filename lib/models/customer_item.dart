/**
 * @file customer_item.dart
 * @brief Entity class for the Customer List module.
 *
 * Defines the fields for a customer record.
 */

import 'package:floor/floor.dart';

@entity
class CustomerItem {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String firstName;
  final String lastName;
  final String address;
  final String birthday;

  CustomerItem(this.id, this.firstName, this.lastName, this.address, this.birthday);
}

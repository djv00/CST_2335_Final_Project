/**
 * @file customer_dao.dart
 * @brief DAO interface for the Customer List module.
 *
 * Defines CRUD operations for customer records.
 */

import 'package:floor/floor.dart';
import '../models/customer_item.dart';

@dao
abstract class CustomerDao {
  @Query('SELECT * FROM CustomerItem')
  Future<List<CustomerItem>> findAllCustomers();

  @insert
  Future<void> insertCustomer(CustomerItem customer);

  @delete
  Future<void> deleteCustomer(CustomerItem customer);

  @update
  Future<void> updateCustomer(CustomerItem customer);
}

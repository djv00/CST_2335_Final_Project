/**
 * @file event_dao.dart
 * @brief DAO interface for the Event Planner module.
 *
 * Provides CRUD operations for event records.
 */

import 'package:floor/floor.dart';
import '../models/event_item.dart';

@dao
abstract class EventDao {
  @Query('SELECT * FROM EventItem')
  Future<List<EventItem>> findAllEvents();

  @insert
  Future<void> insertEvent(EventItem event);

  @delete
  Future<void> deleteEvent(EventItem event);

  @update
  Future<void> updateEvent(EventItem event);
}

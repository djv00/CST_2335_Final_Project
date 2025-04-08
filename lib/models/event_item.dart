/**
 * @file event_item.dart
 * @brief Entity class for the Event Planner module.
 *
 * Defines the fields for an event record.
 */

import 'package:floor/floor.dart';

@entity
class EventItem {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String name;
  final String date;
  final String time;
  final String location;
  final String description;

  EventItem(this.id, this.name, this.date, this.time, this.location,
      this.description);
}

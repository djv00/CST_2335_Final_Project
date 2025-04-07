/**
 * @file event_item.dart
 * @brief 事件数据模型
 *
 * 定义事件的数据结构
 */

import 'package:floor/floor.dart';

@entity
class EventItem {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String title;
  final String date;
  final String location;
  final String description;

  EventItem(this.id, this.title, this.date, this.location, this.description);
}
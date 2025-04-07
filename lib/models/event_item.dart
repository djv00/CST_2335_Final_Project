/**
 * @file event_item.dart
 * @brief 事件规划模块实体类
 *
 * 定义事件记录的各个字段。
 */

import 'package:flutter/material.dart';
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

  EventItem(this.id, this.name, this.date, this.time, this.location, this.description);
}

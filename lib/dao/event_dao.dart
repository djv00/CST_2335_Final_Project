/**
 * @file event_dao.dart
 * @brief 事件计划模块 DAO 接口
 *
 * 定义事件记录的增删改查操作。
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
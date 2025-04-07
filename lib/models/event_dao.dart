/**
 * @file event_dao.dart
 * @brief 事件规划模块 DAO 接口
 *
 * 提供事件记录的增删改查操作。
 */

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

/**
 * @file event_planner_page.dart
 * @brief Event Planner page.
 *
 * Implements adding, displaying, and deleting event records, with a responsive layout,
 * Snackbar notifications, AlertDialog confirmation, FlutterSecureStorage for saving previous inputs,
 * AppBar info instructions, and multi-language support.
 */

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/database.dart';
import '../dao/event_dao.dart';
import '../models/event_item.dart';
import '../utils/localization.dart';

class EventPlannerPage extends StatefulWidget {
  const EventPlannerPage({Key? key}) : super(key: key);

  @override
  State<EventPlannerPage> createState() => _EventPlannerPageState();
}

class _EventPlannerPageState extends State<EventPlannerPage> {
  List<EventItem> events = [];
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  late AppDatabase database;
  late EventDao eventDao;
  final _storage = const FlutterSecureStorage();

  EventItem? selectedEvent;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _loadPreviousInput();
  }

  /// Load previous input values from secure storage.
  Future<void> _loadPreviousInput() async {
    _nameController.text = await _storage.read(key: 'event_name') ?? '';
    _dateController.text = await _storage.read(key: 'event_date') ?? '';
    _timeController.text = await _storage.read(key: 'event_time') ?? '';
    _locationController.text = await _storage.read(key: 'event_location') ?? '';
    _descriptionController.text =
        await _storage.read(key: 'event_description') ?? '';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(getText('copyPrevious'))));
  }

  /// Save current input values to secure storage.
  Future<void> _saveCurrentInput() async {
    await _storage.write(key: 'event_name', value: _nameController.text);
    await _storage.write(key: 'event_date', value: _dateController.text);
    await _storage.write(key: 'event_time', value: _timeController.text);
    await _storage.write(
        key: 'event_location', value: _locationController.text);
    await _storage.write(
        key: 'event_description', value: _descriptionController.text);
  }

  /// Initialize the database and load event records.
  Future<void> _initializeDatabase() async {
    database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    eventDao = database.eventDao;
    final loadedEvents = await eventDao.findAllEvents();
    setState(() {
      events = loadedEvents;
    });
  }

  /// Add a new event record.
  void _addEvent() async {
    if (_nameController.text.isNotEmpty &&
        _dateController.text.isNotEmpty &&
        _timeController.text.isNotEmpty &&
        _locationController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      final newEvent = EventItem(
          null,
          _nameController.text,
          _dateController.text,
          _timeController.text,
          _locationController.text,
          _descriptionController.text);
      await eventDao.insertEvent(newEvent);
      final loadedEvents = await eventDao.findAllEvents();
      setState(() {
        events = loadedEvents;
        _clearInput();
      });
      _saveCurrentInput();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${getText('add')} ${getText('eventPlanner')}')));
    }
  }

  /// Clear all input fields.
  void _clearInput() {
    _nameController.clear();
    _dateController.clear();
    _timeController.clear();
    _locationController.clear();
    _descriptionController.clear();
  }

  /// Delete an event record.
  void _deleteEvent(EventItem event) async {
    await eventDao.deleteEvent(event);
    final loadedEvents = await eventDao.findAllEvents();
    setState(() {
      events = loadedEvents;
      selectedEvent = null;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(getText('delete'))));
  }

  /// Responsive layout: displays list and details side by side on wider screens.
  Widget _responsiveLayout() {
    var size = MediaQuery.of(context).size;
    if (size.width > 720) {
      return Row(
        children: [
          Expanded(flex: 1, child: _buildListView()),
          Expanded(flex: 1, child: _buildDetailsView()),
        ],
      );
    } else {
      return selectedEvent == null ? _buildListView() : _buildDetailsView();
    }
  }

  Widget _buildListView() {
    return Column(
      children: [
        // Input form
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                    labelText: '${getText('enter')} Event Name'),
              ),
              TextField(
                controller: _dateController,
                decoration:
                    InputDecoration(labelText: '${getText('enter')} Date'),
              ),
              TextField(
                controller: _timeController,
                decoration:
                    InputDecoration(labelText: '${getText('enter')} Time'),
              ),
              TextField(
                controller: _locationController,
                decoration:
                    InputDecoration(labelText: '${getText('enter')} Location'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                    labelText: '${getText('enter')} Description'),
              ),
              ElevatedButton(
                onPressed: _addEvent,
                child: Text(getText('add')),
              ),
            ],
          ),
        ),
        // Event list
        Expanded(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedEvent = event;
                  });
                },
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(getText('confirmDeletion')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(getText('no')),
                        ),
                        TextButton(
                          onPressed: () {
                            _deleteEvent(event);
                            Navigator.pop(context);
                          },
                          child: Text(getText('yes')),
                        ),
                      ],
                    ),
                  );
                },
                child: ListTile(
                  title: Text(event.name),
                  subtitle: Text('${event.date} ${event.time}'),
                  tileColor: selectedEvent?.id == event.id
                      ? Colors.blue.shade100
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsView() {
    if (selectedEvent == null) {
      return const Center(child: Text('No event selected'));
    }
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Name: ${selectedEvent!.name}",
              style: const TextStyle(fontSize: 20)),
          Text("Date: ${selectedEvent!.date}"),
          Text("Time: ${selectedEvent!.time}"),
          Text("Location: ${selectedEvent!.location}"),
          Text("Description: ${selectedEvent!.description}"),
          ElevatedButton(
            onPressed: () => _deleteEvent(selectedEvent!),
            child: Text(getText('delete')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getText('eventPlanner')),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(getText('instructions')),
                  content: Text(getText('instructions')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(getText('ok')),
                    )
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              setState(() {
                toggleLanguage();
              });
            },
          ),
        ],
      ),
      body: _responsiveLayout(),
    );
  }
}

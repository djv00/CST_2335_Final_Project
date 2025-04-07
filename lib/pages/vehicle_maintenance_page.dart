/**
 * @file vehicle_maintenance_page.dart
 * @brief 车辆维护页面
 *
 * 实现添加、显示、删除车辆维护记录，支持响应式布局、SnackBar、AlertDialog、
 * FlutterSecureStorage 存储上次输入内容、AppBar 提示及多语言支持。
 */

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/database.dart';
import '../dao/maintenance_dao.dart';
import '../models/maintenance_item.dart';
import '../utils/localization.dart';

class VehicleMaintenancePage extends StatefulWidget {
  const VehicleMaintenancePage({Key? key}) : super(key: key);
  @override
  State<VehicleMaintenancePage> createState() => _VehicleMaintenancePageState();
}

class _VehicleMaintenancePageState extends State<VehicleMaintenancePage> {
  List<MaintenanceItem> maintenances = [];
  final _vehicleNameController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  final _serviceDateController = TextEditingController();
  final _mileageController = TextEditingController();
  final _costController = TextEditingController();

  late AppDatabase database;
  late MaintenanceDao maintenanceDao;
  final _storage = const FlutterSecureStorage();

  MaintenanceItem? selectedMaintenance;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _loadPreviousInput();
  }

  Future<void> _loadPreviousInput() async {
    _vehicleNameController.text = await _storage.read(key: 'maintenance_vehicleName') ?? '';
    _vehicleTypeController.text = await _storage.read(key: 'maintenance_vehicleType') ?? '';
    _serviceTypeController.text = await _storage.read(key: 'maintenance_serviceType') ?? '';
    _serviceDateController.text = await _storage.read(key: 'maintenance_serviceDate') ?? '';
    _mileageController.text = await _storage.read(key: 'maintenance_mileage') ?? '';
    _costController.text = await _storage.read(key: 'maintenance_cost') ?? '';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(getText('copyPrevious'))));
  }

  Future<void> _saveCurrentInput() async {
    await _storage.write(key: 'maintenance_vehicleName', value: _vehicleNameController.text);
    await _storage.write(key: 'maintenance_vehicleType', value: _vehicleTypeController.text);
    await _storage.write(key: 'maintenance_serviceType', value: _serviceTypeController.text);
    await _storage.write(key: 'maintenance_serviceDate', value: _serviceDateController.text);
    await _storage.write(key: 'maintenance_mileage', value: _mileageController.text);
    await _storage.write(key: 'maintenance_cost', value: _costController.text);
  }

  Future<void> _initializeDatabase() async {
    database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    maintenanceDao = database.maintenanceDao;
    final loadedMaintenances = await maintenanceDao.findAllMaintenances();
    setState(() {
      maintenances = loadedMaintenances;
    });
  }

  void _addMaintenance() async {
    if (_vehicleNameController.text.isNotEmpty &&
        _vehicleTypeController.text.isNotEmpty &&
        _serviceTypeController.text.isNotEmpty &&
        _serviceDateController.text.isNotEmpty &&
        _mileageController.text.isNotEmpty &&
        _costController.text.isNotEmpty) {
      final newMaintenance = MaintenanceItem(null, _vehicleNameController.text, _vehicleTypeController.text,
          _serviceTypeController.text, _serviceDateController.text, _mileageController.text, /*_costController.text*/);
      await maintenanceDao.insertMaintenance(newMaintenance);
      final loadedMaintenances = await maintenanceDao.findAllMaintenances();
      setState(() {
        maintenances = loadedMaintenances;
        _clearInput();
      });
      _saveCurrentInput();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${getText('add')} ${getText('vehicleMaintenance')}')));
    }
  }

  void _clearInput() {
    _vehicleNameController.clear();
    _vehicleTypeController.clear();
    _serviceTypeController.clear();
    _serviceDateController.clear();
    _mileageController.clear();
    _costController.clear();
  }

  void _deleteMaintenance(MaintenanceItem maintenance) async {
    await maintenanceDao.deleteMaintenance(maintenance);
    final loadedMaintenances = await maintenanceDao.findAllMaintenances();
    setState(() {
      maintenances = loadedMaintenances;
      selectedMaintenance = null;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(getText('delete'))));
  }

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
      return selectedMaintenance == null ? _buildListView() : _buildDetailsView();
    }
  }

  Widget _buildListView() {
    return Column(
      children: [
        // 输入表单
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _vehicleNameController,
                decoration: InputDecoration(labelText: '${getText('enter')} Vehicle Name'),
              ),
              TextField(
                controller: _vehicleTypeController,
                decoration: InputDecoration(labelText: '${getText('enter')} Vehicle Type'),
              ),
              TextField(
                controller: _serviceTypeController,
                decoration: InputDecoration(labelText: '${getText('enter')} Service Type'),
              ),
              TextField(
                controller: _serviceDateController,
                decoration: InputDecoration(labelText: '${getText('enter')} Service Date'),
              ),
              TextField(
                controller: _mileageController,
                decoration: InputDecoration(labelText: '${getText('enter')} Mileage'),
              ),
              TextField(
                controller: _costController,
                decoration: InputDecoration(labelText: '${getText('enter')} Cost'),
              ),
              ElevatedButton(
                onPressed: _addMaintenance,
                child: Text(getText('add')),
              ),
            ],
          ),
        ),
        // 维护记录列表
        Expanded(
          child: ListView.builder(
            itemCount: maintenances.length,
            itemBuilder: (context, index) {
              final maintenance = maintenances[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMaintenance = maintenance;
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
                            _deleteMaintenance(maintenance);
                            Navigator.pop(context);
                          },
                          child: Text(getText('yes')),
                        ),
                      ],
                    ),
                  );
                },
                child: ListTile(
                  title: Text(maintenance.vehicleName),
                  //subtitle: Text(maintenance.serviceType),
                  tileColor: selectedMaintenance?.id == maintenance.id ? Colors.blue.shade100 : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsView() {
    if (selectedMaintenance == null) {
      return const Center(child: Text('No maintenance record selected'));
    }
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Vehicle: ${selectedMaintenance!.vehicleName}", style: const TextStyle(fontSize: 20)),
          //Text("Type: ${selectedMaintenance!.vehicleType}"),
          //Text("Service: ${selectedMaintenance!.serviceType}"),
          //Text("Date: ${selectedMaintenance!.serviceDate}"),
          //Text("Mileage: ${selectedMaintenance!.mileage}"),
          Text("Cost: ${selectedMaintenance!.cost}"),
          ElevatedButton(
            onPressed: () => _deleteMaintenance(selectedMaintenance!),
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
        title: Text(getText('vehicleMaintenance')),
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

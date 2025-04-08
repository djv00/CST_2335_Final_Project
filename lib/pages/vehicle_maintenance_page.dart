import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../dao/maintenance_dao.dart';
import '../database/database.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(getText('copyPrevious'))),
    );
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
      final newRecord = MaintenanceItem(
        null,
        _vehicleNameController.text,
        _vehicleTypeController.text,
        _serviceTypeController.text,
        _serviceDateController.text,
        _mileageController.text,
        _costController.text,
      );
      await maintenanceDao.insertMaintenance(newRecord);
      final updatedList = await maintenanceDao.findAllMaintenances();
      setState(() {
        maintenances = updatedList;
        _clearInput();
      });
      _saveCurrentInput();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${getText('add')} ${getText('vehicleMaintenance')}')),
      );
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

  void _deleteMaintenance(MaintenanceItem item) async {
    await maintenanceDao.deleteMaintenance(item);
    final updatedList = await maintenanceDao.findAllMaintenances();
    setState(() {
      maintenances = updatedList;
      selectedMaintenance = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(getText('delete'))),
    );
  }

  Widget _responsiveLayout() {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 720
        ? Row(
      children: [
        Expanded(child: _buildListView()),
        Expanded(child: _buildDetailsView()),
      ],
    )
        : selectedMaintenance == null ? _buildListView() : _buildDetailsView();
  }

  Widget _buildListView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildTextField(_vehicleNameController, '${getText('enter')} Vehicle Name'),
              _buildTextField(_vehicleTypeController, '${getText('enter')} Vehicle Type'),
              _buildTextField(_serviceTypeController, '${getText('enter')} Service Type'),
              _buildTextField(_serviceDateController, '${getText('enter')} Service Date'),
              _buildTextField(_mileageController, '${getText('enter')} Mileage'),
              _buildTextField(_costController, '${getText('enter')} Cost'),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _addMaintenance, child: Text(getText('add'))),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: maintenances.length,
            itemBuilder: (context, index) {
              final item = maintenances[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMaintenance = item;
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
                            _deleteMaintenance(item);
                            Navigator.pop(context);
                          },
                          child: Text(getText('yes')),
                        ),
                      ],
                    ),
                  );
                },
                child: ListTile(
                  title: Text(item.vehicleName),
                  subtitle: Text(item.serviceType),
                  tileColor: selectedMaintenance?.id == item.id ? Colors.blue.shade100 : null,
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
      return const Center(child: Text('No record selected'));
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vehicle: ${selectedMaintenance!.vehicleName}', style: const TextStyle(fontSize: 20)),
          Text('Type: ${selectedMaintenance!.vehicleType}'),
          Text('Service: ${selectedMaintenance!.serviceType}'),
          Text('Date: ${selectedMaintenance!.serviceDate}'),
          Text('Mileage: ${selectedMaintenance!.mileage}'),
          Text('Cost: ${selectedMaintenance!.cost}'),
          ElevatedButton(
            onPressed: () => _deleteMaintenance(selectedMaintenance!),
            child: Text(getText('delete')),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
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

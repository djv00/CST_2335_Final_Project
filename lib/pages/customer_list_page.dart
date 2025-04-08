/**
 * @file customer_list_page.dart
 * @brief Customer List page.
 *
 * Implements adding, displaying, and deleting customer records, with a responsive layout,
 * Snackbar notifications, AlertDialog confirmation, FlutterSecureStorage for saving previous inputs,
 * AppBar usage instructions, and multi-language support.
 */

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/database.dart';
import '../dao/customer_dao.dart';
import '../models/customer_item.dart';
import '../utils/localization.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({Key? key}) : super(key: key);
  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  List<CustomerItem> customers = [];
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdayController = TextEditingController();

  late AppDatabase database;
  late CustomerDao customerDao;
  final _storage = const FlutterSecureStorage();

  bool isEditing = false;

  CustomerItem? selectedCustomer;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _loadPreviousInput();
  }

  Future<void> _loadPreviousInput() async {
    _firstNameController.text = await _storage.read(key: 'customer_firstName') ?? '';
    _lastNameController.text = await _storage.read(key: 'customer_lastName') ?? '';
    _addressController.text = await _storage.read(key: 'customer_address') ?? '';
    _birthdayController.text = await _storage.read(key: 'customer_birthday') ?? '';
    // ScaffoldMessenger.of(context)
        // .showSnackBar(SnackBar(content: Text(getText('copyPrevious'))));
  }

  Future<void> _saveCurrentInput() async {
    await _storage.write(key: 'customer_firstName', value: _firstNameController.text);
    await _storage.write(key: 'customer_lastName', value: _lastNameController.text);
    await _storage.write(key: 'customer_address', value: _addressController.text);
    await _storage.write(key: 'customer_birthday', value: _birthdayController.text);
  }

  Future<void> _initializeDatabase() async {
    database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    customerDao = database.customerDao;
    final loadedCustomers = await customerDao.findAllCustomers();
    setState(() {
      customers = loadedCustomers;
    });
  }

  void _addCustomer() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _birthdayController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all the customer information.')));
    } else if (_firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _birthdayController.text.isNotEmpty) {
      final newCustomer = CustomerItem(null, _firstNameController.text, _lastNameController.text,
          _addressController.text, _birthdayController.text);
      await customerDao.insertCustomer(newCustomer);
      final loadedCustomers = await customerDao.findAllCustomers();
      setState(() {
        customers = loadedCustomers;
        _clearInput();
      });
      _saveCurrentInput();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${getText('add')} ${getText('customerList')}')));
    }
  }

  void _clearInput() {
    _firstNameController.clear();
    _lastNameController.clear();
    _addressController.clear();
    _birthdayController.clear();
  }

  void _deleteCustomer(CustomerItem customer) async {
    await customerDao.deleteCustomer(customer);
    final loadedCustomers = await customerDao.findAllCustomers();
    setState(() {
      customers = loadedCustomers;
      selectedCustomer = null;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(getText('Deleted'))));
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
      return selectedCustomer == null ? _buildListView() : _buildDetailsView();
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
                controller: _firstNameController,
                decoration: InputDecoration(labelText: '${getText('enter')} First Name'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: '${getText('enter')} Last Name'),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: '${getText('enter')} Address'),
              ),
              TextField(
                controller: _birthdayController,
                decoration: InputDecoration(labelText: '${getText('enter')} Birthday'),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _addCustomer,
                    child: Text(getText('Add')),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _clearInput,
                    child: Text(getText('Clear')), // assumes 'clear' key exists in localization
                  ),
                ],
              ),
            ],
          ),
        ),
        // Customer list
        Expanded(
          child: ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCustomer = customer;
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
                          child: Text(getText('No')),
                        ),
                        TextButton(
                          onPressed: () {
                            _deleteCustomer(customer);
                            Navigator.pop(context);
                          },
                          child: Text(getText('Yes')),
                        ),
                      ],
                    ),
                  );
                },
                child: ListTile(
                  title: Text('${customer.firstName} ${customer.lastName}'),
                  subtitle: Text(customer.address),
                  tileColor: selectedCustomer?.id == customer.id ? Colors.blue.shade100 : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsView() {
    if (selectedCustomer == null) {
      return const Center(child: Text('No customer selected'));
    }

    if (isEditing) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: '${getText('enter')} First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: '${getText('enter')} Last Name'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: '${getText('enter')} Address'),
            ),
            TextField(
              controller: _birthdayController,
              decoration: InputDecoration(labelText: '${getText('enter')} Birthday'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final updated = CustomerItem(
                        selectedCustomer!.id,
                        _firstNameController.text,
                        _lastNameController.text,
                        _addressController.text,
                        _birthdayController.text,
                      );
                      await customerDao.updateCustomer(updated);
                      final refreshed = await customerDao.findAllCustomers();
                      setState(() {
                        customers = refreshed;
                        selectedCustomer = updated;
                        isEditing = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(getText('Updated'))),
                      );
                    },
                    child: Text(getText('Update')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEditing = false;
                      });
                    },
                    child: Text(getText('Cancel')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${selectedCustomer!.firstName} ${selectedCustomer!.lastName}",
                style: const TextStyle(fontSize: 20)),
            Text("Address: ${selectedCustomer!.address}"),
            Text("Birthday: ${selectedCustomer!.birthday}"),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                      _firstNameController.text = selectedCustomer!.firstName;
                      _lastNameController.text = selectedCustomer!.lastName;
                      _addressController.text = selectedCustomer!.address;
                      _birthdayController.text = selectedCustomer!.birthday;
                    });
                  },
                  child: Text(getText('Edit')),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _deleteCustomer(selectedCustomer!),
                  child: Text(getText('Delete')),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCustomer = null;
                      isEditing = false;
                      _clearInput();
                    });
                  },
                  child: Text(getText('Back')),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getText('customerList')),
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

/**
 * @file expense_tracker_page.dart
 * @brief Expense Tracker page.
 *
 * Implements adding, displaying, and deleting expense records, with a responsive layout,
 * Snackbar notifications, AlertDialog confirmation, FlutterSecureStorage for saving previous inputs,
 * AppBar usage instructions, and multi-language support.
 */

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/database.dart';
import '../dao/expense_dao.dart';
import '../models/expense_item.dart';
import '../utils/localization.dart';

class ExpenseTrackerPage extends StatefulWidget {
  const ExpenseTrackerPage({Key? key}) : super(key: key);
  @override
  State<ExpenseTrackerPage> createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrackerPage> {
  List<ExpenseItem> expenses = [];
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _paymentController = TextEditingController();

  late AppDatabase database;
  late ExpenseDao expenseDao;
  final _storage = const FlutterSecureStorage();

  ExpenseItem? selectedExpense;
  bool _isEditing = false; // 添加编辑模式状态变量

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _loadPreviousInput();
  }

  Future<void> _loadPreviousInput() async {
    _nameController.text = await _storage.read(key: 'expense_name') ?? '';
    _categoryController.text = await _storage.read(key: 'expense_category') ?? '';
    _amountController.text = await _storage.read(key: 'expense_amount') ?? '';
    _dateController.text = await _storage.read(key: 'expense_date') ?? '';
    _paymentController.text = await _storage.read(key: 'expense_payment') ?? '';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(getText('copyPrevious'))));
  }

  Future<void> _saveCurrentInput() async {
    await _storage.write(key: 'expense_name', value: _nameController.text);
    await _storage.write(key: 'expense_category', value: _categoryController.text);
    await _storage.write(key: 'expense_amount', value: _amountController.text);
    await _storage.write(key: 'expense_date', value: _dateController.text);
    await _storage.write(key: 'expense_payment', value: _paymentController.text);
  }

  Future<void> _initializeDatabase() async {
    database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    expenseDao = database.expenseDao;
    final loadedExpenses = await expenseDao.findAllExpenses();
    setState(() {
      expenses = loadedExpenses;
    });
  }

  void _addExpense() async {
    if (_nameController.text.isNotEmpty &&
        _categoryController.text.isNotEmpty &&
        _amountController.text.isNotEmpty &&
        _dateController.text.isNotEmpty &&
        _paymentController.text.isNotEmpty) {
      final newExpense = ExpenseItem(null, _nameController.text, _categoryController.text,
          _amountController.text, _dateController.text, _paymentController.text);
      await expenseDao.insertExpense(newExpense);
      final loadedExpenses = await expenseDao.findAllExpenses();
      _saveCurrentInput();
      setState(() {
        expenses = loadedExpenses;
        _clearInput();
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${getText('add')} ${getText('expenseTracker')}')));
    }
  }

  // 添加更新费用功能
  void _updateExpense() async {
    final currentExpense = selectedExpense;
    if (currentExpense != null &&
        _nameController.text.isNotEmpty &&
        _categoryController.text.isNotEmpty &&
        _amountController.text.isNotEmpty &&
        _dateController.text.isNotEmpty &&
        _paymentController.text.isNotEmpty) {
      final updatedExpense = ExpenseItem(
          currentExpense.id,
          _nameController.text,
          _categoryController.text,
          _amountController.text,
          _dateController.text,
          _paymentController.text);
      await expenseDao.updateExpense(updatedExpense);
      final loadedExpenses = await expenseDao.findAllExpenses();
      setState(() {
        expenses = loadedExpenses;
        selectedExpense = updatedExpense;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(getText('update'))));
    }
  }

  // 加载选定费用到表单
  void _loadExpenseForEditing(ExpenseItem expense) {
    _nameController.text = expense.expenseName;
    _categoryController.text = expense.category;
    _amountController.text = expense.amount;
    _dateController.text = expense.date;
    _paymentController.text = expense.paymentMethod;
    setState(() {
      _isEditing = true;
    });
  }

  void _clearInput() {
    _nameController.clear();
    _categoryController.clear();
    _amountController.clear();
    _dateController.clear();
    _paymentController.clear();
  }

  void _deleteExpense(ExpenseItem expense) async {
    await expenseDao.deleteExpense(expense);
    final loadedExpenses = await expenseDao.findAllExpenses();
    setState(() {
      expenses = loadedExpenses;
      selectedExpense = null;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(getText('delete'))));
  }

  Widget _responsiveLayout() {
    var size = MediaQuery.of(context).size;
    if (size.width > 720) {
      return Row(
        children: [
          Expanded(flex: 1, child: _isEditing ? _buildEditingView() : _buildListView()),
          Expanded(flex: 1, child: _buildDetailsView()),
        ],
      );
    } else {
      if (_isEditing) {
        return _buildEditingView();
      } else {
        return selectedExpense == null ? _buildListView() : _buildDetailsView();
      }
    }
  }

  // 添加编辑视图
  Widget _buildEditingView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(getText('editExpense'), style: const TextStyle(fontSize: 20)),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: '${getText('enter')} ${getText('expenseName')}'),
          ),
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(labelText: '${getText('enter')} ${getText('category')}'),
          ),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(labelText: '${getText('enter')} ${getText('amount')}'),
          ),
          TextField(
            controller: _dateController,
            decoration: InputDecoration(labelText: '${getText('enter')} ${getText('date')}'),
          ),
          TextField(
            controller: _paymentController,
            decoration: InputDecoration(labelText: '${getText('enter')} ${getText('paymentMethod')}'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _clearInput();
                  });
                },
                child: Text(getText('cancel')),
              ),
              ElevatedButton(
                onPressed: _updateExpense,
                child: Text(getText('update')),
              ),
            ],
          ),
        ],
      ),
    );
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
                decoration: InputDecoration(labelText: '${getText('enter')} ${getText('expenseName')}'),
              ),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: '${getText('enter')} ${getText('category')}'),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: '${getText('enter')} ${getText('amount')}'),
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: '${getText('enter')} ${getText('date')}'),
              ),
              TextField(
                controller: _paymentController,
                decoration: InputDecoration(labelText: '${getText('enter')} ${getText('paymentMethod')}'),
              ),
              ElevatedButton(
                onPressed: _addExpense,
                child: Text(getText('add')),
              ),
            ],
          ),
        ),
        // Expense list
        Expanded(
          child: ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedExpense = expense;
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
                            _deleteExpense(expense);
                            Navigator.pop(context);
                          },
                          child: Text(getText('yes')),
                        ),
                      ],
                    ),
                  );
                },
                child: ListTile(
                  title: Text(expense.expenseName),
                  subtitle: Text(expense.category),
                  tileColor: selectedExpense?.id == expense.id ? Colors.blue.shade100 : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsView() {
    if (selectedExpense == null) {
      return const Center(child: Text('No expense selected'));
    }
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${getText('expenseName')}: ${selectedExpense!.expenseName}", style: const TextStyle(fontSize: 20)),
          Text("${getText('category')}: ${selectedExpense!.category}"),
          Text("${getText('amount')}: ${selectedExpense!.amount}"),
          Text("${getText('date')}: ${selectedExpense!.date}"),
          Text("${getText('paymentMethod')}: ${selectedExpense!.paymentMethod}"),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () => _deleteExpense(selectedExpense!),
                child: Text(getText('delete')),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _loadExpenseForEditing(selectedExpense!);
                },
                child: Text(getText('edit')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getText('expenseTracker')),
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
/**
 * @file expense_tracker_page.dart
 * @brief 费用追踪页面
 *
 * 实现添加、显示、删除费用记录，支持响应式布局、SnackBar、AlertDialog、
 * FlutterSecureStorage 存储上次输入内容、AppBar 提示及多语言支持。
 */

import 'package:flutter/material.dart';
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
      setState(() {
        expenses = loadedExpenses;
        _clearInput();
      });
      _saveCurrentInput();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${getText('add')} ${getText('expenseTracker')}')));
    }
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
          Expanded(flex: 1, child: _buildListView()),
          Expanded(flex: 1, child: _buildDetailsView()),
        ],
      );
    } else {
      return selectedExpense == null ? _buildListView() : _buildDetailsView();
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
                controller: _nameController,
                decoration: InputDecoration(labelText: '${getText('enter')} Expense Name'),
              ),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: '${getText('enter')} Category'),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: '${getText('enter')} Amount'),
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: '${getText('enter')} Date'),
              ),
              TextField(
                controller: _paymentController,
                decoration: InputDecoration(labelText: '${getText('enter')} Payment Method'),
              ),
              ElevatedButton(
                onPressed: _addExpense,
                child: Text(getText('add')),
              ),
            ],
          ),
        ),
        // 费用列表
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
          Text("Expense: ${selectedExpense!.expenseName}", style: const TextStyle(fontSize: 20)),
          Text("Category: ${selectedExpense!.category}"),
          Text("Amount: ${selectedExpense!.amount}"),
          Text("Date: ${selectedExpense!.date}"),
          Text("Payment: ${selectedExpense!.paymentMethod}"),
          ElevatedButton(
            onPressed: () => _deleteExpense(selectedExpense!),
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

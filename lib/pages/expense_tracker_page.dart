/**
 * @file expense_tracker_page.dart
 * @brief 费用追踪页面
 *
 * 实现添加、显示、删除费用记录，支持响应式布局、SnackBar、AlertDialog、
 * FlutterSecureStorage 存储上次输入内容、AppBar 提示及多语言支持。
 */

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  AppDatabase? database;
  ExpenseDao? expenseDao;
  bool _isLoading = true;
  final _storage = const FlutterSecureStorage();

  ExpenseItem? selectedExpense;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();

    // 延迟加载前一次输入，确保在initState中不直接使用BuildContext
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreviousInput();
    });
  }

  Future<void> _loadPreviousInput() async {
    try {
      _nameController.text = await _storage.read(key: 'expense_name') ?? '';
      _categoryController.text = await _storage.read(key: 'expense_category') ?? '';
      _amountController.text = await _storage.read(key: 'expense_amount') ?? '';
      _dateController.text = await _storage.read(key: 'expense_date') ?? '';
      _paymentController.text = await _storage.read(key: 'expense_payment') ?? '';

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(getText('copyPrevious'))));
      }
    } catch (e) {
      debugPrint('加载上次输入时出错: $e');
    }
  }

  Future<void> _saveCurrentInput() async {
    try {
      await _storage.write(key: 'expense_name', value: _nameController.text);
      await _storage.write(key: 'expense_category', value: _categoryController.text);
      await _storage.write(key: 'expense_amount', value: _amountController.text);
      await _storage.write(key: 'expense_date', value: _dateController.text);
      await _storage.write(key: 'expense_payment', value: _paymentController.text);
    } catch (e) {
      debugPrint('保存当前输入时出错: $e');
    }
  }

  Future<void> _initializeDatabase() async {
    try {
      if (kIsWeb) {
        // 在Web平台上显示警告，提示切换到移动平台测试
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('平台兼容性提示'),
                content: const Text('Floor数据库在Web平台上需要额外配置。\n\n对于学校项目，建议在Android或iOS模拟器上测试以获得完整功能。'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('了解'),
                  )
                ],
              ),
            );
          });
        }
        return;
      }

      // 按照课程要求方式初始化数据库
      database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();

      if (database != null) {
        expenseDao = database!.expenseDao;
        final loadedExpenses = await expenseDao!.findAllExpenses();

        // 更新最大ID值
        for (var expense in loadedExpenses) {
          if (expense.id != null && expense.id! >= ExpenseItem.ID) {
            ExpenseItem.ID = expense.id! + 1;
          }
        }

        if (mounted) {
          setState(() {
            expenses = loadedExpenses;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('初始化数据库时出错: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('初始化数据库失败: $e')),
        );
      }
    }
  }

  void _addExpense() async {
    // 检查数据库是否已初始化
    if (expenseDao == null && !kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('数据库尚未初始化，请稍后再试')),
      );
      return;
    }

    // 验证输入字段
    if (_nameController.text.isNotEmpty &&
        _categoryController.text.isNotEmpty &&
        _amountController.text.isNotEmpty &&
        _dateController.text.isNotEmpty &&
        _paymentController.text.isNotEmpty) {

      try {
        // 创建新费用条目，使用当前ID计数器
        final newExpense = ExpenseItem(
            ExpenseItem.ID++, // 使用静态ID计数器
            _nameController.text,
            _categoryController.text,
            _amountController.text,
            _dateController.text,
            _paymentController.text
        );

        // 在Web平台上模拟添加
        if (kIsWeb) {
          setState(() {
            expenses.add(newExpense);
            _clearInput();
          });
        } else {
          // 使用数据库添加
          await expenseDao!.insertExpense(newExpense);
          final loadedExpenses = await expenseDao!.findAllExpenses();

          setState(() {
            expenses = loadedExpenses;
            _clearInput();
          });
        }

        // 保存当前输入以备后用
        _saveCurrentInput();

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${getText('add')} ${getText('expenseTracker')}')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加费用时出错: $e')),
        );
      }
    } else {
      // 如果有字段为空，提示用户填写完整
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写所有字段')),
      );
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
    if (expenseDao == null && !kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('数据库尚未初始化，请稍后再试')),
      );
      return;
    }

    try {
      if (kIsWeb) {
        // Web平台上模拟删除
        setState(() {
          expenses.removeWhere((e) => e.id == expense.id);
          selectedExpense = null;
        });
      } else {
        // 使用数据库删除
        await expenseDao!.deleteExpense(expense);
        final loadedExpenses = await expenseDao!.findAllExpenses();
        setState(() {
          expenses = loadedExpenses;
          selectedExpense = null;
        });
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(getText('delete'))));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除费用时出错: $e')),
      );
    }
  }

  Widget _responsiveLayout() {
    // 如果还在加载中，显示加载指示器
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: '${getText('enter')} Date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      }
                    },
                  ),
                ),
              ),
              TextField(
                controller: _paymentController,
                decoration: InputDecoration(labelText: '${getText('enter')} Payment Method'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addExpense,
                child: Text(getText('add')),
              ),
            ],
          ),
        ),
        // 费用列表
        Expanded(
          child: expenses.isEmpty
              ? Center(child: Text('暂无费用记录，请添加'))
              : ListView.builder(
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
                      content: Text('确定要删除 "${expense.expenseName}" 吗？'),
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
                  subtitle: Text('${expense.category} - ${expense.amount}'),
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
      return const Center(child: Text('尚未选择费用项'));
    }
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("费用名称: ${selectedExpense!.expenseName}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("类别: ${selectedExpense!.category}"),
          Text("金额: ${selectedExpense!.amount}"),
          Text("日期: ${selectedExpense!.date}"),
          Text("支付方式: ${selectedExpense!.paymentMethod}"),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: Text(getText('delete')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _deleteExpense(selectedExpense!),
          ),
          if (!kIsWeb) Text("ID: ${selectedExpense!.id}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
          if (kIsWeb)
            IconButton(
              icon: const Icon(Icons.warning_amber),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Web平台提示'),
                    content: const Text('Floor数据库在Web平台上需要额外配置。\n\n对于学校项目，建议在Android或iOS模拟器上测试以获得完整功能。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('了解'),
                      )
                    ],
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(getText('instructions')),
                  content: Text('${getText('instructions')}\n• ${getText('expenseTracker')} - 记录您的个人支出\n• 添加名称、类别、金额、日期和支付方式\n• 长按删除费用记录'),
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

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _paymentController.dispose();
    super.dispose();
  }
}
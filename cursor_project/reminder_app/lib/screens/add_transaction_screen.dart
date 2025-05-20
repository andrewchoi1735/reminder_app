import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/ledger_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? existingTransaction;
  const AddTransactionScreen({super.key, this.existingTransaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}



class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  int _amount = 0;
  DateTime _selectedDate = DateTime.now();
  String _type = 'expense';

  bool _isEditMode = false;
  int _id = 0;

  @override
  void initState() {
    super.initState();
    final tx = widget.existingTransaction;
    if (tx != null) {
      _title = tx.title;
      _amount = tx.amount;
      _selectedDate = tx.date;
      _type = tx.type;
      _id = tx.id!;
      _isEditMode = true;
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // ✅ 이 줄 꼭 있어야 TextFormField의 onSaved가 동작함

      if (_isEditMode) {
        final updated = Transaction(
          id: _id,
          title: _title,
          amount: _amount,
          date: _selectedDate,
          type: _type,
        );
        Provider.of<LedgerProvider>(context, listen: false).updateTransaction(updated);
      } else {
        final newTx = Transaction(
          id: DateTime.now().millisecondsSinceEpoch,
          title: _title,
          amount: _amount,
          date: _selectedDate,
          type: _type,
        );
        Provider.of<LedgerProvider>(context, listen: false).addTransaction(newTx);
      }

      Navigator.pop(context); // ✅ 입력 후 화면 닫기
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('항목 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title, // ✅ 초기값 추가
                decoration: const InputDecoration(labelText: '항목명'),
                onSaved: (val) => _title = val!.trim(),
                validator: (val) => val == null || val.isEmpty ? '항목명을 입력하세요' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _amount == 0 ? '' : _amount.toString(), // ✅ 초기값 추가
                decoration: const InputDecoration(labelText: '금액'),
                keyboardType: TextInputType.number,
                onSaved: (val) => _amount = int.tryParse(val ?? '0') ?? 0,
                validator: (val) {
                  final num = int.tryParse(val ?? '');
                  if (num == null || num <= 0) return '올바른 금액을 입력하세요';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('날짜: ${_selectedDate.toString().split(' ').first}'),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('날짜 선택'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('유형: '),
                  DropdownButton<String>(
                    value: _type,
                    items: const [
                      DropdownMenuItem(value: 'income', child: Text('수입')),
                      DropdownMenuItem(value: 'expense', child: Text('지출')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _type = val!;
                      });
                    },
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('등록'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

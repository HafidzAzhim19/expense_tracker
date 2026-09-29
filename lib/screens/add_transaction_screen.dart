import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/dashboard_provider.dart';
import '../repositories/transaction_repository.dart';
import '../utils/app_colors.dart';

class AddTransactionScreen extends StatefulWidget {
  final int userId;
  const AddTransactionScreen({super.key, required this.userId});
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _type = TransactionType.expense;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int? _selectedCategoryId;
  final _txRepo = TransactionRepository();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final categories = dash.categories;
    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tambah Transaksi Baru'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Jenis Transaksi', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: RadioListTile<TransactionType>(contentPadding: EdgeInsets.zero, title: const Text('Pengeluaran', style: TextStyle(color: AppColors.textInk)), value: TransactionType.expense, groupValue: _type, activeColor: AppColors.primary, onChanged: (v) => setState(() => _type = v!))),
                Expanded(child: RadioListTile<TransactionType>(contentPadding: EdgeInsets.zero, title: const Text('Pemasukan', style: TextStyle(color: AppColors.textInk)), value: TransactionType.income, groupValue: _type, activeColor: AppColors.primary, onChanged: (v) => setState(() => _type = v!))),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textInk, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Nominal (Rp)',
                labelStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border, width: 1.4)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Kategori', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, width: 1.4)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedCategoryId,
                        style: const TextStyle(color: AppColors.textInk, fontSize: 15),
                        items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                        onChanged: (v) => setState(() => _selectedCategoryId = v),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _showAddCategoryDialog,
                  child: const Text('+ Kategori'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _noteController,
              style: const TextStyle(color: AppColors.textInk, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Catatan (opsional)',
                labelStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border, width: 1.4)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Simpan Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Kategori'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Nama kategori baru')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              Navigator.pop(ctx);
              if (name.isEmpty) return;
              final result = await context.read<DashboardProvider>().addCategoryAndRefresh(name);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nominal tidak boleh kosong')));
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nominal tidak valid')));
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kategori terlebih dahulu')));
      return;
    }

    setState(() => _saving = true);
    final result = await _txRepo.addTransaction(
      userId: widget.userId,
      categoryId: _selectedCategoryId!,
      amount: amount,
      type: _type,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      date: DateTime.now().millisecondsSinceEpoch,
    );
    setState(() => _saving = false);

    if (!mounted) return;
    if (result.success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? 'Gagal menyimpan')));
    }
  }
}
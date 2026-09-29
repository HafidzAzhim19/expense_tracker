import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/dashboard_provider.dart';
import '../services/session_manager.dart';
import '../utils/app_colors.dart';
import '../utils/format_utils.dart';
import 'add_transaction_screen.dart';
import 'login_screen.dart';
import 'statistics_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;
  final String username;
  const DashboardScreen({super.key, required this.userId, required this.username});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _session = SessionManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().load(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final balance = dash.totalIncome - dash.totalExpense;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selamat Datang,', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textInk)),
                        Text(widget.username, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.pie_chart, color: AppColors.primary),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => StatisticsScreen(userId: widget.userId))),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary, width: 1.4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _logout,
                    child: const Text('Logout'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Saldo', style: TextStyle(color: Colors.white, fontSize: 13)),
                    Text(FormatUtils.formatRupiah(balance), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pemasukan', style: TextStyle(color: Color(0xFFE3FBFC), fontSize: 12)),
                              Text(FormatUtils.formatRupiah(dash.totalIncome), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pengeluaran', style: TextStyle(color: Color(0xFFE3FBFC), fontSize: 12)),
                              Text(FormatUtils.formatRupiah(dash.totalExpense), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                child: Row(
                  children: [
                    Expanded(child: Text(dash.kursInfo, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5))),
                    IconButton(icon: const Icon(Icons.refresh, size: 20, color: AppColors.secondary), onPressed: () => context.read<DashboardProvider>().fetchKurs()),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(child: Text('Riwayat Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textInk))),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddTransactionScreen(userId: widget.userId)));
                      if (!mounted) return;
                      context.read<DashboardProvider>().refreshAfterAdd();
                    },
                    child: const Text('+ Tambah'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip(context, 'Semua', 'ALL', dash.currentFilter),
                    const SizedBox(width: 8),
                    _filterChip(context, 'Pemasukan', 'INCOME', dash.currentFilter),
                    const SizedBox(width: 8),
                    _filterChip(context, 'Pengeluaran', 'EXPENSE', dash.currentFilter),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: dash.transactions.isEmpty
                    ? const Center(child: Text('Belum ada transaksi', style: TextStyle(color: AppColors.textMuted)))
                    : ListView.builder(
                        itemCount: dash.transactions.length,
                        itemBuilder: (context, index) => _transactionCard(context, dash.transactions[index], dash),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, String value, String current) {
    final active = current == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: active ? Colors.white : AppColors.primary, fontWeight: FontWeight.w600)),
      selected: active,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.primary, width: 1.2),
      onSelected: (_) => context.read<DashboardProvider>().setFilter(value),
    );
  }

  Widget _transactionCard(BuildContext context, AppTransaction tx, DashboardProvider dash) {
    final isIncome = tx.type == TransactionType.income;
    return Dismissible(
      key: ValueKey(tx.id),
      background: Container(color: const Color(0xFFE53935), alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20), child: const Icon(Icons.delete, color: Colors.white)),
      secondaryBackground: Container(color: const Color(0xFFE53935), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
      onDismissed: (_) {
        dash.deleteTransaction(tx.id!);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi dihapus')));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((tx.note != null && tx.note!.isNotEmpty) ? tx.note! : 'Transaksi', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textInk)),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFDCF3F5), borderRadius: BorderRadius.circular(20)),
                    child: Text(dash.categoryMap[tx.categoryId] ?? 'Kategori #${tx.categoryId}', style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 5),
                  Text(FormatUtils.formatDate(tx.date), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            Text(FormatUtils.formatRupiah(tx.amount), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isIncome ? AppColors.income : AppColors.expense)),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _session.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }
}
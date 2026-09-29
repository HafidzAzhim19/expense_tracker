import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../providers/statistics_provider.dart';
import '../utils/app_colors.dart';
import '../utils/format_utils.dart';

class StatisticsScreen extends StatefulWidget {
  final int userId;
  const StatisticsScreen({super.key, required this.userId});
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsProvider>().load(widget.userId);
    });
  }

  static const _palette = [
    AppColors.primary,
    AppColors.secondary,
    Color(0xFFE07A5F),
    Color(0xFF3D5A80),
    Color(0xFFF2CC8F),
    Color(0xFF81B29A),
    Color(0xFF9B5DE5),
  ];

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatisticsProvider>();
    final total = stats.categoryTotals.values.fold(0.0, (a, b) => a + b);
    final entries = stats.categoryTotals.entries.where((e) => e.value > 0).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Statistik Kategori'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _typeChip(context, 'Pengeluaran', TransactionType.expense, stats.selectedType)),
                  const SizedBox(width: 8),
                  Expanded(child: _typeChip(context, 'Pemasukan', TransactionType.income, stats.selectedType)),
                ],
              ),
              const SizedBox(height: 20),
              if (stats.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
              else if (entries.isEmpty)
                const Expanded(child: Center(child: Text('Belum ada data untuk ditampilkan', style: TextStyle(color: AppColors.textMuted))))
              else ...[
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 45,
                      sections: List.generate(entries.length, (i) {
                        final entry = entries[i];
                        final percent = total == 0 ? 0.0 : (entry.value / total) * 100;
                        return PieChartSectionData(
                          color: _palette[i % _palette.length],
                          value: entry.value,
                          title: '${percent.toStringAsFixed(0)}%',
                          radius: 60,
                          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, i) {
                      final entry = entries[i];
                      final name = stats.categoryNames[entry.key] ?? 'Kategori #${entry.key}';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                        child: Row(
                          children: [
                            Container(width: 14, height: 14, decoration: BoxDecoration(color: _palette[i % _palette.length], shape: BoxShape.circle)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(name, style: const TextStyle(color: AppColors.textInk, fontWeight: FontWeight.w600))),
                            Text(FormatUtils.formatRupiah(entry.value), style: const TextStyle(color: AppColors.textInk, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(BuildContext context, String label, TransactionType type, TransactionType current) {
    final active = type == current;
    return GestureDetector(
      onTap: () => context.read<StatisticsProvider>().setType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: active ? AppColors.primary : AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary, width: 1.2)),
        child: Text(label, style: TextStyle(color: active ? Colors.white : AppColors.primary, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
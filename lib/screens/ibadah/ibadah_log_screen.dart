import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/ibadah_log.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ibadah_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/ibadah_tile.dart';
import 'add_ibadah_screen.dart';

class IbadahLogScreen extends StatefulWidget {
  final int initialTab;
  const IbadahLogScreen({super.key, this.initialTab = 0});
  @override
  State<IbadahLogScreen> createState() => _IbadahLogScreenState();
}

class _IbadahLogScreenState extends State<IbadahLogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) context.read<IbadahProvider>().loadMonthlyStats(uid);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _openAddSheet([IbadahLog? existing]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddIbadahScreen(existing: existing)),
    ).then((saved) {
      if (saved == true && mounted) {
        final uid = context.read<AuthProvider>().user?.uid;
        if (uid != null) context.read<IbadahProvider>().loadMonthlyStats(uid);
      }
    });
  }

  void _confirmDelete(BuildContext ctx, String uid, String id) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Ibadah?'),
        content: const Text('Catatan ibadah ini akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<IbadahProvider>().deleteIbadah(uid, id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid ?? '';
    final ibadahProvider = context.watch<IbadahProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Ibadah'),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.accent,
          tabs: const [
            Tab(text: 'Catatan'),
            Tab(text: 'Statistik'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Catat Ibadah', style: TextStyle(color: Colors.white)),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // TAB 1 - Log list
          StreamBuilder<List<IbadahLog>>(
            stream: ibadahProvider.watchAllLogs(uid),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final logs = snap.data ?? [];
              if (logs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_outlined, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Belum ada catatan ibadah', style: TextStyle(color: AppTheme.textGrey)),
                      const SizedBox(height: 8),
                      const Text('Tap tombol + untuk mulai mencatat', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                    ],
                  ),
                );
              }

              // Group by date
              final grouped = <String, List<IbadahLog>>{};
              for (final log in logs) {
                final key = DateFormat('dd MMMM yyyy', 'id').format(log.date);
                grouped.putIfAbsent(key, () => []).add(log);
              }

              return ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Container(
                              width: 4, height: 16,
                              decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(2)),
                            ),
                            const SizedBox(width: 8),
                            Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                            const SizedBox(width: 8),
                            Text('(${entry.value.length})', style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                          ],
                        ),
                      ),
                      ...entry.value.map((log) => IbadahTile(
                            log: log,
                            onDelete: () => _confirmDelete(ctx, uid, log.id!),
                            onEdit: () => _openAddSheet(log),
                          )),
                    ],
                  );
                }).toList(),
              );
            },
          ),

          // TAB 2 - Statistics
          _StatsTab(stats: ibadahProvider.monthlyStats),
        ],
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  final Map<String, int> stats;
  const _StatsTab({required this.stats});

  static const _colors = [
    Color(0xFF1B5E20), Color(0xFF1565C0), Color(0xFF6A1B9A),
    Color(0xFFE65100), Color(0xFF00695C), Color(0xFFB71C1C), Color(0xFF37474F),
  ];

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Belum ada data bulan ini', style: TextStyle(color: AppTheme.textGrey)),
          ],
        ),
      );
    }

    final total = stats.values.fold(0, (a, b) => a + b);
    final entries = stats.entries.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bulan ${DateFormat('MMMM yyyy', 'id').format(DateTime.now())}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          Text('Total: $total ibadah tercatat', style: const TextStyle(color: AppTheme.textGrey)),
          const SizedBox(height: 24),

          // Pie chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Distribusi Ibadah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections: entries.asMap().entries.map((e) {
                          final idx = e.key;
                          final entry = e.value;
                          final pct = (entry.value / total * 100);
                          return PieChartSectionData(
                            value: entry.value.toDouble(),
                            color: _colors[idx % _colors.length],
                            title: '${pct.toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            radius: 70,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Legend
                  ...entries.asMap().entries.map((e) {
                    final idx = e.key;
                    final entry = e.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 14, height: 14,
                            decoration: BoxDecoration(
                              color: _colors[idx % _colors.length],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(entry.key, style: const TextStyle(fontSize: 13))),
                          Text('${entry.value}x', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Bar chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Frekuensi per Ibadah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (entries.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                        barGroups: entries.asMap().entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.value.toDouble(),
                                color: _colors[e.key % _colors.length],
                                width: 18,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, _) {
                                final idx = val.toInt();
                                if (idx >= entries.length) return const SizedBox.shrink();
                                final type = entries[idx].key;
                                final short = type.replaceAll('Shalat ', '').replaceAll(' ', '\n');
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(short, style: const TextStyle(fontSize: 9, color: AppTheme.textGrey), textAlign: TextAlign.center),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

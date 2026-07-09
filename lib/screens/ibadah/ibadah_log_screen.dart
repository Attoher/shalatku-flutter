import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/ibadah_log.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ibadah_provider.dart';
import '../../widgets/ibadah_tile.dart';
import 'add_ibadah_screen.dart';

class IbadahLogScreen extends StatefulWidget {
  final int initialTab;
  final bool hideAppBar;
  const IbadahLogScreen({super.key, this.initialTab = 0, this.hideAppBar = false});
  @override
  State<IbadahLogScreen> createState() => _IbadahLogScreenState();
}

class _IbadahLogScreenState extends State<IbadahLogScreen> with SingleTickerProviderStateMixin {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: Theme.of(context).primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Log Ibadah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.primaryContainer],
                          ),
                        ),
                      ),
                      Positioned(
                        right: -10,
                        top: -10,
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 140,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: TabBar(
                      controller: _tabCtrl,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Catatan'),
                        Tab(text: 'Statistik'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabCtrl,
              children: [
                // TAB 1 - Log list
                Scrollbar(
                  child: StreamBuilder<List<IbadahLog>>(
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
                              Icon(Icons.history_edu, size: 80, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('Belum ada catatan', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                              Text('Mulai catat ibadah harianmu', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                            ],
                          ),
                        );
                      }

                      final grouped = <String, List<IbadahLog>>{};
                      for (final log in logs) {
                        final key = DateFormat('EEEE, dd MMMM yyyy', 'id').format(log.date);
                        grouped.putIfAbsent(key, () => []).add(log);
                      }

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        children: grouped.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 14, color: Theme.of(context).primaryColor),
                                    const SizedBox(width: 8),
                                    Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 13)),
                                    const Spacer(),
                                    Text('${entry.value.length} Ibadah', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                                  ],
                                ),
                              ),
                              ...entry.value.map((log) => IbadahTile(
                                    log: log,
                                    onDelete: () => _confirmDelete(ctx, uid, log.id!),
                                    onEdit: () => _openAddSheet(log),
                                  )),
                              const SizedBox(height: 8),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),

                // TAB 2 - Statistics
                Scrollbar(
                  child: _StatsTab(stats: ibadahProvider.monthlyStats),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton.extended(
              onPressed: () => _openAddSheet(),
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 4,
              icon: const Icon(Icons.add_task, color: Colors.white),
              label: const Text('Catat Ibadah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  final Map<String, int> stats;
  const _StatsTab({required this.stats});


  @override
  Widget build(BuildContext context) {
    Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text('Belum ada catatan ibadah', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
    if (stats.isEmpty) {
      return buildEmptyState();
    }

    final Map<String, int> groupedStats = {};
    stats.forEach((key, value) {
      String mainType = key;
      if (key.startsWith('Shalat Fardhu')) {
        mainType = 'Shalat Fardhu';
      }
      groupedStats[mainType] = (groupedStats[mainType] ?? 0) + value;
    });

    final total = groupedStats.values.fold(0, (a, b) => a + b);
    final entries = groupedStats.entries.toList();

    final colorScheme = Theme.of(context).colorScheme;
    final List<Color> themeColors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
      colorScheme.outline,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM yyyy', 'id').format(DateTime.now()),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  Text(
                    'Total $total ibadah tercatat',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.analytics, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pie chart card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Distribusi Ibadah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 32),
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 60,
                      sections: entries.asMap().entries.map((e) {
                        final idx = e.key;
                        final entry = e.value;
                        final pct = (entry.value / total * 100);
                        return PieChartSectionData(
                          value: entry.value.toDouble(),
                          color: themeColors[idx % themeColors.length],
                          title: '${pct.toStringAsFixed(0)}%',
                          titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          radius: 80,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: entries.asMap().entries.map((e) {
                    final idx = e.key;
                    final entry = e.value;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: themeColors[idx % themeColors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.key,
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.value}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bar chart card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Frekuensi Mingguan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 32),
                SizedBox(
                  height: 200,
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
                              color: themeColors[e.key % themeColors.length],
                              width: 20,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
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
                              final short = type.split(' ').last;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(short, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
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
        ],
      ),
    );
  }
}

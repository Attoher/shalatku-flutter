import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/prayer_card.dart';
import '../ibadah/ibadah_log_screen.dart';
import '../prayer_times/prayer_times_screen.dart';
import '../qibla/qibla_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/notification_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = const [
    _HomePage(),
    PrayerTimesScreen(),
    QiblaScreen(),
    IbadahLogScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.schedule_outlined), selectedIcon: Icon(Icons.schedule), label: 'Jadwal'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Kiblat'),
          NavigationDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: 'Ibadah'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();
  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> with WidgetsBindingObserver {
  late DateTime _lastLoadDate;
  late Timer _timeUpdateTimer;
  late Timer _prayerCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastLoadDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerProvider>().loadData();
    });
    _startDayChangeListener();
    
    // Update UI setiap detik untuk sinkronisasi jam dan refresh status
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        // Refresh prayer status to update isPassed and isNext
        context.read<PrayerProvider>().refreshPrayerStatus();
        setState(() {});
      }
    });

    // Check prayer notifications setiap menit
    _prayerCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        final prayer = context.read<PrayerProvider>();
        if (prayer.prayerTimes.isNotEmpty) {
          print('Checking prayer notifications...');
          NotificationService.checkAndShowPrayerNotifications(prayer.prayerTimes);
        }
      }
    });
  }

  @override
  void dispose() {
    _timeUpdateTimer.cancel();
    _prayerCheckTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App resumed - check prayer notifications');
      final prayer = context.read<PrayerProvider>();
      if (prayer.prayerTimes.isNotEmpty) {
        NotificationService.checkAndShowPrayerNotifications(prayer.prayerTimes);
      }
    } else if (state == AppLifecycleState.paused) {
      print('App paused/moved to background');
    }
  }

  void _startDayChangeListener() {
    Future.doWhile(() async {
      if (!mounted) return false;
      await Future.delayed(const Duration(minutes: 1));
      final now = DateTime.now();
      if (mounted && now.day != _lastLoadDate.day) {
        _lastLoadDate = now;
        if (mounted) {
          context.read<PrayerProvider>().loadData();
        }
      }
      return mounted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prayer = context.watch<PrayerProvider>();
    final name = auth.user?.displayName ?? 'Sahabat';
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Selamat Pagi' : now.hour < 15 ? 'Selamat Siang' : now.hour < 18 ? 'Selamat Sore' : 'Selamat Malam';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, Color(0xFF2E7D32)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 75, 20, 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$greeting,', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              DateFormat('EEEE, dd MMMM yyyy', 'id').format(now),
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('HH:mm', 'id').format(now),
                              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.white70, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Jangan lupa dzikir setiap hari',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Next prayer countdown
                if (prayer.nextPrayer != null) ...[
                  Card(
                    color: AppTheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.white, size: 40),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shalat ${prayer.nextPrayer!.name}',
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                _CountdownTimer(provider: prayer),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                DateFormat('HH:mm').format(prayer.nextPrayer!.time),
                                style: const TextStyle(color: AppTheme.accent, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Prayer times row
                const Text('Jadwal Shalat Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 12),
                if (prayer.loading)
                  const Center(child: CircularProgressIndicator())
                else if (prayer.error != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.location_off, color: AppTheme.textGrey, size: 40),
                          const SizedBox(height: 8),
                          Text(prayer.error!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textGrey)),
                          TextButton(
                            onPressed: () => context.read<PrayerProvider>().loadData(),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: SizedBox(
                          height: 110,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: prayer.prayerTimes.length,
                            itemBuilder: (_, i) => PrayerCard(prayer: prayer.prayerTimes[i]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 6),
                          Text('Geser untuk melihat jadwal lengkap', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 24),

                // Quick actions
                const Text('Aksi Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                  _QuickAction(
                    icon: Icons.explore,
                    label: 'Arah Kiblat',
                    color: AppTheme.primary,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QiblaScreen())),
                  ),
                  _QuickAction(
                    icon: Icons.book,
                    label: 'Log Ibadah',
                    color: const Color(0xFF1565C0),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const IbadahLogScreen())),
                  ),
                  _QuickAction(
                    icon: Icons.bar_chart,
                    label: 'Statistik',
                    color: const Color(0xFF6A1B9A),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const IbadahLogScreen(initialTab: 1))),
                  ),
                  _QuickAction(
                    icon: Icons.notifications_active,
                    label: 'Notifikasi',
                    color: const Color(0xFFE65100),
                    onTap: () {
                      // Navigate to profile tab and show notification settings
                      final parent = context.findAncestorStateOfType<_HomeScreenState>();
                      if (parent != null) {
                        parent.setState(() => parent._currentIndex = 4); // Profile tab index
                      }
                    },
                  ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownTimer extends StatefulWidget {
  final PrayerProvider provider;
  const _CountdownTimer({required this.provider});
  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
  }

  void _updateRemaining() {
    setState(() => _remaining = widget.provider.timeUntilNext);
  }

  @override
  void didUpdateWidget(covariant _CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateRemaining();
  }

  @override
  Widget build(BuildContext context) {
    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Text(
      h > 0 ? '$h jam $m menit' : '$m:$s',
      style: const TextStyle(color: Colors.white70, fontSize: 13),
    );
  }
}

class _QuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: _isPressed ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.color.withValues(alpha: _isPressed ? 0.4 : 0.2),
            width: _isPressed ? 2 : 1,
          ),
          boxShadow: _isPressed
              ? [BoxShadow(color: widget.color.withValues(alpha: 0.25), blurRadius: 12)]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: widget.color, size: 36),
            const SizedBox(height: 12),
            Text(
              widget.label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

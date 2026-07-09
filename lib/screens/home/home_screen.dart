import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/auth_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../widgets/prayer_card.dart';
import '../ibadah/ibadah_log_screen.dart';
import '../prayer_times/prayer_times_screen.dart';
import '../qibla/qibla_screen.dart';
import '../profile/profile_screen.dart';
import '../quran/quran_search_screen.dart';
import '../quran/quran_list_screen.dart';
import 'worship_center_screen.dart';
import 'quran_center_screen.dart';
import '../../services/notification_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<Widget> get _pages => const [
        _HomePage(),
        WorshipCenterScreen(),
        QuranCenterScreen(),
        ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.mosque_outlined), selectedIcon: Icon(Icons.mosque), label: 'Ibadah'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Quran AI'),
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
  final ScrollController _prayerScroll = ScrollController();
  final ScrollController _quickScroll = ScrollController();
  late DateTime _lastLoadDate;
  late Timer _timeUpdateTimer;
  late Timer _prayerCheckTimer;
  bool _isRequestingPermission = false;

  final List<Map<String, String>> _ayats = [
    {
      'text': '"Wahai orang-orang yang beriman! Mohonlah pertolongan (kepada Allah) dengan sabar dan shalat. Sungguh, Allah beserta orang-orang yang sabar."',
      'ref': '(QS. Al-Baqarah: 153)' // Senin
    },
    {
      'text': '"Karena sesungguhnya sesudah kesulitan itu ada kemudahan."',
      'ref': '(QS. Ash-Sharh: 6)' // Selasa
    },
    {
      'text': '"Dan bertawakallah kepada Allah. Dan cukuplah Allah sebagai penjaga."',
      'ref': '(QS. Al-Ahzab: 3)' // Rabu
    },
    {
      'text': '"Maka nikmat Tuhanmu yang manakah yang kamu dustakan?"',
      'ref': '(QS. Ar-Rahman: 13)' // Kamis
    },
    {
      'text': '"Ya Tuhan kami. Berikanlah rahmat kepada kami dari sisi-Mu dan sempurnakanlah petunjuk yang lurus bagi kami dalam urusan kami."',
      'ref': '(QS. Al-Kahfi: 10)' // Jumat
    },
    {
      'text': '"Dan Dia memberinya rezeki dari arah yang tidak disangka-sangkanya. Dan barangsiapa bertawakal kepada Allah, niscaya Allah akan mencukupkan (keperluan)nya."',
      'ref': '(QS. At-Talaq: 3)' // Sabtu
    },
    {
      'text': '"Dan janganlah kamu (merasa) lemah, dan janganlah (pula) kamu bersedih hati, sebab kamu paling tinggi (derajatnya), jika kamu orang beriman."',
      'ref': '(QS. Ali-Imran: 139)' // Minggu
    },
  ];

  final List<Map<String, dynamic>> _tips = [
    {
      'title': 'Semangat Senin',
      'desc': 'Awali minggu dengan doa dan Dzikir Pagi agar urusan dilancarkan.',
      'icon': Icons.wb_sunny_outlined,
      'color': Colors.amber
    },
    {
      'title': 'Kekhusyuan Shalat',
      'desc': 'Fokuslah pada bacaan shalat untuk mencapai ketenangan batin yang maksimal.',
      'icon': Icons.self_improvement,
      'color': Colors.orange
    },
    {
      'title': 'Sedekah Mingguan',
      'desc': 'Sisihkan sebagian rezeki di pertengahan minggu untuk membantu sesama.',
      'icon': Icons.volunteer_activism,
      'color': Colors.pink
    },
    {
      'title': 'Persiapan Jumat',
      'desc': 'Perbanyak shalawat di hari Kamis sore untuk menyambut keberkahan hari Jumat.',
      'icon': Icons.auto_awesome,
      'color': Colors.purple
    },
    {
      'title': 'Sunnah Hari Jumat',
      'desc': 'Baca Surah Al-Kahfi dan perbanyak doa di waktu Ashar hingga Maghrib.',
      'icon': Icons.menu_book_rounded,
      'color': Colors.teal
    },
    {
      'title': 'Silaturahmi',
      'desc': 'Manfaatkan waktu luang di hari Sabtu untuk menjalin hubungan baik dengan keluarga.',
      'icon': Icons.people_outline,
      'color': Colors.blue
    },
    {
      'title': 'Muhasabah Diri',
      'desc': 'Evaluasi ibadah satu minggu ini dan tutup dengan wudhu sebelum tidur.',
      'icon': Icons.bedtime_outlined,
      'color': Colors.indigo
    }
  ];

  Map<String, String> get _currentAyat {
    final weekday = DateTime.now().weekday; // 1 (Senin) - 7 (Minggu)
    return _ayats[(weekday - 1) % _ayats.length];
  }

  List<Map<String, dynamic>> get _currentTips {
    final weekday = DateTime.now().weekday;
    // Tampilkan tip utama hari ini dan satu tip random lainnya
    return [
      _tips[(weekday - 1) % _tips.length],
      _tips[weekday % _tips.length],
    ];
  }

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
          NotificationService.checkAndShowPrayerNotifications(prayer.prayerTimes);
        }
      }
    });
  }

  @override
  void dispose() {
    _prayerScroll.dispose();
    _quickScroll.dispose();
    _timeUpdateTimer.cancel();
    _prayerCheckTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final prayer = context.read<PrayerProvider>();
      if (prayer.prayerTimes.isNotEmpty) {
        NotificationService.checkAndShowPrayerNotifications(prayer.prayerTimes);
      }
      setState(() {});
    }
  }

  void _showSettingsDialog(BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Izin $permissionName Ditolak'),
        content: Text('Anda telah menolak izin $permissionName secara permanen. Silakan aktifkan secara manual di Pengaturan Aplikasi agar fitur ini dapat digunakan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
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
      body: Scrollbar(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.primaryContainer],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
                child: Stack(
                  children: [
                    // Decorative Background Icon
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Icon(
                        Icons.mosque_rounded,
                        size: 140,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.wb_sunny_outlined, color: Theme.of(context).colorScheme.secondary, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        greeting.toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Logo Placeholder
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                              ),
                              child: const Center(
                                child: Icon(Icons.mosque, color: Colors.white, size: 26),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.secondary, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Jangan lupa beribadah kepada allah setiap hari',
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                    color: Theme.of(context).primaryColor,
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
                                style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 24, fontWeight: FontWeight.bold),
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
                Text('Jadwal Shalat Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 12),
                if (prayer.loading)
                  const Center(child: CircularProgressIndicator())
                else if (prayer.error != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.location_off, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 40),
                          const SizedBox(height: 8),
                          Text(prayer.error!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          TextButton(
                            onPressed: () async {
                              if (_isRequestingPermission) return;
                              setState(() => _isRequestingPermission = true);
                              try {
                                debugPrint('Home: Requesting location...');
                                final status = await Permission.locationWhenInUse.request();
                                if (status.isPermanentlyDenied) {
                                  if (context.mounted) {
                                    _showSettingsDialog(context, 'Lokasi');
                                  }
                                } else if (status.isGranted) {
                                  if (context.mounted) {
                                    context.read<PrayerProvider>().loadData();
                                  }
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isRequestingPermission = false);
                                }
                              }
                            },
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
                        child: Scrollbar(
                          controller: _prayerScroll,
                          thumbVisibility: true,
                          radius: const Radius.circular(8),
                          child: SizedBox(
                            height: 125,
                            child: ListView.builder(
                              controller: _prayerScroll,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(bottom: 12),
                              itemCount: prayer.prayerTimes.length,
                              itemBuilder: (_, i) => PrayerCard(prayer: prayer.prayerTimes[i]),
                            ),
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
                Text('Aksi Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 12),
                Scrollbar(
                  controller: _quickScroll,
                  thumbVisibility: true,
                  radius: const Radius.circular(8),
                  child: SizedBox(
                    height: 110,
                    child: ListView(
                      controller: _quickScroll,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 16),
                      children: [
                        _QuickAction(
                          icon: Icons.access_time,
                          label: 'Jadwal',
                          color: const Color(0xFF2E7D32),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrayerTimesScreen())),
                        ),
                        const SizedBox(width: 8),
                        _QuickAction(
                          icon: Icons.explore,
                          label: 'Arah Kiblat',
                          color: Theme.of(context).primaryColor,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QiblaScreen())),
                        ),
                        const SizedBox(width: 8),
                        _QuickAction(
                          icon: Icons.book,
                          label: 'Log Ibadah',
                          color: const Color(0xFF1565C0),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const IbadahLogScreen())),
                        ),
                        const SizedBox(width: 8),
                        _QuickAction(
                          icon: Icons.bar_chart,
                          label: 'Statistik',
                          color: const Color(0xFF6A1B9A),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const IbadahLogScreen(initialTab: 1))),
                        ),
                        const SizedBox(width: 8),
                        _QuickAction(
                          icon: Icons.auto_awesome,
                          label: 'Pencarian AI',
                          color: Colors.teal,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuranSearchScreen())),
                        ),
                        const SizedBox(width: 8),
                        _QuickAction(
                          icon: Icons.menu_book,
                          label: 'Al-Quran',
                          color: Colors.brown,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuranListScreen())),
                        ),
                        const SizedBox(width: 8),
                        _QuickAction(
                          icon: Icons.notifications_active,
                          label: 'Notifikasi',
                          color: const Color(0xFFE65100),
                          onTap: () {
                            final parent = context.findAncestorStateOfType<_HomeScreenState>();
                            if (parent != null) {
                              parent.setState(() => parent._currentIndex = 3);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400),
                    Text('Geser untuk menu lainnya', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 32),

                // Daily Inspiration Section
                Text('Ayat Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.format_quote, color: Theme.of(context).primaryColor.withValues(alpha: 0.3), size: 40),
                      Text(
                        _currentAyat['text']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _currentAyat['ref']!,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('Tips Ibadah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 12),
                ..._currentTips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TipCard(
                    title: tip['title'],
                    desc: tip['desc'] ?? tip['ref'],
                    icon: tip['icon'],
                    color: tip['color'],
                  ),
                )),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    ),
  );
  }
}

class _TipCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  const _TipCard({required this.title, required this.desc, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, height: 1.4)),
              ],
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
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: _isPressed ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isPressed
                  ? [BoxShadow(color: widget.color.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: 1)]
                  : [],
            ),
            child: Icon(widget.icon, color: widget.color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            widget.label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
}

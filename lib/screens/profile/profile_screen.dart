import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ibadah_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme.dart';
import '../auth/login_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<IbadahProvider>().loadMonthlyStats(auth.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncPerms();
      setState(() {});
    }
  }

  Future<void> _syncPerms() async {
    final status = await Permission.notification.status;
    if (mounted) {
      context.read<AuthProvider>().syncNotificationsPermission(status.isGranted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final ibadah = context.watch<IbadahProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Scrollbar(
        child: CustomScrollView(
          slivers: [
          // Premium Header
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            stretch: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.primaryContainer],
                      ),
                    ),
                  ),
                  // Abstract decorative shapes
                  Positioned(
                    top: -50,
                    right: -50,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  // Profile Info
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Hero(
                        tag: 'profile_avatar',
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            child: Text(
                              (user?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          user?.displayName ?? 'Hamba Allah',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Interactive Stats Cards
                  const Text(
                    'Jejak Kebaikan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.auto_awesome,
                          label: 'Total',
                          value: ibadah.monthlyStats.values.fold(0, (a, b) => a + b).toString(),
                          color: const Color(0xFFE8F5E9),
                          iconColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.mosque,
                          label: 'Fardhu',
                          value: ibadah.monthlyStats.entries
                              .where((e) => e.key.startsWith('Shalat Fardhu'))
                              .fold(0, (a, b) => a + b.value)
                              .toString(),
                          color: const Color(0xFFE3F2FD),
                          iconColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Settings Group
                  const Text(
                    'Pengaturan & Akun',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        _InteractiveListTile(
                          icon: Icons.palette_outlined,
                          title: 'Tema Aplikasi',
                          trailing: Consumer<ThemeProvider>(
                            builder: (context, themeProvider, _) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ThemeDot(color: AppTheme.greenPrimary, isSelected: themeProvider.themeMode == AppThemeMode.green, onTap: () => themeProvider.setTheme(AppThemeMode.green)),
                                const SizedBox(width: 8),
                                _ThemeDot(color: AppTheme.bluePrimary, isSelected: themeProvider.themeMode == AppThemeMode.blue, onTap: () => themeProvider.setTheme(AppThemeMode.blue)),
                                const SizedBox(width: 8),
                                _ThemeDot(color: AppTheme.pinkPrimary, isSelected: themeProvider.themeMode == AppThemeMode.pink, onTap: () => themeProvider.setTheme(AppThemeMode.pink)),
                              ],
                            ),
                          ),
                          onTap: () {},
                        ),
                        const Divider(height: 1, indent: 60),
                        _InteractiveListTile(
                          icon: Icons.notifications_active_outlined,
                          title: 'Notifikasi Shalat',
                          trailing: Switch(
                            value: auth.notificationsEnabled,
                            onChanged: (val) async {
                              if (val) {
                                final status = await Permission.notification.status;
                                if (!status.isGranted) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Harap berikan izin notifikasi di menu Izin Aplikasi terlebih dahulu'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                  return;
                                }
                              }
                              if (context.mounted) {
                                context.read<AuthProvider>().toggleNotifications();
                              }
                            },
                            activeThumbColor: Theme.of(context).primaryColor,
                          ),
                          onTap: () {},
                        ),
                        const Divider(height: 1, indent: 60),
                        _InteractiveListTile(
                          icon: Icons.info_outline,
                          title: 'Tentang ShalatKu',
                          onTap: () => _showAboutApp(context),
                        ),
                        const Divider(height: 1, indent: 60),
                        _InteractiveListTile(
                          icon: Icons.help_outline,
                          title: 'Bantuan & Panduan',
                          onTap: () => _showHelpGuide(context),
                        ),
                        const Divider(height: 1, indent: 60),
                        _InteractiveListTile(
                          icon: Icons.security_outlined,
                          title: 'Izin Aplikasi',
                          onTap: () => _showPermissions(context),
                        ),
                        const Divider(height: 1, indent: 60),
                        _InteractiveListTile(
                          icon: Icons.logout,
                          title: 'Keluar Akun',
                          titleColor: Colors.redAccent,
                          iconColor: Colors.redAccent,
                          onTap: () => _confirmLogout(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.mosque, color: Colors.black12, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      'ShalatKu v1.0.0',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Developed by:', style: TextStyle(color: Colors.grey.shade400, fontSize: 9)),
                    const Text('Ath thahir Muhammad Isa Rahmatullah', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                    Text('NRP: 5025231181', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                    Text('Mahasiswa Institut Teknologi Sepuluh Nopember', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                    const SizedBox(height: 12),
                    Text('API Source: equran.id', style: TextStyle(color: Colors.grey.shade300, fontSize: 9)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  void _showAboutApp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Icon(Icons.mosque, size: 64, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text('ShalatKu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            Text('Teman Ibadah Digital Anda', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'ShalatKu adalah aplikasi yang dirancang untuk membantu umat Muslim dalam menjaga konsistensi ibadah harian. Dengan fitur jadwal shalat akurat, pencarian makna Al-Quran berbasis AI, dan pelacak ibadah.',
                    textAlign: TextAlign.center,
                    style: TextStyle(height: 1.5, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  SizedBox(height: 24),
                  Center(child: Text('Technical Features', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                  SizedBox(height: 12),
                  _TechTag(label: 'Prayer Times: Adhan Engine v1.0'),
                  _TechTag(label: 'AI Quran: Semantic Vector Search'),
                  _TechTag(label: 'Cloud: Firebase Realtime Sync'),
                  _TechTag(label: 'Security: SSL Encryption'),
                  SizedBox(height: 24),
                  Center(child: Text('Data & API Credits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                  SizedBox(height: 12),
                  _TechTag(label: 'Al-Quran API v2.0 - Struktur data & audio (equran.id)'),
                  _TechTag(label: 'Vector Search API - Semantic AI Search (equran.id)'),
                  _TechTag(label: 'Jadwal Shalat API - Data 517 Kab/Kota (equran.id)'),
                  const SizedBox(height: 12),
                  const Text(
                    'Seluruh layanan data disediakan oleh equran.id/apidev',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar Akun?'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showHelpGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Panduan Penggunaan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildHelpItem(
                    'Jadwal Shalat',
                    'Aplikasi menggunakan GPS untuk menentukan lokasi Anda dan menghitung jadwal shalat yang akurat sesuai Kemenag RI.',
                    Icons.access_time_filled,
                  ),
                  _buildHelpItem(
                    'Pencarian Al-Quran AI',
                    'Anda bisa mencari ayat berdasarkan makna. Contoh: "Sabar dalam cobaan" atau "Tujuan hidup".',
                    Icons.auto_awesome,
                  ),
                  _buildHelpItem(
                    'Arah Kiblat',
                    'Gunakan sensor kompas pada HP Anda. Pastikan HP berada di posisi datar dan jauh dari benda logam/magnet.',
                    Icons.explore,
                  ),
                  _buildHelpItem(
                    'Log Ibadah',
                    'Catat progres ibadah harianmu di menu "Ibadah". Lihat grafik performamu di tab "Statistik".',
                    Icons.edit_note,
                  ),
                  _buildHelpItem(
                    'Notifikasi Adzan',
                    'Aktifkan notifikasi untuk pengingat waktu shalat. Anda bisa menambahkan suara adzan sendiri di folder sistem aplikasi.',
                    Icons.notifications_active,
                  ),
                  _buildHelpItem(
                    'Akun & Sinkronisasi',
                    'Data ibadah Anda tersimpan aman di Cloud. Anda tidak akan kehilangan data meskipun berganti perangkat.',
                    Icons.cloud_sync,
                  ),
                  _buildHelpItem(
                    'Keamanan & Privasi',
                    'Lokasi Anda hanya digunakan untuk perhitungan jadwal shalat secara lokal dan tidak disalahgunakan.',
                    Icons.verified_user,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _PermissionsModal(),
    );
  }

  Widget _buildHelpItem(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionsModal extends StatefulWidget {
  const _PermissionsModal();

  @override
  State<_PermissionsModal> createState() => _PermissionsModalState();
}

class _PermissionsModalState extends State<_PermissionsModal> with WidgetsBindingObserver {
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        Permission.location.status,
        Permission.notification.status,
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snap) {
        final locStatus = snap.data?[0];
        final notifStatus = snap.data?[1];

        final isLocGranted = locStatus == PermissionStatus.granted;
        final isNotifGranted = notifStatus == PermissionStatus.granted;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Izin Aplikasi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                const SizedBox(height: 8),
                Text('Berikut adalah izin yang diperlukan ShalatKu agar berfungsi maksimal:', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 24),
                _buildPermissionItem(
                  'Lokasi (GPS)',
                  'Diperlukan untuk menghitung jadwal shalat dan arah kiblat sesuai posisi Anda.',
                  Icons.location_on_outlined,
                  isLocGranted,
                  () async {
                    if (_isRequesting) return;
                    setState(() => _isRequesting = true);
                    try {
                      debugPrint('Requesting location permission...');
                      final status = await Permission.locationWhenInUse.request();
                      debugPrint('Location permission result: $status');
                      
                      if (status.isPermanentlyDenied) {
                        if (context.mounted) {
                          _showSettingsDialog(context, 'Lokasi');
                        }
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isRequesting = false);
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildPermissionItem(
                  'Notifikasi',
                  'Diperlukan untuk pengingat adzan dan waktu ibadah lainnya.',
                  Icons.notifications_active_outlined,
                  isNotifGranted,
                  () async {
                    if (_isRequesting) return;
                    setState(() => _isRequesting = true);
                    try {
                      debugPrint('Requesting notification permission...');
                      final status = await Permission.notification.request();
                      debugPrint('Notification permission result: $status');
                      
                      if (status.isPermanentlyDenied) {
                        if (context.mounted) {
                          _showSettingsDialog(context, 'Notifikasi');
                        }
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isRequesting = false);
                      }
                    }
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
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

  Widget _buildPermissionItem(String title, String desc, IconData icon, bool granted, VoidCallback onRequest) {
    return InkWell(
      onTap: granted ? null : onRequest,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(desc, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (granted)
              const Icon(Icons.check_circle, color: Colors.green, size: 24)
            else
              TextButton(
                onPressed: onRequest,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text('Izinkan'),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color iconColor;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: iconColor.withValues(alpha: 0.8)),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: iconColor.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _InteractiveListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;

  const _InteractiveListTile({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Theme.of(context).primaryColor).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor ?? const Color(0xFF1A1A1A),
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
    );
  }
}

class _TechTag extends StatelessWidget {
  final String label;
  const _TechTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _ThemeDot extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeDot({required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 14)
            : null,
      ),
    );
  }
}

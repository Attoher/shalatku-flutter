import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ibadah_provider.dart';
import '../../utils/theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final ibadah = context.watch<IbadahProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar & name
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        (user?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.displayName ?? 'Pengguna',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    Text(user?.email ?? '', style: const TextStyle(color: AppTheme.textGrey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Monthly stats summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Statistik Bulan Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          value: ibadah.monthlyStats.values.fold(0, (a, b) => a + b).toString(),
                          label: 'Total Ibadah',
                          icon: Icons.star,
                        ),
                        _StatItem(
                          value: ibadah.monthlyStats.length.toString(),
                          label: 'Jenis Ibadah',
                          icon: Icons.category,
                        ),
                        _StatItem(
                          value: (ibadah.monthlyStats['Shalat Fardhu'] ?? 0).toString(),
                          label: 'Shalat Fardhu',
                          icon: Icons.mosque,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Settings / actions
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.notifications_outlined,
                      color: auth.notificationsEnabled ? AppTheme.primary : Colors.grey,
                    ),
                    title: const Text('Notifikasi'),
                    subtitle: auth.notificationsEnabled ? const Text('Aktif') : const Text('Nonaktif'),
                    trailing: Switch(
                      value: auth.notificationsEnabled,
                      onChanged: (_) => context.read<AuthProvider>().toggleNotifications(),
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'Tentang ShalatKu',
                    subtitle: 'Versi 1.0.0',
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'ShalatKu',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2025 Ath Thahir Muhammad Isa Rahmatullah',
                      children: [
                        const SizedBox(height: 16),
                        const Text('Aplikasi jadwal shalat, arah kiblat, dan tracker ibadah harian.'),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.logout,
                    title: 'Keluar',
                    subtitle: 'Logout dari akun',
                    color: Colors.red,
                    onTap: () => _confirmLogout(context),
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
        title: const Text('Keluar?'),
        content: const Text('Yakin ingin keluar dari ShalatKu?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
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
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey), textAlign: TextAlign.center),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.title, required this.subtitle, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textDark;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(title, style: TextStyle(color: c, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
      onTap: onTap,
    );
  }
}

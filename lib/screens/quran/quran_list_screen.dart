import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quran_provider.dart';
import 'surah_detail_screen.dart';

class QuranListScreen extends StatefulWidget {
  final bool hideAppBar;
  const QuranListScreen({super.key, this.hideAppBar = false});

  @override
  State<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends State<QuranListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().fetchSurahs();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Scrollbar(
        child: CustomScrollView(
          slivers: [
          if (!widget.hideAppBar)
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Al-Quran Kareem', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                      bottom: -10,
                      child: Icon(
                        Icons.book_online,
                        size: 140,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Search Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari nama surat...',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  onChanged: (val) => setState(() => _query = val),
                ),
              ),
            ),
          ),

          // Content Section
          if (provider.isLoading && provider.surahs.isEmpty)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (provider.error != null && provider.surahs.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${provider.error}', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchSurahs(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (provider.searchSurah(_query).isEmpty)
              const SliverFillRemaining(child: Center(child: Text('Surat tidak ditemukan')))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final filtered = provider.searchSurah(_query);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SurahCard(surah: filtered[index]),
                      );
                    },
                    childCount: provider.searchSurah(_query).length,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SurahCard extends StatelessWidget {
  final dynamic surah;
  const _SurahCard({required this.surah});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.star_rounded, color: Theme.of(context).primaryColor.withValues(alpha: 0.15), size: 48),
            Text(
              '${surah.nomor}',
              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        title: Text(
          surah.namaLatin,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
        ),
        subtitle: Row(
          children: [
            Text(
              surah.tempatTurun.toUpperCase(),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
            Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey)),
            const SizedBox(width: 8),
            Text(
              '${surah.jumlahAyat} AYAT',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        trailing: Text(
          surah.nama,
          style: TextStyle(fontSize: 24, fontFamily: 'Amiri', color: Theme.of(context).primaryColor),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurahDetailScreen(nomor: surah.nomor),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shalatku/providers/quran_provider.dart';
import 'package:shalatku/models/quran_model.dart';

class SurahDetailScreen extends StatefulWidget {
  final int nomor;

  const SurahDetailScreen({super.key, required this.nomor});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().fetchSurahDetail(widget.nomor);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranProvider>();
    final surah = provider.currentSurah;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Scrollbar(
        child: CustomScrollView(
          slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            actions: [
              IconButton(
                icon: Icon(
                  provider.isMushafMode ? Icons.list_alt_rounded : Icons.menu_book_rounded,
                  color: Colors.white,
                ),
                onPressed: () => provider.toggleMushafMode(),
                tooltip: provider.isMushafMode ? 'Mode Per Ayat' : 'Mode Mushaf',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(surah?.namaLatin ?? 'Memuat...', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
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
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 160,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  if (surah != null)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Text(surah.nama, style: const TextStyle(color: Colors.white, fontSize: 42, fontFamily: 'Amiri')),
                          const SizedBox(height: 8),
                          Text('${surah.arti} • ${surah.jumlahAyat} Ayat', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          if (provider.isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (provider.error != null)
            SliverFillRemaining(child: Center(child: Text('Error: ${provider.error}')))
          else if (surah != null) ...[
            if (surah.nomor != 1 && surah.nomor != 9)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  alignment: Alignment.center,
                  child: Text(
                    'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
                    style: TextStyle(fontSize: 32, fontFamily: 'Amiri', color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            
            if (provider.isMushafMode)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                sliver: SliverToBoxAdapter(
                  child: _MushafView(surah: surah),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _AyatItem(ayat: surah.ayat[index]),
                    childCount: surah.ayat.length,
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

class _MushafView extends StatelessWidget {
  final dynamic surah;
  const _MushafView({required this.surah});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Soft cream/parchment color
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            children: surah.ayat.map((ayat) {
              return TextSpan(
                children: [
                  TextSpan(
                    text: ayat.teksArab,
                    style: TextStyle(
                      fontSize: 26,
                      height: 2.5,
                      fontFamily: 'Amiri',
                      color: const Color(0xFF1F2937),
                      letterSpacing: 0.5,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), width: 1.5),
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${ayat.nomorAyat}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontFamily: 'sans-serif',
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _AyatItem extends StatelessWidget {
  final AyatModel ayat;
  const _AyatItem({required this.ayat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${ayat.nomorAyat}',
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Icon(Icons.share_outlined, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            ayat.teksArab,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 28,
              height: 2.2,
              fontFamily: 'Amiri',
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            ayat.teksLatin,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).primaryColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ayat.teksIndonesia,
            style: TextStyle(fontSize: 14, height: 1.6, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

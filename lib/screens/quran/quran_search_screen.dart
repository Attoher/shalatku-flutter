import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quran_search_provider.dart';
import 'surah_detail_screen.dart';

class QuranSearchScreen extends StatefulWidget {
  final bool hideAppBar;
  const QuranSearchScreen({super.key, this.hideAppBar = false});

  @override
  State<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends State<QuranSearchScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedType = 'ayat';
  final List<Map<String, String>> _types = [
    {'id': 'ayat', 'label': 'Ayat'},
    {'id': 'tafsir', 'label': 'Tafsir'},
    {'id': 'surat', 'label': 'Surat'},
    {'id': 'doa', 'label': 'Doa'},
  ];

  String get _hintText {
    switch (_selectedType) {
      case 'tafsir':
        return 'Cari tafsir tentang...';
      case 'surat':
        return 'Cari surat tentang...';
      case 'doa':
        return 'Cari doa tentang...';
      default:
        return 'Cari ayat tentang...';
    }
  }

  String get _exampleText {
    switch (_selectedType) {
      case 'tafsir':
        return 'Cth: "Tafsir surat Al-Baqarah ayat 153"';
      case 'surat':
        return 'Cth: "Surat tentang hari kiamat"';
      case 'doa':
        return 'Cth: "Doa memohon kesabaran"';
      default:
        return 'Cth: "Ayat tentang kesabaran" atau "Tujuan hidup"';
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    if (_searchCtrl.text.isNotEmpty) {
      context.read<QuranSearchProvider>().search(
            _searchCtrl.text,
            types: [_selectedType],
          );
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranSearchProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scrollbar(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
            if (!widget.hideAppBar)
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Pencarian Makna AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
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
                      bottom: 0,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 150,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Search Input Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: _hintText,
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor, size: 20),
                        suffixIcon: IconButton(
                          icon: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 18,
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                          ),
                          onPressed: _onSearch,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      onSubmitted: (_) => _onSearch(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _types.length,
                      itemBuilder: (context, index) {
                        final type = _types[index];
                        final isSelected = _selectedType == type['id'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () => setState(() => _selectedType = type['id']!),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                type['label']!,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Results Section
          if (provider.loading)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(strokeWidth: 3),
                    SizedBox(height: 20),
                    Text('AI sedang mendalami makna...', style: TextStyle(color: Color(0xFF757575), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            )
          else if (provider.error != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 80, color: Colors.black12),
                      const SizedBox(height: 16),
                      Text(provider.error!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            )
          else if (provider.results.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_outlined, size: 80, color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
                      const SizedBox(height: 24),
                      Text(
                        'Tanyakan apa saja pada AI',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _exampleText,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _SearchResultCard(result: provider.results[index]),
                  childCount: provider.results.length,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

class _SearchResultCard extends StatelessWidget {
  final dynamic result;
  const _SearchResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getTypeColor(context, result.tipe).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                result.tipe.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getTypeColor(context, result.tipe),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                result.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              const Icon(Icons.analytics_outlined, size: 12, color: Color(0xFF757575)),
              const SizedBox(width: 4),
              Text(
                'Relevansi: ${(result.skor * 100).toStringAsFixed(1)}% (${result.relevansi})',
                style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (result.tipe == 'surat') ...[
                   _InfoRow(label: 'Arti', value: result.data['arti'] ?? ''),
                   _InfoRow(label: 'Jumlah Ayat', value: '${result.data['jumlah_ayat'] ?? ''}'),
                   _InfoRow(label: 'Tempat Turun', value: result.data['tempat_turun'] ?? ''),
                   const Divider(height: 24),
                ],
                if (result.arabic.isNotEmpty) ...[
                  Text(
                    result.arabic,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 22,
                      fontFamily: 'Amiri',
                      height: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (result.latin.isNotEmpty) ...[
                  Text(
                    result.latin,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  result.content,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                if (result.tipe == 'doa' && (result.data['catatan']?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline, size: 14, color: Colors.amber),
                            SizedBox(width: 8),
                            Text('Catatan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.data['catatan'],
                          style: const TextStyle(fontSize: 11, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                if (result.surahNumber != null) ...[
                  const Divider(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SurahDetailScreen(nomor: result.surahNumber!),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book, size: 18),
                    label: const Text('Lihat di Al-Quran'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(BuildContext context, String type) {
    switch (type) {
      case 'ayat': return Theme.of(context).primaryColor;
      case 'tafsir': return Colors.orange;
      case 'surat': return Colors.blue;
      case 'doa': return Colors.purple;
      default: return Colors.grey;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

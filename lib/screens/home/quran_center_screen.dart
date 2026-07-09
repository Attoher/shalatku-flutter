import 'package:flutter/material.dart';
import '../quran/quran_search_screen.dart';
import '../quran/quran_list_screen.dart';

class QuranCenterScreen extends StatelessWidget {
  const QuranCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quran AI Center', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.primaryContainer],
              ),
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            tabs: const [
              Tab(icon: Icon(Icons.auto_awesome), text: 'AI Search'),
              Tab(icon: Icon(Icons.menu_book), text: 'Baca Quran'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            QuranSearchScreen(hideAppBar: true),
            QuranListScreen(hideAppBar: true),
          ],
        ),
      ),
    );
  }
}

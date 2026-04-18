import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ibadah_log.dart';
import '../utils/theme.dart';

class IbadahTile extends StatelessWidget {
  final IbadahLog log;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const IbadahTile({
    super.key,
    required this.log,
    required this.onDelete,
    required this.onEdit,
  });

  IconData _iconFor(String type) {
    switch (type) {
      case 'Shalat Fardhu': return Icons.mosque;
      case 'Shalat Sunnah': return Icons.nights_stay;
      case 'Puasa Sunnah': return Icons.no_food;
      case 'Dzikir': return Icons.favorite;
      case 'Membaca Al-Quran': return Icons.menu_book;
      case 'Sedekah': return Icons.volunteer_activism;
      default: return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          child: Icon(_iconFor(log.type), color: AppTheme.primary, size: 20),
        ),
        title: Text(log.type, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('HH:mm - dd MMM yyyy', 'id').format(log.date)),
            if (log.notes.isNotEmpty)
              Text(log.notes, style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (val) {
            if (val == 'edit') onEdit();
            if (val == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Row(
              children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')],
            )),
            const PopupMenuItem(value: 'delete', child: Row(
              children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))],
            )),
          ],
        ),
      ),
    );
  }
}

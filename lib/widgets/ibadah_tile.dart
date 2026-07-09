import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ibadah_log.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconFor(log.type), color: Theme.of(context).primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.type,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (log.type != 'Puasa Sunnah')
                      Text(
                        DateFormat('HH:mm', 'id').format(log.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    if (log.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          log.notes,
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Row(
                    children: [Icon(Icons.edit, size: 18, color: Theme.of(context).primaryColor), const SizedBox(width: 8), Text('Edit', style: TextStyle(color: Theme.of(context).primaryColor))],
                  )),
                  const PopupMenuItem(value: 'delete', child: Row(
                    children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))],
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

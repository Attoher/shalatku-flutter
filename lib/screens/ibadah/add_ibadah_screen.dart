import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/ibadah_log.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ibadah_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';

class AddIbadahScreen extends StatefulWidget {
  final IbadahLog? existing;
  const AddIbadahScreen({super.key, this.existing});

  @override
  State<AddIbadahScreen> createState() => _AddIbadahScreenState();
}

class _AddIbadahScreenState extends State<AddIbadahScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();
  final _customTypeCtrl = TextEditingController();
  String _selectedType = AppConstants.ibadahTypes.first;
  bool _useCustomType = false;
  DateTime _selectedDate = DateTime.now();
  bool _loading = false;
  String _selectedFardhuName = 'Dzuhur'; // Temporary default

  final List<String> _fardhuNames = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    
    // Set initial fardhu name based on current time
    final prayerProvider = context.read<PrayerProvider>();
    if (prayerProvider.prayerTimes.isNotEmpty) {
      final now = DateTime.now();
      // Find the last prayer that has passed
      String lastPassed = 'Isya'; // Default to Isya if before Subuh
      for (var prayer in prayerProvider.prayerTimes) {
        if (now.isAfter(prayer.time) && _fardhuNames.contains(prayer.name)) {
          lastPassed = prayer.name;
        }
      }
      _selectedFardhuName = lastPassed;
    }

    if (isEditing) {
      _selectedType = widget.existing!.type;
      _notesCtrl.text = widget.existing!.notes;
      _selectedDate = widget.existing!.date;
      _useCustomType = !AppConstants.ibadahTypes.any((t) => _selectedType.startsWith(t));
      
      if (!_useCustomType) {
        if (_selectedType.startsWith('Shalat Fardhu')) {
          final match = RegExp(r'\((.*?)\)').firstMatch(_selectedType);
          if (match != null) {
            _selectedFardhuName = match.group(1)!;
          }
          _selectedType = 'Shalat Fardhu';
        }
      } else {
        _customTypeCtrl.text = _selectedType;
      }
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _customTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (time != null && mounted) {
        setState(() {
          _selectedDate = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final userId = context.read<AuthProvider>().user!.uid;
    final provider = context.read<IbadahProvider>();
    
    // Use custom type if enabled, otherwise use selected type
    String finalType = _useCustomType ? _customTypeCtrl.text.trim() : _selectedType;
    if (_selectedType == 'Shalat Fardhu' && !_useCustomType) {
      finalType = 'Shalat Fardhu ($_selectedFardhuName)';
    }

    try {
      // Validate timing for Shalat Fardhu
      if (_selectedType == 'Shalat Fardhu' && !isEditing) {
        final now = DateTime.now();
        final isToday = _selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day == now.day;
        
        if (isToday) {
          final prayerTimes = context.read<PrayerProvider>().prayerTimes;
          final prayer = prayerTimes.where((p) => p.name == _selectedFardhuName).firstOrNull;
          
          if (prayer != null && now.isBefore(prayer.time)) {
             setState(() => _loading = false);
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Belum masuk waktu Shalat $_selectedFardhuName.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
          }
        }
      }

      // Check for duplicate on same date (only for new entries, not edit)
      if (!isEditing && (finalType == 'Puasa Sunnah' || _selectedType == 'Shalat Fardhu')) {
        final hasDuplicate = await provider.hasSameTypeOnDate(
          userId,
          finalType,
          _selectedDate,
        );

        if (hasDuplicate && mounted) {
          setState(() => _loading = false);
          
          String message = 'Ibadah ini sudah dicatat.';
          if (finalType == 'Puasa Sunnah') {
            message = 'Anda sudah mencatat Puasa Sunnah hari ini.';
          } else if (_selectedType == 'Shalat Fardhu') {
            message = 'Shalat $_selectedFardhuName sudah dicatat hari ini.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }

      if (isEditing) {
        await provider.updateIbadah(userId, widget.existing!.copyWith(
          type: finalType,
          notes: _notesCtrl.text.trim(),
          date: _selectedDate,
        ));
      } else {
        await provider.addIbadah(userId, IbadahLog(
          userId: userId,
          type: finalType,
          notes: _notesCtrl.text.trim(),
          date: _selectedDate,
        ));
        // Show notification after successfully logging ibadah
        try {
          await NotificationService.showIbadahReminder();
        } catch (e) {
          // Notification error handling
        }
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(isEditing ? 'Edit Ibadah' : 'Catat Ibadah Baru', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
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
                      Icons.edit_note_rounded,
                      size: 120,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type selector
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.category_outlined, color: Theme.of(context).primaryColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text('Jenis Ibadah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ...AppConstants.ibadahTypes.map((type) {
                          final selected = _selectedType == type && !_useCustomType;
                          return InkWell(
                            onTap: () => setState(() {
                              _selectedType = type;
                              _useCustomType = false;
                              _customTypeCtrl.clear();
                            }),
                            borderRadius: BorderRadius.circular(15),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? Theme.of(context).primaryColor : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: selected ? Theme.of(context).primaryColor : Colors.grey.shade200),
                                boxShadow: selected
                                    ? [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))]
                                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  color: selected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }),
                        InkWell(
                          onTap: () => setState(() => _useCustomType = true),
                          borderRadius: BorderRadius.circular(15),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: _useCustomType ? Theme.of(context).primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: _useCustomType ? Theme.of(context).primaryColor : Colors.grey.shade200),
                              boxShadow: _useCustomType
                                  ? [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))]
                                  : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
                            ),
                            child: Text(
                              '+ Lainnya',
                              style: TextStyle(
                                color: _useCustomType ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: _useCustomType ? FontWeight.bold : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedType == 'Shalat Fardhu' && !_useCustomType) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: _fardhuNames.map((name) {
                            final isSelected = _selectedFardhuName == name;
                            return Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _selectedFardhuName = name),
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
                                  ),
                                  child: Center(
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    if (_useCustomType) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _customTypeCtrl,
                        decoration: InputDecoration(
                          hintText: 'Cth: Tahajud, Dhuha, Sedekah...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Masukkan jenis ibadah' : null,
                        onChanged: (value) => setState(() => _selectedType = value),
                      ),
                    ],
                    const SizedBox(height: 32),

                    if (_selectedType != 'Puasa Sunnah') ...[
                      // Date & time picker
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.event_available_outlined, color: Colors.orange, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text('Waktu Pelaksanaan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
                          ),
                          child: Row(
                            children: [
                              Text(
                                DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  DateFormat('HH:mm').format(_selectedDate),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.edit_calendar_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      // For Puasa, only date picker if needed, or just show current date
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.event_available_outlined, color: Colors.orange, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text('Tanggal Puasa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                           final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
                          ),
                          child: Row(
                            children: [
                              Text(
                                DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const Spacer(),
                              Icon(Icons.edit_calendar_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Notes
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.description_outlined, color: Colors.blue, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text('Catatan Detail', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 5,
                      maxLength: 500,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan pengalaman atau doa khususmu...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                    const SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: _loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(isEditing ? Icons.save : Icons.add_task, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  isEditing ? 'Simpan Perubahan' : 'Catat Sekarang',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
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
}

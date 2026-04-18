import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/ibadah_log.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ibadah_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

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

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _selectedType = widget.existing!.type;
      _notesCtrl.text = widget.existing!.notes;
      _selectedDate = widget.existing!.date;
      _useCustomType = !AppConstants.ibadahTypes.contains(_selectedType);
      if (_useCustomType) {
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
    final finalType = _useCustomType ? _customTypeCtrl.text.trim() : _selectedType;

    try {
      // Check for duplicate on same date (only for new entries, not edit)
      if (!isEditing) {
        final hasDuplicate = await provider.hasSameTypeOnDate(
          userId,
          finalType,
          _selectedDate,
        );

        if (hasDuplicate && mounted) {
          setState(() => _loading = false);
          
          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Ibadah Sudah Ada'),
              content: Text('Sudah ada ibadah "$finalType" pada hari ini. Lanjutkan?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Lanjutkan', style: TextStyle(color: Colors.orange)),
                ),
              ],
            ),
          );

          if (confirmed != true) {
            return;
          }
          
          setState(() => _loading = true);
        }
      }

      if (isEditing) {
        await provider.updateIbadah(widget.existing!.copyWith(
          type: finalType,
          notes: _notesCtrl.text.trim(),
          date: _selectedDate,
        ));
      } else {
        await provider.addIbadah(IbadahLog(
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
      appBar: AppBar(title: Text(isEditing ? 'Edit Ibadah' : 'Tambah Ibadah')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type selector
              const Text('Jenis Ibadah', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...AppConstants.ibadahTypes.map((type) {
                    final selected = _selectedType == type && !_useCustomType;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedType = type;
                        _useCustomType = false;
                        _customTypeCtrl.clear();
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? AppTheme.primary : Colors.grey.shade300,
                          ),
                          boxShadow: selected
                              ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 6)]
                              : null,
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            color: selected ? Colors.white : AppTheme.textGrey,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: () => setState(() => _useCustomType = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _useCustomType ? AppTheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _useCustomType ? AppTheme.primary : Colors.grey.shade300,
                        ),
                        boxShadow: _useCustomType
                            ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 6)]
                            : null,
                      ),
                      child: Text(
                        '+ Custom',
                        style: TextStyle(
                          color: _useCustomType ? Colors.white : AppTheme.textGrey,
                          fontWeight: _useCustomType ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_useCustomType) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customTypeCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Tuliskan jenis ibadah custom (misal: Tahajud, Istikharah)',
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Jenis ibadah tidak boleh kosong' : null,
                  onChanged: (value) => setState(() => _selectedType = value),
                ),
              ],
              const SizedBox(height: 24),

              // Date & time picker
              const Text('Waktu', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy – HH:mm', 'id').format(_selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit, color: AppTheme.textGrey, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Notes
              const Text('Catatan Lengkap', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 4,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Tuliskan catatan detail ibadahmu...\n\nContoh:\n• Tempat/Lokasi ibadah\n• Kondisi saat ibadah\n• Target atau doa khusus\n• Anggota keluarga yang ikut',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        isEditing ? 'Simpan Perubahan' : 'Catat Ibadah',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

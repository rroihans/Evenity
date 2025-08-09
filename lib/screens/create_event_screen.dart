import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _maxAttendeesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          final finalDateTime = DateTime(
            picked.year, picked.month, picked.day,
            pickedTime.hour, pickedTime.minute,
          );
          if (isStartDate) {
            _startDate = finalDateTime;
          } else {
            _endDate = finalDateTime;
          }
        });
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap pilih tanggal mulai dan selesai')),
        );
        return;
      }

      setState(() { _isLoading = true; });

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token == null) throw Exception('Anda harus login');

        await _apiService.createEvent(
          title: _titleController.text,
          description: _descriptionController.text,
          location: _locationController.text,
          category: _categoryController.text,
          startDate: _startDate!,
          endDate: _endDate!,
          maxAttendees: int.parse(_maxAttendeesController.text),
          token: token,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event berhasil dibuat!')),
        );
        // kembali ke halaman sebelumnya dan kirim sinyal 'true' untuk refresh
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}')),
        );
      } finally {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Event Baru')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Judul Event'), validator: (v) => v!.isEmpty ? 'Judul tidak boleh kosong' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Deskripsi'), maxLines: 3, validator: (v) => v!.isEmpty ? 'Deskripsi tidak boleh kosong' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Lokasi'), validator: (v) => v!.isEmpty ? 'Lokasi tidak boleh kosong' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Kategori'), validator: (v) => v!.isEmpty ? 'Kategori tidak boleh kosong' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _maxAttendeesController, decoration: const InputDecoration(labelText: 'Maksimal Peserta'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Jumlah peserta tidak boleh kosong' : null),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Tanggal & Waktu Mulai'),
                  subtitle: Text(_startDate == null ? 'Pilih tanggal' : DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(_startDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, isStartDate: true),
                ),
                ListTile(
                  title: const Text('Tanggal & Waktu Selesai'),
                  subtitle: Text(_endDate == null ? 'Pilih tanggal' : DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(_endDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, isStartDate: false),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(onPressed: _submitForm, child: const Text('Buat Event')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

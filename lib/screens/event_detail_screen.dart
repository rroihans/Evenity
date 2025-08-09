import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // judul dan kategori
              Chip(
                label: Text(event.category),
                backgroundColor: Colors.blue.shade100,
              ),
              const SizedBox(height: 8),
              Text(
                event.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Diselenggarakan oleh: ${event.creatorName}',
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // info waktu dan lokasi
              _buildInfoRow(Icons.calendar_today, 'Mulai', DateFormat('EEEE, d MMM yyyy, HH:mm', 'id_ID').format(event.startDate)),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.calendar_today, 'Selesai', DateFormat('EEEE, d MMM yyyy, HH:mm', 'id_ID').format(event.endDate)),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.location_on, 'Lokasi', event.location),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // deskripsi
              const Text(
                'Deskripsi Event',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // info kuota
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Maksimal Peserta:', style: TextStyle(fontSize: 16)),
                  Text('${event.maxAttendees}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sisa Kuota:', style: TextStyle(fontSize: 16)),
                  Text('${event.availableSpots}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ],
          ),
        ),
      ),
      // tombol untuk mendaftar event
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur pendaftaran event belum tersedia.')),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Daftar Event Ini', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  // widget untuk baris info (judul, isi, dll)
  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }
}

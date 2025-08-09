class Event {
  final int id;
  final String title;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final int maxAttendees;
  final String category;
  final String creatorName;
  final int availableSpots;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.maxAttendees,
    required this.category,
    required this.creatorName,
    required this.availableSpots,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'] ?? 'Tanpa Judul',
      description: json['description'] ?? 'Tidak ada deskripsi',
      location: json['location'] ?? 'Lokasi tidak diketahui',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      maxAttendees: json['max_attendees'] ?? 0,
      category: json['category'] ?? 'Lainnya',
      creatorName: json['creator'] != null ? json['creator']['name'] : 'Anonim',
      availableSpots: json['available_spots'] ?? 0,
    );
  }
}

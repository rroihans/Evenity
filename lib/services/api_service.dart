import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class ApiService {
  final String baseUrl = 'http://103.160.63.165/api';

  Future<List<Event>> getEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> eventData = responseData['data']['events'];

        return eventData.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat event');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../models/user.dart';

class ApiService {
  final String baseUrl = 'http://103.160.63.165/api';

  Future<List<Event>> getEvents({String? searchQuery, String? category}) async {
    try {
      var uri = Uri.parse('$baseUrl/events');

      Map<String, String> queryParams = {};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri);

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

  Future<AuthResponse> login(String studentNumber, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'student_number': studentNumber,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return AuthResponse.fromJson(responseData['data']);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Login Gagal');
    }
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String studentNumber,
    required String major,
    required int classYear,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'student_number': studentNumber,
        'major': major,
        'class_year': classYear,
        'password': password,
        'password_confirmation': password,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return AuthResponse.fromJson(responseData['data']);
    } else {
      final errorData = json.decode(response.body);
      String errorMessage = errorData['message'] ?? 'Registrasi Gagal';
      if (errorData['errors'] != null) {
        errorMessage = errorData['errors'].values.first[0];
      }
      throw Exception(errorMessage);
    }
  }

  Future<void> createEvent({
    required String title,
    required String description,
    required String location,
    required String category,
    required DateTime startDate,
    required DateTime endDate,
    required int maxAttendees,
    required String token,
  }) async {
    final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss");

    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'title': title,
        'description': description,
        'location': location,
        'category': category,
        'start_date': formatter.format(startDate),
        'end_date': formatter.format(endDate),
        'max_attendees': maxAttendees,
        'price': 0,
        'image_url': 'https://placehold.co/600x400'
      }),
    );

    if (response.statusCode != 201) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal membuat event');
    }
  }
}

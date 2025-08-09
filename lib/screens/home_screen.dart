import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/event.dart';
import '../widgets/event_card.dart';
import 'login_screen.dart';
import 'create_event_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  Future<List<Event>>? _eventsFuture;
  String? _token;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  Timer? _debounce;

  final List<String> _categories = ['Workshop', 'Seminar', 'Lomba', 'Meetup', 'Conference', 'Course'];

  @override
  void initState() {
    super.initState();
    _loadTokenAndEvents();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // fungsi untuk mengambil event dengan filter
  void _fetchEvents() {
    setState(() {
      _eventsFuture = apiService.getEvents(
        searchQuery: _searchQuery,
        category: _selectedCategory,
      );
    });
  }

  // akan dipanggil setiap kali teks di search bar berubah
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
          _fetchEvents();
        });
      }
    });
  }

  Future<void> _loadTokenAndEvents() async {
    await _loadToken();
    _fetchEvents();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }



  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    setState(() {
      _token = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Anda telah logout.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evenity'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          _token == null
              ? TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()))
                  .then((_) => _loadTokenAndEvents());
            },
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          )
              : IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchEvents();
        },
        child: Column(
          children: [
            // --- UI UNTUK SEARCH DAN FILTER ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Cari event...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: _categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                          _fetchEvents();
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // --- LIST EVENT ---
            Expanded(
              child: FutureBuilder<List<Event>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Tidak ada event ditemukan.'));
                  } else {
                    final events = snapshot.data!;
                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return EventCard(event: events[index]);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _token != null ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateEventScreen()))
              .then((result) {
            if (result == true) {
              _fetchEvents();
            }
          });
        },
        tooltip: 'Buat Event Baru',
        child: const Icon(Icons.add),
      ) : null,
    );
  }
}

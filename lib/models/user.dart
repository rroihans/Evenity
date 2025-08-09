// untuk merepresentasikan data pengguna
class User {
  final int id;
  final String name;
  final String email;
  final String studentNumber;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.studentNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      studentNumber: json['student_number'] ?? '',
    );
  }
}

// untuk menangani keseluruhan respons dari api login/register
class AuthResponse {
  final User user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://192.168.1.105:8080";

  String? token;
  int? userId;
  String? userName;
  String? role;

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    print("LOGIN STATUS: ${response.statusCode}");
    print("LOGIN BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      token = data['token'];
      userId = data['userId'];
      userName = data['name'];
      role = data['role'];

      return token;
    } else {
      return null;
    }
  }
  
  Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );
print("REGISTER STATUS: ${response.statusCode}");
print("REGISTER BODY: ${response.body}");
    return response.statusCode == 200 || response.statusCode == 201;
    
  }
}
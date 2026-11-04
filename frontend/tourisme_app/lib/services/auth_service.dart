import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'session.dart';

class AuthService {
  final String baseUrl = ApiConfig.baseUrl;

  String? token;
  int? userId;
  String? userName;
  String? role;

  Future<String?> login(String email, String password) async {
    final http.Response response;
    try {
      response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    ).timeout(const Duration(seconds: 15));
    } catch (e) {
      print("LOGIN ERROR: $e");
      return null;
    }

    print("LOGIN STATUS: ${response.statusCode}");
    print("LOGIN BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      token = data['token'];
      userId = data['userId'];
      userName = data['name'];
      role = data['role'];

      Session.userId = userId;
      Session.token = token;
      Session.userName = userName;

      return token;
    } else {
      return null;
    }
  }
  
  Future<bool> register(String name, String email, String password) async {
    final http.Response response;
    try {
      response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    ).timeout(const Duration(seconds: 15));
    } catch (e) {
      print("REGISTER ERROR: $e");
      return false;
    }
print("REGISTER STATUS: ${response.statusCode}");
print("REGISTER BODY: ${response.body}");
    return response.statusCode == 200 || response.statusCode == 201;
    
  }
}
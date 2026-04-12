import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.8:8080";
  static Map<String, String> headers(String token) {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }
  static Future<void> addHotel(String token, Map<String, dynamic> hotel) async {
    await http.post(
      Uri.parse("$baseUrl/hotels"),
      headers: headers(token),
      body: jsonEncode(hotel),
    );
  }
}
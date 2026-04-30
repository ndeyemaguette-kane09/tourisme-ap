import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/beach.dart';

import '../config/api_config.dart';


class BeachService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<Beach>> getBeaches(String token) async {
  final response = await http.get(
    Uri.parse("$baseUrl/beaches"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  List data = jsonDecode(response.body);
  return data.map((e) => Beach.fromJson(e)).toList();
}

Future<void> deleteBeach(int id, String token) async {
  await http.delete(
    Uri.parse("$baseUrl/beaches/$id"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );
}

Future<void> updateBeach(int id, Map<String, dynamic> beach, String token) async {
  final response = await http.put(
    Uri.parse("$baseUrl/beaches/$id"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode(beach),
  );

  print("UPDATE BEACH STATUS: ${response.statusCode}");
  print("UPDATE BEACH BODY: ${response.body}");

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception("Erreur mise à jour plage");
  }
}
}
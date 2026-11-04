import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class EventService {
  static Future<List<Map<String, dynamic>>> getUpcoming() async {
    final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/events"));
    if (response.statusCode != 200) throw Exception("Erreur chargement calendrier");
    final List data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.cast<Map<String, dynamic>>();
  }

  static const _months = [
    "janvier", "février", "mars", "avril", "mai", "juin",
    "juillet", "août", "septembre", "octobre", "novembre", "décembre",
  ];

  static DateTime start(Map<String, dynamic> e) => DateTime.parse(e["startDate"]);
  static DateTime end(Map<String, dynamic> e) => DateTime.parse(e["endDate"] ?? e["startDate"]);

  static String dateLabel(Map<String, dynamic> e) {
    final s = start(e);
    final f = end(e);
    if (s == f) return "${s.day} ${_months[s.month - 1]} ${s.year}";
    if (s.month == f.month) return "${s.day}–${f.day} ${_months[s.month - 1]} ${s.year}";
    return "${s.day} ${_months[s.month - 1]} – ${f.day} ${_months[f.month - 1]} ${f.year}";
  }

  static String countdown(Map<String, dynamic> e) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = start(e).difference(today).inDays;
    if (days < 0) return "En cours";
    if (days == 0) return "Aujourd'hui";
    if (days == 1) return "Demain";
    if (days < 60) return "Dans $days jours";
    return "Dans ${(days / 30.4).round()} mois";
  }

  static Map<String, String> _headers(String token) => {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

  static Future<List<Map<String, dynamic>>> getAll(String token) async {
    final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/events?upcoming=false"), headers: _headers(token));
    if (response.statusCode != 200) throw Exception("Erreur chargement calendrier");
    final List data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.cast<Map<String, dynamic>>();
  }

  static Future<void> save(String token, Map<String, dynamic> event, {int? id}) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/events${id == null ? "" : "/$id"}");
    final body = jsonEncode(event);
    final response = id == null
        ? await http.post(uri, headers: _headers(token), body: body)
        : await http.put(uri, headers: _headers(token), body: body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Erreur enregistrement événement");
    }
  }

  static Future<void> delete(String token, int id) async {
    final response = await http.delete(Uri.parse("${ApiConfig.baseUrl}/events/$id"), headers: _headers(token));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Erreur suppression événement");
    }
  }
}

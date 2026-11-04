import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'session.dart';

class DiscoverService {
  static final String baseUrl = ApiConfig.baseUrl;

  static List<Map<String, dynamic>> _decodeList(http.Response response) {
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> search({
    String? query,
    String? type,
    String? city,
    String? category,
    double? minRating,
    double? maxPrice,
  }) async {
    final params = <String, String>{
      if (query != null && query.trim().isNotEmpty) "q": query.trim(),
      if (type != null) "type": type,
      if (city != null && city.isNotEmpty) "city": city,
      if (category != null) "category": category,
      if (minRating != null) "minRating": minRating.toString(),
      if (maxPrice != null) "maxPrice": maxPrice.toString(),
    };

    final response = await http.get(
      Uri.parse("$baseUrl/search").replace(queryParameters: params),
    );

    if (response.statusCode == 200) {
      return _decodeList(response);
    }
    throw Exception("Erreur de recherche");
  }

  static Future<List<Map<String, dynamic>>> recommendations({int limit = 10}) async {
    if (!Session.isLoggedIn) {
      return (await search()).take(limit).toList();
    }

    final response = await http.get(
      Uri.parse("$baseUrl/recommendations/user/${Session.userId}?limit=$limit"),
      headers: Session.headers,
    );

    if (response.statusCode == 200) {
      return _decodeList(response);
    }
    throw Exception("Erreur chargement recommandations");
  }

  static Future<Map<String, dynamic>> getItem(String type, int id) async {
    const paths = {
      "hotel": "hotels",
      "restaurant": "restaurants",
      "beach": "beaches",
      "place": "places",
    };

    final response = await http.get(Uri.parse("$baseUrl/${paths[type]}/$id"));

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception("Lieu introuvable");
  }

  static Future<Map<String, dynamic>> itinerary({
    required int days,
    List<String> categories = const [],
    String? start,
  }) async {
    final uri = Uri.parse("$baseUrl/recommendations/itinerary").replace(queryParameters: {
      "days": "$days",
      if (categories.isNotEmpty) "categories": categories.join(","),
      if (start != null) "start": start,
    });

    final response = await http.get(uri, headers: Session.headers);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception("Impossible de générer l'itinéraire");
  }

  static Future<void> likeHotel(int hotelId, bool liked) async {
    if (!Session.isLoggedIn) return;
    try {
      await http.post(
        Uri.parse("$baseUrl/recommendations/like"),
        headers: Session.headers,
        body: jsonEncode({"userId": Session.userId, "hotelId": hotelId, "liked": liked}),
      );
    } catch (_) {}
  }
}

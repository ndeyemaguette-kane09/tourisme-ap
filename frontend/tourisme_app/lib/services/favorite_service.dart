import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'session.dart';

class FavoriteService {
  static String get _key => "favorites_${Session.userId ?? 'guest'}";

  static Future<List<Map<String, dynamic>>> _readLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> _writeLocal(List<Map<String, dynamic>> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, favorites.map(jsonEncode).toList());
  }

  static bool _same(Map a, Map b) => a["id"] == b["id"] && a["type"] == b["type"];

  static Future<void> addFavorite(Map<String, dynamic> item) async {
    final favorites = await _readLocal();
    if (favorites.any((f) => _same(f, item))) return;

    final favorite = {
      "id": item["id"],
      "type": item["type"],
      "title": item["title"],
      "image": item["image"],
      "subtitle": item["subtitle"],
      "city": item["city"] ?? "",
    };
    favorites.add(favorite);
    await _writeLocal(favorites);

    if (!Session.isLoggedIn) return;
    try {
      await http.post(
        Uri.parse("${ApiConfig.baseUrl}/recommendations/favorites"),
        headers: Session.headers,
        body: jsonEncode({
          "userId": Session.userId,
          "itemId": item["id"],
          "itemType": item["type"],
          "title": item["title"],
          "imageUrl": item["image"],
          "city": item["city"] ?? "",
        }),
      );
    } catch (_) {
      // pas de réseau : le favori reste en local
    }
  }

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final local = await _readLocal();
    if (!Session.isLoggedIn) return local;

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/recommendations/favorites/user/${Session.userId}"),
        headers: Session.headers,
      );
      if (response.statusCode != 200) return local;

      final remote = (jsonDecode(utf8.decode(response.bodyBytes)) as List)
          .map((f) => <String, dynamic>{
                "id": f["itemId"],
                "type": f["itemType"],
                "title": f["title"],
                "image": f["imageUrl"],
                "subtitle": local.firstWhere(
                  (l) => l["id"] == f["itemId"] && l["type"] == f["itemType"],
                  orElse: () => {},
                )["subtitle"] ?? f["city"] ?? "",
                "city": f["city"] ?? "",
              })
          .toList();

      await _writeLocal(remote);
      return remote;
    } catch (_) {
      return local;
    }
  }

  static Future<void> removeFavorite(Map<String, dynamic> item) async {
    final favorites = await _readLocal();
    favorites.removeWhere((f) => _same(f, item));
    await _writeLocal(favorites);

    if (!Session.isLoggedIn) return;
    try {
      await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/recommendations/favorites"
            "?userId=${Session.userId}&itemId=${item["id"]}&itemType=${item["type"]}"),
        headers: Session.headers,
      );
    } catch (_) {}
  }
}

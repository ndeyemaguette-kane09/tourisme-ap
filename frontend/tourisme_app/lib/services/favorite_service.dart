import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static Future<void> addFavorite(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];

    final exists = favorites.any((fav) {
      final decoded = jsonDecode(fav);
      return decoded["id"] == item["id"] && decoded["type"] == item["type"];
    });

    if (!exists) {
      favorites.add(jsonEncode({
        "id": item["id"],
        "type": item["type"],
        "title": item["title"],
        "image": item["image"],
        "subtitle": item["subtitle"],
        "city": item["city"] ?? "",
      }));

      await prefs.setStringList('favorites', favorites);
      print("FAVORI AJOUTÉ: $item");
    }
  }

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];

    return favorites
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();
  }

  static removeFavorite(favorit) {}
}
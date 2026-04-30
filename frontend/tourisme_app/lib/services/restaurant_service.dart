import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/restaurant.dart';
import '../config/api_config.dart';

class RestaurantService {
  final String baseUrl = ApiConfig.baseUrl;

  //  GET RESTAURANTS
  Future<List<Restaurant>> getRestaurants(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/restaurants"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Restaurant.fromJson(e)).toList();
    } else {
      throw Exception("Erreur chargement restaurants");
    }
  }

  //  DELETE
  Future<void> deleteRestaurant(int id, String token) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/restaurants/$id"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception("Erreur suppression restaurant");
    }
  }

  // UPDATE
  Future<void> updateRestaurant(int id, Map<String, dynamic> restaurant, String token) async {
    final response = await http.put(
      Uri.parse("$baseUrl/restaurants/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(restaurant),
    );

    print("UPDATE RESTAURANT STATUS: ${response.statusCode}");
    print("UPDATE RESTAURANT BODY: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Erreur mise à jour restaurant");
    }
  }
}
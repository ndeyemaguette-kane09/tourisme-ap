import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

import '../models/category.dart';

class CategoryService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<List<Category>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data
          .map((json) => Category.fromJson(json))
          .toList();
    } else {
      throw Exception('Erreur chargement catégories');
    }
  }
}
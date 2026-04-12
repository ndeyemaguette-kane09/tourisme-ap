import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';
import 'api_service.dart';

class HotelService {
  Future<List<Hotel>> getHotels(String token) async {
    final url = Uri.parse("${ApiService.baseUrl}/hotels");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((hotel) => Hotel.fromJson(hotel)).toList();
    } else {
      throw Exception("Failed to load hotels");
    }
  }
}
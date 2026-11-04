import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'session.dart';

class AccountService {
  static const _timeout = Duration(seconds: 15);
  static String get _base => ApiConfig.baseUrl;

  static Future<Map<String, dynamic>?> profile(int id) async {
    try {
      final res = await http.get(Uri.parse("$_base/auth/profile/$id"), headers: Session.headers).timeout(_timeout);
      if (res.statusCode != 200) return null;
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> update(int id, {required String name, required String email, required String phone}) async {
    try {
      final res = await http
          .put(
            Uri.parse("$_base/auth/profile/$id"),
            headers: Session.headers,
            body: jsonEncode({"name": name, "email": email, "phone": phone}),
          )
          .timeout(_timeout);
      if (res.statusCode == 200) Session.userName = name;
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> changePassword(int id, String oldPassword, String newPassword) async {
    try {
      final res = await http
          .put(
            Uri.parse("$_base/auth/change-password/$id"),
            headers: Session.headers,
            body: jsonEncode({"oldPassword": oldPassword, "newPassword": newPassword}),
          )
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> delete(int id) async {
    try {
      final res = await http.delete(Uri.parse("$_base/auth/profile/$id"), headers: Session.headers).timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

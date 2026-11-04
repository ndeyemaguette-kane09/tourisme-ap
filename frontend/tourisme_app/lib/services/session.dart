class Session {
  static int? userId;
  static String? token;
  static String? userName;

  static bool get isLoggedIn => userId != null && token != null;

  static Map<String, String> get headers => {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

  static void clear() {
    userId = null;
    token = null;
    userName = null;
  }
}

import 'package:flutter/material.dart';
import '../services/favorite_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> favorites = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final data = await FavoriteService.getFavorites();
    setState(() => favorites = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: FavoriteService.getFavorites(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final favorites = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      "Mes favoris",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4E1B00),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                ...favorites.map((item) {
                  return GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: DecorationImage(
                          image: NetworkImage(item["image"]),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.85),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item["title"] ?? "",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.favorite, color: Colors.red),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item["city"] != null && item["city"].toString().isNotEmpty
                                        ? item["city"]
                                        : item["subtitle"] ?? "",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      ),
    );
  }
}
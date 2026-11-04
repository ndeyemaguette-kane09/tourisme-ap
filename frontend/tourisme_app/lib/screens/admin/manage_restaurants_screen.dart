import 'package:flutter/material.dart';
import '../../services/restaurant_service.dart';
import '../../widgets/admin_kit.dart';
import 'restaurant_form_screen.dart';

class ManageRestaurantsScreen extends StatelessWidget {
  final String token;

  const ManageRestaurantsScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return AdminListPage(
      title: "Restaurants",
      icon: Icons.restaurant_rounded,
      onAdd: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RestaurantFormScreen(token: token)),
      ),
      load: (refresh) async {
        final restaurants = await RestaurantService().getRestaurants(token);
        return restaurants
            .map((r) => AdminRow(
                  title: r.name,
                  subtitle: r.city,
                  imageUrl: r.imageUrl,
                  hasGps: r.latitude != 0 && r.longitude != 0,
                  onEdit: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RestaurantFormScreen(token: token, restaurant: r)),
                    );
                    if (changed == true) refresh();
                  },
                  onDelete: () => RestaurantService().deleteRestaurant(r.id, token),
                ))
            .toList();
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../services/beach_service.dart';
import '../widgets/swipe_deck.dart';
import 'beach_details_screen.dart';

class BeachSwipeScreen extends StatelessWidget {
  final String token;

  const BeachSwipeScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return SwipeDeck(
      title: "Plages",
      subtitle: "Glisse à droite pour ajouter une plage à tes favoris.",
      icon: Icons.beach_access_rounded,
      load: () async {
        final beaches = await BeachService().getBeaches(token);
        return beaches
            .map((b) => SwipeEntry(
                  id: b.id,
                  type: "beach",
                  name: b.name,
                  imageUrl: b.imageUrl,
                  location: b.city,
                  rating: b.rating,
                  onOpen: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BeachDetailsScreen(beach: b)),
                  ),
                ))
            .toList();
      },
    );
  }
}

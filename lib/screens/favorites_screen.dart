import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/colors.dart';
import '../utils/mock_data.dart';
import '../widgets/restaurant_card.dart';
import 'restaurant_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sadece ilk iki restoranı favori gibi gösteriyoruz (Mock)
    final favorites = MockData.restaurants.take(2).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorilerim')),
      body: favorites.isEmpty
          ? const Center(child: Text('Henüz favori restoranın yok.'))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    RestaurantCard(
                      restaurant: favorites[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RestaurantScreen(restaurant: favorites[index])),
                        );
                      },
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.favorite_rounded, color: AppColors.error, size: 20),
                      ),
                    ),
                  ],
                ).animate().fade(delay: (100 * index).ms).scale(begin: const Offset(0.9, 0.9));
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_card.dart';
import 'restaurant_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  final _firestore = FirebaseFirestore.instance;

  Restaurant _docToRestaurant(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      imageUrl: data['imageUrl'] ?? 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
      reviews: [],
      deliveryTimeMin: (data['deliveryTimeMin'] ?? 20) as int,
      deliveryTimeMax: (data['deliveryTimeMax'] ?? 40) as int,
      deliveryFee: (data['deliveryFee'] ?? 14.99) as double,
      categories: List<String>.from(data['categories'] ?? ['Çeşitli']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Arama', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: AppColors.primary),
                  hintText: 'Restoran veya kategori ara...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildInitialState()
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('restaurants').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      }
                      
                      final docs = snapshot.data?.docs ?? [];
                      final filtered = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data['name'] as String? ?? '').toLowerCase();
                        final cats = (data['categories'] as List?)?.join(' ').toLowerCase() ?? '';
                        final query = _searchQuery.toLowerCase();
                        return name.contains(query) || cats.contains(query);
                      }).toList();

                      if (filtered.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final restaurant = _docToRestaurant(filtered[index]);
                          return RestaurantCard(
                            restaurant: restaurant,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => RestaurantScreen(restaurant: restaurant)),
                              );
                            },
                          ).animate().fade(duration: 200.ms).slideY(begin: 0.1, end: 0);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.search_rounded, size: 80, color: AppColors.cardShadow).animate().scale(delay: 200.ms),
        const SizedBox(height: 16),
        const Text(
          'Canın ne çekiyor?',
          style: TextStyle(color: AppColors.textLight, fontSize: 16),
        ).animate().fade(delay: 300.ms),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.sentiment_dissatisfied_rounded, size: 80, color: AppColors.textLight.withValues(alpha: 0.5)),
        const SizedBox(height: 16),
        const Text('Sonuç bulunamadı', style: TextStyle(color: AppColors.textLight)),
      ],
    );
  }
}

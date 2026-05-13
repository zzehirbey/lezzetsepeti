import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';
import '../utils/mock_data.dart';
import '../widgets/restaurant_card.dart';
import '../models/restaurant.dart';
import 'restaurant_screen.dart';
import 'ai_assistant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Tümü';
  final _firestore = FirebaseFirestore.instance;

  void _showAddressBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Teslimat Adresi Seçin',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.home_rounded, color: AppColors.primary),
                title: const Text('Ev'),
                subtitle: const Text('Atatürk Mah. Cumhuriyet Cad...'),
                trailing: const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.work_rounded, color: AppColors.textLight),
                title: const Text('İş'),
                subtitle: const Text('Barbaros Mah. Menekşe Sok...'),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_location_alt_rounded),
                  label: const Text('Yeni Adres Ekle'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _seedData() async {
    setState(() => _isSeeding = true);
    final firestore = FirebaseFirestore.instance;
    
    for (var rest in MockData.restaurants) {
      final restRef = firestore.collection('restaurants').doc(rest.id);
      await restRef.set({
        'name': rest.name,
        'logoUrl': rest.logoUrl,
        'imageUrl': rest.imageUrl,
        'deliveryTimeMin': rest.deliveryTimeMin,
        'deliveryTimeMax': rest.deliveryTimeMax,
        'deliveryFee': rest.deliveryFee,
        'categories': rest.categories,
        'rating': 4.5,
        'reviewCount': 10,
        'isOpen': true,
      });

      // Seed menu items for this restaurant
      final items = MockData.getMenuItems(rest.id);
      for (var item in items) {
        await restRef.collection('menu').doc(item.id).set({
          'name': item.name,
          'description': item.description,
          'price': item.price,
          'imageUrl': item.imageUrl,
          'isPopular': item.isPopular,
        });
      }
    }
    if (mounted) setState(() => _isSeeding = false);
  }

  bool _isSeeding = false;

  /// Convert a Firestore doc to a Restaurant model for RestaurantCard
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
      dbRating: (data['rating'] ?? 0.0).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _showAddressBottomSheet,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Teslimat Adresi',
                              style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                          Row(children: [
                            const Text('Ev',
                                style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                          ]),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text('LezzetSepeti',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: -0.5)),
                ]).animate().fade().slideX(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: const Text('Bugün ne yemek\nistersin?',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.2))
                    .animate().fade(duration: 400.ms).slideY(begin: 0.2, end: 0),
              ),
              const SizedBox(height: 20),
              // ── Banners ──
              SizedBox(
                height: 140,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildBanner('Günün Fırsatı', 'Tüm Pizzalarda %20 İndirim!',
                        'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80', AppColors.primary),
                    _buildBanner('Hoş Geldin', 'İlk Siparişe Özel Ücretsiz Teslimat',
                        'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?auto=format&fit=crop&w=800&q=80', AppColors.textDark),
                  ],
                ),
              ).animate().fade(delay: 200.ms).slideX(),
              const SizedBox(height: 24),
              // ── Categories ──
              SizedBox(
                height: 100,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: MockData.categories.length,
                  itemBuilder: (context, index) {
                    final category = MockData.categories[index];
                    final isSelected = _selectedCategory == category.name;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = category.name),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutBack,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surface,
                                shape: BoxShape.circle,
                                boxShadow: isSelected
                                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
                                    : [const BoxShadow(color: AppColors.cardShadow, blurRadius: 10)],
                              ),
                              child: Text(category.emoji, style: const TextStyle(fontSize: 28)),
                            ),
                            const SizedBox(height: 8),
                            Text(category.name,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppColors.primary : AppColors.textLight,
                                  fontSize: 13,
                                )),
                          ],
                        ),
                      ).animate().fade(delay: (50 * index).ms).scale(begin: const Offset(0.8, 0.8)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  _selectedCategory == 'Tümü' ? 'Tüm Restoranlar' : '$_selectedCategory Restoranları',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ),
              const SizedBox(height: 16),
              // ── Live Firestore Restaurant List ──
              StreamBuilder<QuerySnapshot>(
                stream: _buildQuery(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    );
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(children: [
                          const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.textLight),
                          const SizedBox(height: 16),
                          const Text('Veritabanında hiç restoran bulunamadı.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textLight, fontSize: 16)),
                          const SizedBox(height: 24),
                          if (_isSeeding)
                            const CircularProgressIndicator(color: AppColors.primary)
                          else
                            ElevatedButton.icon(
                              onPressed: _seedData,
                              icon: const Icon(Icons.restore_rounded),
                              label: const Text('Örnek Restoranları Yükle'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          const SizedBox(height: 8),
                          const Text('Bu işlem Mock verileri Firestore\'a taşır.',
                              style: TextStyle(color: AppColors.textLight, fontSize: 11)),
                        ]),
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final restaurant = _docToRestaurant(docs[index]);
                      return RestaurantCard(
                        restaurant: restaurant,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 500),
                              pageBuilder: (_, __, ___) => RestaurantScreen(restaurant: restaurant),
                              transitionsBuilder: (_, animation, __, child) =>
                                  FadeTransition(opacity: animation, child: child),
                            ),
                          );
                        },
                      ).animate(key: ValueKey('${_selectedCategory}_${docs[index].id}')).fade().slideY(begin: 0.1, end: 0);
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIAssistantScreen())),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.smart_toy_rounded, color: Colors.white),
        label: const Text('Lezzet Asistanı', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Stream<QuerySnapshot> _buildQuery() {
    Query<Map<String, dynamic>> q = _firestore.collection('restaurants');
    if (_selectedCategory != 'Tümü') {
      q = q.where('categories', arrayContains: _selectedCategory);
    }
    return q.snapshots();
  }

  Widget _buildBanner(String title, String subtitle, String imageUrl, Color bgColor) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [bgColor.withOpacity(0.8), Colors.transparent],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
              child: Text(title, style: TextStyle(color: bgColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

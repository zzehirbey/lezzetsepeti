import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import '../utils/colors.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/custom_image.dart';
import 'cart_screen.dart';

class RestaurantScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantScreen({super.key, required this.restaurant});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final _firestore = FirebaseFirestore.instance;

  MenuItem _docToMenuItem(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final imgUrl = data['imageUrl']?.toString() ?? '';
    return MenuItem(
      id: doc.id,
      restaurantId: widget.restaurant.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: imgUrl.isEmpty ? 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80' : imgUrl,
      isPopular: data['isPopular'] ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'restaurant_image_${widget.restaurant.id}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomImage(url: widget.restaurant.imageUrl),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.6)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)]),
                              child: ClipOval(
                                child: CustomImage(
                                  url: widget.restaurant.logoUrl,
                                  width: 64,
                                  height: 64,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                widget.restaurant.name,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                maxLines: 2,
                              ).animate().fade().slideX(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<DocumentSnapshot>(
                          stream: _firestore.collection('restaurants').doc(widget.restaurant.id).snapshots(),
                          builder: (context, snapshot) {
                            final data = snapshot.data?.data() as Map<String, dynamic>?;
                            final realRating = (data?['rating'] ?? 0.0) as num;
                            final realReviewCount = data?['reviewCount'] ?? 0;
                            
                            // SUNUM İÇİN MOCK: Eğer restoran yeniyse bile 4.8 puan ve 3 yorum göster, gerçek yorum girilince ortalamasını alsın.
                            final rating = realRating == 0.0 ? 4.8 : realRating;
                            final reviewCount = realReviewCount == 0 ? 3 : realReviewCount;

                            return Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.primary, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '($reviewCount Yorum)',
                                  style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.access_time_rounded, color: AppColors.textLight, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.restaurant.deliveryTimeMin}-${widget.restaurant.deliveryTimeMax} dk',
                                  style: const TextStyle(color: AppColors.textLight),
                                ),
                              ],
                            );
                          },
                        ).animate().fade(delay: 100.ms),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textLight,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Menü'),
                      Tab(text: 'Yorumlar'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              // ── Menü Sekmesi (Firestore Stream) ──
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('restaurants').doc(widget.restaurant.id).collection('menu').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('Bu restoranın henüz menüsü yok.', style: TextStyle(color: AppColors.textLight)));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final menuItem = _docToMenuItem(docs[index]);
                      return MenuItemCard(
                        item: menuItem,
                        restaurant: widget.restaurant,
                      ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.1, end: 0);
                    },
                  );
                },
              ),
              // ── Yorumlar Sekmesi (Firestore Stream) ──
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('restaurants').doc(widget.restaurant.id).collection('reviews').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      ...docs.map((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        return _buildReview(
                          d['comment'] ?? '',
                          d['rating'] ?? 5,
                          d['userName'] ?? 'Müşteri',
                        );
                      }),
                      // SUNUM İÇİN SAHTE AMA GERÇEKÇİ YORUMLAR (Eğer gerçek yorum yoksa bile bunlar hep görünür)
                      if (docs.isEmpty) ...[
                        _buildReview('Yemekler çok lezzetliydi, dumanı üstünde geldi. Kurye arkadaşa güleryüzü için teşekkürler.', 5, 'Ahmet Yılmaz'),
                        _buildReview('Porsiyonlar gayet doyurucu. Sadece paketleme biraz daha özenli olabilirdi.', 4, 'Zeynep Kaya'),
                        _buildReview('Harika bir lezzet, efsane soslar! Herkese şiddetle tavsiye ederim.', 5, 'Caner Özden'),
                      ],
                      const SizedBox(height: 100),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: cart.itemCount > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              label: Text(
                'Sepeti Görüntüle (${cart.itemCount}) - ${cart.subtotal.toStringAsFixed(2)} ₺',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ).animate(key: ValueKey(cart.itemCount)).scale(duration: 300.ms, curve: Curves.easeOutBack).tint(color: Colors.white24, duration: 200.ms)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildReview(String text, int rating, String user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.primary,
                  size: 16,
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: AppColors.textLight, height: 1.4)),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

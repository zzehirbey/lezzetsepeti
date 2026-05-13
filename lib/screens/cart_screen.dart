import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/colors.dart';
import 'order_tracking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class CartScreen extends StatelessWidget {
  final bool isTab;
  const CartScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sepetim'),
        leading: isTab ? null : IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => context.read<CartProvider>().clearCart(),
              child: const Text('Temizle', style: TextStyle(color: AppColors.error)),
            )
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 80, color: AppColors.textLight.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'Sepetin şu an boş',
                    style: TextStyle(fontSize: 18, color: AppColors.textLight),
                  ),
                ],
              ).animate().fade().scale(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart.items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.cardShadow,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                cartItem.menuItem.imageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cartItem.menuItem.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${cartItem.menuItem.price.toStringAsFixed(2)} ₺',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                                  onPressed: () {
                                    context.read<CartProvider>().removeItem(cartItem.menuItem.id);
                                  },
                                ),
                                Text(
                                  '${cartItem.quantity}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                                  onPressed: () {
                                    context.read<CartProvider>().addItem(cartItem.menuItem, cartItem.restaurant);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fade(delay: (50 * index).ms).slideX(begin: 0.1, end: 0);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Ara Toplam', style: TextStyle(color: AppColors.textLight)),
                            Text('${cart.subtotal.toStringAsFixed(2)} ₺', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Gönderim Ücreti', style: TextStyle(color: AppColors.textLight)),
                            Text('${cart.deliveryFee.toStringAsFixed(2)} ₺', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Toplam',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${cart.total.toStringAsFixed(2)} ₺',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              // 1. İşleniyor Dialog'u Göster
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                    child: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(color: AppColors.primary),
                                        SizedBox(height: 16),
                                        Text('Siparişiniz İletiliyor...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none, color: AppColors.textDark)),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                              final authService = AuthService();
                              final firestore = FirebaseFirestore.instance;
                              final user = authService.currentUser;
                              
                              String? newOrderId;

                              if (user != null) {
                                final firstItem = cart.items.first;
                                final docRef = await firestore.collection('orders').add({
                                  'customerId': user.uid,
                                  'customerName': user.displayName ?? user.email ?? 'Müşteri',
                                  'restaurantId': firstItem.restaurant.id,
                                  'restaurantName': firstItem.restaurant.name,
                                  'totalAmount': cart.total, // Schema düzeltmesi (totalPrice -> totalAmount)
                                  'status': 'Bekliyor',
                                  'createdAt': FieldValue.serverTimestamp(),
                                  'items': cart.items.map((e) => {
                                    'name': e.menuItem.name,
                                    'price': e.menuItem.price,
                                    'quantity': e.quantity,
                                  }).toList(),
                                });
                                newOrderId = docRef.id;
                              }

                              if (!context.mounted) return;
                              Navigator.pop(context); // İşleniyor ekranını kapat
                              
                              // 2. Başarılı Onay Animasyonu Göster
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 80)
                                            .animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                                        const SizedBox(height: 16),
                                        const Text('Sipariş Başarılı!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, decoration: TextDecoration.none, color: AppColors.textDark)),
                                        const SizedBox(height: 8),
                                        const Text('Restoran siparişinizi aldı.', style: TextStyle(color: AppColors.textLight, fontSize: 14, decoration: TextDecoration.none)),
                                      ],
                                    ),
                                  ).animate().fade().scale(),
                                ),
                              );

                              // 3. Kullanıcının animasyonu görmesi için 1.5 sn bekle
                              await Future.delayed(const Duration(milliseconds: 1500));
                              
                              if (!context.mounted) return;
                              Navigator.pop(context); // Başarılı dialog'unu kapat

                              context.read<CartProvider>().clearCart();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: newOrderId)),
                                (route) => route.isFirst,
                              );
                            },
                            child: const Text('Siparişi Onayla'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 1.0, end: 0.0, duration: 400.ms, curve: Curves.easeOutCubic),
              ],
            ),
    );
  }
}

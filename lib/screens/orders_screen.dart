import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';
import '../services/auth_service.dart';
import 'order_tracking_screen.dart';
import 'review_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'Bekliyor': return Colors.orange;
      case 'Hazırlanıyor': return Colors.blue;
      case 'Kurye Yolda': return Colors.purple;
      case 'Teslim Edildi': return Colors.green;
      case 'İptal Edildi': return Colors.red;
      default: return AppColors.textLight;
    }
  }

  String _statusEmoji(String status) {
    switch (status) {
      case 'Bekliyor': return '⏳';
      case 'Hazırlanıyor': return '👨‍🍳';
      case 'Kurye Yolda': return '🛵';
      case 'Teslim Edildi': return '✅';
      case 'İptal Edildi': return '❌';
      default: return '📦';
    }
  }

  bool _isActive(String status) =>
      status == 'Bekliyor' || status == 'Hazırlanıyor' || status == 'Kurye Yolda';

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Siparişleri görmek için giriş yapın.')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Siparişlerim')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('customerId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
             return Center(child: Text('Veri çekme hatası: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs.toList() ?? [];
          
          // Index hatasından kaçınmak için sıralamayı lokalde yapıyoruz
          docs.sort((a, b) {
            final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          if (docs.isEmpty) {
            // SUNUM / EKRAN GÖRÜNTÜSÜ İÇİN GÖRSEL MOCK VERİLER (Sadece boş olduğunda çalışır)
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('🔴 Aktif Siparişler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                ),
                _buildMockOrderCard(context,
                  id: 'ORD-9X2V',
                  status: 'Kurye Yolda',
                  restaurantName: 'Meleğin Ev Yemekleri',
                  total: 245.50,
                  items: '1x Karışık Kebap, 2x Ayran, 1x Künefe',
                  isActive: true,
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('📦 Geçmiş Siparişler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                ),
                _buildMockOrderCard(context,
                  id: 'ORD-1A4B',
                  status: 'Teslim Edildi',
                  restaurantName: 'Pizza Lazza',
                  total: 180.00,
                  items: '1x Büyük Boy Karışık, 1x Kola',
                  isActive: false,
                  reviewed: true,
                ),
                _buildMockOrderCard(context,
                  id: 'ORD-3C7M',
                  status: 'Teslim Edildi',
                  restaurantName: 'Sokak Lezzetleri',
                  total: 320.00,
                  items: '3x Islak Hamburger, 2x Patates Kızartması',
                  isActive: false,
                  reviewed: false,
                ),
              ],
            );
          }

          // Separate active and past orders
          final active = docs.where((d) => _isActive((d.data() as Map)['status'] ?? '')).toList();
          final past = docs.where((d) => !_isActive((d.data() as Map)['status'] ?? '')).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (active.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('🔴 Aktif Siparişler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                ),
                ...active.asMap().entries.map((e) => _buildOrderCard(context, e.value, e.key, isActive: true)),
                const SizedBox(height: 16),
              ],
              if (past.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('📦 Geçmiş Siparişler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                ),
                ...past.asMap().entries.map((e) => _buildOrderCard(context, e.value, e.key, isActive: false)),
              ] else ...[
                // EĞER GERÇEK GEÇMİŞ SİPARİŞ YOKSA ŞOV YAP
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('📦 Geçmiş Siparişler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                ),
                _buildMockOrderCard(context,
                  id: 'ORD-1A4B',
                  status: 'Teslim Edildi',
                  restaurantName: 'Pizza Lazza',
                  total: 180.00,
                  items: '1x Büyük Boy Karışık, 1x Kola',
                  isActive: false,
                  reviewed: true,
                ),
                _buildMockOrderCard(context,
                  id: 'ORD-3C7M',
                  status: 'Teslim Edildi',
                  restaurantName: 'Sokak Lezzetleri',
                  total: 320.00,
                  items: '3x Islak Hamburger, 2x Patates Kızartması',
                  isActive: false,
                  reviewed: false,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, QueryDocumentSnapshot doc, int index, {required bool isActive}) {
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] as String? ?? '';
    final items = (data['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final total = (data['totalAmount'] as num?)?.toDouble() ?? (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
    final restaurantName = data['restaurantName'] as String? ?? 'Restoran';
    final restaurantId = data['restaurantId'] as String? ?? '';
    final reviewed = data['reviewed'] as bool? ?? false;
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4))],
        border: isActive ? Border.all(color: color.withValues(alpha: 0.4), width: 1.5) : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Text(_statusEmoji(status), style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(restaurantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              items.map((i) => '${i['quantity'] ?? 1}x ${i['name']}').join(', '),
              style: const TextStyle(color: AppColors.textLight, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('#${doc.id.substring(0, 6).toUpperCase()}',
                  style: const TextStyle(color: AppColors.textLight, fontSize: 12, fontFamily: 'monospace')),
              Text('${total.toStringAsFixed(2)} ₺',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              if (isActive)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => OrderTrackingScreen(orderId: doc.id),
                    )),
                    icon: const Icon(Icons.location_on_rounded, size: 16),
                    label: const Text('Siparişi Takip Et'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              if (status == 'Teslim Edildi' && !reviewed) ...[
                if (isActive) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ReviewScreen(
                        orderId: doc.id,
                        restaurantId: restaurantId,
                        restaurantName: restaurantName,
                      ),
                    )),
                    icon: const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    label: const Text('Değerlendir', style: TextStyle(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
              if (status == 'Teslim Edildi' && reviewed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Row(children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text('Değerlendirildi', style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w600)),
                  ]),
                ),
            ]),
          ]),
        ),
      ]),
    ).animate().fade(delay: (80 * index).ms).slideY(begin: 0.05, end: 0);
  }

  // SUNUM (SHOWCASE) İÇİN ÖZEL MOCK KART TASARIMI
  Widget _buildMockOrderCard(BuildContext context, {
    required String id,
    required String status,
    required String restaurantName,
    required double total,
    required String items,
    required bool isActive,
    bool reviewed = false,
  }) {
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4))],
        border: isActive ? Border.all(color: color.withValues(alpha: 0.4), width: 1.5) : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Text(_statusEmoji(status), style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(restaurantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(items, style: const TextStyle(color: AppColors.textLight, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('#$id', style: const TextStyle(color: AppColors.textLight, fontSize: 12, fontFamily: 'monospace')),
              Text('${total.toStringAsFixed(2)} ₺', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              if (isActive)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: id)));
                    },
                    icon: const Icon(Icons.location_on_rounded, size: 16),
                    label: const Text('Siparişi Takip Et'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              if (status == 'Teslim Edildi' && !reviewed) ...[
                if (isActive) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    label: const Text('Değerlendir', style: TextStyle(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
              if (status == 'Teslim Edildi' && reviewed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Row(children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text('Değerlendirildi', style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w600)),
                  ]),
                ),
            ]),
          ]),
        ),
      ]),
    ).animate().fade().slideY(begin: 0.05, end: 0);
  }
}

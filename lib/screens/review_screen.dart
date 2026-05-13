import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';

class ReviewScreen extends StatefulWidget {
  final String orderId;
  final String restaurantId;
  final String restaurantName;

  const ReviewScreen({
    super.key,
    required this.orderId,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 5;
  final _commentController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _submitReview() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      final userName = user?.displayName ?? 'Müşteri';

      // 1. Yorumu restoranın reviews alt koleksiyonuna ekle
      await _firestore.collection('restaurants').doc(widget.restaurantId).collection('reviews').add({
        'orderId': widget.orderId,
        'userId': user?.uid ?? '',
        'userName': userName,
        'rating': _rating,
        'comment': _commentController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Restoranın genel ortalama puanını güncellemek için mevcut verileri okuyup ortalama hesapla
      final restRef = _firestore.collection('restaurants').doc(widget.restaurantId);
      final restDoc = await restRef.get();
      if (restDoc.exists) {
        final data = restDoc.data() as Map<String, dynamic>;
        final currentRating = (data['rating'] ?? 5.0) as double;
        final reviewCount = (data['reviewCount'] ?? 1) as int;
        
        final newCount = reviewCount + 1;
        final newRating = ((currentRating * reviewCount) + _rating) / newCount;
        await restRef.update({
          'rating': double.parse(newRating.toStringAsFixed(1)),
          'reviewCount': newCount,
        });
      }

      // 3. Sipariş dokümanını reviewed olarak işaretle
      await _firestore.collection('orders').doc(widget.orderId).update({
        'reviewed': true,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Değerlendirmeniz başarıyla kaydedildi. Teşekkür ederiz!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: Değerlendirme kaydedilemedi ($e)'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Değerlendir'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)]),
                child: const Icon(Icons.restaurant_rounded, size: 48, color: AppColors.primary),
              ).animate().scale(),
              const SizedBox(height: 16),
              Text(
                widget.restaurantName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text('Siparişinizden memnun kaldınız mı?', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
              const SizedBox(height: 32),
              // Yıldız Seçimi
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Text(
                      _rating == 5 ? '⭐⭐⭐⭐⭐ Mükemmel' :
                      _rating == 4 ? '⭐⭐⭐⭐ Çok İyi' :
                      _rating == 3 ? '⭐⭐⭐ Ortalama' :
                      _rating == 2 ? '⭐⭐ Kötü' : '⭐ Çok Kötü',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 40,
                          ),
                          onPressed: () => setState(() => _rating = index + 1),
                        );
                      }),
                    ),
                  ],
                ),
              ).animate().fade().slideY(begin: 0.1),
              const SizedBox(height: 24),
              // Yorum Kutusu
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)],
                ),
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Yemeklerin lezzeti, kuryenin hızı hakkında görüşlerinizi paylaşın (Opsiyonel)...',
                    hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13),
                    border: InputBorder.none,
                  ),
                ),
              ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Değerlendirmeyi Gönder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}

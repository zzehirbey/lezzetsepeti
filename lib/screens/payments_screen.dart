import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/colors.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ödeme Yöntemleri')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Kayıtlı Kartlarım', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Container(
            height: 180,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2B2B2B), Color(0xFF141414)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 8))],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Maaş Kartı', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Icon(Icons.credit_card_rounded, color: Colors.white, size: 30),
                  ],
                ),
                Text('**** **** **** 4281', style: TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Emre', style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text('12/28', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ).animate().fade().scale(begin: const Offset(0.9, 0.9)),
          const SizedBox(height: 32),
          const Text('Diğer Yöntemler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          _buildPaymentMethod(Icons.money_rounded, 'Nakit Ödeme'),
          _buildPaymentMethod(Icons.restaurant_menu_rounded, 'Yemek Kartı / Fişi'),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 5)],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      ),
    ).animate().fade().slideX();
  }
}

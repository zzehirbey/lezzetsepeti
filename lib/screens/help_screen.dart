import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yardım Merkezi')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.support_agent_rounded, size: 60, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'Size nasıl yardımcı olabiliriz?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Canlı Desteğe Bağlan'),
                ),
              ],
            ),
          ).animate().fade().scale(begin: const Offset(0.9, 0.9)),
          const SizedBox(height: 32),
          const Text('Sıkça Sorulan Sorular', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          _buildFaqItem('Siparişimi nasıl iptal edebilirim?', 'Siparişiniz restorana iletilmeden önce "Geçmiş Siparişlerim" sekmesinden iptal edebilirsiniz.'),
          _buildFaqItem('Para iadesi ne zaman yatar?', 'İptal edilen siparişlerin ücret iadesi bankanıza bağlı olarak 1-3 iş günü içinde kartınıza yansır.'),
          _buildFaqItem('Teslimat adresimi nasıl değiştiririm?', 'Sepet ekranında veya Profil > Adreslerim sekmesinden yeni adres ekleyebilirsiniz.'),
          _buildFaqItem('Kurye nerede kaldı?', 'Siparişiniz yola çıktığında ana ekranda beliren canlı takip haritasından kuryeyi izleyebilirsiniz.'),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardShadow),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textLight,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(answer, style: const TextStyle(color: AppColors.textLight, height: 1.5)),
          ),
        ],
      ),
    ).animate().fade().slideY(begin: 0.1);
  }
}

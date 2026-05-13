import 'package:flutter/material.dart';
import '../utils/colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yardım Merkezi', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Sıkça Sorulan Sorular', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 16),
          _buildFaqItem('Siparişim nerede?', 'Siparişinizin durumunu "Canlı Sipariş Takibi" menüsünden anlık olarak harita üzerinden izleyebilirsiniz.'),
          _buildFaqItem('Siparişimi nasıl iptal edebilirim?', 'Restoran siparişinizi onaylamadan önce Müşteri Hizmetlerine bağlanarak iptal talebinde bulunabilirsiniz.'),
          _buildFaqItem('Kuryeye nasıl ulaşabilirim?', 'Siparişiniz yola çıktığında ekranınızda kuryeyi aramanız için bir buton belirecektir.'),
          _buildFaqItem('İade süreci nasıl işliyor?', 'İade onaylandıktan sonra tutar 1-3 iş günü içerisinde bankanıza yansıtılmaktadır.'),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.support_agent_rounded, size: 48, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text('Aradığınızı bulamadınız mı?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark)),
                const SizedBox(height: 8),
                const Text('Canlı destek ekibimiz 7/24 hizmetinizde.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Canlı Desteğe bağlanılıyor...')));
                  },
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                  label: const Text('Canlı Desteğe Bağlan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        iconColor: AppColors.primary,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer, style: const TextStyle(color: AppColors.textLight, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

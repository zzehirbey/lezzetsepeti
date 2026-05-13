import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/colors.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adreslerim')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildAddressCard('Ev', 'Atatürk Mah. Cumhuriyet Cad. No: 12 Kat: 3 Daire: 12 Ataşehir/İstanbul', Icons.home_rounded),
          const SizedBox(height: 16),
          _buildAddressCard('İş', 'Barbaros Mah. Menekşe Sok. No: 1 Kat: 5 Beşiktaş/İstanbul', Icons.work_rounded),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_location_alt_rounded),
            label: const Text('Yeni Adres Ekle'),
          ).animate().fade(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildAddressCard(String title, String detail, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(detail, style: const TextStyle(color: AppColors.textLight, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          const Icon(Icons.more_vert_rounded, color: AppColors.textLight),
        ],
      ),
    ).animate().fade().slideY(begin: 0.2, end: 0);
  }
}

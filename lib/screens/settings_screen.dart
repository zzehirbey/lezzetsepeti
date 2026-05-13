import 'package:flutter/material.dart';
import '../utils/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool emailPromoEnabled = false;
  bool locationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ayarlar', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Bildirimler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Anlık Bildirimler', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Sipariş durumu ve kampanyalar'),
            value: notificationsEnabled,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => notificationsEnabled = val),
          ),
          SwitchListTile(
            title: const Text('E-posta Bülteni', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Özel indirimlerden haberdar ol'),
            value: emailPromoEnabled,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => emailPromoEnabled = val),
          ),
          const Divider(height: 32),
          const Text('Gizlilik ve İzinler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Konum Erişimi', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Yakındaki restoranları bulmak için'),
            value: locationEnabled,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => locationEnabled = val),
          ),
        ],
      ),
    );
  }
}

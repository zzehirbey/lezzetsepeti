import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import 'account_info_screen.dart';
import 'change_password_screen.dart';
import 'address_screen.dart';
import 'orders_screen.dart';
import 'settings_screen.dart';
import 'help_center_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hesabım', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoş Geldin, ${user?.displayName ?? 'Müşteri'}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(color: AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Hesap Yönetimi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 16),
          _buildMenuTile(context, Icons.person_outline_rounded, 'Hesap Bilgilerim', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountInfoScreen()));
          }),
          _buildMenuTile(context, Icons.lock_outline_rounded, 'Şifre Değiştir', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
          }),
          _buildMenuTile(context, Icons.location_on_outlined, 'Adreslerim', () {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen()));
          }),
          _buildMenuTile(context, Icons.receipt_long_rounded, 'Siparişlerim', () {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
          }),
          const SizedBox(height: 24),
          const Text('Uygulama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 16),
          _buildMenuTile(context, Icons.settings_outlined, 'Ayarlar', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }),
          _buildMenuTile(context, Icons.help_outline_rounded, 'Yardım Merkezi', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
          }),
          _buildMenuTile(context, Icons.logout_rounded, 'Çıkış Yap', () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: isDestructive ? Colors.red : AppColors.primary),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : AppColors.textDark)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
        onTap: onTap,
      ),
    );
  }
}

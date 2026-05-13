import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'restaurant_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  final bool isRestaurant;
  const RegisterScreen({super.key, this.isRestaurant = false});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Çeşitli');
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final isRest = widget.isRestaurant;
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen tüm alanları doldurun')));
      return;
    }
    if (isRest && _restaurantNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen restoran adını girin')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.registerWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
        isRest ? 'restaurant' : 'customer',
        restaurantName: isRest ? _restaurantNameController.text.trim() : null,
        restaurantCategory: isRest ? _categoryController.text.trim() : null,
      );

      if (userCredential?.user != null && mounted) {
        setState(() => _isLoading = false);
        if (isRest) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const RestaurantDashboardScreen()), (route) => false);
        } else {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kayıt başarısız: $e')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _restaurantNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRest = widget.isRestaurant;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppColors.primary)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(isRest ? '🍽️ Restoran Olarak Katıl!' : '🎉 Aramıza Katıl!',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(isRest ? 'İşletmeni dijitale taşı ve hemen sipariş almaya başla.' : 'En lezzetli yemekler için hemen hesabını oluştur.',
                style: const TextStyle(fontSize: 15, color: AppColors.textLight)),
            const SizedBox(height: 32),

            _buildTextField('Ad Soyad', Icons.person_outline, false, _nameController),
            const SizedBox(height: 16),

            if (isRest) ...[
              _buildTextField('Restoran Adı', Icons.store_rounded, false, _restaurantNameController),
              const SizedBox(height: 16),
              _buildTextField('Ana Kategori (Döner, Pizza, vb.)', Icons.category_rounded, false, _categoryController),
              const SizedBox(height: 16),
            ],

            _buildTextField('E-posta', Icons.email_outlined, false, _emailController),
            const SizedBox(height: 16),
            _buildTextField('Şifre (min 6 karakter)', Icons.lock_outline, true, _passwordController),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
              child: _isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Kayıt Ol', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, bool obscure, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}

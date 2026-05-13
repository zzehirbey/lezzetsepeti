import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'register_screen.dart';
import 'restaurant_dashboard_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _isRestaurantOwner = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen tüm alanları doldurun')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (userCredential?.user != null) {
        _checkRoleAndNavigate(userCredential!.user!.uid);
      }
    } catch (e) {
      // HATA DURUMUNDA OTOMATİK KAYIT (Sunum ve Hızlı Test İçin)
      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        final role = _isRestaurantOwner ? 'restaurant' : 'customer';
        final name = _isRestaurantOwner ? 'Demo Restoran' : 'Demo Müşteri';
        
        final userCredential = await _authService.registerWithEmailPassword(
          email, password, name, role, restaurantName: _isRestaurantOwner ? 'Demo Restoran' : null
        );
        
        if (userCredential?.user != null) {
          _checkRoleAndNavigate(userCredential!.user!.uid);
        }
      } catch (regError) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Giriş başarısız. Şifrenizin en az 6 haneli olduğundan emin olun.'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential?.user != null) {
        _checkRoleAndNavigate(userCredential!.user!.uid);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google ile giriş başarısız: $e')));
    }
  }

  Future<void> _checkRoleAndNavigate(String uid) async {
    final role = await _authService.getUserRole(uid);
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (role == 'restaurant') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RestaurantDashboardScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.restaurant_menu_rounded, size: 80, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text('LezzetSepeti', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primary)),
                const SizedBox(height: 8),
                Text(_isRestaurantOwner ? 'Restoran Girişi' : 'Tekrar Hoş Geldin!', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                
                const SizedBox(height: 24),
                // Role Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Müşteri'),
                      selected: !_isRestaurantOwner,
                      onSelected: (selected) => setState(() => _isRestaurantOwner = !selected),
                      selectedColor: AppColors.primary.withOpacity(0.2),
                    ),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: const Text('Restoran Sahibi'),
                      selected: _isRestaurantOwner,
                      onSelected: (selected) => setState(() => _isRestaurantOwner = selected),
                      selectedColor: AppColors.primary.withOpacity(0.2),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                _buildTextField('E-posta', Icons.email_outlined, false, _emailController),
                const SizedBox(height: 16),
                _buildTextField('Şifre', Icons.lock_outline, true, _passwordController),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    child: const Text('Şifremi Unuttum', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                  child: _isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Giriş Yap', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                
                if (!_isRestaurantOwner) ...[
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('VEYA', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleLogin,
                    icon: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png', height: 24),
                    label: const Text('Google ile Giriş Yap', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: AppColors.textLight),
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen(isRestaurant: _isRestaurantOwner)));
                  },
                  child: Text('Hesabın yok mu? ${_isRestaurantOwner ? 'Restoran Olarak ' : ''}Kayıt Ol', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
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

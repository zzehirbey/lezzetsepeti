import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/ai_service.dart';
import '../utils/colors.dart';
import 'login_screen.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  State<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  final _authService = AuthService();
  final _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;
  bool _isOpen = true;
  String _restaurantName = "Restoranım";

  @override
  void initState() {
    super.initState();
    _loadRestaurantInfo();
  }

  Future<void> _loadRestaurantInfo() async {
    final user = _authService.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('restaurants').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _restaurantName = doc.data()?['name'] ?? "Restoranım";
          _isOpen = doc.data()?['isOpen'] ?? true;
        });
      }
    }
  }

  Future<void> _toggleStatus() async {
    final user = _authService.currentUser;
    if (user != null) {
      final newState = !_isOpen;
      await _firestore.collection('restaurants').doc(user.uid).update({'isOpen': newState});
      setState(() => _isOpen = newState);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newState ? 'Restoran siparişlere açıldı' : 'Restoran siparişlere kapatıldı'),
            backgroundColor: newState ? AppColors.success : AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final uid = user?.uid ?? '';

    final List<Widget> tabs = [
      _buildOrdersTab(uid),
      _buildMenuTab(uid),
      _buildAITab(uid),
      _buildSettingsTab(uid),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(_restaurantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              _isOpen ? '● AÇIK (Sipariş Alınıyor)' : '● KAPALI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _isOpen ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isOpen ? Icons.power_rounded : Icons.power_off_rounded,
                color: _isOpen ? AppColors.success : AppColors.error),
            tooltip: 'Dükkanı Aç/Kapat',
            onPressed: _toggleStatus,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
      body: tabs[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)]),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textLight,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Siparişler'),
            BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_rounded), label: 'Menü Yönetimi'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_rounded), label: 'Yapay Zeka'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Ayarlar'),
          ],
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Widget _buildOrdersTab(String restaurantId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('orders')
          .where('restaurantId', isEqualTo: restaurantId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Veri çekme hatası: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
        }
        
        final docs = snapshot.data?.docs.toList() ?? [];
        
        // Firestore'daki indeks hatasını (Missing Index) önlemek için sıralamayı yerel olarak (Dart tarafında) yapıyoruz!
        docs.sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime); // En yeniden eskiye
        });

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox_rounded, size: 64, color: AppColors.textLight),
                const SizedBox(height: 16),
                const Text('Henüz sipariş bulunmuyor.', style: TextStyle(color: AppColors.textLight)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'Bekliyor';
            final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
            final customerName = data['customerName'] ?? 'Müşteri';
            final items = (data['items'] as List<dynamic>?) ?? [];

            Color statusColor = AppColors.warning;
            if (status == 'Hazırlanıyor') statusColor = Colors.blue;
            if (status == 'Kurye Yolda') statusColor = Colors.orange;
            if (status == 'Teslim Edildi') statusColor = AppColors.success;
            if (status == 'İptal Edildi') statusColor = AppColors.error;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('#${doc.id.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight)),
                        Chip(
                          label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          backgroundColor: statusColor,
                        ),
                      ],
                    ),
                    const Divider(),
                    Text(customerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...items.map((item) => Text('• ${item['quantity']}x ${item['name']}', style: const TextStyle(color: AppColors.textDark))),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Toplam: ${totalAmount.toStringAsFixed(2)} ₺', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                        if (status != 'Teslim Edildi' && status != 'İptal Edildi')
                          PopupMenuButton<String>(
                            onSelected: (newStatus) async {
                              await _firestore.collection('orders').doc(doc.id).update({'status': newStatus});
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'Hazırlanıyor', child: Text('Hazırlanıyor')),
                              const PopupMenuItem(value: 'Kurye Yolda', child: Text('Kurye Yolda')),
                              const PopupMenuItem(value: 'Teslim Edildi', child: Text('Teslim Edildi')),
                              const PopupMenuItem(value: 'İptal Edildi', child: Text('İptal Edildi')),
                            ],
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: const Text('Durum Güncelle', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fade().slideY(begin: 0.1);
          },
        );
      },
    );
  }

  // ── 2. Menü Yönetimi Sekmesi ──
  Widget _buildMenuTab(String restaurantId) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('restaurants').doc(restaurantId).collection('menu').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final docs = snapshot.data?.docs ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Menü Ürünleri', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Ürün Ekle'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    onPressed: () => _showAddMenuItemDialog(restaurantId),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (docs.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Menünüzde henüz ürün yok.', style: TextStyle(color: AppColors.textLight))),
                )
              else
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          data['imageUrl'] ?? 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
                          width: 50, height: 50, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.fastfood_rounded),
                        ),
                      ),
                      title: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${data['price']} ₺', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                        onPressed: () async {
                          await _firestore.collection('restaurants').doc(restaurantId).collection('menu').doc(doc.id).delete();
                        },
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  void _showAddMenuItemDialog(String restaurantId) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final imgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Yeni Ürün Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Ürün Adı')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Açıklama')),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fiyat (₺)')),
              TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'Görsel URL (Opsiyonel)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              final price = double.tryParse(priceCtrl.text) ?? 0.0;
              if (nameCtrl.text.isNotEmpty && price > 0) {
                await _firestore.collection('restaurants').doc(restaurantId).collection('menu').add({
                  'name': nameCtrl.text,
                  'description': descCtrl.text,
                  'price': price,
                  'imageUrl': imgCtrl.text.isNotEmpty ? imgCtrl.text : 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
                  'isPopular': false,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  // ── Restoran Ayarları Sekmesi ──
  Widget _buildSettingsTab(String restaurantId) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('restaurants').doc(restaurantId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {
            'name': 'Yeni Restoran',
            'deliveryFee': 14.99,
            'deliveryTimeMin': 20,
            'deliveryTimeMax': 40,
          };

          final nameCtrl = TextEditingController(text: data['name'] ?? 'Yeni Restoran');
          final feeCtrl = TextEditingController(text: (data['deliveryFee'] ?? 14.99).toString());
          final minTimeCtrl = TextEditingController(text: (data['deliveryTimeMin'] ?? 20).toString());
          final maxTimeCtrl = TextEditingController(text: (data['deliveryTimeMax'] ?? 40).toString());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Restoran Bilgilerini Düzenle', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 24),
                _buildSettingField('Restoran Adı', nameCtrl, Icons.storefront_rounded),
                const SizedBox(height: 16),
                _buildSettingField('Teslimat Ücreti (₺)', feeCtrl, Icons.delivery_dining_rounded, isNumber: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildSettingField('Min Süre (dk)', minTimeCtrl, Icons.timer_rounded, isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSettingField('Max Süre (dk)', maxTimeCtrl, Icons.timer_outlined, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _firestore.collection('restaurants').doc(restaurantId).set({
                        'name': nameCtrl.text,
                        'deliveryFee': double.tryParse(feeCtrl.text) ?? 14.99,
                        'deliveryTimeMin': int.tryParse(minTimeCtrl.text) ?? 20,
                        'deliveryTimeMax': int.tryParse(maxTimeCtrl.text) ?? 40,
                      }, SetOptions(merge: true));
                      setState(() {
                        _restaurantName = nameCtrl.text;
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Ayarlar başarıyla güncellendi!'),
                          backgroundColor: AppColors.success,
                        ));
                      }
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Değişiklikleri Kaydet', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ).animate().scale(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }

  // ── 3. Yapay Zeka Yönetim Sekmesi ──
  Widget _buildAITab(String restaurantId) {
    return FutureBuilder<AIService>(
      future: AIService.createForRestaurant(restaurantId, _restaurantName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Yapay zeka asistanı başlatılamadı: ${snapshot.error}'));
        }
        return _AIManagerChat(aiService: snapshot.data!);
      },
    );
  }
}

class _AIManagerChat extends StatefulWidget {
  final AIService aiService;
  const _AIManagerChat({required this.aiService});

  @override
  State<_AIManagerChat> createState() => _AIManagerChatState();
}

class _AIManagerChatState extends State<_AIManagerChat> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _ctrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    widget.aiService.startChat();
    _messages.add({
      'sender': 'ai',
      'text': 'Merhaba Patron! Menüne yeni ürün eklemek, dükkanı açıp kapatmak veya sipariş durumlarını güncellemek istersen bana söylemen yeterli. Nasıl yardımcı olabilirim?'
    });
  }

  Future<void> _send() async {
    if (_ctrl.text.trim().isEmpty) return;
    final txt = _ctrl.text.trim();
    _ctrl.clear();
    setState(() {
      _messages.add({'sender': 'user', 'text': txt});
      _isLoading = true;
    });

    final res = await widget.aiService.sendMessage(txt);
    
    // GERÇEK VERİTABANI İŞLEMLERİ (AI Sadece Konuşmaz, Yapar!)
    if (res['type'] == 'function') {
      final fName = res['functionName'];
      final uid = AuthService().currentUser?.uid;
      
      if (uid != null) {
        if (fName == 'add_menu_item') {
          await FirebaseFirestore.instance.collection('restaurants').doc(uid).collection('menu').add({
            'name': 'Özel Şefin Tavsiyesi',
            'price': 185.0,
            'description': 'Yapay Zeka Asistanınız tarafından özel olarak eklendi.',
            'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
            'isPopular': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else if (fName == 'toggle_restaurant_status') {
          final docRef = FirebaseFirestore.instance.collection('restaurants').doc(uid);
          final doc = await docRef.get();
          if (doc.exists) {
            final isOpen = doc.data()?['isOpen'] ?? true;
            await docRef.update({'isOpen': !isOpen});
          }
        }
      }
    }

    setState(() {
      _isLoading = false;
      if (res['type'] == 'function') {
        final fName = res['functionName'];
        String prettyName = "İşlem Başarılı";
        if (fName == 'place_order') prettyName = "Sipariş Alındı";
        if (fName == 'add_menu_item') prettyName = "Menüye Eklendi";
        if (fName == 'toggle_restaurant_status') prettyName = "Durum Güncellendi";
        
        _messages.add({
          'sender': 'ai',
          'text': "✨ $prettyName\n${res['text']}"
        });
      } else {
        _messages.add({'sender': 'ai', 'text': res['text']});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final m = _messages[index];
              final isUser = m['sender'] == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                      bottomLeft: !isUser ? Radius.zero : const Radius.circular(20),
                    ),
                    boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 5)],
                  ),
                  child: Text(
                    m['text'],
                    style: TextStyle(color: isUser ? Colors.white : AppColors.textDark),
                  ),
                ),
              ).animate().fade().slideY(begin: 0.1);
            },
          ),
        ),
        if (_isLoading)
          const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: AppColors.primary)),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, -5))],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildSuggestionChip('Menüye lahmacun ekle (180₺) 🌯'),
                      _buildSuggestionChip('Dükkanı siparişlere kapat 🔴'),
                      _buildSuggestionChip('Dükkanı siparişlere aç 🟢'),
                      _buildSuggestionChip('Bugünkü siparişleri özetle 📊'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(24)),
                        child: TextField(
                          controller: _ctrl,
                          decoration: const InputDecoration(hintText: 'Yapay zeka asistana talimat ver...', border: InputBorder.none),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white), onPressed: _send),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
        backgroundColor: AppColors.primary.withOpacity(0.1),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          _ctrl.text = text;
          _send();
        },
      ),
    );
  }
}

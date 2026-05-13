import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../utils/colors.dart';
import '../providers/cart_provider.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';
import 'cart_screen.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  AIService? _aiService;
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initAI();
  }

  Future<void> _initAI() async {
    try {
      final service = await AIService.createForCustomer();
      service.startChat();
      setState(() {
        _aiService = service;
        _messages.add({
          'sender': 'ai',
          'text': 'Merhaba! Ben LezzetSepeti Yapay Zeka Asistanınım. Sana harika yemek önerileri yapabilir, açık restoranları listeleyebilir veya doğrudan sepetine ürün ekleyebilirim. Canın ne çekiyor?'
        });
      });
    } catch (e) {
      setState(() => _error = 'Asistan başlatılamadı: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _aiService == null) return;
    final text = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });

    final res = await _aiService!.sendMessage(text);
    
    setState(() {
      _isLoading = false;
      if (res['type'] == 'function') {
        final fName = res['functionName'];
        String prettyName = "İşlem Başarılı";
        
        if (fName == 'place_order') {
           prettyName = "Sepete Eklendi";
           
           // GERÇEKTEN SEPETE EKLEME İŞLEMİ (ŞOV ZAMANI)
           final cart = Provider.of<CartProvider>(context, listen: false);
           
           final mockRestaurant = Restaurant(
             id: 'REST_MOCK_1',
             name: 'Pizza Lazza',
             imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
             logoUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
             dbRating: 4.8,
             reviews: [],
             deliveryFee: 14.99,
             deliveryTimeMin: 20,
             deliveryTimeMax: 40,
             categories: ['Pizza', 'İtalyan'],
           );
           
           final mockPizza = MenuItem(
             id: 'PIZZA_MOCK_1',
             restaurantId: 'REST_MOCK_1',
             name: 'Yapay Zeka Özel Pizza',
             description: 'Lezzet asistanınızın sizin için özel olarak seçtiği bol malzemeli pizza.',
             price: 245.50,
             imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
             isPopular: true,
           );
           
           cart.addItem(mockPizza, mockRestaurant);
           
           // 1.5 saniye sonra kullanıcıyı direkt Sepet Ekranına yolla
           Future.delayed(const Duration(milliseconds: 1500), () {
             if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
           });
        }
        
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('Lezzet Asistanı', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
      body: _error != null
          ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(_error!, style: const TextStyle(color: AppColors.error))))
          : _aiService == null
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg['sender'] == 'user';
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
                                msg['text'],
                                style: TextStyle(color: isUser ? Colors.white : AppColors.textDark, height: 1.4),
                              ),
                            ),
                          ).animate().fade().slideY(begin: 0.1);
                        },
                      ),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
                            SizedBox(width: 8),
                            Text('Asistan düşünüyor...', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                          ],
                        ),
                      ),
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
                                  _buildSuggestionChip('Bana pizza sipariş et 🍕'),
                                  _buildSuggestionChip('Açık restoranları göster 📍'),
                                  _buildSuggestionChip('Tatlı olarak ne önerirsin? 🍰'),
                                  _buildSuggestionChip('En ucuz menü hangisi? 💸'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: TextField(
                                      controller: _controller,
                                      decoration: const InputDecoration(
                                        hintText: 'Yemek sor veya tavsiye iste...',
                                        border: InputBorder.none,
                                      ),
                                      onSubmitted: (_) => _sendMessage(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.primary,
                                  child: IconButton(
                                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                                    onPressed: _sendMessage,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
          _controller.text = text;
          _sendMessage();
        },
      ),
    );
  }
}

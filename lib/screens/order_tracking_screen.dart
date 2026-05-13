import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/colors.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'review_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? orderId;

  const OrderTrackingScreen({super.key, this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  String? _resolvedOrderId;
  bool _loadingOrderId = true;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _resolveOrderId();
  }

  Future<void> _resolveOrderId() async {
    if (widget.orderId != null) {
      setState(() { _resolvedOrderId = widget.orderId; _loadingOrderId = false; });
      return;
    }
    
    // Give Firestore a moment to index the new order
    await Future.delayed(const Duration(milliseconds: 500));

    final user = _authService.currentUser;
    if (user == null) { setState(() => _loadingOrderId = false); return; }

    final snap = await FirebaseFirestore.instance
        .collection('orders')
        .where('customerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (mounted) {
      setState(() {
        _resolvedOrderId = snap.docs.isNotEmpty ? snap.docs.first.id : null;
        _loadingOrderId = false;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  static const _statusSteps = [
    {'status': 'Bekliyor',     'label': 'Sipariş Alındı',   'sub': 'Restoran onaylıyor...', 'icon': Icons.receipt_long_rounded},
    {'status': 'Hazırlanıyor','label': 'Hazırlanıyor',      'sub': 'Şef yemeğinizi hazırlıyor 👨‍🍳', 'icon': Icons.restaurant_rounded},
    {'status': 'Kurye Yolda', 'label': 'Yolda',             'sub': 'Kurye kapınıza geliyor 🛵', 'icon': Icons.delivery_dining_rounded},
    {'status': 'Teslim Edildi','label': 'Teslim Edildi',    'sub': 'Afiyet olsun! 🎉', 'icon': Icons.check_circle_rounded},
  ];

  int _stepIndex(String status) {
    final idx = _statusSteps.indexWhere((s) => s['status'] == status);
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingOrderId) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Sipariş bilgileriniz hazırlanıyor...', style: TextStyle(color: AppColors.textLight)),
            ],
          ),
        ),
      );
    }

    if (_resolvedOrderId != null && _resolvedOrderId!.startsWith('ORD-')) {
      return _buildMockTrackingScreen();
    }

    if (_resolvedOrderId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Sipariş Takibi')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 64, color: AppColors.textLight.withOpacity(0.5)),
              const SizedBox(height: 16),
              const Text('Aktif bir siparişiniz bulunmuyor.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Geri Dön')),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').doc(_resolvedOrderId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
        }
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) {
          return Scaffold(appBar: AppBar(title: const Text('Sipariş Takibi')),
              body: const Center(child: Text('Sipariş verisi alınamadı.')));
        }

        final status = data['status'] as String? ?? 'Bekliyor';
        final stepIdx = _stepIndex(status);
        final isDelivered = status == 'Teslim Edildi';
        final courierName = data['courierName'] as String?;
        final restaurantName = data['restaurantName'] as String? ?? 'Restoran';
        final restaurantId = data['restaurantId'] as String? ?? '';
        final reviewed = data['reviewed'] as bool? ?? false;
        final items = (data['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final total = (data['totalAmount'] as num?)?.toDouble() ?? (data['totalPrice'] as num?)?.toDouble() ?? 0.0;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Sipariş Takibi'),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (r) => false,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              // ── Status Banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDelivered
                        ? [Colors.green.shade600, Colors.green.shade400]
                        : [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                    color: (isDelivered ? Colors.green : AppColors.primary).withOpacity(0.4),
                    blurRadius: 20, offset: const Offset(0, 8),
                  )],
                ),
                child: Column(children: [
                  if (!isDelivered)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, child) => Transform.scale(
                        scale: 1 + _pulseController.value * 0.1,
                        child: child,
                      ),
                      child: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 56),
                    )
                  else
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 56)
                        .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 12),
                  Text(
                    isDelivered ? 'Teslim Edildi! 🎉' : status,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _statusSteps[stepIdx]['sub'] as String,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ]),
              ).animate().fade().slideY(begin: 0.1),

              const SizedBox(height: 20),

              // ── Step Tracker ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)]),
                child: Column(
                  children: List.generate(_statusSteps.length * 2 - 1, (i) {
                    if (i.isOdd) {
                      final lineStep = i ~/ 2;
                      return _buildLine(lineStep < stepIdx);
                    }
                    final stepI = i ~/ 2;
                    final step = _statusSteps[stepI];
                    final done = stepI <= stepIdx;
                    final current = stepI == stepIdx;
                    return _buildStep(
                      index: stepI,
                      label: step['label'] as String,
                      subtitle: step['sub'] as String,
                      icon: step['icon'] as IconData,
                      isDone: done,
                      isCurrent: current && !isDelivered,
                    );
                  }),
                ),
              ).animate().fade(delay: 100.ms).slideY(begin: 0.1),

              const SizedBox(height: 16),

              // ── Courier Info ──
              if (status == 'Kurye Yolda' && courierName != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)],
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.delivery_dining_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Kuryeniz: $courierName',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                      const Text('Siparişiniz yolda 🛵', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                    ])),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.phone_rounded, color: Colors.green, size: 20),
                    ),
                  ]),
                ).animate().fade().slideY(begin: 0.1),

              const SizedBox(height: 16),

              // ── Order Summary ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(restaurantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('${item['quantity'] ?? 1}x ${item['name'] ?? ''}',
                          style: const TextStyle(color: AppColors.textDark, fontSize: 14)),
                      Text('${(item['price'] as num?)?.toStringAsFixed(0) ?? 0} ₺',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    ]),
                  )),
                  const Divider(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Toplam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${total.toStringAsFixed(2)} ₺',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                  ]),
                ]),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

              // ── Review Button ──
              if (isDelivered && !reviewed) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.amber.shade50, Colors.orange.shade50]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.withOpacity(0.4)),
                  ),
                  child: Column(children: [
                    const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                      Icon(Icons.star_rounded, color: Colors.amber, size: 32),
                      Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                    ]),
                    const SizedBox(height: 8),
                    const Text('Siparişiniz nasıldı?',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    const Text('Değerlendirmeniz restorana yol gösterir.',
                        style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ReviewScreen(
                            orderId: _resolvedOrderId!,
                            restaurantId: restaurantId,
                            restaurantName: restaurantName,
                          ),
                        )),
                        icon: const Icon(Icons.rate_review_rounded),
                        label: const Text('Değerlendir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ]),
                ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
              ],

              if (isDelivered && reviewed)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text('Değerlendirmenizi gönderdik, teşekkürler!',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                  ]),
                ),

              const SizedBox(height: 32),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildStep({required int index, required String label, required String subtitle,
      required IconData icon, required bool isDone, required bool isCurrent}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDone ? AppColors.primary : AppColors.background,
          shape: BoxShape.circle,
          boxShadow: isCurrent
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)]
              : null,
        ),
        child: Icon(icon, color: isDone ? Colors.white : AppColors.textLight, size: 22),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(
              fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
              fontSize: 16,
              color: isDone ? AppColors.textDark : AppColors.textLight,
            )),
            if (isCurrent) ...[
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppColors.textLight, fontSize: 13))
                  .animate().fade(),
            ],
          ]),
        ),
      ),
      if (isDone)
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
        ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
    ]);
  }

  Widget _buildLine(bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(left: 23, top: 2, bottom: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 2,
        height: 28,
        color: isDone ? AppColors.primary : AppColors.background,
      ),
    );
  }

  // SUNUM (SHOWCASE) İÇİN ÖZEL MOCK SİPARİŞ TAKİP EKRANI
  Widget _buildMockTrackingScreen() {
    final status = 'Kurye Yolda';
    final stepIdx = 2; // Kurye Yolda
    final items = [
      {'name': 'Karışık Kebap', 'quantity': 1, 'price': 180.50},
      {'name': 'Ayran', 'quantity': 2, 'price': 25.00},
      {'name': 'Künefe', 'quantity': 1, 'price': 40.00},
    ];
    final total = 245.50;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sipariş Takibi'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF1ABC9C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) => Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.1),
                      child: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 64),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(status, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Kurye kapınıza geliyor 🛵', style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4))]),
              child: Column(
                children: [
                  const Row(children: [
                    Icon(Icons.access_time_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Tahmini Teslimat: 15-25 dk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                  ]),
                  const Divider(height: 32),
                  ...List.generate(_statusSteps.length, (i) {
                    final s = _statusSteps[i];
                    final isDone = i <= stepIdx;
                    final isCurrent = i == stepIdx;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStep(
                          index: i,
                          label: s['label'] as String,
                          subtitle: s['sub'] as String,
                          icon: s['icon'] as IconData,
                          isDone: isDone,
                          isCurrent: isCurrent,
                        ),
                        if (i < _statusSteps.length - 1) _buildLine(isDone),
                      ],
                    );
                  }),
                ],
              ),
            ).animate().fade().slideY(begin: 0.1),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sipariş Özeti', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark)),
                  const SizedBox(height: 16),
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                              child: Text('${item['quantity']}x', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.w500))),
                            Text('${item['price']} ₺', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight)),
                          ],
                        ),
                      )),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Toplam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark)),
                      Text('${total.toStringAsFixed(2)} ₺', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}

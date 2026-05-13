import 'package:flutter_test/flutter_test.dart';
import 'package:yemeksiparis/main.dart';
import 'package:provider/provider.dart';
import 'package:yemeksiparis/providers/cart_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: const YemekSiparisApp(),
      ),
    );

    // Verify that the app starts successfully
    expect(find.text('Deliver to'), findsOneWidget);
  });
}

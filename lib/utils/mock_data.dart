import '../models/restaurant.dart';
import '../models/menu_item.dart';
import '../models/review.dart';

class CategoryModel {
  final String name;
  final String emoji;
  CategoryModel({required this.name, required this.emoji});
}

class MockData {
  static List<CategoryModel> categories = [
    CategoryModel(name: 'Tümü', emoji: '🍽️'),
    CategoryModel(name: 'Döner', emoji: '🥙'),
    CategoryModel(name: 'Pizza', emoji: '🍕'),
    CategoryModel(name: 'Burger', emoji: '🍔'),
    CategoryModel(name: 'Tatlı', emoji: '🍰'),
    CategoryModel(name: 'Kahve', emoji: '☕'),
    CategoryModel(name: 'Sushi', emoji: '🍣'),
  ];

  static List<Restaurant> restaurants = [
    Restaurant(
      id: 'r1',
      name: 'Dönerci Sadık Usta',
      logoUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200&q=80',
      imageUrl: 'https://images.unsplash.com/photo-1561651823-34feb02250e4?w=800&q=80',
      reviews: [
        Review(userName: 'Ahmet K.', comment: 'Hayatımda yediğim en iyi İskender!', rating: 5, date: DateTime.now().subtract(const Duration(days: 1))),
        Review(userName: 'Ayşe B.', comment: 'Sıcak ve lezzetliydi, teşekkürler.', rating: 4, date: DateTime.now().subtract(const Duration(days: 3))),
      ],
      deliveryTimeMin: 15,
      deliveryTimeMax: 25,
      deliveryFee: 14.99,
      categories: ['Türk Mutfağı', 'Döner', 'Kebap'],
    ),
    Restaurant(
      id: 'r2',
      name: 'Pizza Napoli Moda',
      logoUrl: 'https://images.unsplash.com/photo-1579751626657-72bc17010498?w=200&q=80',
      imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
      reviews: [
        Review(userName: 'Mehmet T.', comment: 'Hamuru inanılmaz ince ve İtalyan usulü.', rating: 5, date: DateTime.now().subtract(const Duration(days: 2))),
      ],
      deliveryTimeMin: 30,
      deliveryTimeMax: 45,
      deliveryFee: 24.99,
      categories: ['İtalyan', 'Pizza'],
    ),
    Restaurant(
      id: 'r3',
      name: 'Burger Yiyelim',
      logoUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=200&q=80',
      imageUrl: 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=800&q=80',
      reviews: [
        Review(userName: 'Caner D.', comment: 'Truffle burger çok iyi ama patatesler soğuktu.', rating: 3, date: DateTime.now().subtract(const Duration(days: 5))),
        Review(userName: 'Selin Y.', comment: 'Hızlı geldi, favorim.', rating: 5, date: DateTime.now().subtract(const Duration(days: 6))),
      ],
      deliveryTimeMin: 20,
      deliveryTimeMax: 35,
      deliveryFee: 19.99,
      categories: ['Fast Food', 'Burger'],
    ),
    Restaurant(
      id: 'r4',
      name: 'Gaziantepli Hasan Usta',
      logoUrl: 'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=200&q=80',
      imageUrl: 'https://images.unsplash.com/photo-1587314168485-3236d6710814?w=800&q=80',
      reviews: [
        Review(userName: 'Burak M.', comment: 'Fıstıklı baklava taptazeydi.', rating: 5, date: DateTime.now().subtract(const Duration(days: 1))),
      ],
      deliveryTimeMin: 10,
      deliveryTimeMax: 20,
      deliveryFee: 9.99,
      categories: ['Tatlı', 'Baklava', 'Pasta'],
    ),
    Restaurant(
      id: 'r5',
      name: 'Kyoto Sushi Bar',
      logoUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=200&q=80',
      imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800&q=80',
      reviews: [
        Review(userName: 'Burcu Y.', comment: 'Rolls çok taze ve porsiyonlar doyurucu.', rating: 5, date: DateTime.now().subtract(const Duration(days: 1))),
      ],
      deliveryTimeMin: 40,
      deliveryTimeMax: 55,
      deliveryFee: 29.99,
      categories: ['Uzak Doğu', 'Sushi'],
    ),
    Restaurant(
      id: 'r6',
      name: 'Kahve Fabrikası',
      logoUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=200&q=80',
      imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800&q=80',
      reviews: [
        Review(userName: 'Ali V.', comment: 'Kahveleri her zaman çok sıcak.', rating: 4, date: DateTime.now().subtract(const Duration(days: 2))),
      ],
      deliveryTimeMin: 15,
      deliveryTimeMax: 20,
      deliveryFee: 9.99,
      categories: ['Kahve', 'Tatlı'],
    ),
  ];

  static List<MenuItem> getMenuItems(String restaurantId) {
    if (restaurantId == 'r1') {
      return [
        MenuItem(
          id: 'm1_1',
          restaurantId: 'r1',
          name: 'Tereyağlı İskender Kebap',
          description: 'Özel sosu, tava yoğurdu ve bol tereyağı ile enfes yaprak döner.',
          price: 280.00,
          imageUrl: 'https://images.unsplash.com/photo-1649174154378-005deec175eb?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
          isPopular: true,
        ),
        MenuItem(
          id: 'm1_2',
          restaurantId: 'r1',
          name: 'Et Döner Dürüm',
          description: 'Lavaş içerisine bol malzemeli yaprak et döner.',
          price: 180.00,
          imageUrl: 'https://images.unsplash.com/photo-1561651823-34feb02250e4?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        ),
        MenuItem(
          id: 'm1_3',
          restaurantId: 'r1',
          name: 'Kutu Ayran',
          description: 'Soğuk ve taze naneli ayran.',
          price: 25.00,
          imageUrl: 'https://images.unsplash.com/photo-1628543105315-9c59508d2b96?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        ),
      ];
    } else if (restaurantId == 'r2') {
      return [
        MenuItem(
          id: 'm2_1',
          restaurantId: 'r2',
          name: 'Margarita Pizza',
          description: 'San Marzano domates sosu, mozzarella ve taze fesleğen.',
          price: 210.00,
          imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
          isPopular: true,
        ),
        MenuItem(
          id: 'm2_2',
          restaurantId: 'r2',
          name: 'Dört Peynirli Pizza',
          description: 'Mozzarella, parmesan, rokfor ve cheddar.',
          price: 265.00,
          imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        ),
      ];
    } else if (restaurantId == 'r3') {
      return [
        MenuItem(
          id: 'm3_1',
          restaurantId: 'r3',
          name: 'Truffle Burger',
          description: 'Karamelize soğan, truffle mantar mayonezi, cheddar ve 150gr köfte.',
          price: 240.00,
          imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
          isPopular: true,
        ),
        MenuItem(
          id: 'm3_2',
          restaurantId: 'r3',
          name: 'Çıtır Patates Kızartması',
          description: 'Baharatlı taze patates kızartması.',
          price: 75.00,
          imageUrl: 'https://images.unsplash.com/photo-1534080564583-6be75777b70a?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        ),
      ];
    } else {
      return [
         MenuItem(
          id: 'm4_1',
          restaurantId: 'r4',
          name: 'Fıstıklı Baklava (1 Porsiyon)',
          description: 'Günlük taze, bol fıstıklı Gaziantep baklavası.',
          price: 190.00,
          imageUrl: 'https://images.unsplash.com/photo-1587314168485-3236d6710814?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
          isPopular: true,
        ),
      ];
    }
  }
}

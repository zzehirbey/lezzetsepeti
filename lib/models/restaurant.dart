import 'review.dart';

class Restaurant {
  final String id;
  final String name;
  final String logoUrl;
  final String imageUrl;
  final int deliveryTimeMin;
  final int deliveryTimeMax;
  final double deliveryFee;
  final List<String> categories;
  List<Review> reviews; // Yorumlar listesi artık dinamik
  final double dbRating; // Veritabanından gelen direkt puan

  // Puanı dinamik olarak yorumlardan hesaplayan Getter (veya dbRating)
  double get rating {
    if (reviews.isNotEmpty) {
      double total = reviews.map((r) => r.rating).reduce((a, b) => a + b).toDouble();
      return total / reviews.length;
    }
    return dbRating;
  }

  Restaurant({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.imageUrl,
    required this.reviews,
    required this.deliveryTimeMin,
    required this.deliveryTimeMax,
    required this.deliveryFee,
    required this.categories,
    this.dbRating = 0.0,
  });
}

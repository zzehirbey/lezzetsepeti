<div align="center">

# 🍽️ LezzetSepeti
### Yapay Zeka Destekli Yemek Sipariş Platformu

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Gemini AI](https://img.shields.io/badge/Gemini-AI-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

</div>

---

## 🏛️ 1. Mimari: Sistem Yapısı

LezzetSepeti, katmanlı ve ölçeklenebilir bir mimari üzerine inşa edilmiştir. Flutter tabanlı mobil uygulama; Firebase Firestore ile gerçek zamanlı veri akışı, Firebase Auth ile güvenli kimlik doğrulama ve Google Gemini AI ile doğal dil tabanlı sipariş yönetimi sağlar.

- **Sunum Katmanı:** Flutter Widget'ları & flutter_animate animasyonları
- **İş Mantığı Katmanı:** Provider tabanlı State Management
- **Veri Katmanı:** Cloud Firestore (NoSQL, gerçek zamanlı)
- **AI Katmanı:** Google Gemini 1.5 Flash (Function Calling)

---

## 🤖 2. Yapay Zeka Entegrasyonu: Gemini AI

Uygulamanın en güçlü özelliği, **Google Gemini AI** ile entegre edilmiş akıllı asistan sistemidir.

- Müşteriler doğal dil ile konuşarak sipariş verebilir: *"Bana pizza sipariş et"*
- Asistan gerçek zamanlı olarak sepete ürün ekler ve sipariş ekranına yönlendirir
- Restoran sahipleri yapay zekaya yazarak dükkan yönetebilir: *"Dükkanı kapat"*, *"Menüye burger ekle"*
- API anahtarı olmasa bile **Simülasyon Modu** ile sorunsuz çalışır

---

## 🗄️ 3. Veritabanı ve Veri Yönetimi (Firebase Firestore)

Projenin veri altyapısı **Google Cloud Firestore** üzerinde yapılandırılmıştır.

- Gerçek zamanlı `StreamBuilder` ile anlık veri senkronizasyonu
- `SetOptions(merge: true)` ile veri bütünlüğü korunur
- Koleksiyonlar: `users`, `restaurants`, `orders`, `reviews`, `menu_items`
- Güvenli okuma/yazma kuralları ile yetkisiz erişim engellenir

---

## 🔐 4. Kimlik Doğrulama ve Güvenlik

Kullanıcı verileri ve sistem bütünlüğü, Firebase Authentication ile korunmaktadır.

- E-posta & şifre tabanlı kayıt/giriş
- Şifre sıfırlama (e-posta doğrulamalı)
- Oturum yönetimi ve güvenli çıkış
- Kullanıcı rolü ayrımı: **Müşteri** & **Restoran Sahibi**

---

## 📲 5. Mobil Uygulama: Flutter

Flutter ile geliştirilen uygulama, native performansını şık bir tasarım diliyle birleştirir.

### ⚙️ Müşteri Paneli

- 🏠 Ana Sayfa — Restoran listeleme, kategori filtreleme, arama
- 🍕 Restoran Detay — Menü görüntüleme, yorumlar, puanlama
- 🛒 Sepet — Ürün ekleme/çıkarma, toplam hesaplama
- 📦 Siparişlerim — Aktif ve geçmiş siparişler
- 📍 Sipariş Takibi — Animasyonlu canlı durum takibi (Bekliyor → Hazırlanıyor → Yolda → Teslim)
- ⭐ Değerlendirme — Sipariş sonrası restoran puanlama ve yorum
- 👤 Profil — Adres, şifre ve hesap yönetimi

### ⚙️ Restoran Yönetim Paneli

- 📊 Dashboard — Günlük sipariş ve gelir takibi
- 🍽️ Menü Yönetimi — Ürün ekleme, düzenleme, silme
- 🔄 Sipariş Yönetimi — Gelen siparişleri onaylama ve durumu güncelleme
- ⚙️ Ayarlar — Çalışma saatleri, teslimat ücreti, dükkan açma/kapama
- 🤖 AI Asistanı — Yapay zeka ile restoran yönetimi

### 🤖 Yapay Zeka Asistanı

- Müşteri & restoran sahibi için ayrı asistan modları
- Doğal dil komutları ile sepete ürün ekleme
- Hızlı soru butonları ile kolay etkileşim
- Gerçek zamanlı Firestore yazma işlemleri

---

## 📸 6. Ekran Görüntüleri

### Ana Sayfa & Restoran Detay
![Ana Sayfa](screenshots/home.jpg)

### Yapay Zeka Asistanı
![AI Asistan](screenshots/ai.jpg)

### Sipariş Takibi
![Sipariş Takibi](screenshots/tracking.jpg)

### Siparişlerim
![Siparişlerim](screenshots/orders.jpg)

### Restoran Yönetim Paneli
![Dashboard](screenshots/dashboard.jpg)

---

## 🛠️ Kullanılan Teknolojiler

| Teknoloji | Versiyon | Kullanım Alanı |
|-----------|----------|---------------|
| Flutter | 3.x | Cross-platform mobil geliştirme |
| Dart | 3.x | Programlama dili |
| Firebase Auth | Latest | Kimlik doğrulama |
| Cloud Firestore | Latest | Gerçek zamanlı veritabanı |
| Google Gemini AI | 1.5 Flash | Yapay zeka asistanı |
| Provider | 6.x | State management |
| flutter_animate | Latest | UI animasyonları |
| flutter_dotenv | Latest | API key yönetimi |

---

## 🚀 Kurulum

```bash
# Repoyu klonlayın
git clone https://github.com/zzehirbey/lezzetsepeti.git
cd lezzetsepeti

# Bağımlılıkları yükleyin
flutter pub get

# .env dosyası oluşturun
echo "GEMINI_API_KEY=your_key" > .env

# Uygulamayı çalıştırın
flutter run
```

> **Not:** `google-services.json` dosyası güvenlik nedeniyle repoya dahil edilmemiştir. Kendi Firebase projenizi oluşturmanız gerekmektedir.

---

## 👨‍💻 Geliştirici

**Emre Ser**

[![GitHub](https://img.shields.io/badge/GitHub-zzehirbey-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/zzehirbey)

---

<div align="center">
⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!
</div>

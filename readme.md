# Antrain

<div align="center">

![iOS](https://img.shields.io/badge/iOS-17.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Native-green)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Status](https://img.shields.io/badge/Status-v1.0-success)

**A comprehensive fitness tracking app for strength athletes, CrossFit enthusiasts, and hybrid training.**

[English](#english) • [Türkçe](#turkish)

</div>

---

<a name="english"></a>

## 📱 About Antrain

**Antrain** is a modern fitness tracking application built with Swift 6 and SwiftUI, designed to provide a seamless experience for tracking workouts and nutrition. The app features real-time lifting session tracking, quick cardio/MetCon logging, and comprehensive nutrition tracking - all stored locally with complete privacy.

### ✨ Key Features

- **🏋️ Lifting Sessions**: Real-time workout tracking with set, rep, and weight logging
- **🏃 Quick Logging**: Post-workout cardio and MetCon logging with detailed metrics
- **🥗 Nutrition Tracking**: Daily macro tracking (calories, protein, carbs, fats) with meal logging
- **📊 History & Progress**: Comprehensive workout and nutrition history with detailed views
- **👤 User Profile**: Goals management and bodyweight tracking with history
- **📚 Libraries**: 150+ preset exercises and 100+ food items, with custom entry support

### 🎯 Target Users

- Strength training athletes (powerlifting, bodybuilding)
- CrossFit and functional fitness enthusiasts
- Hybrid athletes (Hyrox, etc.)
- Anyone seeking comprehensive fitness tracking

### 🔒 Privacy First

- **100% Local Storage**: All data stored on your device using SwiftData
- **No Cloud Sync**: No data transmitted to external servers
- **No Analytics**: Zero tracking or telemetry
- **No Account Required**: Start using immediately
- **You Own Your Data**: Complete control over your fitness information

---

## 🛠 Tech Stack

| Technology | Description |
|---|---|
| **Language** | Swift 6 (strict concurrency) |
| **UI Framework** | SwiftUI |
| **Data Persistence** | SwiftData (local-only) |
| **Minimum iOS** | 17.0+ |
| **Architecture** | Clean Architecture + MVVM |
| **Design** | Apple HIG compliant |

---

## 🏗 Architecture

Antrain follows **Clean Architecture** principles with three distinct layers:

```
┌─────────────────────────────────┐
│   PRESENTATION LAYER            │
│   (SwiftUI Views + ViewModels)  │
└─────────────────────────────────┘
            ↓ ↑
┌─────────────────────────────────┐
│   DOMAIN LAYER                  │
│   (Business Logic & Protocols)  │
└─────────────────────────────────┘
            ↓ ↑
┌─────────────────────────────────┐
│   DATA LAYER                    │
│   (Repositories & SwiftData)    │
└─────────────────────────────────┘
```

### Key Principles

- **SOLID Principles**: Single responsibility, dependency inversion, interface segregation
- **Protocol-Oriented**: All repositories defined as protocols for testability
- **Dependency Injection**: Through `AppDependencies` container
- **Repository Pattern**: Clean abstraction over data sources
- **Micro-Modular**: Files kept to 100-200 lines for optimal maintainability

For detailed architecture documentation, see [ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## 📸 Screenshots

<div align="center">

| Lifting Session | Nutrition Tracking | Profile & History |
|---|---|---|
| *Coming Soon* | *Coming Soon* | *Coming Soon* |

</div>

---

## 🚀 Getting Started

### Prerequisites

- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+ device or simulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/burakkho/antrain.git
   cd antrain
   ```

2. **Open in Xcode**
   ```bash
   open antrain.xcodeproj
   ```

3. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd + R` to build and run
   - No external dependencies required!

### Configuration

- **Bundle Identifier**: Update in project settings as needed
- **Team**: Set your development team in Xcode
- **Deployment Target**: iOS 17.0

---

## 📖 Documentation

Comprehensive documentation is available in the `/docs` directory:

- [**ARCHITECTURE.md**](docs/ARCHITECTURE.md) - Detailed architecture and design patterns
- [**MODELS.md**](docs/MODELS.md) - Core domain models and relationships
- [**DESIGN_SYSTEM.md**](docs/DESIGN_SYSTEM.md) - Design tokens and component library
- [**SPRINT_LOG.md**](docs/SPRINT_LOG.md) - Development history and sprint tracking
- [**PRIVACY_POLICY.md**](PRIVACY_POLICY.md) - Privacy policy and data handling

---

## 🗺 Roadmap

### Current Status: v1.0 (90% Complete)

#### ✅ Completed
- Foundation & Core Architecture
- Nutrition Tracking (complete with food library)
- Quick Logging (cardio & MetCon)
- Lifting Session Tracking
- User Profile & Settings
- Design System & Dark Mode
- Weight Unit System (kg/lbs conversion)

#### 🔜 Coming Soon (v1.1+)
- Exercise library expansion (150+ exercises)
- Custom exercise/food creation UI
- Workout templates and routines
- Advanced analytics and progress charts
- Personal records (PR) tracking
- HealthKit integration

#### 🚀 Future Phases
- Cloud sync across devices
- Apple Watch app
- Data export (CSV, PDF)
- Rest timer with notifications
- Exercise instruction videos

---

## 🤝 Contributing

This is currently a **portfolio showcase project**. While contributions are not accepted at this time, feel free to:

- ⭐ Star the repository
- 🐛 Report bugs via [Issues](https://github.com/burakkho/antrain/issues)
- 💡 Suggest features via [Issues](https://github.com/burakkho/antrain/issues)
- 📧 Contact for questions

For more details, see [CONTRIBUTING.md](CONTRIBUTING.md).

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📧 Contact

**Burak Küçükhüseyinoğlu**

- GitHub: [@burakkho](https://github.com/burakkho)
- Email: burakkho@gmail.com
- Repository: [github.com/burakkho/antrain](https://github.com/burakkho/antrain)

---

## 🙏 Acknowledgments

- Built with [Swift 6](https://swift.org) and [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Follows [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- Inspired by the fitness tracking community

---

<div align="center">

**⚡ Built with passion for the fitness community ⚡**

[Report Bug](https://github.com/burakkho/antrain/issues) • [Request Feature](https://github.com/burakkho/antrain/issues)

</div>

---
---

<a name="turkish"></a>

# Antrain (Türkçe)

<div align="center">

**Güç sporcuları, CrossFit meraklıları ve hibrit antrenman için kapsamlı fitness takip uygulaması.**

</div>

---

## 📱 Antrain Hakkında

**Antrain**, Swift 6 ve SwiftUI ile geliştirilmiş modern bir fitness takip uygulamasıdır. Antrenman ve beslenme takibi için kusursuz bir deneyim sunmak üzere tasarlanmıştır. Uygulama, gerçek zamanlı ağırlık antrenmanı takibi, hızlı kardiyо/MetCon kaydı ve kapsamlı beslenme takibi sunar - tüm veriler tamamen gizlilik ile yerel olarak saklanır.

### ✨ Öne Çıkan Özellikler

- **🏋️ Ağırlık Antrenmanları**: Set, tekrar ve ağırlık kaydı ile gerçek zamanlı antrenman takibi
- **🏃 Hızlı Kayıt**: Detaylı metriklerle antrenman sonrası kardiyо ve MetCon kaydı
- **🥗 Beslenme Takibi**: Öğün kaydı ile günlük makro takibi (kalori, protein, karbonhidrat, yağ)
- **📊 Geçmiş ve İlerleme**: Detaylı görünümlerle kapsamlı antrenman ve beslenme geçmişi
- **👤 Kullanıcı Profili**: Hedef yönetimi ve geçmiş ile vücut ağırlığı takibi
- **📚 Kütüphaneler**: 150+ hazır egzersiz ve 100+ besin öğesi, özel giriş desteği ile

### 🎯 Hedef Kullanıcılar

- Güç sporcuları (powerlifting, vücut geliştirme)
- CrossFit ve fonksiyonel fitness meraklıları
- Hibrit sporcular (Hyrox, vb.)
- Kapsamlı fitness takibi arayan herkes

### 🔒 Gizlilik Öncelikli

- **%100 Yerel Depolama**: Tüm veriler SwiftData kullanılarak cihazınızda saklanır
- **Cloud Senkronizasyonu Yok**: Harici sunuculara veri aktarımı yapılmaz
- **Analitik Yok**: Sıfır izleme veya telemetri
- **Hesap Gerekmez**: Hemen kullanmaya başlayın
- **Verileriniz Size Ait**: Fitness bilgileriniz üzerinde tam kontrol

---

## 🛠 Teknoloji Yığını

| Teknoloji | Açıklama |
|---|---|
| **Dil** | Swift 6 (katı eşzamanlılık) |
| **UI Framework** | SwiftUI |
| **Veri Kalıcılığı** | SwiftData (sadece yerel) |
| **Minimum iOS** | 17.0+ |
| **Mimari** | Clean Architecture + MVVM |
| **Tasarım** | Apple HIG uyumlu |

---

## 🏗 Mimari

Antrain, üç farklı katmanlı **Clean Architecture** prensiplerini takip eder:

```
┌─────────────────────────────────┐
│   SUNUM KATMANI                 │
│   (SwiftUI Views + ViewModels)  │
└─────────────────────────────────┘
            ↓ ↑
┌─────────────────────────────────┐
│   ALAN KATMANI                  │
│   (İş Mantığı ve Protokoller)   │
└─────────────────────────────────┘
            ↓ ↑
┌─────────────────────────────────┐
│   VERİ KATMANI                  │
│   (Repository'ler & SwiftData)  │
└─────────────────────────────────┘
```

### Ana Prensipler

- **SOLID Prensipleri**: Tek sorumluluk, bağımlılık tersine çevirme, arayüz ayrımı
- **Protokol Odaklı**: Test edilebilirlik için tüm repository'ler protokol olarak tanımlanmıştır
- **Bağımlılık Enjeksiyonu**: `AppDependencies` container üzerinden
- **Repository Pattern**: Veri kaynakları üzerinde temiz soyutlama
- **Mikro-Modüler**: Optimal sürdürülebilirlik için dosyalar 100-200 satırda tutulur

Detaylı mimari dokümantasyonu için [ARCHITECTURE.md](docs/ARCHITECTURE.md) dosyasına bakın.

---

## 📸 Ekran Görüntüleri

<div align="center">

| Ağırlık Antrenmanı | Beslenme Takibi | Profil ve Geçmiş |
|---|---|---|
| *Yakında* | *Yakında* | *Yakında* |

</div>

---

## 🚀 Başlarken

### Ön Gereksinimler

- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+ cihaz veya simülatör

### Kurulum

1. **Repository'yi klonlayın**
   ```bash
   git clone https://github.com/burakkho/antrain.git
   cd antrain
   ```

2. **Xcode'da açın**
   ```bash
   open antrain.xcodeproj
   ```

3. **Derleyin ve Çalıştırın**
   - Hedef cihazınızı/simülatörünüzü seçin
   - `Cmd + R` ile derleyin ve çalıştırın
   - Harici bağımlılık gerektirmez!

### Yapılandırma

- **Bundle Identifier**: Proje ayarlarından gerektiği gibi güncelleyin
- **Team**: Xcode'da geliştirme ekibinizi ayarlayın
- **Deployment Target**: iOS 17.0

---

## 📖 Dokümantasyon

Kapsamlı dokümantasyon `/docs` dizininde mevcuttur:

- [**ARCHITECTURE.md**](docs/ARCHITECTURE.md) - Detaylı mimari ve tasarım desenleri
- [**MODELS.md**](docs/MODELS.md) - Temel domain modelleri ve ilişkileri
- [**DESIGN_SYSTEM.md**](docs/DESIGN_SYSTEM.md) - Tasarım token'ları ve bileşen kütüphanesi
- [**SPRINT_LOG.md**](docs/SPRINT_LOG.md) - Geliştirme geçmişi ve sprint takibi
- [**PRIVACY_POLICY.md**](PRIVACY_POLICY.md) - Gizlilik politikası ve veri işleme

---

## 🗺 Yol Haritası

### Mevcut Durum: v1.0 (%90 Tamamlandı)

#### ✅ Tamamlandı
- Temel Yapı ve Çekirdek Mimari
- Beslenme Takibi (besin kütüphanesi ile tam)
- Hızlı Kayıt (kardiyо ve MetCon)
- Ağırlık Antrenmanı Takibi
- Kullanıcı Profili ve Ayarlar
- Tasarım Sistemi ve Karanlık Mod
- Ağırlık Birimi Sistemi (kg/lbs dönüşümü)

#### 🔜 Yakında (v1.1+)
- Egzersiz kütüphanesi genişletmesi (150+ egzersiz)
- Özel egzersiz/besin oluşturma UI'ı
- Antrenman şablonları ve rutinleri
- Gelişmiş analitik ve ilerleme grafikleri
- Kişisel rekorlar (PR) takibi
- HealthKit entegrasyonu

#### 🚀 Gelecek Aşamalar
- Cihazlar arası cloud senkronizasyonu
- Apple Watch uygulaması
- Veri dışa aktarma (CSV, PDF)
- Bildirimlerle dinlenme zamanlayıcısı
- Egzersiz talimat videoları

---

## 🤝 Katkıda Bulunma

Bu şu anda bir **portfolyo vitrin projesidir**. Katkılar şu anda kabul edilmemekle birlikte, şunları yapabilirsiniz:

- ⭐ Repository'yi yıldızlayın
- 🐛 [Issues](https://github.com/burakkho/antrain/issues) üzerinden hata bildirin
- 💡 [Issues](https://github.com/burakkho/antrain/issues) üzerinden özellik önerin
- 📧 Sorularınız için iletişime geçin

Daha fazla detay için [CONTRIBUTING.md](CONTRIBUTING.md) dosyasına bakın.

---

## 📄 Lisans

Bu proje MIT Lisansı altında lisanslanmıştır - detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

## 📧 İletişim

**Burak Küçükhüseyinoğlu**

- GitHub: [@burakkho](https://github.com/burakkho)
- Email: burakkho@gmail.com
- Repository: [github.com/burakkho/antrain](https://github.com/burakkho/antrain)

---

## 🙏 Teşekkürler

- [Swift 6](https://swift.org) ve [SwiftUI](https://developer.apple.com/xcode/swiftui/) ile geliştirildi
- [Apple İnsan Arayüzü Yönergeleri](https://developer.apple.com/design/human-interface-guidelines/)'ni takip eder
- Fitness takip topluluğundan ilham alındı

---

<div align="center">

**⚡ Fitness topluluğu için tutkuyla geliştirildi ⚡**

[Hata Bildir](https://github.com/burakkho/antrain/issues) • [Özellik İste](https://github.com/burakkho/antrain/issues)

</div>

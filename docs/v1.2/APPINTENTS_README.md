# 🎤 Antrain App Shortcuts - Implementation Guide

## ✅ Tamamlanan İşlemler

### 1. AppIntents Oluşturuldu
- ✅ `StartWorkoutIntent.swift` - Ana workout başlatma intent
- ✅ `AppShortcuts.swift` - Siri phrase registry

### 2. Localization Dosyaları (3 Dil)
- ✅ `en.lproj/AppIntents.strings` - İngilizce
- ✅ `tr.lproj/AppIntents.strings` - Türkçe
- ✅ `es.lproj/AppIntents.strings` - İspanyolca

### 3. Deep Link Integration
- ✅ Mevcut deep link sistemi kullanılıyor (`antrain://start-workout`)
- ✅ AntrainApp.swift zaten handle ediyor

---

## 🔧 Xcode'da Yapılması Gerekenler

### 1. Dosyaları Targets'a Ekle

**Ana app target'a eklenecekler:**
- ✅ `StartWorkoutIntent.swift`
- ✅ `AppShortcuts.swift`
- ✅ `en.lproj/AppIntents.strings`
- ✅ `tr.lproj/AppIntents.strings`
- ✅ `es.lproj/AppIntents.strings`

**Nasıl yapılır:**
1. Project Navigator'da her dosyayı seç
2. Sağ panelde "Target Membership" bölümünü bul
3. Ana app target'ını (antrain) işaretle

### 2. Info.plist'e Siri Capability Ekle

**Xcode'da:**
1. Project → Target (antrain) seç
2. **Signing & Capabilities** tab'ına git
3. **+ Capability** butonuna bas
4. **"Siri"** arama yap ve ekle

### 3. Localization Setup

**Xcode'da:**
1. Project settings → Info → Localizations
2. Şu dillerin eklendiğinden emin ol:
   - ✅ English (base)
   - ✅ Turkish
   - ✅ Spanish

**Eğer eksikse:**
1. **+** butonuna bas
2. Dilleri ekle (Turkish, Spanish)
3. Localization files'ları seç

---

## 🧪 Test Etme

### 1. Build ve Run
```bash
⌘ + R
```

### 2. Shortcuts App'te Kontrol

1. **Shortcuts app'i aç** (iPhone'da)
2. Sağ üstte **"+"** butonuna bas
3. **"Add Action"** seç
4. **"Apps"** tab'ına git
5. **"Antrain"** uygulamasını bul
6. **"Start Workout"** action'ını görmelisin!

### 3. Siri ile Test

**İngilizce (iPhone EN):**
```
"Hey Siri, start workout"
```

**Türkçe (iPhone TR):**
```
"Hey Siri, antrenmana başla"
```

**İspanyolca (iPhone ES):**
```
"Hey Siri, comenzar entrenamiento"
```

### 4. Manuel Shortcut Oluştur

1. Shortcuts app'te **yeni shortcut** oluştur
2. **"Antrain" → "Start Workout"** action ekle
3. Shortcut'a isim ver: "Workout"
4. Test et: Shortcut'a dokun
5. Uygulama açılmalı ve Home tab'a gitmeli!

---

## 🎯 Beklenen Davranış

### Siri'den Çalıştırınca:
```
User: "Hey Siri, start workout"
Siri: "Starting your workout" (veya dile göre lokalize)
App: Açılır → Home tab → Workout başlama akışı
```

### Shortcuts'tan Çalıştırınca:
```
User: Shortcut'a dokun
App: Açılır → Home tab → Workout başlama akışı
```

### Widget'tan Çalıştırınca (Mevcut):
```
User: Widget'a dokun
App: Açılır → Home tab
```

---

## 🌍 Multi-Language Support

| Dil | Siri Phrase | Sonuç |
|-----|-------------|-------|
| 🇬🇧 English | "Start workout" | "Starting your workout" |
| 🇹🇷 Türkçe | "Antrenmana başla" | "Antrenman başlatılıyor" |
| 🇪🇸 Español | "Comenzar entrenamiento" | "Comenzando tu entrenamiento" |

---

## 📝 Phrase Variations

### English:
- "Start workout with Antrain"
- "Begin training in Antrain"
- "Start my workout in Antrain"

### Turkish:
- "Antrain ile antrenmana başla"
- "Antrain'de antrenmana başla"
- "Antrain'de antrenmanımı başlat"

### Spanish:
- "Comenzar entrenamiento con Antrain"
- "Empezar entrenamiento en Antrain"
- "Comenzar mi entrenamiento en Antrain"

---

## 🔍 Troubleshooting

### Siri doesn't recognize the phrase
- ✅ Siri capability ekli mi kontrol et
- ✅ iPhone dilini değiştir ve test et
- ✅ "Hey Siri, what can Antrain do?" diye sor (Siri available shortcuts'ları gösterir)

### Shortcut appears but doesn't work
- ✅ Deep link URL'i kontrol et: `antrain://start-workout`
- ✅ AntrainApp.swift'de `handleURLOpen` çalışıyor mu?
- ✅ MainTabView'de `NavigateToWorkout` notification handler var mı?

### Localization doesn't work
- ✅ `.strings` dosyaları target'a ekli mi?
- ✅ iPhone dili değiştirildi mi?
- ✅ App yeniden build edildi mi?

---

## 🚀 Sonraki Adımlar (Optional)

### Ek Intent'ler:
1. **GetLastWorkoutIntent**
   - "Show my last workout"
   - Son workout'u göster

2. **GetPersonalRecordIntent**
   - "What's my squat PR?"
   - PR'ları sorgula

3. **QuickLogCardioIntent**
   - "Log a 5K run"
   - Hızlı cardio log

---

## 📊 Files Created

```
antrain/
├── AppIntents/
│   ├── StartWorkoutIntent.swift       ✅ NEW
│   └── AppShortcuts.swift             ✅ NEW
└── Resources/
    ├── en.lproj/
    │   └── AppIntents.strings         ✅ NEW
    ├── tr.lproj/
    │   └── AppIntents.strings         ✅ NEW
    └── es.lproj/
        └── AppIntents.strings         ✅ NEW
```

---

## ✅ Ready to Test!

1. **Xcode'da targets'a ekle**
2. **Siri capability ekle**
3. **Build et (⌘ + R)**
4. **"Hey Siri, start workout" de!** 🎤

Good luck! 🚀

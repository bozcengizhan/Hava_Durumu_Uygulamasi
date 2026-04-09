# 🌦️ InstantaneousWeather - Live Weather App

**InstantaneousWeather**, Flutter ile geliştirilmiş, kullanıcıların dünya genelindeki şehirlerin hava durumunu anlık olarak takip etmelerini sağlayan, görsel odaklı ve kullanıcı dostu bir mobil uygulamadır. Uygulama, sıcaklık değerlerine göre dinamik olarak renk değiştiren modern arayüzü ile hava durumunu sadece bir sayı olmaktan çıkarıp görsel bir deneyime dönüştürür.

---

## 🚀 Uygulamayı Deneyimleyin
Uygulama şu an **Google Play Store** üzerinde yayındadır. Özellikleri ve ekran görüntülerini mağaza sayfası üzerinden inceleyebilirsiniz:

👉 **[Google Play Store'da Görüntüle](https://play.google.com/store/apps/details?id=com.cengiz.liveweather)**

---

## ✨ Özellikler

- **🌍 Küresel Şehir Listeleme:** GeoNames API entegrasyonu ile seçilen ülkedeki tüm önemli şehir merkezlerini otomatik olarak listeler.
- **🌡️ Dinamik Renk Paleti:** Sıcaklık değerlerine göre (Sıcak, Ilık, Serin, Soğuk) arka plan ve kart renkleri anlık olarak değişir.
- **🔍 Akıllı Arama ve Filtreleme:** Şehirler arasında hızlıca arama yapabilir ve istediğiniz konumu bulabilirsiniz.
- **📊 Detaylı Meteoroloji:** Sadece sıcaklık değil; nem oranı ve rüzgar hızı gibi kritik verileri sunar.
- **🌐 Çok Dil Desteği:** TR, EN, DE ve FR dillerini destekleyerek cihaz diline göre otomatik uyum sağlar.
- **⚡ Performans Odaklı:** API istekleri için optimize edilmiş `Dio` mimarisi ve akıllı veri çekme (throttling) mekanizması.

---

## 🛠️ Teknik Altyapı

Uygulamanın geliştirilmesinde aşağıdaki teknolojiler ve mimariler kullanılmıştır:

* **Framework:** [Flutter](https://flutter.dev/)
* **Programlama Dili:** [Dart](https://dart.dev/)
* **Networking:** [Dio](https://pub.dev/packages/dio) (API istekleri ve JSON yönetimi için)
* **State Management:** State-bound UI components (Clean Code prensiplerine uygun mimari)
* **API Entegrasyonları:**
    * [OpenWeatherMap API](https://openweathermap.org/api): Gerçek zamanlı hava durumu verileri.
    * [GeoNames API](https://www.geonames.org/): Coğrafi veri ve şehir listeleme hizmeti.

---

## 📁 Dosya Yapısı

lib/
├ Models/
├ countries
├ districtListScreen.dart
├ cityListScreen.dart
└ main.darta

# 🌦️ LiveWeather – Real-Time Weather Updates

Stay prepared for every day with **LiveWeather**, your simple and reliable weather app! LiveWeather provides accurate, real-time weather updates for your city or current location. No more guessing the weather—get instant temperature, humidity, wind speed, and weather conditions with just a few taps.

---

## 🚀 Experience the App
The application is currently live on the **Google Play Store**. You can check out the features, performance, and screenshots on the store page:

👉 **[View on Google Play Store](https://play.google.com/store/apps/details?id=com.cengiz.liveweather)**

---

## ✨ Key Features

- **🌍 Global City Discovery:** Automatically lists major city centers for any selected country using the GeoNames API integration.
- **🎨 Dynamic Visual Feedback:** The background and card colors transition smoothly based on temperature (Hot, Warm, Cool, Cold) using `AnimatedContainer`.
- **🔍 Smart Search & Filter:** Quickly find any city among thousands of entries with an optimized search modal.
- **📊 Comprehensive Meteorology:** Detailed insights including humidity levels, wind speed, and weather descriptions.
- **🌐 Multilingual Support:** Supports English, Turkish, German, and French, automatically adapting to the device's system language.
- **⚡ Optimized Performance:** Features smart API throttling (350ms delays) and efficient JSON parsing to stay within rate limits and ensure smooth scrolling.

---

## 🛠️ Technical Stack

Built with modern mobile development standards:

* **Framework:** [Flutter](https://flutter.dev/)
* **Language:** [Dart](https://dart.dev/)
* **Networking:** [Dio](https://pub.dev/packages/dio) (For advanced REST API requests and configuration)
* **State Management:** Reactive state handling with `StatefulWidget` and clean architectural separation.
* **APIs Integrated:**
    * [OpenWeatherMap API](https://openweathermap.org/api): Real-time meteorological data.
    * [GeoNames API](https://www.geonames.org/): Geographical database and city listing service.

---

### Installation

1. **Clone the repository:**
   
- git clone [https://github.com/bozcengizhan/Hava_Durumu_Uygulamasi.git](https://github.com/bozcengizhan/Hava_Durumu_Uygulamasi.git)

2. Navigate to the project directory:
   
- cd Hava_Durumu_Uygulamasi

3. Install dependencies:
   
- flutter pub get

4. Run the application:

- flutter run

### License
Distributed under the MIT License. See LICENSE for more information.

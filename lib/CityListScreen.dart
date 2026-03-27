import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hava_durumu_uygulamasi/Models/weatherModel.dart';
import 'package:hava_durumu_uygulamasi/districtListScreen.dart';
import 'dart:ui' as ui; // Cihaz dilini almak için

// 🌍 Desteklenen diller
const supportedLanguages = ['tr', 'en', 'de', 'fr'];

String getDeviceLanguageCode() {
  final code = ui.window.locale.languageCode;
  return supportedLanguages.contains(code) ? code : 'en';
}

final texts = {
  'all_temps_fetched': {
    'tr': '✅ Tüm şehir sıcaklıkları çekildi.',
    'en': '✅ All city temperatures fetched.',
    'de': '✅ Alle Stadttemperaturen abgerufen.',
    'fr': '✅ Toutes les températures des villes récupérées.',
  },
  'temp_fetch_failed': {
    'tr': 'sıcaklığı alınamadı: ',
    'en': 'temperature could not be fetched: ',
    'de': 'Temperatur konnte nicht abgerufen werden: ',
    'fr': 'température n’a pas pu être récupérée: ',
  },
  'all_cities_ok': {
    'tr': '🎉 Tüm şehirler sorunsuz.',
    'en': '🎉 All cities fetched successfully.',
    'de': '🎉 Alle Städte erfolgreich abgerufen.',
    'fr': '🎉 Toutes les villes récupérées avec succès.',
  },
  'failed_cities': {
    'tr': '⚠️ Hata alınan şehirler: ',
    'en': '⚠️ Failed cities: ',
    'de': '⚠️ Fehlerhafte Städte: ',
    'fr': '⚠️ Villes échouées: ',
  },
  'all_cities_tried': {
    'tr': '✅ Tüm şehirler sırayla denendi.',
    'en': '✅ All cities tried sequentially.',
    'de': '✅ Alle Städte nacheinander getestet.',
    'fr': '✅ Toutes les villes testées séquentiellement.',
  },
  'general_error': {
    'tr': '❌ Genel Hata: ',
    'en': '❌ General error: ',
    'de': '❌ Allgemeiner Fehler: ',
    'fr': '❌ Erreur générale: ',
  },
  'success': {
    'tr': '✅ Başarılı: ',
    'en': '✅ Success: ',
    'de': '✅ Erfolgreich: ',
    'fr': '✅ Réussi: ',
  },
  'no_coords': {
    'tr': '(Koordinat yok)',
    'en': '(No coordinates)',
    'de': '(Keine Koordinaten)',
    'fr': '(Pas de coordonnées)',
  },
  'humidity': {
    'tr': 'Nem',
    'en': 'Humidity',
    'de': 'Feuchtigkeit',
    'fr': 'Humidité',
  },
  'wind': {'tr': 'Rüzgar', 'en': 'Wind', 'de': 'Wind', 'fr': 'Vent'},
  'm_s': {'tr': 'm/s', 'en': 'm/s', 'de': 'm/s', 'fr': 'm/s'},
  'search_city': {
    'tr': 'Şehir ara',
    'en': 'Search city',
    'de': 'Stadt suchen',
    'fr': 'Chercher une ville',
  },
  'no_match': {
    'tr': 'Eşleşen şehir yok',
    'en': 'No matching city',
    'de': 'Keine passende Stadt',
    'fr': 'Aucune ville correspondante',
  },
  'enter_name': {
    'tr': 'Şehir adı yazın',
    'en': 'Type city name',
    'de': 'Stadtnamen eingeben',
    'fr': 'Tapez le nom de la ville',
  },
  'weather_error': {
    'tr': 'Hava durumu alınamadı!',
    'en': 'Weather data unavailable!',
    'de': 'Wetterdaten nicht verfügbar!',
    'fr': 'Données météo indisponibles!',
  },
};

class CityListScreen extends StatefulWidget {
  final String countryCode;
  final String countryName;
  const CityListScreen({
    super.key,
    required this.countryCode,
    required this.countryName,
  });

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  // name, geonameId, lat, lon tutacak yeni yapı
  List<Map<String, dynamic>> cities = [];
  bool isLoading = true;
  double? currentTemp;
  Map<String, double> cityTemps = {}; // şehir-sıcaklık eşleşmeleri

  String?
  selectedCityName; // Seçili şehrin adı (GeoNames'ten gelen orijinal isim)
  Map<String, dynamic>? selectedCityData; // Seçili şehrin tüm verisi
  Future<WeatherModel>? cityWeather;

  final dioWeather = Dio(
    BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/2.5/',
      queryParameters: {
        'appid': 'abbfebf7bdfbe772d0a94fb270654739',
        'units': 'metric',
        'lang': getDeviceLanguageCode(), // Cihaz diline göre
      },
    ),
  );

  @override
  void initState() {
    super.initState();
    fetchCities(); // sayfa yüklenince otomatik başlatır
  }

  Future<void> fetchCities() async {
    // 🔹 Şehir isimlerini değiştirmek için map
    final Map<String, String> cityReplacements = {
      'İzmit': 'Kocaeli',
      'Adapazarı': 'Sakarya',
      // İleride başka eşlemeler ekleyebilirsin
    };

    try {
      final dio = Dio();
      final response = await dio.get(
        'http://api.geonames.org/searchJSON',
        queryParameters: {
          'country': widget.countryCode,
          'featureClass': 'P',
          'featureCode': 'PPLA',
          'maxRows': 1000,
          'username': 'bozcengizhan',
          'lang': getDeviceLanguageCode(),
        },
      );

      final data = response.data['geonames'] as List;

      setState(() {
        cities = data
            .map(
              (e) => {
                'name':
                    cityReplacements[e['name']] ??
                    e['name'], // 🔹 Replacement burada
                'geonameId': e['geonameId'],
                'lat': double.tryParse(e['lat'] ?? '0.0'),
                'lon': double.tryParse(e['lng'] ?? '0.0'),
              },
            )
            .toList();

        cities.sort(
          (a, b) => (a['name'] as String).toLowerCase().compareTo(
            (b['name'] as String).toLowerCase(),
          ),
        );

        isLoading = false;
      });
    } catch (e) {
      debugPrint('GeoNames error: $e');
      setState(() => isLoading = false);
    }
    if (mounted) {
      await fetchCityTemperatures(); // şehir sıcaklıklarını çek
    }
  }

  Future<void> fetchCityTemperatures() async {
    for (final city in cities) {
      final name = city['name'] as String;
      final lat = city['lat'] as double?;
      final lon = city['lon'] as double?;

      if (lat == null || lon == null) continue;

      try {
        final weather = await getWeather(lat, lon);
        final temp = weather.main?.temp;
        if (temp != null) {
          setState(() {
            cityTemps[name] = temp;
          });
        }
      } catch (e) {
        debugPrint(
          texts['temp_fetch_failed']![getDeviceLanguageCode()]! + '$name: $e',
        );
      }

      // Gereksiz API yüklenmesini azaltmak için biraz bekle
      await Future.delayed(const Duration(milliseconds: 350));
    }

    debugPrint(texts['all_temps_fetched']![getDeviceLanguageCode()]!);
  }

  Future<WeatherModel> getWeather(double lat, double lon) async {
    try {
      final response = await dioWeather.get(
        '/weather',
        queryParameters: {'lat': lat, 'lon': lon},
      );

      return WeatherModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Weather fetch error for Lat: $lat, Lon: $lon: $e');
      rethrow;
    }
  }

  Color _getTempColor(double temp) {
    if (temp > 30) return Colors.redAccent.shade400;
    if (temp > 20) return Colors.orangeAccent.shade400;
    if (temp > 10) return Colors.greenAccent.shade400;
    return Colors.lightBlueAccent.shade400;
  }

  Color _getTempColor2(double temp) {
    if (temp > 30) return Color.fromARGB(255, 250, 149, 140);
    if (temp >= 20 && temp < 30) return Color.fromARGB(255, 251, 212, 145);
    if (temp >= 10 && temp < 20) return Color.fromARGB(255, 139, 249, 170);
    return Color.fromARGB(255, 138, 215, 248);
  }

  Widget _weatherCard(WeatherModel weather) {
    final temp = weather.main?.temp ?? 0;
    final tempText = temp.toStringAsFixed(1);
    final descRaw = (weather.weather != null && weather.weather!.isNotEmpty)
        ? weather.weather![0].description ?? ''
        : '';
    final desc = descRaw.isEmpty
        ? '--'
        : '${descRaw[0].toUpperCase()}${descRaw.substring(1)}';
    final humidity = weather.main?.humidity?.toString() ?? '--';
    final wind = weather.wind?.speed?.toString() ?? '--';

    // ⭐️ BURADAKİ DEĞİŞİKLİK: Her zaman GeoNames'tan gelen orijinal ismi kullanır.
    final name = selectedCityName ?? '--';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _getTempColor(temp),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _getTempColor(temp).withOpacity(0.4),
            spreadRadius: 10,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          final geonameId = selectedCityData?['geonameId'];
          if (geonameId != null && selectedCityName != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DistrictListScreen(
                  countryCode: widget.countryCode,
                  cityName: selectedCityName!, // Orijinal ismi gönder
                  cityGeonameId: geonameId,
                ),
              ),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              tempText + '°C',
              style: const TextStyle(
                shadows: [
                  Shadow(
                    offset: Offset(0, 0),
                    blurRadius: 15,
                    color: Color.fromRGBO(255, 200, 0, 0.18),
                  ),
                  Shadow(
                    offset: Offset(0, 4),
                    blurRadius: 15,
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                  ),
                ],
                fontSize: 55,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              desc,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Icon(Icons.water_drop),
                    const SizedBox(height: 4),
                    Text(
                      texts['humidity']![getDeviceLanguageCode()]! +
                          ': $humidity%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  children: [
                    const Icon(Icons.air),
                    const SizedBox(height: 4),
                    Text(
                      texts['wind']![getDeviceLanguageCode()]! +
                          ': $wind ' +
                          texts['m_s']![getDeviceLanguageCode()]!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 6,
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              "${cities.length} cities",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 118, 117, 117),
              ),
            ),
            SizedBox(height: 8),
            Icon(Icons.location_city, size: 40, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showCitySearchModal() {
    String query = '';
    // Filtreleme için sadece isimleri kullan
    List<String> filteredNames = cities
        .map((e) => e['name'] as String)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final result = filteredNames
                .where((s) => s.toLowerCase().contains(query.toLowerCase()))
                .toList();
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (v) => setModalState(() => query = v),
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    child: result.isEmpty
                        ? Center(
                            child: Text(
                              texts['no_match']![getDeviceLanguageCode()]!,
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: result.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final city = result[index];
                              final isSel = city == selectedCityName;
                              return ListTile(
                                title: Text(city),
                                trailing: isSel
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.blue,
                                      )
                                    : null,
                                onTap: () {
                                  // Şehir seçildiğinde tüm verisini bul
                                  final selected = cities.firstWhere(
                                    (c) => c['name'] == city,
                                  );

                                  setState(() {
                                    selectedCityName = city;
                                    selectedCityData = selected;
                                    cityWeather = getWeather(
                                      selected['lat'] as double,
                                      selected['lon'] as double,
                                    );
                                  });
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌡 Seçili şehrin sıcaklığını al
    final selectedTemp = selectedCityName != null
        ? cityTemps[selectedCityName]
        : null;

    final bgColor = selectedTemp != null
        ? _getTempColor2(selectedTemp)
        : Colors.white;

    Color getColorByTempGridview(double? temp) {
      if (temp == null) return Colors.grey.shade300;
      if (temp >= 30) return Colors.red.shade300;
      if (temp >= 20) return Colors.orange.shade300;
      if (temp >= 10) return Colors.green.shade300;
      return Colors.blue.shade200;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          widget.countryName,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.normal,
            shadows: [
              Shadow(
                offset: Offset(0, 0),
                blurRadius: 8,
                color: Color.fromRGBO(255, 200, 0, 0.18),
              ),
              Shadow(
                offset: Offset(0, 4),
                blurRadius: 6,
                color: Color.fromRGBO(0, 0, 0, 0.3),
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 2.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 28,
                    ),
                    label: Text(
                      texts['search_city']![getDeviceLanguageCode()]!,
                      style: TextStyle(color: Colors.amber, fontSize: 22),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
                    ),
                    onPressed: _showCitySearchModal,
                  ),
                ),

                FutureBuilder<WeatherModel>(
                  future: cityWeather,
                  builder: (context, snapshot) {
                    if (selectedCityName == null) {
                      return _defaultCard();
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasData) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          currentTemp = snapshot.data!.main?.temp;
                        });
                      });
                      return _weatherCard(snapshot.data!);
                    } else {
                      return Card(
                        margin: EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 6,
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Text(
                                texts['weather_error']![getDeviceLanguageCode()]!,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(height: 8),
                              Icon(
                                Icons.error_outline,
                                size: 40,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: cities.length,
                      itemBuilder: (context, index) {
                        final cityData = cities[index];
                        final city = cityData['name'] as String;
                        final isSel = city == selectedCityName;

                        final temp = cityTemps.containsKey(city)
                            ? cityTemps[city]
                            : null;

                        // hedef renk
                        final targetColor = isSel
                            ? Colors.blueGrey
                            : (temp != null
                                  ? getColorByTempGridview(temp)
                                  : Colors.grey.shade200);

                        // AnimatedContainer + transform ile hafifçe büyüme efekti ekledim.
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          transform: Matrix4.identity()
                            ..scale(isSel ? 1.03 : 1.0),
                          decoration: BoxDecoration(
                            color: targetColor,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                if (selectedCityName == city) {
                                  selectedCityName = null;
                                  selectedCityData = null;
                                  cityWeather = null;
                                } else {
                                  selectedCityName = city;
                                  selectedCityData = cityData;
                                  cityWeather = getWeather(
                                    cityData['lat'] as double,
                                    cityData['lon'] as double,
                                  );
                                }
                              });
                            },
                            child: Center(
                              child: Text(
                                cityTemps.containsKey(city)
                                    ? '$city  ${cityTemps[city]!.toStringAsFixed(0)}°C'
                                    : city,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSel ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

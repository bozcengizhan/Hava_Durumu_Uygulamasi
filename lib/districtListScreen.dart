import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hava_durumu_uygulamasi/Models/weatherModel.dart';
import 'dart:ui' as ui;

// 🌍 Desteklenen diller
const supportedLanguages = ['tr', 'en', 'de', 'fr'];

// 📱 Cihaz dilini al
String getDeviceLanguageCode() {
  final code = ui.window.locale.languageCode;
  return supportedLanguages.contains(code) ? code : 'en';
}

// 🌐 Çok dilli metinler
final texts = {
  'weather_error': {
    'tr': 'Hava durumu alınamadı!',
    'en': 'Weather data unavailable!',
    'de': 'Wetterdaten nicht verfügbar!',
    'fr': 'Données météo indisponibles!',
  },
  'all_temps_fetched': {
    'tr': '🏁 Tüm ilçelerin sıcaklık verileri çekildi.',
    'en': '🏁 All district temperatures fetched.',
    'de': '🏁 Alle Bezirks-Temperaturen abgerufen.',
    'fr': '🏁 Toutes les températures des arrondissements récupérées.',
  },
  'data_unavailable': {
    'tr': '⚠️ Veri alınamadı',
    'en': '⚠️ Data unavailable',
    'de': '⚠️ Daten nicht verfügbar',
    'fr': '⚠️ Données indisponibles',
  },
  'geonames_coord_error': {
    'tr': '🌍 GeoNames koordinat hatası:',
    'en': '🌍 GeoNames coordinate error:',
    'de': '🌍 GeoNames Koordinatenfehler:',
    'fr': '🌍 Erreur de coordonnées GeoNames:',
  },
  'no_geonames_result': {
    'tr': '🚫 için GeoNames sonucu yok.',
    'en': '🚫 No GeoNames result for',
    'de': '🚫 Kein GeoNames-Ergebnis für',
    'fr': '🚫 Aucun résultat GeoNames pour',
  },
  'no_name_result_try_coord': {
    'tr': '❗ için isimle sonuç yok, koordinatla deneniyor...',
    'en': '❗ No result with name, trying with coordinates...',
    'de': '❗ Kein Ergebnis mit Name, versuche Koordinaten...',
    'fr': '❗ Aucun résultat avec le nom, essai avec les coordonnées...',
  },
  'search_district': {
    'tr': 'İlçe ara',
    'en': 'Search district',
    'de': 'Bezirk suchen',
    'fr': 'Chercher un arrondissement',
  },
  'type_district': {
    'tr': 'İlçe adı yazın',
    'en': 'Type district name',
    'de': 'Bezirkname eingeben',
    'fr': 'Tapez le nom de l’arrondissement',
  },
  'no_match': {
    'tr': 'Eşleşen ilçe yok',
    'en': 'No matching district',
    'de': 'Kein passender Bezirk',
    'fr': 'Aucun arrondissement correspondant',
  },
  'weather_error': {
    'tr': 'Hava durumu alınamadı!',
    'en': 'Weather data unavailable!',
    'de': 'Wetterdaten nicht verfügbar!',
    'fr': 'Données météo indisponibles!',
  },
  'humidity': {
    'tr': 'Nem',
    'en': 'Humidity',
    'de': 'Feuchtigkeit',
    'fr': 'Humidité',
  },
  'wind': {'tr': 'Rüzgar', 'en': 'Wind', 'de': 'Wind', 'fr': 'Vent'},
  'm_s': {'tr': 'm/s', 'en': 'm/s', 'de': 'm/s', 'fr': 'm/s'},
};

class DistrictListScreen extends StatefulWidget {
  final String cityName;
  final String countryCode;
  final int cityGeonameId;

  const DistrictListScreen({
    super.key,
    required this.cityName,
    required this.countryCode,
    required this.cityGeonameId,
  });

  @override
  State<DistrictListScreen> createState() => _DistrictListScreenState();
}

class _DistrictListScreenState extends State<DistrictListScreen> {
  List<String> districts = [];
  bool isLoading = true;

  String? selectedDistrict;
  Future<WeatherModel?>? districtWeather;

  Map<String, double> districtTemps = {};

  final dioWeather = Dio(
    BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/2.5/',
      queryParameters: {
        'appid': 'abbfebf7bdfbe772d0a94fb270654739',
        'units': 'metric',
        'lang': getDeviceLanguageCode(),
      },
    ),
  );

  final lang = getDeviceLanguageCode();

  @override
  void initState() {
    super.initState();
    fetchDistricts();
  }

  String cleanDistrictName(String name) {
    name = name.trim();
    final suffixes = [
      ' ilçesi',
      ' District',
      ' Bezirk',
      ' arrondissement',
      ' Municipio',
      ' Comune',
      ' Parish',
    ];
    final prefixes = ['Bashkia', 'Gueltat', 'Daïra de', 'Daïra d’', 'Muang'];
    for (final prefix in prefixes) {
      if (name.toLowerCase().startsWith(prefix.toLowerCase())) {
        name = name.substring(prefix.length).trim();
      }
    }
    for (final suffix in suffixes) {
      if (name.toLowerCase().endsWith(suffix.toLowerCase())) {
        name = name.substring(0, name.length - suffix.length).trim();
      }
    }
    return name;
  }

  Future<void> fetchDistricts() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'http://api.geonames.org/searchJSON',
        queryParameters: {
          'q': widget.cityName,
          'country': widget.countryCode,
          'featureCode': 'ADM2',
          'maxRows': 100,
          'username': 'bozcengizhan',
          'lang': getDeviceLanguageCode(),
        },
      );

      final data = response.data['geonames'] as List;
      setState(() {
        districts = data
            .where((e) => e['fcode'] == 'ADM2' || e['fcode'] == 'PPL')
            .map((e) => cleanDistrictName(e['name'] as String))
            .toList();

        districts = districts.toSet().toList();
        districts.sort((a, b) => a.compareTo(b));
        if (districts.isEmpty) {
          districts.add(texts['no_match']![lang].toString());
        }
        isLoading = false;
      });

      await fetchDistrictTemperatures();
    } catch (e) {
      debugPrint('GeoNames error: $e');
      setState(() {
        districts = [texts['no_match']![lang].toString()];
        isLoading = false;
      });
    }
  }

  // 🌤 Gelişmiş hava durumu sorgusu (isim + koordinat yedekli)
  Future<WeatherModel?> getWeather(String district) async {
    try {
      if (district == texts['no_match']![lang]) return null;

      final query = '$district,${widget.cityName},${widget.countryCode}';

      final response = await dioWeather.get(
        '/weather',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        debugPrint('⚠️ Weather data not found for $query');
        return null;
      }
    } catch (e) {
      if (e.toString().contains('404')) {
        debugPrint('${texts['no_name_result_try_coord']![lang]!} $district');
        try {
          final geoResponse = await Dio().get(
            'http://api.geonames.org/searchJSON',
            queryParameters: {
              'q': '$district ${widget.cityName}',
              'country': widget.countryCode,
              'maxRows': 1,
              'username': 'bozcengizhan',
            },
          );

          final geoList = geoResponse.data['geonames'] as List?;
          if (geoList == null || geoList.isEmpty) {
            debugPrint('${texts['no_geonames_result']![lang]!} $district');
            return null;
          }

          final lat = geoList.first['lat'];
          final lon = geoList.first['lng'];

          final coordResponse = await dioWeather.get(
            '/weather',
            queryParameters: {'lat': lat, 'lon': lon},
          );

          return WeatherModel.fromJson(coordResponse.data);
        } catch (geoErr) {
          debugPrint(
            '${texts['geonames_coord_error']![lang]!} $district: $geoErr',
          );
          return null;
        }
      } else {
        debugPrint('❌ Weather fetch error for $district: $e');
        return null;
      }
    }
  }

  // 🔁 İlçe sıcaklıklarını sırayla al
  Future<void> fetchDistrictTemperatures() async {
    for (final district in districts) {
      if (district == texts['no_match']![lang]) continue;

      final weather = await getWeather(district);

      if (weather != null && weather.main?.temp != null) {
        setState(() {
          districtTemps[district] = weather.main!.temp!;
        });
        debugPrint('✅ ${weather.name ?? district}: ${weather.main!.temp}°C');
      } else {
        debugPrint('${texts['data_unavailable']![lang]!} for $district');
      }

      await Future.delayed(const Duration(milliseconds: 350));
    }

    debugPrint(texts['all_temps_fetched']![lang]!);
  }

  // 🎨 Renk geçişleri
  Color _getTempColor(double temp) {
    if (temp > 30) return Colors.redAccent.shade400;
    if (temp > 20) return Colors.orangeAccent.shade400;
    if (temp > 10) return Colors.greenAccent.shade400;
    return Colors.lightBlueAccent.shade400;
  }

  Color _getTempColor2(double temp) {
    if (temp > 30) return Colors.redAccent.shade100;
    if (temp >= 20 && temp < 30) return Colors.orangeAccent.shade100;
    if (temp >= 10 && temp < 20) return Colors.greenAccent.shade100;
    return Colors.lightBlueAccent.shade100;
  }

  // 🌡 Hava durumu kartı
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
    final name = selectedDistrict ?? '--';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _getTempColor(temp),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _getTempColor(temp).withOpacity(0.3),
            spreadRadius: 10,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 35, fontWeight: FontWeight.normal),
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
                    '${texts['humidity']![lang]}: $humidity%',
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
                    '${texts['wind']![lang]}: $wind ${texts['m_s']![lang]}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🎯 İlçe arama
  void _showDistrictSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String query = '';
        List<String> filtered = districts;
        return StatefulBuilder(
          builder: (context, setModalState) {
            filtered = districts
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
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: texts['type_district']![lang],
                      ),
                      onChanged: (v) => setModalState(() => query = v),
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    child: filtered.isEmpty
                        ? Center(child: Text(texts['no_match']![lang]!))
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final district = filtered[index];
                              final isSel = district == selectedDistrict;
                              return ListTile(
                                title: Text(district),
                                trailing: isSel
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.blue,
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    selectedDistrict = district;
                                    districtWeather = getWeather(district);
                                  });
                                  Navigator.pop(context);
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
    final selectedTemp = selectedDistrict != null
        ? districtTemps[selectedDistrict]
        : null;

    final backgroundColor = selectedTemp != null
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.cityName,
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
                      '${texts['search_district']![lang]}',
                      style: TextStyle(color: Colors.amber, fontSize: 22),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
                    ),
                    onPressed: _showDistrictSearch,
                  ),
                ),
                FutureBuilder<WeatherModel?>(
                  key: ValueKey(selectedDistrict),
                  future: districtWeather,
                  builder: (context, snapshot) {
                    if (selectedDistrict == null) {
                      return Card(
                        margin: EdgeInsets.all(16.0),
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Text(
                                "${districts.length} districts",
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Icon(
                                Icons.location_city,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasData && snapshot.data != null) {
                      return _weatherCard(snapshot.data!);
                    } else {
                      return Card(
                        margin: EdgeInsets.all(16.0),
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Text(
                                texts['weather_error']!['en']!,
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
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: districts.length,
                      itemBuilder: (context, index) {
                        final district = districts[index];
                        final temp = districtTemps[district];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          decoration: BoxDecoration(
                            color: selectedDistrict == district
                                ? Colors.blueGrey
                                : getColorByTempGridview(temp),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                if (selectedDistrict == district) {
                                  // Aynı ilçeye tekrar tıklandı → seçimi iptal et
                                  selectedDistrict = null;
                                  districtWeather = null;
                                } else {
                                  // Yeni bir ilçe seçildi → hava durumu getir
                                  selectedDistrict = district;
                                  districtWeather = getWeather(district);
                                }
                              });
                            },
                            child: Center(
                              child: Text(
                                '$district\n${temp != null ? '${temp.toStringAsFixed(0)}°' : '--'}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
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

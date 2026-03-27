// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hava_durumu_uygulamasi/CityListScreen.dart';
import 'package:hava_durumu_uygulamasi/Models/weatherModel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'countries';
import 'dart:ui' as ui;

String getDeviceLanguageCode() {
  final code = ui.window.locale.languageCode; // Daha güvenli erişim
  const supportedLanguages = ['tr', 'en', 'de', 'fr'];
  return supportedLanguages.contains(code) ? code : 'en';
}

final texts = {
  'humidity': {
    'tr': 'Nem',
    'en': 'Humidity',
    'de': 'Feuchtigkeit',
    'fr': 'Humidité',
  },
  'wind': {'tr': 'Rüzgar', 'en': 'Wind', 'de': 'Wind', 'fr': 'Vent'},
  'm_s': {'tr': 'm/s', 'en': 'm/s', 'de': 'm/s', 'fr': 'm/s'},
  'search_country': {
    'tr': 'Ülke ara',
    'en': 'Search country',
    'de': 'Land suchen',
    'fr': 'Rechercher un pays',
  },
  'use_device_location': {
    'tr': 'Cihaz konumunu kullan',
    'en': 'Use device location',
    'de': 'Gerätestandort verwenden',
    'fr': 'Utiliser la position de l’appareil',
  },
  'no_match': {
    'tr': 'Eşleşen ülke yok',
    'en': 'No matching country',
    'de': 'Keine Übereinstimmungen',
    'fr': 'Aucun pays correspondant',
  },
  'enter_name': {
    'tr': 'Ülke adı yazın',
    'en': 'Type country name',
    'de': 'Ländernamen eingeben',
    'fr': 'Tapez le nom du pays',
  },
  'location': {
    'tr': 'Konum',
    'en': 'Location',
    'de': 'Standort',
    'fr': 'Localisation',
  },
  'country_selected': {
    'tr': 'Ülke seçildi',
    'en': 'Country selected',
    'de': 'Land ausgewählt',
    'fr': 'Pays sélectionné',
  },
  'no_data': {
    'tr': 'Veri bulunamadı',
    'en': 'No data found',
    'de': 'Keine Daten gefunden',
    'fr': 'Aucune donnée trouvée',
  },
  'weather_world': {
    'tr': 'Weather World',
    'en': 'Weather World',
    'de': 'Weather World',
    'fr': 'Weather World',
  },
  'country_code_missing': {
    'tr': 'Ülke kodu alınamadı!',
    'en': 'Country code could not be fetched!',
    'de': 'Ländercode konnte nicht abgerufen werden!',
    'fr': 'Le code pays n’a pas pu être récupéré!',
  },
  'all_countries_temps_fetched': {
    'tr': '✅ Tüm ülkelerin sıcaklıkları çekildi.',
    'en': '✅ All countries temperatures fetched.',
    'de': '✅ Alle Länder-Temperaturen abgerufen.',
    'fr': '✅ Toutes les températures des pays récupérées.',
  },
  'location_error': {
    'tr': 'Konum alınırken hata oluştu. Loglara bakın.',
    'en': 'Error while fetching location. Check logs.',
    'de': 'Fehler beim Abrufen des Standorts. Prüfen Sie die Logs.',
    'fr':
        'Erreur lors de la récupération de la localisation. Vérifiez les logs.',
  },
  'location_city_failed': {
    'tr':
        'Konumdan şehir elde edilemedi. Ağ veya geocoder sorununu kontrol edin.',
    'en':
        'City could not be obtained from location. Check network or geocoder.',
    'de':
        'Stadt konnte nicht aus dem Standort ermittelt werden. Netzwerk oder Geocoder prüfen.',
    'fr':
        'La ville n’a pas pu être obtenue depuis la localisation. Vérifiez le réseau ou le géocodeur.',
  },
  'location_perm_denied_forever': {
    'tr': 'Konum izni kalıcı olarak reddedildi. Ayarlardan verin.',
    'en': 'Location permission permanently denied. Give it from settings.',
    'de':
        'Standortberechtigung dauerhaft verweigert. In den Einstellungen gewähren.',
    'fr':
        'Permission de localisation refusée définitivement. Accordez-la depuis les paramètres.',
  },
  'location_perm_denied': {
    'tr': 'Konum izni reddedildi. İzin verin.',
    'en': 'Location permission denied. Please allow it.',
    'de': 'Standortberechtigung verweigert. Bitte erlauben.',
    'fr': 'Permission de localisation refusée. Veuillez l’autoriser.',
  },
  'location_service_disabled': {
    'tr': 'Konum servisi kapalı. Lütfen cihaz konumunu açın.',
    'en': 'Location service disabled. Please enable device location.',
    'de': 'Standortdienst deaktiviert. Bitte Geräteortung aktivieren.',
    'fr':
        'Service de localisation désactivé. Veuillez activer la localisation de l’appareil.',
  },
  'fetching_location': {
    'tr': 'Konum alınıyor...',
    'en': 'Fetching location...',
    'de': 'Standort wird abgerufen...',
    'fr': 'Récupération de la localisation...',
  },
  'error_prefix': {
    'tr': 'Hata: ',
    'en': 'Error: ',
    'de': 'Fehler: ',
    'fr': 'Erreur : ',
  },
  'weather_fetch_error': {
    'tr': 'Hava durumu fetch error: ',
    'en': 'Weather fetch error: ',
    'de': 'Fehler beim Abrufen des Wetters: ',
    'fr': 'Erreur lors de la récupération de la météo : ',
  },
  'country_weather_failed': {
    'tr': ' hava durumu alınamadı: ',
    'en': ' weather could not be fetched: ',
    'de': ' Wetter konnte nicht abgerufen werden: ',
    'fr': ' Impossible de récupérer la météo : ',
  },
  'location_assigned': {
    'tr': 'Konum atandı: ',
    'en': 'Location assigned: ',
    'de': 'Standort zugewiesen: ',
    'fr': 'Emplacement attribué : ',
  },
};

void main() => runApp(const HavaDurumuApp());

class HavaDurumuApp extends StatelessWidget {
  const HavaDurumuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      home: _HavaDurumuSayfasi(),
    );
  }
}

class _HavaDurumuSayfasi extends StatefulWidget {
  const _HavaDurumuSayfasi();

  @override
  State<_HavaDurumuSayfasi> createState() => __HavaDurumuSayfasiState();
}

class __HavaDurumuSayfasiState extends State<_HavaDurumuSayfasi> {
  double? _lastTemp;
  String? secilenUlke;
  Future<WeatherModel>? havaDurumu;
  Map<String, double?> countryTemps = {};

  Future<void> _useDeviceLocationAndSetCity(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Color.fromARGB(255, 51, 51, 51),
        content: Text(
          texts['fetching_location']?[getDeviceLanguageCode()] ??
              'Fetching location...',
          style: TextStyle(color: Colors.amber, fontSize: 22),
          textAlign: TextAlign.center,
        ),
      ),
    );

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 51, 51, 51),
            content: Text(
              texts['location_service_disabled']?[getDeviceLanguageCode()] ??
                  'Location service disabled. Please enable device location.',
              style: TextStyle(color: Colors.amber, fontSize: 22),
              textAlign: TextAlign.center,
            ),
          ),
        );
        debugPrint('Location service disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              backgroundColor: Color.fromARGB(255, 51, 51, 51),
              content: Text(
                texts['location_perm_denied']?[getDeviceLanguageCode()] ??
                    'Location permission denied. Please allow it.',
                style: TextStyle(color: Colors.amber, fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
          );
          debugPrint('Location permission denied');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 51, 51, 51),
            content: Text(
              texts['location_perm_denied_forever']?[getDeviceLanguageCode()] ??
                  'Location permission permanently denied. Give it from settings.',
              style: TextStyle(color: Colors.amber, fontSize: 22),
              textAlign: TextAlign.center,
            ),
          ),
        );
        debugPrint('Location permission denied forever');
        return;
      }

      Position? pos = await Geolocator.getLastKnownPosition();
      pos ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint('Position: ${pos.latitude}, ${pos.longitude}');

      // 1) Önce platform geocoder'ı dene
      List<Placemark> placemarks = [];
      try {
        placemarks = await placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
          localeIdentifier: 'tr_TR',
        );
        debugPrint('placemarks (platform): $placemarks');
      } catch (e) {
        debugPrint(
          'placemarkFromCoordinates ${texts['error_prefix']?[getDeviceLanguageCode()]} $e',
        );
      }

      String? city;
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        city = pm.locality ?? pm.subAdministrativeArea ?? pm.administrativeArea;
        debugPrint('City from placemark: $city');
      }

      // 2) Eğer platform geocoder boş döndüyse OpenWeatherMap reverse geocoding ile dene
      if (city == null || city.isEmpty) {
        try {
          final apiKey = dio.options.queryParameters['appid'] as String? ?? '';
          final resp = await Dio().get(
            'https://api.openweathermap.org/geo/1.0/reverse',
            queryParameters: {
              'lat': pos.latitude,
              'lon': pos.longitude,
              'limit': 1,
              'appid': apiKey,
              'lang': getDeviceLanguageCode(),
            },
          );
          debugPrint('OpenWeather reverse resp: ${resp.data}');
          if (resp.data is List && (resp.data as List).isNotEmpty) {
            final item = (resp.data as List).first;
            city =
                (item['name'] as String?) ??
                (item['local_names'] != null
                    ? (item['local_names']['tr'] as String?)
                    : null) ??
                city;
            debugPrint('City from OpenWeather reverse: $city');
          }
        } catch (e) {
          debugPrint(
            'OpenWeather reverse geocode ${texts['error_prefix']?[getDeviceLanguageCode()]}: $e',
          );
        }
      }

      if (city == null || city.isEmpty) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              texts['location_city_failed']?[getDeviceLanguageCode()] ??
                  'City could not be obtained from location. Check network or geocoder.',
              style: TextStyle(color: Colors.amber, fontSize: 22),
              textAlign: TextAlign.center,
            ),
          ),
        );
        debugPrint('City still empty after both methods');
        return;
      }

      setState(() {
        secilenUlke = city;
        havaDurumu = getWeather(city!);
      });

      havaDurumu!
          .then((model) => setState(() => _lastTemp = model.main?.temp))
          .catchError((e) => debugPrint('Weather load error: $e'));

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 51, 51, 51),
          content: Text(
            '${texts['location_assigned']?[getDeviceLanguageCode()]} $city',
            style: TextStyle(color: Colors.amber, fontSize: 22),
            textAlign: TextAlign.center,
          ),
        ),
      );
      debugPrint('Location success, city: $city');
    } catch (e, st) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 51, 51, 51),
          content: Text(
            texts['location_error']?[getDeviceLanguageCode()] ??
                'Error while fetching location. Check logs.',
            style: TextStyle(color: Colors.amber, fontSize: 22),
            textAlign: TextAlign.center,
          ),
        ),
      );
      debugPrint('Error getting location: $e\n$st');
    }
  }

  void selectedCountry(String ulke) {
    setState(() {
      if (secilenUlke == ulke) {
        secilenUlke = null;
        havaDurumu = null;
        _lastTemp = null;
      } else {
        secilenUlke = ulke;
        havaDurumu = getWeather(ulke);

        havaDurumu!
            .then((model) {
              setState(() {
                _lastTemp = model.main?.temp;
                countryTemps[ulke] = model.main?.temp; // 🔹 sıcaklık kaydı
              });
            })
            .catchError((_) {
              setState(() {
                _lastTemp = null;
                countryTemps[ulke] = null;
              });
            });
      }
    });
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/2.5/',
      queryParameters: {
        'appid': 'abbfebf7bdfbe772d0a94fb270654739',
        'units': 'metric',
        'lang': getDeviceLanguageCode(),
      },
    ),
  );

  Future<WeatherModel> getWeather(String secilenUlke) async {
    final replacements = {
      'South Korea': 'Republic of Korea,KR',
      'South Africa': 'Republic of South Africa,ZA',
      'Saint Kitts and Nevis': '	Federation of Saint Kitts and Nevis,KN',
      'Palestine State': 'Gaza,PS',
      'Myanmar (formerly Burma)': '	Union of Burma,MM',
      'Holy See': 'Vatican City,VA',
      'Eswatini (fmr. Swaziland)': 'Eswatini,SZ',
      'Czechia (Czech Republic)': 'Czechia,CZ',
      'Congo (Congo-Brazzaville)': 'Republic of the Congo,CG',
      'India': '	Republic of India',
    };

    final query = replacements[secilenUlke] ?? secilenUlke;

    try {
      final response = await dio.get('/weather', queryParameters: {'q': query});
      var model = WeatherModel.fromJson(response.data);
      debugPrint('Weather loaded: ${model.name}');
      return model;
    } on DioError catch (e) {
      debugPrint('DioError: ${e.type} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unknown error: $e');
      rethrow;
    }
  }

  String _capitalizeFirst(String? s) {
    if (s == null) return '';
    final trimmed = s.trim();
    if (trimmed.isEmpty) return '';
    return trimmed
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return word;
          final first = word[0];
          final rest = word.length > 1 ? word.substring(1) : '';
          final upperFirst = (first == 'i') ? 'İ' : first.toUpperCase();
          return upperFirst + rest;
        })
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    fetchAllCountriesWeather();

    // Uygulama açıldığında konum otomatik alınsın
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _useDeviceLocationAndSetCity(context);
    });
  }

  Future<void> fetchAllCountriesWeather() async {
    for (final ulke in ulkeler) {
      try {
        final weather = await getWeather(ulke);
        setState(() {
          countryTemps[ulke] = weather.main?.temp;
        });
        await Future.delayed(
          const Duration(milliseconds: 0),
        ); // API yükünü azaltır
      } catch (e) {
        debugPrint(
          '⚠️ $ulke ${texts['country_weather_failed']?[getDeviceLanguageCode()]} $e',
        );
        setState(() {
          countryTemps[ulke] = null;
        });
      }
    }
    debugPrint(texts['all_countries_temps_fetched']?[getDeviceLanguageCode()]);
  }

  Widget _builderWeatherInfoCard(WeatherModel weather) {
    final name = weather.name ?? '--';
    final country = weather.sys?.country ?? '';
    final temp = weather.main?.temp;
    final tempStr = temp != null ? '${temp.toStringAsFixed(1)}°C' : '--';
    final descriptionRaw =
        (weather.weather != null && weather.weather!.isNotEmpty)
        ? (weather.weather![0].description ?? '')
        : '';
    final description = _capitalizeFirst(descriptionRaw);
    final humidity = weather.main?.humidity?.toString() ?? '--';
    final wind = weather.wind?.speed?.toString() ?? '--';

    return GestureDetector(
      onTap: () async {
        if (secilenUlke != null && havaDurumu != null) {
          try {
            final weather = await havaDurumu!;
            final countryCode = weather.sys?.country;
            final countryName = weather.name;
            if (countryCode != null && countryCode.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CityListScreen(
                    countryCode: countryCode,
                    countryName: countryName.toString(),
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    texts['country_code_missing']?[getDeviceLanguageCode()] ??
                        'Country code could not be fetched!',
                  ),
                ),
              );
            }
          } catch (e) {
            debugPrint(
              '${texts['weather_fetch_error']?[getDeviceLanguageCode()]} $e',
            );
          }
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$name${country.isNotEmpty ? ', $country ' : ''}',
            style: const TextStyle(fontSize: 35, fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            tempStr,
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
              fontSize: 54,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
          Text(
            description,
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
                    '${texts['humidity']?[getDeviceLanguageCode()]}: $humidity%',
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
                    '${texts['wind']?[getDeviceLanguageCode()]}: $wind ${texts['m_s']?[getDeviceLanguageCode()]}',
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

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    if (_lastTemp != null) {
      if (_lastTemp! >= 30) {
        bgColor = Colors.red.shade100;
      }
      if (_lastTemp! >= 20 && _lastTemp! < 30) {
        bgColor = Colors.orange.shade100;
      }
      if (_lastTemp! >= 10 && _lastTemp! < 20) {
        bgColor = Colors.green.shade100;
      }
      if (_lastTemp! < 10) {
        bgColor = Colors.blue.shade100;
      }
    }
    Color getColorByTempGridview(double? temp) {
      if (temp == null) return Colors.grey.shade300;
      if (temp >= 30) return Colors.red.shade300;
      if (temp >= 20) return Colors.orange.shade300;
      if (temp >= 10) return Colors.green.shade300;
      return Colors.blue.shade400;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'LiveWeather',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.normal,
            shadows: [
              // glow + hafif yukarı gölge kombinasyonu
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
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search, color: Colors.white, size: 28),
                label: Text(
                  texts['search_country']?[getDeviceLanguageCode()] ??
                      'Search country',
                  style: const TextStyle(color: Colors.amber, fontSize: 22),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  backgroundColor: const Color.fromARGB(255, 51, 51, 51),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      String query = '';
                      List<String> filtered = ulkeler;
                      return StatefulBuilder(
                        builder: (context, setModalState) {
                          filtered = ulkeler
                              .where(
                                (s) => s.toLowerCase().contains(
                                  query.toLowerCase(),
                                ),
                              )
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
                                      prefixIcon: const Icon(Icons.search),
                                      hintText:
                                          texts['enter_name']?[getDeviceLanguageCode()] ??
                                          'Type country name',
                                    ),
                                    onChanged: (v) =>
                                        setModalState(() => query = v),
                                  ),
                                ),
                                SizedBox(
                                  height: 300,
                                  child: filtered.isEmpty
                                      ? Center(
                                          child: Text(
                                            texts['no_match']?[getDeviceLanguageCode()] ??
                                                'No matching country',
                                          ),
                                        )
                                      : ListView.separated(
                                          shrinkWrap: true,
                                          itemCount: filtered.length,
                                          separatorBuilder: (_, __) =>
                                              const Divider(height: 1),
                                          itemBuilder: (context, index) {
                                            final city = filtered[index];
                                            final isSel = city == secilenUlke;
                                            return ListTile(
                                              title: Text(city),
                                              trailing: isSel
                                                  ? const Icon(
                                                      Icons.check,
                                                      color: Colors.blue,
                                                    )
                                                  : null,
                                              onTap: () {
                                                selectedCountry(city);
                                                Navigator.of(context).pop();
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      '$city ${texts['country_selected']?[getDeviceLanguageCode()]}',
                                                    ),
                                                  ),
                                                );
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
                },
              ),
            ),

            const SizedBox(height: 16),
            if (havaDurumu != null)
              FutureBuilder<WeatherModel>(
                future: havaDurumu,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text(
                      '${texts['error_prefix']?[getDeviceLanguageCode()]}: ${snapshot.error}',
                    );
                  } else if (snapshot.hasData) {
                    final weather = snapshot.data!;
                    if (weather.main!.temp! >= 30) {
                      // Sıcaklık 30°C veya üzerindeyse
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 248, 149, 149),
                              Color.fromARGB(255, 255, 2, 2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              spreadRadius: 10,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: _builderWeatherInfoCard(weather),
                      );
                    } else if (weather.main!.temp! >= 20 &&
                        weather.main!.temp! < 30) {
                      // Sıcaklık 20°C veya üzerindeyse
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 249, 194, 150),
                              Color.fromARGB(255, 241, 95, 4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.4),
                              spreadRadius: 9,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: _builderWeatherInfoCard(weather),
                      );
                    } else if (weather.main!.temp! > 10 &&
                        weather.main!.temp! < 20) {
                      // Sıcaklık 10°C veya altındaysa
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 149, 248, 198),
                              Color.fromARGB(255, 2, 255, 73),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              spreadRadius: 10,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: _builderWeatherInfoCard(weather),
                      );
                    } else if (weather.main!.temp! <= 10) {
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 151, 226, 253),
                              Color.fromARGB(255, 0, 128, 255),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              spreadRadius: 10,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: _builderWeatherInfoCard(weather),
                      );
                    }
                    // If none of the above conditions match, return a default widget
                    return Text(
                      texts['no_data']?[getDeviceLanguageCode()] ??
                          'No data found',
                    );
                  } else {
                    return Text(
                      texts['no_data']?[getDeviceLanguageCode()] ??
                          'No data found',
                    );
                  }
                },
              ),
            SizedBox(height: 12.0),
            ElevatedButton.icon(
              icon: const Icon(Icons.my_location, color: Colors.white),
              style: ElevatedButton.styleFrom(
                elevation: 6,
                backgroundColor: const Color.fromARGB(255, 51, 51, 51),
              ),
              label: Text(
                texts['use_device_location']?[getDeviceLanguageCode()] ??
                    'Use device location',
                style: const TextStyle(color: Colors.amber),
              ),
              onPressed: () async {
                await _useDeviceLocationAndSetCity(context);
              },
            ),
            SizedBox(height: 8.0),

            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 6.0,
                  mainAxisSpacing: 6.0,
                  childAspectRatio: 4 / 1,
                ),
                itemCount: ulkeler.length,
                itemBuilder: (context, index) {
                  final isSelected = secilenUlke == ulkeler[index];
                  final temp = countryTemps[ulkeler[index]];

                  return GestureDetector(
                    onTap: () => selectedCountry(ulkeler[index]),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      color: isSelected
                          ? Colors.blueGrey
                          : getColorByTempGridview(temp),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 6.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                ulkeler[index],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Text(
                                temp != null
                                    ? '${temp.toStringAsFixed(0)}°C'
                                    : '--',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w400,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

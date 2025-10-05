// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hava_durumu_uygulamasi/CityListScreen.dart';
import 'package:hava_durumu_uygulamasi/Models/weatherModel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'countries';

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

  Future<void> _useDeviceLocationAndSetCity(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        backgroundColor: Color.fromARGB(255, 51, 51, 51),
        content: Text(
          'Konum alınıyor...',
          style: TextStyle(color: Colors.amber, fontSize: 22),
          textAlign: TextAlign.center,
        ),
      ),
    );

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            backgroundColor: Color.fromARGB(255, 51, 51, 51),
            content: Text(
              'Konum servisi kapalı. Lütfen cihaz konumunu açın.',
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
            const SnackBar(
              backgroundColor: Color.fromARGB(255, 51, 51, 51),
              content: Text(
                'Konum izni reddedildi. İzin verin.',
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
          const SnackBar(
            backgroundColor: Color.fromARGB(255, 51, 51, 51),
            content: Text(
              'Konum izni kalıcı olarak reddedildi. Ayarlardan verin.',
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
        debugPrint('placemarkFromCoordinates hata: $e');
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
          debugPrint('OpenWeather reverse geocode hata: $e');
        }
      }

      if (city == null || city.isEmpty) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Konumdan şehir elde edilemedi. Ağ veya geocoder sorununu kontrol edin.',
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
        havaDurumu = getWeather(city!); // <-- city! ile non-null olarak geçir
      });

      havaDurumu!
          .then((model) => setState(() => _lastTemp = model.main?.temp))
          .catchError((e) => debugPrint('Weather load error: $e'));

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 51, 51, 51),
          content: Text(
            'Konum atandı: $city',
            style: TextStyle(color: Colors.amber, fontSize: 22),
            textAlign: TextAlign.center,
          ),
        ),
      );
      debugPrint('Location success, city: $city');
    } catch (e, st) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: Color.fromARGB(255, 51, 51, 51),
          content: Text(
            'Konum alınırken hata oluştu. Loglara bakın.',
            style: TextStyle(color: Colors.amber, fontSize: 22),
            textAlign: TextAlign.center,
          ),
        ),
      );
      debugPrint('Error getting location: $e\n$st');
    }
  }

  void selectedCity(String ulke) {
    setState(() {
      if (secilenUlke == ulke) {
        // aynı şehre tekrar tıklanırsa seçimi kaldır
        secilenUlke = null;
        havaDurumu = null;
        _lastTemp = null;
      } else {
        secilenUlke = ulke;
        havaDurumu = getWeather(ulke);
        // future tamamlandığında son sıcaklığı sakla
        havaDurumu!
            .then((model) {
              setState(() {
                _lastTemp = model.main?.temp;
              });
            })
            .catchError((_) {
              // hata durumunda reset veya log istersen buraya ekle
              setState(() => _lastTemp = null);
            });
      }
    });
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/2.5/',
      queryParameters: {
        'appid':
            'abbfebf7bdfbe772d0a94fb270654739', // Replace with your OpenWeatherMap API key
        'units': 'metric',
        'lang': 'tr',
      },
    ),
  );

  Future<WeatherModel> getWeather(String secilenUlke) async {
    try {
      final response = await dio.get(
        '/weather',
        queryParameters: {'q': secilenUlke},
      );
      var model = WeatherModel.fromJson(response.data);
      debugPrint('Weather loaded: ${model.name}');
      return model;
    } on DioError catch (e) {
      debugPrint('DioError: ${e.type} - ${e.message}');
      rethrow; // FutureBuilder'da snapshot.hasError tetiklenir
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

  Widget _builderWeatherInfoCard(WeatherModel weather) {
    // güvenli alanlar
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
            if (countryCode != null && countryCode.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CityListScreen(countryCode: countryCode),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ülke kodu alınamadı!')),
              );
            }
          } catch (e) {
            debugPrint('Hava durumu fetch error: $e');
          }
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$name${country.isNotEmpty ? ', $country' : ''}',
            style: const TextStyle(fontSize: 35, fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            tempStr,
            style: const TextStyle(
              shadows: [
                // glow + hafif yukarı gölge kombinasyonu
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
                    'Nem: $humidity%',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Column(
                children: [
                  const Icon(Icons.air),
                  const SizedBox(height: 4),
                  Text(
                    'Rüzgar: $wind m/s',
                    style: TextStyle(fontWeight: FontWeight.bold),
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Weather Statement',
          style: TextStyle(
            fontSize: 30,
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
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search, color: Colors.white),
                label: const Text(
                  'Şehir ara',
                  style: TextStyle(color: Colors.amber),
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
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.search),
                                      hintText: 'Şehir adı yazın',
                                    ),
                                    onChanged: (v) =>
                                        setModalState(() => query = v),
                                  ),
                                ),
                                SizedBox(
                                  height: 300,
                                  child: filtered.isEmpty
                                      ? const Center(
                                          child: Text('Eşleşen şehir yok'),
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
                                                selectedCity(city);
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
                    return Text('Hata: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final weather = snapshot.data!;
                    if (weather.main!.temp! >= 30) {
                      // Sıcaklık 30°C veya üzerindeyse
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 243, 243, 243),
                              Color.fromARGB(255, 200, 0, 0),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: const Offset(0, 0),
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
                              Color.fromARGB(255, 255, 255, 255),
                              Color.fromARGB(255, 223, 89, 1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: const Offset(0, 0),
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
                              Color.fromARGB(255, 241, 255, 248),
                              Color.fromARGB(255, 2, 224, 65),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: const Offset(0, 0),
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
                              Color.fromARGB(255, 119, 207, 247),
                              Color.fromARGB(255, 40, 54, 176),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: _builderWeatherInfoCard(weather),
                      );
                    }
                    // If none of the above conditions match, return a default widget
                    return const Text('Veri bulunamadı');
                  } else {
                    return const Text('Veri bulunamadı');
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
              label: Text('Konum', style: TextStyle(color: Colors.amber)),
              onPressed: () async {
                await _useDeviceLocationAndSetCity(context);
              },
            ),
            SizedBox(height: 8.0),

            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 4 / 1,
                ),
                itemBuilder: (context, index) {
                  final isSelected = secilenUlke == ulkeler[index];

                  return GestureDetector(
                    onTap: () => selectedCity(ulkeler[index]),
                    child: Card(
                      color: isSelected
                          ? Colors.blueGrey
                          : Colors.grey.shade200,
                      child: Center(
                        child: Text(
                          ulkeler[index],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: ulkeler.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

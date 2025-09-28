// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hava_durumu_uygulamasi/Models/weatherModel.dart';
import 'package:hava_durumu_uygulamasi/info_screen.dart';

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
  final List<String> sehirler = [
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Amasya',
    'Ankara',
    'Antalya',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkari',
    'Hatay',
    'Isparta',
    'Mersin',
    'İstanbul',
    'İzmir',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kırklareli',
    'Kırşehir',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Kahramanmaraş',
    'Mardin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Rize',
    'Sakarya',
    'Samsun',
    'Siirt',
    'Sinop',
    'Sivas',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Şanlıurfa',
    'Uşak',
    'Van',
    'Yozgat',
    'Zonguldak',
    'Aksaray',
    'Bayburt',
    'Karaman',
    'Kırıkkale',
    'Batman',
    'Şırnak',
    'Bartın',
    'Ardahan',
    'Iğdır',
    'Yalova',
    'Karabük',
    'Kilis',
    'Osmaniye',
    'Düzce',
  ];

  double? _lastTemp;
  String? secilenSehir;
  Future<WeatherModel>? havaDurumu;

  void selectedCity(String sehir) {
    setState(() {
      if (secilenSehir == sehir) {
        // aynı şehre tekrar tıklanırsa seçimi kaldır
        secilenSehir = null;
        havaDurumu = null;
        _lastTemp = null;
      } else {
        secilenSehir = sehir;
        havaDurumu = getWeather(sehir);
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

  Future<WeatherModel> getWeather(String secilenSehir) async {
    try {
      final response = await dio.get(
        '/weather',
        queryParameters: {'q': secilenSehir},
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

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '$name${country.isNotEmpty ? ', $country' : ''}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            TextButton.icon(
              iconAlignment: IconAlignment.end,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfoScreen(sehirDetay: weather),
                  ),
                );
              },
              label: Icon(Icons.info),
              style: TextButton.styleFrom(iconSize: 30),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          tempStr,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(fontSize: 18),
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
                Text('Nem: $humidity%'),
              ],
            ),
            const SizedBox(width: 30),
            Column(
              children: [
                const Icon(Icons.air),
                const SizedBox(height: 4),
                Text('Rüzgar: $wind m/s'),
              ],
            ),
          ],
        ),
      ],
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
        title: const Text('Hava Durumu'),
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
            SizedBox(height: 16.0),

            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 4 / 1,
                ),
                itemBuilder: (context, index) {
                  final isSelected = secilenSehir == sehirler[index];
                  return GestureDetector(
                    onTap: () => selectedCity(sehirler[index]),
                    child: Card(
                      color: isSelected ? Colors.blueGrey : Colors.white,
                      child: Center(
                        child: Text(
                          sehirler[index],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: sehirler.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

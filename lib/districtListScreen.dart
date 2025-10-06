import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hava_durumu_uygulamasi/Models/weatherModel.dart';

class DistrictListScreen extends StatefulWidget {
  final String cityName;
  final String countryCode;
  final int cityGeonameId; // CityListScreen’den geliyor

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

  final dioWeather = Dio(
    BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/2.5/',
      queryParameters: {
        'appid': 'abbfebf7bdfbe772d0a94fb270654739',
        'units': 'metric',
        'lang': 'tr',
      },
    ),
  );

  @override
  void initState() {
    super.initState();
    fetchDistricts();
  }

  String cleanDistrictName(String name) {
    name = name.trim(); // baştaki/sondaki boşlukları temizle

    // 🔹 İlçeyi ifade eden kelimeler (sonda olursa sil)
    final suffixes = <String>[
      ' ilçesi', // Türkçe
      ' District', // İngilizce
      ' Bezirk', // Almanca
      ' arrondissement', // Fransızca
      ' Municipio', // İspanyolca / İtalyanca
      ' Comune', // İtalyanca
      ' Parish', // İngilizce (özellikle Karayipler)
    ];

    // 🔹 Başta olursa silinecek kelimeler
    final prefixes = <String>[
      'Bashkia', 'Gueltat', 'Daïra de', 'Daïra d’', // Arnavutça: Belediye
    ];

    // Başta geçen kelimeleri sil
    for (final prefix in prefixes) {
      if (name.toLowerCase().startsWith(prefix.toLowerCase())) {
        name = name.substring(prefix.length).trim();
      }
    }

    // Sonda geçen kelimeleri sil
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
          'lang': 'eng',
        },
      );

      final data = response.data['geonames'] as List;

      setState(() {
        districts = data
            .where((e) => e['fcode'] == 'ADM2' || e['fcode'] == 'PPL')
            .map((e) => cleanDistrictName(e['name'] as String))
            .toList();

        // 🔹 Alfabetik sırala
        districts.sort((a, b) => a.compareTo(b));

        if (districts.isEmpty) {
          districts.add('İlçe bulunamadı');
        }

        isLoading = false;
      });
    } catch (e) {
      debugPrint('GeoNames error: $e');
      setState(() {
        districts = ['İlçe bulunamadı'];
        isLoading = false;
      });
    }
  }

  Future<WeatherModel?> getWeather(String district) async {
    try {
      if (district == 'İlçe bulunamadı') return null;
      final response = await dioWeather.get(
        '/weather',
        queryParameters: {'q': '$district,${widget.countryCode}'},
      );
      return WeatherModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Weather fetch error for $district: $e');
      return null; // hata durumunda null
    }
  }

  Color _getTempColor(double temp) {
    if (temp > 30) return Colors.redAccent.shade400;
    if (temp > 20) return Colors.orangeAccent.shade400;
    if (temp > 10) return Colors.greenAccent.shade400;
    return Colors.lightBlueAccent.shade400;
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
    final name = weather.name ?? '--';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _getTempColor(temp),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$name',
            style: const TextStyle(fontSize: 35, fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            temp.toString(),
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

  Widget _defaultCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 6,
      child: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Bir ilçe seçin',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Icon(Icons.location_city, size: 40, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cityName, // 👈 artık ülke ismi burada
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
                FutureBuilder<WeatherModel?>(
                  key: ValueKey(selectedDistrict),
                  future: districtWeather,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasData && snapshot.data != null) {
                      return _weatherCard(snapshot.data!);
                    } else {
                      return _defaultCard();
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
                      itemCount: districts.length,
                      itemBuilder: (context, index) {
                        final district = districts[index];
                        final isSel = district == selectedDistrict;
                        return GestureDetector(
                          onTap: () {
                            if (selectedDistrict != district) {
                              setState(() {
                                selectedDistrict = district;
                                districtWeather = getWeather(district);
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSel
                                  ? Colors.blueGrey
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                district,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
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

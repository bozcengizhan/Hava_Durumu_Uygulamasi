import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hava_durumu_uygulamasi/Models/weatherModel.dart';
import 'package:hava_durumu_uygulamasi/districtListScreen.dart';

class CityListScreen extends StatefulWidget {
  final String countryCode;
  const CityListScreen({super.key, required this.countryCode});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  List<Map<String, dynamic>> cities = []; // name ve geonameId
  bool isLoading = true;

  String? selectedCity;
  Future<WeatherModel>? cityWeather;

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
    fetchCities();
  }

  Future<void> fetchCities() async {
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
        },
      );
      final data = response.data['geonames'] as List;
      setState(() {
        cities = data
            .map((e) => {'name': e['name'], 'geonameId': e['geonameId']})
            .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('GeoNames error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<WeatherModel> getWeather(String city) async {
    try {
      final response = await dioWeather.get(
        '/weather',
        queryParameters: {'q': '$city,${widget.countryCode}'},
      );
      return WeatherModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Weather fetch error: $e');
      rethrow;
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
      child: GestureDetector(
        onTap: () {
          final selected = cities.firstWhere(
            (c) => c['name'] == selectedCity,
            orElse: () => {},
          );
          final geonameId = selected['geonameId'];
          if (geonameId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DistrictListScreen(
                  countryCode: widget.countryCode,
                  cityName: name,
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
              '$name',
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              temp.toString(),
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
              'Bir şehir seçin',
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
      appBar: AppBar(title: const Text('Şehirler')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                FutureBuilder<WeatherModel>(
                  future: cityWeather,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasData) {
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
                      itemCount: cities.length,
                      itemBuilder: (context, index) {
                        final city = cities[index]['name'] as String;
                        final isSel = city == selectedCity;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCity = city;
                              cityWeather = getWeather(city);
                            });
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
                                city,
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

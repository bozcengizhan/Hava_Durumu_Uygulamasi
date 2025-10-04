import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CountryCitiesPage extends StatefulWidget {
  final String country;

  const CountryCitiesPage({super.key, required this.country});

  @override
  State<CountryCitiesPage> createState() => _CountryCitiesPageState();
}

class _CountryCitiesPageState extends State<CountryCitiesPage> {
  List<String> cities = [];
  bool loading = true;
  String? error;

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://api.geonames.org/',
      queryParameters: {
        'username': 'demo', // kendi GeoNames username'ini buraya koy
      },
    ),
  );

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  Future<void> fetchCities() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await dio.get(
        'searchJSON',
        queryParameters: {
          'country': widget
              .country, // GeoNames country code değil, ülke adı istiyor olabilir
          'featureClass': 'P', // 'P' = populated place
          'maxRows': 100,
          'orderby': 'population',
        },
      );

      final data = response.data['geonames'] as List<dynamic>;
      final fetchedCities = data
          .map((e) => e['name'].toString())
          .toSet()
          .toList(); // unique
      fetchedCities.sort();
      setState(() {
        cities = fetchedCities;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Şehirler alınamadı: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Şehirler: ${widget.country}')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : ListView.separated(
              itemCount: cities.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(title: Text(cities[index]));
              },
            ),
    );
  }
}

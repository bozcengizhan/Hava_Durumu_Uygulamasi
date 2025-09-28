import 'package:flutter/material.dart';
import 'package:hava_durumu_uygulamasi/Models/weatherModel.dart';

class InfoScreen extends StatelessWidget {
  final WeatherModel sehirDetay;
  const InfoScreen({super.key, required this.sehirDetay});

  @override
  Widget build(BuildContext context) {
    final name = sehirDetay.name ?? '--';
    final country = sehirDetay.sys?.country ?? '';
    final temp = sehirDetay.main?.temp;
    final tempStr = temp != null ? '${temp.toStringAsFixed(1)}°C' : '--';
    final descriptionRaw =
        (sehirDetay.weather != null && sehirDetay.weather!.isNotEmpty)
        ? (sehirDetay.weather![0].description ?? '')
        : '';
    final description = descriptionRaw;
    final humidity = sehirDetay.main?.humidity?.toString() ?? '--';
    final wind = sehirDetay.wind?.speed?.toString() ?? '--';

    Color bgColor = Colors.white;
    bgColor = info_screen_background_color(bgColor);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          name + " " + country,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Color.fromARGB(255, 64, 109, 255)],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Text(tempStr),
            Text(descriptionRaw),
            Text(description),
            Text(humidity),
            Text(wind),
          ],
        ),
      ),
    );
  }

  Color info_screen_background_color(Color bgColor) {
    if (sehirDetay.main!.temp! >= 30) {
      bgColor = Colors.red.shade100;
    } else if (sehirDetay.main!.temp! >= 20 && sehirDetay.main!.temp! < 30) {
      bgColor = Colors.orange.shade100;
    } else if (sehirDetay.main!.temp! >= 10 && sehirDetay.main!.temp! < 20) {
      bgColor = Colors.green.shade100;
    } else {
      bgColor = Colors.blue.shade100;
    }
    return bgColor;
  }
}

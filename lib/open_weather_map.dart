import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

class OpenWeatherMap {
  static const baseUrl = 'http://api.openweathermap.org/data/2.5';
  final apiKey;

  OpenWeatherMap({@required this.apiKey}) : assert(apiKey != null);

  Future<Weather> fetchWeatherByLocation(
      {@required double latitude,
      @required double longitude,
      String units}) async {
    var url = '$baseUrl/weather/?lat=$latitude&lon=$longitude&appid=$apiKey';
    if (units.isNotEmpty) {
      url += "&units=$units";
    }
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: unable to fetch weather data");
    }
    final weatherJson = json.decode(res.body);
    return Weather.fromJson(weatherJson);
  }
}

class Weather {
  String icon;
  String cityName;
  double temperature;

  Weather({
    this.cityName,
    this.temperature,
    this.icon,
  });

  static Weather fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'],
      icon:
          'http://openweathermap.org/img/wn/${json['weather'][0]['icon']}@2x.png',
    );
  }
}

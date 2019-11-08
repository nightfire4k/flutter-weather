import 'package:flutter/material.dart';
import 'env.dart';
import 'open_weather_map.dart';

void main() async {
  await Env.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherPage(title: 'City'),
    );
  }
}

class WeatherPage extends StatefulWidget {
  WeatherPage({this.title});
  final String title;

  @override
  _WeatherPageState createState() => _WeatherPageState(title: title);
}

class _WeatherPageState extends State<WeatherPage> {
  _WeatherPageState({this.title});
  String title;
  bool _isLoading = false;
  Weather weather;

  fetchWeather() async {
    if (!mounted) throw Exception("Widget not ready");

    setState(() {
      _isLoading = true;
    });

    try {
      final openWeather = OpenWeatherMap(apiKey: Env.openWeatherMapApiKey);
      weather = await openWeather.fetchWeatherByLocation(
          latitude: 25.761681, longitude: -80.191788, units: "metric");
      title = weather.cityName;
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : fetchWeather,
          )
        ],
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : WeatherPageBody(weather: weather),
      ),
    );
  }
}

class WeatherPageBody extends StatelessWidget {
  WeatherPageBody({this.weather});
  final Weather weather;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        weather != null ? Image.network(weather.icon) : Container(),
        Text(
          (weather != null ? weather.temperature.toString() : "?") + "°",
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

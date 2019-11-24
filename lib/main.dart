import 'package:flutter/material.dart';
import 'env.dart';
import 'open_weather_map.dart';
import 'package:location/location.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';

void main() async {
  await Env.init();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          color: Colors.white,
          brightness: Brightness.light
        )
      ),
      home: WeatherPage(title: 'City'),
    );
  }
}

class WeatherPage extends StatefulWidget {
  WeatherPage({this.title});
  final String title;

  @override
  _WeatherPageState createState() => _WeatherPageState(cityName: title);
}

class _WeatherPageState extends State<WeatherPage> {
  _WeatherPageState({this.cityName});
  String cityName;
  bool _isLoading = false;
  Weather weather;
  LocationData currentLocation;
  Location location = new Location();

  fetchWeather() async {
    if (!mounted) throw Exception("Widget not ready");

    setState(() {
      _isLoading = true;
    });

    try {
      currentLocation = await location.getLocation();
      print(currentLocation.longitude);
      final openWeather = OpenWeatherMap(apiKey: Env.openWeatherMapApiKey);
      weather = await openWeather.fetchWeatherByLocation(
          latitude: currentLocation.latitude , longitude: currentLocation.longitude, units: "metric");
      cityName = weather.cityName;
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
        title: FancyShimmerText(Text("Premium Weather Deluxe Edition")),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black54,),
            onPressed: _isLoading ? null : fetchWeather,
          )
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25)
          )
        ),
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
    return weather != null ?
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(weather.icon),
        FancyShimmerText(Text(
              weather.temperature.toString() + "°",
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            )
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.location_on),
            Text(weather.cityName)
          ],
        )
      ],
    ) : Container();
  }
}

class FancyShimmerText extends StatelessWidget {
  FancyShimmerText(this.text);
  final Text text;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.lightBlue,
      highlightColor: Colors.purpleAccent,
      child: text
    );
  }
}



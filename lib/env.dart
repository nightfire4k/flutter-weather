import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get openWeatherMapApiKey =>
      DotEnv().env['OPENWEATHERMAP_API_KEY'];

  static init() async {
    await DotEnv().load('.env');
  }
}

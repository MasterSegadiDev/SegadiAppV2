import 'package:segadi/core/config/app_enviroment.dart';

class Env {
  static Environment environment = Environment.dev;

  static bool get isDev => environment == Environment.dev;

  static bool get isQa => environment == Environment.qa;

  static bool get isProd => environment == Environment.prod;
}

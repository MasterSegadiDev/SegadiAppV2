import 'app_enviroment.dart';

class AppConfig {
  static late Environment environment;

  static void initialize(
    Environment env,
  ) {
    environment = env;
  }

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.development:
        //return 'http://198.251.68.42/DesarrolloSEGADI/web/index.php?r=esegadi';
        // return 'http://10.0.2.2:3000';
        return 'https://stage.segadi.linkthinks.com:6011/api/mobile';

      case Environment.production:
        return 'http://198.251.68.42/SEGADI/web/index.php?r=esegadi';
    }
  }

  static String get airbagBaseUrl {
    switch (environment) {
      case Environment.development:
        return '';

      case Environment.production:
        return 'https://sync.airbagtech.io/driver/';
    }
  }
}

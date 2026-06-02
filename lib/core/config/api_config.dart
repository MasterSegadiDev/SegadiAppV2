import 'package:segadi/core/config/app_enviroment.dart';

import 'env.dart';

class ApiConfig {
  static String get segadiBaseUrl {
    switch (Env.environment) {
      case Environment.dev:
        return 'http://198.251.68.42/DesarrolloSEGADI/web/';

      case Environment.qa:
        return '';

      case Environment.prod:
        return 'http://198.251.68.42/SEGADI/web/';
    }
  }

  static String get airbagBaseUrl {
    switch (Env.environment) {
      case Environment.dev:
      case Environment.qa:
      case Environment.prod:
        return 'https://sync.airbagtech.io/driver/';
    }
  }

  static const Duration timeout = Duration(seconds: 60);

  static const Duration uploadTimeout = Duration(seconds: 120);

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> get airbagHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': airbagApiKey,
      };

  static String get airbagApiKey {
    switch (Env.environment) {
      case Environment.dev:
        return 'apikey 5dd2063066755195541b0e82b9bfb196398851c681b2c0856ed0a06596de79c6';

      case Environment.qa:
        return '';

      case Environment.prod:
        return 'apikey 5dd2063066755195541b0e82b9bfb196398851c681b2c0856ed0a06596de79c6';
    }
  }
}

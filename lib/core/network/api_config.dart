class ApiConfig {
  // SEGADI
  static const String segadiBaseUrl =
      'http://198.251.68.42/DesarrolloSEGADI/web/';

  //static const String segadiBaseUrl = 'http://198.251.68.42/SEGADI/web/';

  static const Duration timeout = Duration(seconds: 15);
  static const Duration uploadTimeout = Duration(seconds: 120);

  // AIRBAG
  static const String airbagBaseUrl = 'https://sync.airbagtech.io/driver/';
  static const String airbagApiKey =
      'apikey 5dd2063066755195541b0e82b9bfb196398851c681b2c0856ed0a06596de79c6';

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> get airbagHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': airbagApiKey,
      };
}

class GlobalVariables {
  //delete on production
  static String baseUrl = 'http://198.251.68.42/DesarrolloSEGADI/web/';
  // add only production
  //static String baseUrl = 'http://198.251.68.42/SEGADI/web/';

  //headers to call api develop or production
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  //save token
  static String token = '';

  //id service detail to functions services
  static int serviceDetailId = 0;
}

class GlobalVariablesAirbag {
  //documentation airbag https://docs.airbagtech.io/docs/actividades
  // api of airbag, url basic
  static String baseUrl = 'https://sync.airbagtech.io/driver/';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'apikey 5dd2063066755195541b0e82b9bfb196398851c681b2c0856ed0a06596de79c6'
  };
}

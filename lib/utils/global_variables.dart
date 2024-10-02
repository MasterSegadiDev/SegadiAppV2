class GlobalVariables {
  //delete on production
  static String baseUrl = 'http://198.251.68.42/DesarrolloSEGADI/web/';
  // add only production
  // static String baseUrl = 'http://198.251.68.42/SEGADI/web/index.php?r=esegadi/';

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

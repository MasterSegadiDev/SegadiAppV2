import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:segadi/screens/home/routes.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Segadi',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home_page': (context) => HomePage(),
        '/services': (context) => ServicesScreen(),
        '/detail_service': (context) => DetailServicesScreen(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:segadi/screens/home/routes.dart';
import 'package:segadi/screens/services/finished_services.dart';

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
        '/home_page': (context) => const HomeScreen(),
        '/services': (context) => const ServicesScreen(),
        '/services_finished': (context) => const FinishServiceList(),
        '/detail_service': (context) => const DetailServicesScreen(),
      },
    );
  }
}

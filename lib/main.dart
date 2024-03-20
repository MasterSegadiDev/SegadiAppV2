import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:segadi/helper/navigator.dart';

import 'package:segadi/view/home/routes.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.instance.navigationKey,
      title: 'Segadi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // home: const LoginScreen(),
      routes: {
        '/': (context) => const LoginScreen(),
        '/home_page': (context) => const HomeScreen(),
        '/services': (context) => const ServicesScreen(),
        '/services_finished': (context) => const FinishServiceList(),
        '/detail_service': (context) => const DetailServicesScreen(
              id: 0,
            ),
        '/detail_service_finished': (context) =>
            const DetailServicesFinishedScreen(id: 0),
        //'/check_list': (context) => const Custom(),

        '/trip_closure': (context) => const TripClosureScreen(
              id: 0,
              serviceId: "",
            ),
        '/travel_expenses': (context) => const TravelExpensesScreen(id: 0),
      },
    );
  }
}

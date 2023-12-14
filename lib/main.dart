import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:segadi/view/home/routes.dart';
import 'package:segadi/view/services/trip_closure.dart';

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /*return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceViewModel()),
      ],
      child: MaterialApp(
        title: 'Segadi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.green,
          brightness: Brightness.light,
          visualDensity: VisualDensity.adaptivePlatformDensity
        ),
        routes: {
          '/': (context) => const LoginScreen(),
          '/home_page': (context) => const HomeScreen(),
          '/services': (context) => const ServicesScreen(),
          '/services_finished': (context) => const FinishServiceList(),
          '/detail_service': (context) => const DetailServicesScreen(
                id: 0,
              ),
          '/detail_service_finished': (context) =>
              const DetailServicesFinishedScreen(
                  id: 0, detailFinished: false, response: {}),
          '/check_list': (context) => const CustomDialog(),
          '/status_support': (context) => const StatusSupport(),
        },
      ),
    );*/
    return MaterialApp(
      title: 'Segadi',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home_page': (context) => const HomeScreen(),
        '/services': (context) => const ServicesScreen(),
        '/services_finished': (context) => const FinishServiceList(),
        '/detail_service': (context) => const DetailServicesScreen(
              id: 0,
            ),
        '/detail_service_finished': (context) =>
            const DetailServicesFinishedScreen(
                id: 0, detailFinished: false, response: {}),
        '/check_list': (context) => const CustomDialog(),
        '/status_support': (context) => const StatusSupport(),
        '/trip_closure': (context) => const TripClosureScreen(),
      },
    );
  }
}

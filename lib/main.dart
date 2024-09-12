import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:segadi/helper/navigator.dart';

import 'package:segadi/view/home/routes.dart';
import 'package:segadi/view_model/home/home_view_model.dart';
import 'package:segadi/view_model/login/biometric_viewmodel.dart';
import 'package:segadi/view_model/login/user_login.dart';
import 'package:segadi/view_model/services_operator/assigned_services.dart';
import 'package:segadi/view_model/services_operator/check_list.dart';

import 'package:segadi/view_model/services_operator/detail_service.dart';
import 'package:segadi/view_model/services_operator/travel_expenses.dart';
import 'package:segadi/view_model/services_operator/trip_closure.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => BiometricViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        //ChangeNotifierProvider(create: (_) => ServicesViewModel().fetchItems()),
        ChangeNotifierProvider(
          create: (_) {
            final serviceViewModel = ServicesViewModel();
            serviceViewModel.fetchItems();
            return serviceViewModel;
          },
        ),
        ChangeNotifierProvider(create: (_) => DetailViewModel()),
        ChangeNotifierProvider(create: (_) => CheckListViewModel()),
        ChangeNotifierProvider(create: (_) => TripClosureViewModel()),
         ChangeNotifierProvider(create: (_) => TravelExpensesViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: NavigationService.instance.navigationKey,
        title: 'Segadi',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        routes: {
          '/': (context) => const LoginView(),
          '/home_page': (context) => const HomeScreen(),
          '/services': (context) => const ServiceListView(),
          '/services_finished': (context) => const FinishServiceList(),
          '/detail_service': (context) => const DetailServiceScreen(),
          '/detail_service_finished': (context) =>
              const DetailServicesFinishedScreen(id: 0),
          'trip_closure': (context) => const TripClosureScreen(),
          '/user': (context) => const UserScreen(),
          '/travel_expenses': (context) => const TravelExpensesScreen(),
        },
      ),
    );
  }
}

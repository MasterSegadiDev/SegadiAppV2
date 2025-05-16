import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:segadi/helper/navigator.dart';
import 'package:segadi/repo/device_info_respository.dart';
import 'package:segadi/services/getDataDevice.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_list_view_model.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';
import 'package:segadi/views/container_movements/container_movement_list_view.dart';

//import 'package:segadi/repo/device_info_respository.dart';

import 'package:segadi/views/home/routes.dart';
import 'package:segadi/viewmodels/devices/device_view_model.dart';
//import 'package:segadi/view_model/devices/device_view_model.dart';
import 'package:segadi/viewmodels/home/home_view_model.dart';
import 'package:segadi/viewmodels/login/biometric_viewmodel.dart';
import 'package:segadi/viewmodels/login/user_login.dart';
import 'package:segadi/viewmodels/services_operator/assigned_services.dart';
import 'package:segadi/viewmodels/services_operator/check_list.dart';

import 'package:segadi/viewmodels/services_operator/detail_service.dart';
import 'package:segadi/viewmodels/services_operator/travel_expenses.dart';
import 'package:segadi/viewmodels/services_operator/trip_closure.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight
  ]);

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('🔴 Error: ${details.exception}');
    print('🧱 Stack: ${details.stack}');
  };

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => BiometricViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
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
        ChangeNotifierProvider(
          create: (_) {
            final loadTableTravelExpenses = TravelExpensesViewModel();
            loadTableTravelExpenses.tableFetchItems();
            return loadTableTravelExpenses;
          },
        ),
        ChangeNotifierProvider(
            create: (_) => DeviceInfoViewModel(
                DeviceInfoRespository(), InfoDeviceSystemERP())),
        ChangeNotifierProvider(create: (_) {
          final data = ContainerMovementListViewModel();
          data.loadMovimientos();
          return data;
        }),
        ChangeNotifierProvider(create: (_) => UbicacionesViewModel()),
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
          '/': (context) => LoginView(),
          '/home_page': (context) => HomeScreen(),
          '/services': (context) => ServiceListView(),
          '/services_finished': (context) => FinishServiceList(),
          '/detail_service': (context) => DetailServiceScreen(),
          '/detail_service_finished': (context) =>
              DetailServicesFinishedScreen(id: 0),
          'trip_closure': (context) => TripClosureScreen(
                id: 0,
                serviceId: '',
              ),
          '/user': (context) => UserScreen(),
          '/travel_expenses': (context) => TravelExpensesScreen(),
          '/container_map': (context) => MovimientoView(),
        },
      ),
    );
  }
}

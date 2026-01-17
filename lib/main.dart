import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// ========================
// SERVICE DETAIL
// ========================
import 'package:segadi/features/service_detail/data/repositories/detail_service_repository_impl.dart';
import 'package:segadi/features/service_detail/presentation/pages/detail_service_page.dart';
import 'package:segadi/features/service_detail/presentation/viewmodel/detail_service_viewmodel.dart';
import 'package:segadi/features/trip_closure/data/trip_closure_repository_impl.dart';
import 'package:segadi/features/trip_closure/presentation/pages/capture_trip_evidence_page.dart';
import 'package:segadi/features/trip_closure/presentation/widget/trip_closure_flow_page.dart';

// ========================
// CORE / OTROS
// ========================
import 'package:segadi/helper/navigator.dart';
import 'package:segadi/services/operatorServices/DetailServiceApi.dart';
import 'package:segadi/services/operatorServices/ServicesListApi.dart';

import 'package:segadi/viewmodels/services_operator/assigned_services.dart';
import 'package:segadi/views/container_movements/container_movement_list_view.dart';
import 'package:segadi/views/login/splash_screen.dart';
import 'package:segadi/views/home/routes.dart';
import 'package:segadi/viewmodels/login/user_login.dart';
import 'package:segadi/viewmodels/login/biometric_viewmodel.dart';
import 'package:segadi/viewmodels/home/home_view_model.dart';

import 'features/trip_closure/presentation/viewmodels/trip_closure_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ========================
        // APIs
        // ========================
        Provider<ServicesApi>(create: (_) => ServicesApi()),
        Provider<DetailServiceApi>(create: (_) => DetailServiceApi()),

        // ========================
        // AUTH / HOME
        // ========================
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => BiometricViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(
          create: (context) => ServicesViewModel(
            context.read<ServicesApi>(),
          ),
        ),
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
          '/': (_) => const SplashScreen(),
          '/login': (_) => LoginView(),
          '/home_page': (_) => HomeScreen(),
          '/services': (_) => ServiceListView(),
          '/services_finished': (_) => FinishServiceList(),

          // ========================
          // DETAIL SERVICE
          // ========================
          '/detail_service': (context) {
            final serviceId = ModalRoute.of(context)!.settings.arguments as int;

            return ChangeNotifierProvider(
              create: (_) => DetailServiceViewModel(
                DetailServiceRepositoryImpl(
                  context.read<DetailServiceApi>(),
                ),
              ),
              child: DetailServicePage(serviceId: serviceId),
            );
          },

          '/trip-closure': (_) => const TripClosureFlowPage(),

          // ========================
          // USERS
          // ========================

          '/user': (context) => UserScreen(),

          // ========================
          // VIATICOS
          // ========================
          '/travel_expenses': (context) => TravelExpensesScreen(),

          // ========================
          // CONTAINER MAP
          // ========================
          '/container_map': (context) =>
              MovimientoView(), //'/container_map': (context) => MovimientoView(),
        },
      ),
    );
  }
}

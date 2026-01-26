import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/firebase_cloud_messaging.dart/data/datasources/fcm_datasource.dart';
import 'package:segadi/features/firebase_cloud_messaging.dart/data/repositories/service_repository_impl.dart';
import 'package:segadi/features/firebase_cloud_messaging.dart/domain/usecases/listen_service_update.dart';

// ========================
// SERVICE DETAIL (SIN CAMBIOS)
// ========================
import 'package:segadi/features/service_detail/data/repositories/detail_service_repository_impl.dart';
import 'package:segadi/features/service_detail/presentation/pages/detail_service_page.dart';
import 'package:segadi/features/service_detail/presentation/viewmodel/detail_service_viewmodel.dart';
import 'package:segadi/features/services_assigned/data/datasources/service_remote_datasource_impl.dart';
import 'package:segadi/features/services_assigned/data/repositories/service_repository_impl.dart';
import 'package:segadi/features/services_assigned/domain/usecases/get_assigned_services.dart';
import 'package:segadi/features/services_assigned/presentation/pages/service_list_page.dart';
import 'package:segadi/features/services_assigned/presentation/viewmodels/services_viewmodel.dart';
import 'package:segadi/features/trip_closure/presentation/widget/trip_closure_flow_page.dart';

// ========================
// CORE / OTROS
// ========================
import 'package:segadi/helper/navigator.dart';
import 'package:segadi/services/operatorServices/DetailServiceApi.dart';

// ⬇️ API legacy (la reutilizamos)
import 'package:segadi/services/operatorServices/ServicesListApi.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_list_view_model.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';

// ========================
// CLEAN ARCH - SERVICES
// ========================
// import 'package:segadi/data/datasources/services_remote_datasource.dart';
// import 'package:segadi/data/repositories/services_repository_impl.dart';
// import 'package:segadi/domain/usecases/get_assigned_services.dart';
// import 'package:segadi/presentation/viewmodels/services_viewmodel.dart';

// ========================
// VIEWS
// ========================
import 'package:segadi/views/login/splash_screen.dart';
import 'package:segadi/views/home/routes.dart';
import 'package:segadi/views/container_movements/container_movement_list_view.dart';

// ========================
// VIEWMODELS EXISTENTES
// ========================
import 'package:segadi/viewmodels/login/user_login.dart';
import 'package:segadi/viewmodels/login/biometric_viewmodel.dart';
import 'package:segadi/viewmodels/home/home_view_model.dart';

//////////////////////////////
/////  FIREBASE PACKAGE //////
/////////////////////////////
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('📩 Background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('🔥 Firebase inicializado correctamente');

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

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
        Provider(create: (_) => FcmDatasource()..init()),

        // ========================
        // AUTH / HOME (SIN CAMBIOS)
        // ========================
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => BiometricViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),

        ChangeNotifierProvider(
          create: (_) => ContainerMovementListViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => UbicacionesViewModel(),
        ),

        // ========================
        // SERVICES (CLEAN + MVVM)
        // ========================
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

          // ========================
          // SERVICES
          // ========================
          '/services': (context) {
            return ChangeNotifierProvider(
              create: (_) => ServicesViewModel(
                GetAssignedServices(
                  ServicesRepositoryImpl(
                    ServicesRemoteDataSourceImpl(
                      context.read<ServicesApi>(),
                    ),
                  ),
                ),
              )..loadServices(),
              child: const ServiceListView(),
            );
          },
          '/services_finished': (_) => FinishServiceList(),

          // ========================
          // DETAIL SERVICE (SIN CAMBIOS)
          // ========================
          '/detail_service': (context) {
            final serviceId = ModalRoute.of(context)!.settings.arguments as int;

            return ChangeNotifierProvider(
              create: (_) {
                final fcmDatasource = context.read<FcmDatasource>();

                return DetailServiceViewModel(
                  DetailServiceRepositoryImpl(
                    context.read<DetailServiceApi>(),
                  ),
                  ListenServicioUpdates(
                    ServicioRepositoryImpl(fcmDatasource),
                  ),
                )..init(serviceId.toString()); // ✅ aquí, una sola vez
              },
              child: DetailServicePage(
                serviceId: serviceId,
              ),
            );
          },

          '/trip-closure': (_) => const TripClosureFlowPage(),

          // ========================
          // USERS
          // ========================
          '/user': (_) => UserScreen(),

          // ========================
          // VIATICOS
          // ========================
          '/travel_expenses': (_) => TravelExpensesScreen(),

          // ========================
          // CONTAINER MAP
          // ========================
          '/container_map': (_) => MovimientoView(),
        },
      ),
    );
  }
}

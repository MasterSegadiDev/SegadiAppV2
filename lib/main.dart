import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:segadi/core/network/dio_client.dart';
import 'package:segadi/core/network/network_info.dart';
import 'package:segadi/features/firebase_cloud_messaging.dart/data/datasources/fcm_datasource.dart';
import 'package:segadi/features/firebase_cloud_messaging.dart/data/repositories/service_repository_impl.dart';
import 'package:segadi/features/firebase_cloud_messaging.dart/domain/usecases/listen_service_update.dart';
import 'package:segadi/features/services_assigned/data/datasources/services_remote_data_source_impl.dart';
///// ========================
///// FEATURES - SERVICES ASSIGNED
///========================

import 'package:segadi/features/services_assigned/data/repositories/service_repository_impl.dart';
import 'package:segadi/features/services_assigned/domain/usecases/get_assigned_services.dart';

// ========================
// SERVICE DETAIL (SIN CAMBIOS)
// ========================
import 'package:segadi/features/service_detail/data/repositories/detail_service_repository_impl.dart';
import 'package:segadi/features/service_detail/presentation/pages/detail_service_page.dart';
import 'package:segadi/features/service_detail/presentation/viewmodel/detail_service_viewmodel.dart';
import 'package:segadi/features/services_assigned/presentation/pages/service_list_page.dart';
import 'package:segadi/features/services_assigned/presentation/viewmodels/services_viewmodel.dart';
import 'package:segadi/features/travel_expenses/data/datasources/travel_expenses_remote_datasource.dart';
import 'package:segadi/features/travel_expenses/data/repositories/travel_expenses_repository_impl.dart';
import 'package:segadi/features/travel_expenses/domain/repositories/travel_expenses_repository.dart';
import 'package:segadi/features/travel_expenses/domain/usecases/travel_expenses_usecases.dart';
import 'package:segadi/features/travel_expenses/presentation/viewmodels/travel_expenses_view_model.dart';
import 'package:segadi/features/travel_expenses/presentation/views/travel_expenses_screen.dart';
import 'package:segadi/features/trip_closure/presentation/widget/trip_closure_flow_page.dart';

// ========================
// CORE / OTROS
// ========================
import 'package:segadi/helper/navigator.dart';
import 'package:segadi/models/containers/container_movement.dart';
import 'package:segadi/models/login/user_login.dart';
import 'package:segadi/services/containers/container_movement_list_service.dart';
import 'package:segadi/services/contenedores/movimientos_service.dart';
import 'package:segadi/services/contenedores/ubicaciones_service.dart';
import 'package:segadi/services/operatorServices/DetailServiceApi.dart';

// ⬇️ API legacy (la reutilizamos)
import 'package:segadi/services/operatorServices/ServicesListApi.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_list_view_model.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';
import 'package:segadi/viewmodels/contenedores/movimientoPisoViewModel.dart';
import 'package:segadi/viewmodels/contenedores/movimientosContenedoresListadoViewModel.dart';
import 'package:segadi/viewmodels/user/user_information.dart';

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
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
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

        Provider(create: (_) => DioClient()),
        Provider<NetworkInfo>(
          create: (_) => NetworkInfoImpl(Connectivity()),
        ),
        Provider<ServicesApi>(create: (_) => ServicesApi()),
        Provider(
            create: (context) => AuthService(context.read<DioClient>().dio)),
        Provider(
            create: (context) =>
                MovimientoService(context.read<DioClient>().dio)),

        Provider(create: (_) => FcmDatasource()..init()),
        Provider<DetailServiceApi>(
          create: (context) => DetailServiceApi(
            context
                .read<DioClient>()
                .dio, // <--- Esto soluciona el "1 positional argument"
          ),
        ),
        Provider<UbicationMovement>(
          create: (context) => UbicationMovement(context.read<DioClient>().dio),
        ),
        Provider<UbicacionesService>(
          create: (context) =>
              UbicacionesService(context.read<DioClient>().dio),
        ),
        Provider<MovimientosService>(
          create: (context) =>
              MovimientosService(context.read<DioClient>().dio),
        ),

        Provider(create: (context) => User(context.read<DioClient>().dio)),

        // ========================
        // AUTH / HOME (SIN CAMBIOS)
        // ========================
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),

        ChangeNotifierProvider(
          create: (context) => ContainerMovementListViewModel(
            context.read<MovimientoService>(), // <-- Ahora sí lo va a encontrar
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => BiometricViewModel(
            context
                .read<AuthService>(), // <--- PASAMOS EL AUTHSERVICE, NO EL DIO
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UbicacionesViewModel(
            context.read<UbicationMovement>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => MovimientoPisoViewModel(
            context.read<MovimientosService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => movimientosContenedoresListadoViewModel(
            context.read<MovimientosService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UbicacionesViewModel(
            context.read<UbicationMovement>(),
            // Si pide UbicacionesService, cambia la línea de arriba por este.
          ),
        ),

        // =======================
        // TRAVEL EXPENSES (SIN CAMBIOS)
        // =======================
        Provider(
            create: (context) =>
                TravelExpensesRemoteDataSource(context.read<DioClient>().dio)),
        ProxyProvider<TravelExpensesRemoteDataSource, TravelExpensesRepository>(
          update: (_, ds, __) => TravelExpensesRepositoryImpl(ds),
        ),
        ChangeNotifierProvider(
          create: (context) {
            final repo = context.read<TravelExpensesRepository>();
            return TravelExpensesViewModel(
              getConceptsUseCase: GetAvailableConceptsUseCase(repo),
              getRegisteredUseCase: GetRegisteredExpensesUseCase(repo),
              insertUseCase: InsertExpenseUseCase(repo),
            );
          },
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
            // 1. Obtenemos el cliente de Dio que YA registramos en el MultiProvider
            // Si no usas Provider aquí, usa: final dioConfigurado = DioClient().dio;
            final dio = context.read<DioClient>().dio;

            // 2. Usamos Connectivity() como antes
            final networkInfo = NetworkInfoImpl(Connectivity());

            // 3. Inyectamos dioConfigurado
            final dataSource = ServicesRemoteDataSourceImpl(dio);
            final repository = ServicesRepositoryImpl(
              remoteDataSource: dataSource,
              networkInfo: networkInfo,
            );

            final useCase = GetAssignedServices(repository);

            return ChangeNotifierProvider(
              create: (_) => ServicesViewModel(
                getAssignedServicesUseCase: useCase,
              )..loadServices(),
              child: const ServicesAssignedPage(),
            );
          },
          //'/services_finished': (_) => FinishServiceList(),

          // ========================
          // DETAIL SERVICE (SIN CAMBIOS)
          // ========================
          '/detail_service': (context) {
            final serviceId = ModalRoute.of(context)!.settings.arguments as int;

            return ChangeNotifierProvider(
              create: (_) {
                final fcmDatasource = context.read<FcmDatasource>();

                // 1. Obtenemos las dependencias del contexto
                final api = context.read<DetailServiceApi>();
                final networkInfo = context.read<
                    NetworkInfo>(); // Asegúrate de tenerlo en tu MultiProvider

                return DetailServiceViewModel(
                  // CORRECCIÓN: Usamos parámetros nombrados 'api' y 'networkInfo'
                  repository: DetailServiceRepositoryImpl(
                    api: api,
                    networkInfo: networkInfo,
                  ),
                  listenServicioUpdates: ListenServicioUpdates(
                    ServicioRepositoryImpl(fcmDatasource),
                  ),
                )..init(serviceId.toString());
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
          //'/user': (_) => UserScreen(),

          // ========================
          // VIATICOS
          // ========================
          '/travel_expenses': (context) {
            // Extraemos los argumentos enviados a través de Navigator
            final int serviceId =
                ModalRoute.of(context)!.settings.arguments as int;
            return TravelExpensesScreen(serviceId: serviceId);
          },

          // ========================
          // CONTAINER MAP
          // ========================
          '/container_map': (_) => MovimientoView(),
        },
      ),
    );
  }
}

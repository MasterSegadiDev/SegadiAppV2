import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segadi/app/router/app_routes.dart';
import 'package:segadi/features/check_list/presentation/models/checklist_arguments.dart';
import 'package:segadi/features/check_list/presentation/pages/checklist_page.dart';
import 'package:segadi/features/developer/presentation/screens/developer_screen.dart';
import 'package:segadi/features/evidence/presentation/pages/widgets/capture_evidence_page.dart';
import 'package:segadi/features/evidence/presentation/pages/widgets/confirm_evidence_page.dart';
import 'package:segadi/features/georuta/presentation/pages/georoute_page.dart';
import 'package:segadi/features/local_service/presentation/pages/tramo_detail_page.dart';
import 'package:segadi/features/local_service/presentation/pages/truck_home_page.dart';
import 'package:segadi/features/services/presentation/detail/arguments/service_detail_arguments.dart';
import 'package:segadi/features/services/presentation/detail/pages/service_detail_page.dart';
import 'package:segadi/features/services/presentation/list/pages/services_page.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/layout/main_layout.dart';
import '../../features/home/presentation/screens/dashboard_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';

final routerProvider = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.truck,
          builder: (
            context,
            state,
          ) {
            final operadorId = state.extra as String;

            return MainLayout(
              child: TruckHomePage(
                operadorId: operadorId,
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.tramoDetail,
          builder: (
            context,
            state,
          ) {
            return const TramoDetailPage();
          },
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const MainLayout(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/services',
          builder: (context, state) => const MainLayout(
            child: ServicesPage(),
          ),
        ),
        GoRoute(
          path: '/screenDevelop',
          builder: (context, state) => const DeveloperScreen(),
        ),
        GoRoute(
          path: AppRoutes.serviceDetail,
          builder: (context, state) {
            final arguments = state.extra as ServiceDetailArguments;

            return ServiceDetailPage(
              arguments: arguments,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.checklist,
          builder: (context, state) {
            final arguments = state.extra as ChecklistArguments;

            return ChecklistPage(
              arguments: arguments,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.georoute,
          builder: (context, state) {
            final serviceRequestId = state.extra as String;

            return GeoroutePage(
              serviceRequestId: serviceRequestId,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.evidenceConfirmation,
          builder: (context, state) {
            final arguments = state.extra as ServiceDetailArguments;

            return ConfirmEvidencePage(
              arguments: arguments,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.evidenceCapture,
          builder: (context, state) {
            final arguments = state.extra as ServiceDetailArguments;

            return CaptureEvidencePage(
              arguments: arguments,
            );
          },
        ),
      ],
    );
  },
);

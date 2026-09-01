import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segadi/features/developer/presentation/screens/developer_screen.dart';
import 'package:segadi/features/evidence/presentation/pages/widgets/capture_evidence_page.dart';
import 'package:segadi/features/evidence/presentation/pages/widgets/confirm_evidence_page.dart';
import 'package:segadi/features/services/presentation/models/service_detail_arguments.dart';
import 'package:segadi/features/services/presentation/pages/service_detail_page.dart';
import 'package:segadi/features/services/presentation/pages/services_page.dart';

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
          path: '/service-detail/:id',
          builder: (context, state) {
            final args = state.extra as ServiceDetailArguments;
            return ServiceDetailPage(arguments: args);
          },
        ),
        GoRoute(
          path: '/evidence/confirmation',
          builder: (context, state) {
            final args = state.extra as ServiceDetailArguments;
            return ConfirmEvidencePage(arguments: args);
          },
        ),
        GoRoute(
          path: '/evidence/capture',
          builder: (context, state) {
            final args = state.extra as ServiceDetailArguments;
            return CaptureEvidencePage(arguments: args);
          },
        ),
      ],
    );
  },
);

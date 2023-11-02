import 'package:auto_route/auto_route.dart';
import 'package:lmlb/auth.dart';
import 'package:lmlb/screens/appointment_detail.dart';
import 'package:lmlb/screens/appointments.dart';
import 'package:lmlb/screens/client_details.dart';
import 'package:lmlb/screens/clients.dart';
import 'package:lmlb/screens/overview.dart';

@AdaptiveAutoRouter(
  replaceInRouteName: 'Page,Route,Screen',
  routes: <AutoRoute>[
    AutoRoute(
      initial: true,
      path: '/dashboard',
      page: OverviewScreen,
      guards: [AuthGuard],
    ),
    AutoRoute(
      path: '/appointment/:appointmentID',
      page: AppointmentDetailScreen,
      guards: [AuthGuard],
    ),
    AutoRoute(
      path: '/appointments',
      page: AppointmentsScreen,
      guards: [AuthGuard],
    ),
    AutoRoute(
      path: '/clients',
      page: ClientsScreen,
      guards: [AuthGuard],
    ),
    AutoRoute(
      path: '/client/:clientId',
      page: ClientDetailsScreen,
      guards: [AuthGuard],
    ),
    ...authRoutes,
    // redirect all other paths
    RedirectRoute(path: '*', redirectTo: '/'),
    //Home
  ],
)
class $AppRouter {}
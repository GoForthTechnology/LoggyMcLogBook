import 'package:auto_route/auto_route.dart';
import 'package:lmlb/auth.dart';
import 'package:lmlb/screens/appointment_info.dart';
import 'package:lmlb/screens/appointments.dart';
import 'package:lmlb/screens/client_info.dart';
import 'package:lmlb/screens/clients.dart';
import 'package:lmlb/screens/invoice_info.dart';
import 'package:lmlb/screens/invoices.dart';
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
      path: '/appointment/:appointmentId',
      page: AppointmentInfoScreen,
      guards: [AuthGuard],
    ),
    AutoRoute(
      path: '/appointments/:view',
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
      page: ClientInfoScreen,
      guards: [AuthGuard],
    ),
    AutoRoute(
      path: '/invoices',
      page: InvoicesScreen,
      guards: [AuthGuard],
    ),
    AutoRoute(
      path: '/invoice/:invoiceId',
      page: InvoiceInfoScreen,
      guards: [AuthGuard],
    ),
    ...authRoutes,
    // redirect all other paths
    RedirectRoute(path: '*', redirectTo: '/'),
    //Home
  ],
)
class $AppRouter {}
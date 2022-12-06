import 'package:auto_route/auto_route.dart';
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
    ),
    AutoRoute(
      path: '/appointment',
      page: AppointmentInfoScreen,
    ),
    AutoRoute(
      path: '/appointments',
      page: AppointmentsScreen,
    ),
    AutoRoute(
      path: '/clients',
      page: ClientsScreen,
    ),
    AutoRoute(
      path: '/client',
      page: ClientInfoScreen,
    ),
    AutoRoute(
      path: '/invoices',
      page: InvoicesScreen,
    ),
    AutoRoute(
      path: '/invoice',
      page: InvoiceInfoScreen,
    ),
    // redirect all other paths
    RedirectRoute(path: '*', redirectTo: '/'),
    //Home
  ],
)
class $AppRouter {}
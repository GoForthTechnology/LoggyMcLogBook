import 'package:auto_route/auto_route.dart';
import 'package:lmlb/auth.dart';
import 'package:lmlb/screens/appointment_detail.dart';
import 'package:lmlb/screens/appointments.dart';
import 'package:lmlb/screens/client_details.dart';
import 'package:lmlb/screens/clients.dart';
import 'package:lmlb/screens/invoice_detail.dart';
import 'package:lmlb/screens/invoices.dart';
import 'package:lmlb/screens/new_client.dart';
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
      page: AppointmentDetailScreen,
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
      path: '/client/new',
      page: NewClientScreen,
      guards: [AuthGuard],
    ),
    AutoRoute(
      path: '/client/:clientId',
      page: ClientDetailsScreen,
      guards: [AuthGuard],
    ),
    AutoRoute(
      path: '/invoices',
      page: InvoicesScreen,
      guards: [AuthGuard],
    ),
    AutoRoute(
      path: '/invoice/:invoiceId',
      page: InvoiceDetailScreen,
      guards: [AuthGuard],
    ),
    ...authRoutes,
    // redirect all other paths
    RedirectRoute(path: '*', redirectTo: '/'),
    //Home
  ],
)
class $AppRouter {}
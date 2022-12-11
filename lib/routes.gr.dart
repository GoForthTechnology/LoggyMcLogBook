// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:flutter/material.dart' as _i10;
import 'package:lmlb/auth.dart' as _i8;
import 'package:lmlb/entities/appointment.dart' as _i11;
import 'package:lmlb/entities/client.dart' as _i12;
import 'package:lmlb/screens/appointment_detail.dart' as _i2;
import 'package:lmlb/screens/appointments.dart' as _i3;
import 'package:lmlb/screens/client_details.dart' as _i5;
import 'package:lmlb/screens/clients.dart' as _i4;
import 'package:lmlb/screens/invoice_detail.dart' as _i7;
import 'package:lmlb/screens/invoices.dart' as _i6;
import 'package:lmlb/screens/overview.dart' as _i1;

class AppRouter extends _i9.RootStackRouter {
  AppRouter({
    _i10.GlobalKey<_i10.NavigatorState>? navigatorKey,
    required this.authGuard,
  }) : super(navigatorKey);

  final _i8.AuthGuard authGuard;

  @override
  final Map<String, _i9.PageFactory> pagesMap = {
    OverviewScreenRoute.name: (routeData) {
      return _i9.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i1.OverviewScreen(),
      );
    },
    AppointmentInfoScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<AppointmentInfoScreenRouteArgs>(
          orElse: () => AppointmentInfoScreenRouteArgs(
              appointmentId: pathParams.optString('appointmentId')));
      return _i9.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i2.AppointmentDetailScreen(
          key: args.key,
          appointmentId: args.appointmentId,
          appointment: args.appointment,
        ),
      );
    },
    AppointmentsScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<AppointmentsScreenRouteArgs>(
          orElse: () =>
              AppointmentsScreenRouteArgs(view: pathParams.getString('view')));
      return _i9.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i3.AppointmentsScreen(
          key: args.key,
          client: args.client,
          view: args.view,
        ),
      );
    },
    ClientsScreenRoute.name: (routeData) {
      return _i9.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i4.ClientsScreen(),
      );
    },
    ClientDetailsScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<ClientDetailsScreenRouteArgs>(
          orElse: () => ClientDetailsScreenRouteArgs(
              clientId: pathParams.optString('clientId')));
      return _i9.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i5.ClientDetailsScreen(
          key: args.key,
          clientId: args.clientId,
        ),
      );
    },
    InvoicesScreenRoute.name: (routeData) {
      final args = routeData.argsAs<InvoicesScreenRouteArgs>(
          orElse: () => const InvoicesScreenRouteArgs());
      return _i9.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i6.InvoicesScreen(
          key: args.key,
          client: args.client,
        ),
      );
    },
    InvoiceInfoScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<InvoiceInfoScreenRouteArgs>(
          orElse: () => InvoiceInfoScreenRouteArgs(
              invoiceId: pathParams.optString('invoiceId')));
      return _i9.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i7.InvoiceDetailScreen(
          key: args.key,
          invoiceId: args.invoiceId,
          clientId: args.clientId,
        ),
      );
    },
    LoginScreenRoute.name: (routeData) {
      return _i9.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i8.LoginScreen(),
      );
    },
    EmailVerifyScreenRoute.name: (routeData) {
      return _i9.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i8.EmailVerifyScreen(),
      );
    },
  };

  @override
  List<_i9.RouteConfig> get routes => [
        _i9.RouteConfig(
          '/#redirect',
          path: '/',
          redirectTo: '/dashboard',
          fullMatch: true,
        ),
        _i9.RouteConfig(
          OverviewScreenRoute.name,
          path: '/dashboard',
          guards: [authGuard],
        ),
        _i9.RouteConfig(
          AppointmentInfoScreenRoute.name,
          path: '/appointment/:appointmentId',
          guards: [authGuard],
        ),
        _i9.RouteConfig(
          AppointmentsScreenRoute.name,
          path: '/appointments/:view',
          guards: [authGuard],
        ),
        _i9.RouteConfig(
          ClientsScreenRoute.name,
          path: '/clients',
          guards: [authGuard],
        ),
        _i9.RouteConfig(
          ClientDetailsScreenRoute.name,
          path: '/client/:clientId',
          guards: [authGuard],
        ),
        _i9.RouteConfig(
          InvoicesScreenRoute.name,
          path: '/invoices',
          guards: [authGuard],
        ),
        _i9.RouteConfig(
          InvoiceInfoScreenRoute.name,
          path: '/invoice/:invoiceId',
          guards: [authGuard],
        ),
        _i9.RouteConfig(
          LoginScreenRoute.name,
          path: '/login',
          children: [
            _i9.RouteConfig(
              '*#redirect',
              path: '*',
              parent: LoginScreenRoute.name,
              redirectTo: '',
              fullMatch: true,
            )
          ],
        ),
        _i9.RouteConfig(
          EmailVerifyScreenRoute.name,
          path: '/verify-email',
        ),
        _i9.RouteConfig(
          '*#redirect',
          path: '*',
          redirectTo: '/',
          fullMatch: true,
        ),
      ];
}

/// generated route for
/// [_i1.OverviewScreen]
class OverviewScreenRoute extends _i9.PageRouteInfo<void> {
  const OverviewScreenRoute()
      : super(
          OverviewScreenRoute.name,
          path: '/dashboard',
        );

  static const String name = 'OverviewScreenRoute';
}

/// generated route for
/// [_i2.AppointmentDetailScreen]
class AppointmentInfoScreenRoute
    extends _i9.PageRouteInfo<AppointmentInfoScreenRouteArgs> {
  AppointmentInfoScreenRoute({
    _i10.Key? key,
    String? appointmentId,
    _i11.Appointment? appointment,
  }) : super(
          AppointmentInfoScreenRoute.name,
          path: '/appointment/:appointmentId',
          args: AppointmentInfoScreenRouteArgs(
            key: key,
            appointmentId: appointmentId,
            appointment: appointment,
          ),
          rawPathParams: {'appointmentId': appointmentId},
        );

  static const String name = 'AppointmentInfoScreenRoute';
}

class AppointmentInfoScreenRouteArgs {
  const AppointmentInfoScreenRouteArgs({
    this.key,
    this.appointmentId,
    this.appointment,
  });

  final _i10.Key? key;

  final String? appointmentId;

  final _i11.Appointment? appointment;

  @override
  String toString() {
    return 'AppointmentInfoScreenRouteArgs{key: $key, appointmentId: $appointmentId, appointment: $appointment}';
  }
}

/// generated route for
/// [_i3.AppointmentsScreen]
class AppointmentsScreenRoute
    extends _i9.PageRouteInfo<AppointmentsScreenRouteArgs> {
  AppointmentsScreenRoute({
    _i10.Key? key,
    _i12.Client? client,
    required String view,
  }) : super(
          AppointmentsScreenRoute.name,
          path: '/appointments/:view',
          args: AppointmentsScreenRouteArgs(
            key: key,
            client: client,
            view: view,
          ),
          rawPathParams: {'view': view},
        );

  static const String name = 'AppointmentsScreenRoute';
}

class AppointmentsScreenRouteArgs {
  const AppointmentsScreenRouteArgs({
    this.key,
    this.client,
    required this.view,
  });

  final _i10.Key? key;

  final _i12.Client? client;

  final String view;

  @override
  String toString() {
    return 'AppointmentsScreenRouteArgs{key: $key, client: $client, view: $view}';
  }
}

/// generated route for
/// [_i4.ClientsScreen]
class ClientsScreenRoute extends _i9.PageRouteInfo<void> {
  const ClientsScreenRoute()
      : super(
          ClientsScreenRoute.name,
          path: '/clients',
        );

  static const String name = 'ClientsScreenRoute';
}

/// generated route for
/// [_i5.ClientDetailsScreen]
class ClientDetailsScreenRoute
    extends _i9.PageRouteInfo<ClientDetailsScreenRouteArgs> {
  ClientDetailsScreenRoute({
    _i10.Key? key,
    String? clientId,
  }) : super(
          ClientDetailsScreenRoute.name,
          path: '/client/:clientId',
          args: ClientDetailsScreenRouteArgs(
            key: key,
            clientId: clientId,
          ),
          rawPathParams: {'clientId': clientId},
        );

  static const String name = 'ClientDetailsScreenRoute';
}

class ClientDetailsScreenRouteArgs {
  const ClientDetailsScreenRouteArgs({
    this.key,
    this.clientId,
  });

  final _i10.Key? key;

  final String? clientId;

  @override
  String toString() {
    return 'ClientDetailsScreenRouteArgs{key: $key, clientId: $clientId}';
  }
}

/// generated route for
/// [_i6.InvoicesScreen]
class InvoicesScreenRoute extends _i9.PageRouteInfo<InvoicesScreenRouteArgs> {
  InvoicesScreenRoute({
    _i10.Key? key,
    _i12.Client? client,
  }) : super(
          InvoicesScreenRoute.name,
          path: '/invoices',
          args: InvoicesScreenRouteArgs(
            key: key,
            client: client,
          ),
        );

  static const String name = 'InvoicesScreenRoute';
}

class InvoicesScreenRouteArgs {
  const InvoicesScreenRouteArgs({
    this.key,
    this.client,
  });

  final _i10.Key? key;

  final _i12.Client? client;

  @override
  String toString() {
    return 'InvoicesScreenRouteArgs{key: $key, client: $client}';
  }
}

/// generated route for
/// [_i7.InvoiceDetailScreen]
class InvoiceInfoScreenRoute
    extends _i9.PageRouteInfo<InvoiceInfoScreenRouteArgs> {
  InvoiceInfoScreenRoute({
    _i10.Key? key,
    String? invoiceId,
    String? clientId,
  }) : super(
          InvoiceInfoScreenRoute.name,
          path: '/invoice/:invoiceId',
          args: InvoiceInfoScreenRouteArgs(
            key: key,
            invoiceId: invoiceId,
            clientId: clientId,
          ),
          rawPathParams: {'invoiceId': invoiceId},
        );

  static const String name = 'InvoiceInfoScreenRoute';
}

class InvoiceInfoScreenRouteArgs {
  const InvoiceInfoScreenRouteArgs({
    this.key,
    this.invoiceId,
    this.clientId,
  });

  final _i10.Key? key;

  final String? invoiceId;

  final String? clientId;

  @override
  String toString() {
    return 'InvoiceInfoScreenRouteArgs{key: $key, invoiceId: $invoiceId, clientId: $clientId}';
  }
}

/// generated route for
/// [_i8.LoginScreen]
class LoginScreenRoute extends _i9.PageRouteInfo<void> {
  const LoginScreenRoute({List<_i9.PageRouteInfo>? children})
      : super(
          LoginScreenRoute.name,
          path: '/login',
          initialChildren: children,
        );

  static const String name = 'LoginScreenRoute';
}

/// generated route for
/// [_i8.EmailVerifyScreen]
class EmailVerifyScreenRoute extends _i9.PageRouteInfo<void> {
  const EmailVerifyScreenRoute()
      : super(
          EmailVerifyScreenRoute.name,
          path: '/verify-email',
        );

  static const String name = 'EmailVerifyScreenRoute';
}

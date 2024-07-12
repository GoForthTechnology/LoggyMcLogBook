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
import 'package:auto_route/auto_route.dart' as _i10;
import 'package:flutter/material.dart' as _i11;
import 'package:lmlb/auth.dart' as _i9;
import 'package:lmlb/screens/appointment_detail.dart' as _i2;
import 'package:lmlb/screens/appointments.dart' as _i3;
import 'package:lmlb/screens/client_details.dart' as _i7;
import 'package:lmlb/screens/clients.dart' as _i6;
import 'package:lmlb/screens/gif.dart' as _i8;
import 'package:lmlb/screens/invoice_detail.dart' as _i5;
import 'package:lmlb/screens/invoices.dart' as _i4;
import 'package:lmlb/screens/overview.dart' as _i1;

class AppRouter extends _i10.RootStackRouter {
  AppRouter({
    _i11.GlobalKey<_i11.NavigatorState>? navigatorKey,
    required this.authGuard,
  }) : super(navigatorKey);

  final _i9.AuthGuard authGuard;

  @override
  final Map<String, _i10.PageFactory> pagesMap = {
    OverviewScreenRoute.name: (routeData) {
      return _i10.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i1.OverviewScreen(),
      );
    },
    AppointmentDetailScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<AppointmentDetailScreenRouteArgs>(
          orElse: () => AppointmentDetailScreenRouteArgs(
                appointmentID: pathParams.getString('appointmentID'),
                clientID: pathParams.getString('clientID'),
              ));
      return _i10.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i2.AppointmentDetailScreen(
          key: args.key,
          appointmentID: args.appointmentID,
          clientID: args.clientID,
        ),
      );
    },
    AppointmentsScreenRoute.name: (routeData) {
      return _i10.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i3.AppointmentsScreen(),
      );
    },
    InvoicesScreenRoute.name: (routeData) {
      return _i10.AdaptivePage<dynamic>(
        routeData: routeData,
        child: const _i4.InvoicesScreen(),
      );
    },
    InvoiceDetailScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<InvoiceDetailScreenRouteArgs>(
          orElse: () => InvoiceDetailScreenRouteArgs(
                invoiceID: pathParams.getString('invoiceID'),
                clientID: pathParams.getString('clientID'),
              ));
      return _i10.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i5.InvoiceDetailScreen(
          key: args.key,
          invoiceID: args.invoiceID,
          clientID: args.clientID,
        ),
      );
    },
    ClientsScreenRoute.name: (routeData) {
      return _i10.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i6.ClientsScreen(),
      );
    },
    ClientDetailsScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<ClientDetailsScreenRouteArgs>(
          orElse: () => ClientDetailsScreenRouteArgs(
              clientId: pathParams.getString('clientId')));
      return _i10.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i7.ClientDetailsScreen(
          key: args.key,
          clientId: args.clientId,
        ),
      );
    },
    GifScreenRoute.name: (routeData) {
      return _i10.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i8.GifScreen(),
      );
    },
    LoginScreenRoute.name: (routeData) {
      return _i10.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i9.LoginScreen(),
      );
    },
    EmailVerifyScreenRoute.name: (routeData) {
      return _i10.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i9.EmailVerifyScreen(),
      );
    },
  };

  @override
  List<_i10.RouteConfig> get routes => [
        _i10.RouteConfig(
          '/#redirect',
          path: '/',
          redirectTo: '/dashboard',
          fullMatch: true,
        ),
        _i10.RouteConfig(
          OverviewScreenRoute.name,
          path: '/dashboard',
          guards: [authGuard],
        ),
        _i10.RouteConfig(
          AppointmentDetailScreenRoute.name,
          path: '/client/:clientID/appointment/:appointmentID',
          guards: [authGuard],
        ),
        _i10.RouteConfig(
          AppointmentsScreenRoute.name,
          path: '/appointments',
          guards: [authGuard],
        ),
        _i10.RouteConfig(
          InvoicesScreenRoute.name,
          path: '/invoices',
          guards: [authGuard],
        ),
        _i10.RouteConfig(
          InvoiceDetailScreenRoute.name,
          path: '/client/:clientID/invoice/:invoiceID',
          guards: [authGuard],
        ),
        _i10.RouteConfig(
          ClientsScreenRoute.name,
          path: '/clients',
          guards: [authGuard],
        ),
        _i10.RouteConfig(
          ClientDetailsScreenRoute.name,
          path: '/client/:clientId',
          guards: [authGuard],
        ),
        _i10.RouteConfig(
          GifScreenRoute.name,
          path: '/gif',
          guards: [authGuard],
        ),
        _i10.RouteConfig(
          LoginScreenRoute.name,
          path: '/login',
          children: [
            _i10.RouteConfig(
              '*#redirect',
              path: '*',
              parent: LoginScreenRoute.name,
              redirectTo: '',
              fullMatch: true,
            )
          ],
        ),
        _i10.RouteConfig(
          EmailVerifyScreenRoute.name,
          path: '/verify-email',
        ),
        _i10.RouteConfig(
          '*#redirect',
          path: '*',
          redirectTo: '/',
          fullMatch: true,
        ),
      ];
}

/// generated route for
/// [_i1.OverviewScreen]
class OverviewScreenRoute extends _i10.PageRouteInfo<void> {
  const OverviewScreenRoute()
      : super(
          OverviewScreenRoute.name,
          path: '/dashboard',
        );

  static const String name = 'OverviewScreenRoute';
}

/// generated route for
/// [_i2.AppointmentDetailScreen]
class AppointmentDetailScreenRoute
    extends _i10.PageRouteInfo<AppointmentDetailScreenRouteArgs> {
  AppointmentDetailScreenRoute({
    _i11.Key? key,
    required String appointmentID,
    required String clientID,
  }) : super(
          AppointmentDetailScreenRoute.name,
          path: '/client/:clientID/appointment/:appointmentID',
          args: AppointmentDetailScreenRouteArgs(
            key: key,
            appointmentID: appointmentID,
            clientID: clientID,
          ),
          rawPathParams: {
            'appointmentID': appointmentID,
            'clientID': clientID,
          },
        );

  static const String name = 'AppointmentDetailScreenRoute';
}

class AppointmentDetailScreenRouteArgs {
  const AppointmentDetailScreenRouteArgs({
    this.key,
    required this.appointmentID,
    required this.clientID,
  });

  final _i11.Key? key;

  final String appointmentID;

  final String clientID;

  @override
  String toString() {
    return 'AppointmentDetailScreenRouteArgs{key: $key, appointmentID: $appointmentID, clientID: $clientID}';
  }
}

/// generated route for
/// [_i3.AppointmentsScreen]
class AppointmentsScreenRoute extends _i10.PageRouteInfo<void> {
  const AppointmentsScreenRoute()
      : super(
          AppointmentsScreenRoute.name,
          path: '/appointments',
        );

  static const String name = 'AppointmentsScreenRoute';
}

/// generated route for
/// [_i4.InvoicesScreen]
class InvoicesScreenRoute extends _i10.PageRouteInfo<void> {
  const InvoicesScreenRoute()
      : super(
          InvoicesScreenRoute.name,
          path: '/invoices',
        );

  static const String name = 'InvoicesScreenRoute';
}

/// generated route for
/// [_i5.InvoiceDetailScreen]
class InvoiceDetailScreenRoute
    extends _i10.PageRouteInfo<InvoiceDetailScreenRouteArgs> {
  InvoiceDetailScreenRoute({
    _i11.Key? key,
    required String invoiceID,
    required String clientID,
  }) : super(
          InvoiceDetailScreenRoute.name,
          path: '/client/:clientID/invoice/:invoiceID',
          args: InvoiceDetailScreenRouteArgs(
            key: key,
            invoiceID: invoiceID,
            clientID: clientID,
          ),
          rawPathParams: {
            'invoiceID': invoiceID,
            'clientID': clientID,
          },
        );

  static const String name = 'InvoiceDetailScreenRoute';
}

class InvoiceDetailScreenRouteArgs {
  const InvoiceDetailScreenRouteArgs({
    this.key,
    required this.invoiceID,
    required this.clientID,
  });

  final _i11.Key? key;

  final String invoiceID;

  final String clientID;

  @override
  String toString() {
    return 'InvoiceDetailScreenRouteArgs{key: $key, invoiceID: $invoiceID, clientID: $clientID}';
  }
}

/// generated route for
/// [_i6.ClientsScreen]
class ClientsScreenRoute extends _i10.PageRouteInfo<void> {
  const ClientsScreenRoute()
      : super(
          ClientsScreenRoute.name,
          path: '/clients',
        );

  static const String name = 'ClientsScreenRoute';
}

/// generated route for
/// [_i7.ClientDetailsScreen]
class ClientDetailsScreenRoute
    extends _i10.PageRouteInfo<ClientDetailsScreenRouteArgs> {
  ClientDetailsScreenRoute({
    _i11.Key? key,
    required String clientId,
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
    required this.clientId,
  });

  final _i11.Key? key;

  final String clientId;

  @override
  String toString() {
    return 'ClientDetailsScreenRouteArgs{key: $key, clientId: $clientId}';
  }
}

/// generated route for
/// [_i8.GifScreen]
class GifScreenRoute extends _i10.PageRouteInfo<void> {
  const GifScreenRoute()
      : super(
          GifScreenRoute.name,
          path: '/gif',
        );

  static const String name = 'GifScreenRoute';
}

/// generated route for
/// [_i9.LoginScreen]
class LoginScreenRoute extends _i10.PageRouteInfo<void> {
  const LoginScreenRoute({List<_i10.PageRouteInfo>? children})
      : super(
          LoginScreenRoute.name,
          path: '/login',
          initialChildren: children,
        );

  static const String name = 'LoginScreenRoute';
}

/// generated route for
/// [_i9.EmailVerifyScreen]
class EmailVerifyScreenRoute extends _i10.PageRouteInfo<void> {
  const EmailVerifyScreenRoute()
      : super(
          EmailVerifyScreenRoute.name,
          path: '/verify-email',
        );

  static const String name = 'EmailVerifyScreenRoute';
}

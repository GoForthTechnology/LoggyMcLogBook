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
import 'package:auto_route/auto_route.dart' as _i8;
import 'package:flutter/material.dart' as _i9;
import 'package:lmlb/entities/appointment.dart' as _i10;
import 'package:lmlb/entities/client.dart' as _i11;
import 'package:lmlb/entities/invoice.dart' as _i12;
import 'package:lmlb/screens/appointment_info.dart' as _i2;
import 'package:lmlb/screens/appointments.dart' as _i3;
import 'package:lmlb/screens/client_info.dart' as _i5;
import 'package:lmlb/screens/clients.dart' as _i4;
import 'package:lmlb/screens/invoice_info.dart' as _i7;
import 'package:lmlb/screens/invoices.dart' as _i6;
import 'package:lmlb/screens/overview.dart' as _i1;

class AppRouter extends _i8.RootStackRouter {
  AppRouter([_i9.GlobalKey<_i9.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i8.PageFactory> pagesMap = {
    OverviewScreenRoute.name: (routeData) {
      return _i8.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i1.OverviewScreen(),
      );
    },
    AppointmentInfoScreenRoute.name: (routeData) {
      final args = routeData.argsAs<AppointmentInfoScreenRouteArgs>(
          orElse: () => const AppointmentInfoScreenRouteArgs());
      return _i8.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i2.AppointmentInfoScreen(
          key: args.key,
          appointment: args.appointment,
        ),
      );
    },
    AppointmentsScreenRoute.name: (routeData) {
      final args = routeData.argsAs<AppointmentsScreenRouteArgs>();
      return _i8.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i3.AppointmentsScreen(
          key: args.key,
          client: args.client,
          view: args.view,
        ),
      );
    },
    ClientsScreenRoute.name: (routeData) {
      return _i8.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i4.ClientsScreen(),
      );
    },
    ClientInfoScreenRoute.name: (routeData) {
      final args = routeData.argsAs<ClientInfoScreenRouteArgs>(
          orElse: () => const ClientInfoScreenRouteArgs());
      return _i8.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i5.ClientInfoScreen(
          key: args.key,
          client: args.client,
        ),
      );
    },
    InvoicesScreenRoute.name: (routeData) {
      final args = routeData.argsAs<InvoicesScreenRouteArgs>(
          orElse: () => const InvoicesScreenRouteArgs());
      return _i8.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i6.InvoicesScreen(
          key: args.key,
          client: args.client,
        ),
      );
    },
    InvoiceInfoScreenRoute.name: (routeData) {
      final args = routeData.argsAs<InvoiceInfoScreenRouteArgs>(
          orElse: () => const InvoiceInfoScreenRouteArgs());
      return _i8.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i7.InvoiceInfoScreen(
          key: args.key,
          invoice: args.invoice,
        ),
      );
    },
  };

  @override
  List<_i8.RouteConfig> get routes => [
        _i8.RouteConfig(
          '/#redirect',
          path: '/',
          redirectTo: '/dashboard',
          fullMatch: true,
        ),
        _i8.RouteConfig(
          OverviewScreenRoute.name,
          path: '/dashboard',
        ),
        _i8.RouteConfig(
          AppointmentInfoScreenRoute.name,
          path: '/appointment',
        ),
        _i8.RouteConfig(
          AppointmentsScreenRoute.name,
          path: '/appointments',
        ),
        _i8.RouteConfig(
          ClientsScreenRoute.name,
          path: '/clients',
        ),
        _i8.RouteConfig(
          ClientInfoScreenRoute.name,
          path: '/client',
        ),
        _i8.RouteConfig(
          InvoicesScreenRoute.name,
          path: '/invoices',
        ),
        _i8.RouteConfig(
          InvoiceInfoScreenRoute.name,
          path: '/invoice',
        ),
        _i8.RouteConfig(
          '*#redirect',
          path: '*',
          redirectTo: '/',
          fullMatch: true,
        ),
      ];
}

/// generated route for
/// [_i1.OverviewScreen]
class OverviewScreenRoute extends _i8.PageRouteInfo<void> {
  const OverviewScreenRoute()
      : super(
          OverviewScreenRoute.name,
          path: '/dashboard',
        );

  static const String name = 'OverviewScreenRoute';
}

/// generated route for
/// [_i2.AppointmentInfoScreen]
class AppointmentInfoScreenRoute
    extends _i8.PageRouteInfo<AppointmentInfoScreenRouteArgs> {
  AppointmentInfoScreenRoute({
    _i9.Key? key,
    _i10.Appointment? appointment,
  }) : super(
          AppointmentInfoScreenRoute.name,
          path: '/appointment',
          args: AppointmentInfoScreenRouteArgs(
            key: key,
            appointment: appointment,
          ),
        );

  static const String name = 'AppointmentInfoScreenRoute';
}

class AppointmentInfoScreenRouteArgs {
  const AppointmentInfoScreenRouteArgs({
    this.key,
    this.appointment,
  });

  final _i9.Key? key;

  final _i10.Appointment? appointment;

  @override
  String toString() {
    return 'AppointmentInfoScreenRouteArgs{key: $key, appointment: $appointment}';
  }
}

/// generated route for
/// [_i3.AppointmentsScreen]
class AppointmentsScreenRoute
    extends _i8.PageRouteInfo<AppointmentsScreenRouteArgs> {
  AppointmentsScreenRoute({
    _i9.Key? key,
    _i11.Client? client,
    required _i3.View view,
  }) : super(
          AppointmentsScreenRoute.name,
          path: '/appointments',
          args: AppointmentsScreenRouteArgs(
            key: key,
            client: client,
            view: view,
          ),
        );

  static const String name = 'AppointmentsScreenRoute';
}

class AppointmentsScreenRouteArgs {
  const AppointmentsScreenRouteArgs({
    this.key,
    this.client,
    required this.view,
  });

  final _i9.Key? key;

  final _i11.Client? client;

  final _i3.View view;

  @override
  String toString() {
    return 'AppointmentsScreenRouteArgs{key: $key, client: $client, view: $view}';
  }
}

/// generated route for
/// [_i4.ClientsScreen]
class ClientsScreenRoute extends _i8.PageRouteInfo<void> {
  const ClientsScreenRoute()
      : super(
          ClientsScreenRoute.name,
          path: '/clients',
        );

  static const String name = 'ClientsScreenRoute';
}

/// generated route for
/// [_i5.ClientInfoScreen]
class ClientInfoScreenRoute
    extends _i8.PageRouteInfo<ClientInfoScreenRouteArgs> {
  ClientInfoScreenRoute({
    _i9.Key? key,
    _i11.Client? client,
  }) : super(
          ClientInfoScreenRoute.name,
          path: '/client',
          args: ClientInfoScreenRouteArgs(
            key: key,
            client: client,
          ),
        );

  static const String name = 'ClientInfoScreenRoute';
}

class ClientInfoScreenRouteArgs {
  const ClientInfoScreenRouteArgs({
    this.key,
    this.client,
  });

  final _i9.Key? key;

  final _i11.Client? client;

  @override
  String toString() {
    return 'ClientInfoScreenRouteArgs{key: $key, client: $client}';
  }
}

/// generated route for
/// [_i6.InvoicesScreen]
class InvoicesScreenRoute extends _i8.PageRouteInfo<InvoicesScreenRouteArgs> {
  InvoicesScreenRoute({
    _i9.Key? key,
    _i11.Client? client,
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

  final _i9.Key? key;

  final _i11.Client? client;

  @override
  String toString() {
    return 'InvoicesScreenRouteArgs{key: $key, client: $client}';
  }
}

/// generated route for
/// [_i7.InvoiceInfoScreen]
class InvoiceInfoScreenRoute
    extends _i8.PageRouteInfo<InvoiceInfoScreenRouteArgs> {
  InvoiceInfoScreenRoute({
    _i9.Key? key,
    _i12.Invoice? invoice,
  }) : super(
          InvoiceInfoScreenRoute.name,
          path: '/invoice',
          args: InvoiceInfoScreenRouteArgs(
            key: key,
            invoice: invoice,
          ),
        );

  static const String name = 'InvoiceInfoScreenRoute';
}

class InvoiceInfoScreenRouteArgs {
  const InvoiceInfoScreenRouteArgs({
    this.key,
    this.invoice,
  });

  final _i9.Key? key;

  final _i12.Invoice? invoice;

  @override
  String toString() {
    return 'InvoiceInfoScreenRouteArgs{key: $key, invoice: $invoice}';
  }
}

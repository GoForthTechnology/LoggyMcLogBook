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
import 'package:lmlb/auth.dart' as _i7;
import 'package:lmlb/screens/appointment_detail.dart' as _i2;
import 'package:lmlb/screens/appointments.dart' as _i3;
import 'package:lmlb/screens/client_details.dart' as _i5;
import 'package:lmlb/screens/clients.dart' as _i4;
import 'package:lmlb/screens/gif.dart' as _i6;
import 'package:lmlb/screens/overview.dart' as _i1;

class AppRouter extends _i8.RootStackRouter {
  AppRouter({
    _i9.GlobalKey<_i9.NavigatorState>? navigatorKey,
    required this.authGuard,
  }) : super(navigatorKey);

  final _i7.AuthGuard authGuard;

  @override
  final Map<String, _i8.PageFactory> pagesMap = {
    OverviewScreenRoute.name: (routeData) {
      return _i8.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i1.OverviewScreen(),
      );
    },
    AppointmentDetailScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<AppointmentDetailScreenRouteArgs>(
          orElse: () => AppointmentDetailScreenRouteArgs(
                appointmentID: pathParams.getString('appointmentID'),
                clientID: pathParams.getString('clientID'),
              ));
      return _i8.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i2.AppointmentDetailScreen(
          key: args.key,
          appointmentID: args.appointmentID,
          clientID: args.clientID,
        ),
      );
    },
    AppointmentsScreenRoute.name: (routeData) {
      return _i8.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i3.AppointmentsScreen(),
      );
    },
    ClientsScreenRoute.name: (routeData) {
      return _i8.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i4.ClientsScreen(),
      );
    },
    ClientDetailsScreenRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<ClientDetailsScreenRouteArgs>(
          orElse: () => ClientDetailsScreenRouteArgs(
              clientId: pathParams.getString('clientId')));
      return _i8.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i5.ClientDetailsScreen(
          key: args.key,
          clientId: args.clientId,
        ),
      );
    },
    GifScreenRoute.name: (routeData) {
      return _i8.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i6.GifScreen(),
      );
    },
    LoginScreenRoute.name: (routeData) {
      return _i8.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i7.LoginScreen(),
      );
    },
    EmailVerifyScreenRoute.name: (routeData) {
      return _i8.AdaptivePage<dynamic>(
        routeData: routeData,
        child: _i7.EmailVerifyScreen(),
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
          guards: [authGuard],
        ),
        _i8.RouteConfig(
          AppointmentDetailScreenRoute.name,
          path: '/client/:clientID/appointment/:appointmentID',
          guards: [authGuard],
        ),
        _i8.RouteConfig(
          AppointmentsScreenRoute.name,
          path: '/appointments',
          guards: [authGuard],
        ),
        _i8.RouteConfig(
          ClientsScreenRoute.name,
          path: '/clients',
          guards: [authGuard],
        ),
        _i8.RouteConfig(
          ClientDetailsScreenRoute.name,
          path: '/client/:clientId',
          guards: [authGuard],
        ),
        _i8.RouteConfig(
          GifScreenRoute.name,
          path: '/gif',
          guards: [authGuard],
        ),
        _i8.RouteConfig(
          LoginScreenRoute.name,
          path: '/login',
          children: [
            _i8.RouteConfig(
              '*#redirect',
              path: '*',
              parent: LoginScreenRoute.name,
              redirectTo: '',
              fullMatch: true,
            )
          ],
        ),
        _i8.RouteConfig(
          EmailVerifyScreenRoute.name,
          path: '/verify-email',
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
/// [_i2.AppointmentDetailScreen]
class AppointmentDetailScreenRoute
    extends _i8.PageRouteInfo<AppointmentDetailScreenRouteArgs> {
  AppointmentDetailScreenRoute({
    _i9.Key? key,
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

  final _i9.Key? key;

  final String appointmentID;

  final String clientID;

  @override
  String toString() {
    return 'AppointmentDetailScreenRouteArgs{key: $key, appointmentID: $appointmentID, clientID: $clientID}';
  }
}

/// generated route for
/// [_i3.AppointmentsScreen]
class AppointmentsScreenRoute extends _i8.PageRouteInfo<void> {
  const AppointmentsScreenRoute()
      : super(
          AppointmentsScreenRoute.name,
          path: '/appointments',
        );

  static const String name = 'AppointmentsScreenRoute';
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
/// [_i5.ClientDetailsScreen]
class ClientDetailsScreenRoute
    extends _i8.PageRouteInfo<ClientDetailsScreenRouteArgs> {
  ClientDetailsScreenRoute({
    _i9.Key? key,
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

  final _i9.Key? key;

  final String clientId;

  @override
  String toString() {
    return 'ClientDetailsScreenRouteArgs{key: $key, clientId: $clientId}';
  }
}

/// generated route for
/// [_i6.GifScreen]
class GifScreenRoute extends _i8.PageRouteInfo<void> {
  const GifScreenRoute()
      : super(
          GifScreenRoute.name,
          path: '/gif',
        );

  static const String name = 'GifScreenRoute';
}

/// generated route for
/// [_i7.LoginScreen]
class LoginScreenRoute extends _i8.PageRouteInfo<void> {
  const LoginScreenRoute({List<_i8.PageRouteInfo>? children})
      : super(
          LoginScreenRoute.name,
          path: '/login',
          initialChildren: children,
        );

  static const String name = 'LoginScreenRoute';
}

/// generated route for
/// [_i7.EmailVerifyScreen]
class EmailVerifyScreenRoute extends _i8.PageRouteInfo<void> {
  const EmailVerifyScreenRoute()
      : super(
          EmailVerifyScreenRoute.name,
          path: '/verify-email',
        );

  static const String name = 'EmailVerifyScreenRoute';
}

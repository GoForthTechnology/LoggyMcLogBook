import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/auth.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'entities/appointment.dart';
import 'entities/invoice.dart';
import 'firebase_options.dart';
import 'persistence/firebase/firebase_crud.dart';
import 'routes.gr.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await init(MyApp(), kIsWeb).then(runApp);
}

Future<Widget> init(Widget app, bool isWeb) {
  final clients = Clients(new FirebaseCrud(
    directory: "clients",
    fromJson: Client.fromJson,
    toJson: (c) => c.toJson(),
  ));
  final appointments = Appointments(new FirebaseCrud(
    directory: "appointments",
    fromJson: Appointment.fromJson,
    toJson: (a) => a.toJson(),
  ));
  final invoices = Invoices(new FirebaseCrud(
    directory: "invoices",
    fromJson: Invoice.fromJson,
    toJson: (i) => i.toJson(),
  ), appointments);
  final init = Future.wait<Object>([clients.init(), appointments.init(), invoices.init()]);
  return init.then((_) => MultiProvider(providers: [
    ChangeNotifierProvider.value(value: clients),
    ChangeNotifierProvider.value(value: appointments),
    ChangeNotifierProvider.value(value: invoices),
  ], child: app));
}

class MyApp extends StatelessWidget {

  final _appRouter = AppRouter(authGuard: AuthGuard());

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FirebaseUIAuth.configureProviders(authProviders);

    return MaterialApp.router(
      title: 'FCP Log Book',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      routeInformationParser: _appRouter.defaultRouteParser(),
      routerDelegate: _appRouter.delegate()
    );
  }
}

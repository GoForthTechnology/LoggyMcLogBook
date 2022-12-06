import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/persistence/local/LocalCrud.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/invoices.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'routes.gr.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await init(MyApp(), kIsWeb).then(runApp);
}

Future<Widget> init(Widget app, bool isWeb) {
  final clients = Clients(new LocalCrud());
  final appointments = Appointments(new LocalCrud());
  final invoices = Invoices(new LocalCrud(), appointments);
  final init = Future.wait<Object>([clients.init(), appointments.init(), invoices.init()]);
  return init.then((_) => MultiProvider(providers: [
    ChangeNotifierProvider.value(value: clients),
    ChangeNotifierProvider.value(value: appointments),
    ChangeNotifierProvider.value(value: invoices),
  ], child: app));
}

class MyApp extends StatelessWidget {

  final _appRouter = AppRouter();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

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

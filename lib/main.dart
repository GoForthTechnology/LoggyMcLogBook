import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lmlb/auth.dart';
import 'package:lmlb/entities/client.dart';
import 'package:lmlb/entities/reminder.dart';
import 'package:lmlb/models/child_model.dart';
import 'package:lmlb/models/pregnancy_model.dart';
import 'package:lmlb/models/reproductive_category_model.dart';
import 'package:lmlb/persistence/firebase/firestore_crud.dart';
import 'package:lmlb/repos/appointments.dart';
import 'package:lmlb/repos/clients.dart';
import 'package:lmlb/repos/gif_repo.dart';
import 'package:lmlb/repos/reminders.dart';
import 'package:provider/provider.dart';

import 'entities/appointment.dart';
import 'firebase_options.dart';
import 'routes.gr.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth auth = FirebaseAuth.instance;
  auth.setPersistence(Persistence.INDEXED_DB);

  await init(MyApp(), kIsWeb).then(runApp);
}

Future<Widget> init(Widget app, bool isWeb) {
  final clients = Clients(FirestoreCrud(
    directory: "clients",
    fromJson: Client.fromJson,
    toJson: (c) => c.toJson(),
  ));
  final appointments = Appointments(FirestoreCrud(
    directory: "appointments",
    fromJson: Appointment.fromJson,
    toJson: (a) => a.toJson(),
  ));
  final reminderRepo = Reminders(
    FirestoreCrud(
        directory: "reminders",
        fromJson: Reminder.fromJson,
        toJson: (r) => r.toJson()),
  );
  final gifRepo = GifRepo(FirebaseFormCrud<void>(
    parseExtras: (Map<String, dynamic> m) => [],
    serializeExtras: (List<void> es) => [],
  ));
  //final init = Future.wait<Object>([clients.init(), appointments.init(), invoices.init()]);
  final init = Future.value(null);
  return init.then((_) => MultiProvider(providers: [
        ChangeNotifierProvider.value(value: clients),
        ChangeNotifierProvider.value(value: appointments),
        ChangeNotifierProvider.value(value: gifRepo),
        ChangeNotifierProvider.value(value: reminderRepo),
        ChangeNotifierProvider.value(value: ReproductiveCategoryModel()),
        ChangeNotifierProvider.value(value: PregnancyModel()),
        ChangeNotifierProvider.value(value: ChildModel()),
      ], child: app));
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter(authGuard: AuthGuard());

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FirebaseUIAuth.configureProviders([
      GoogleProvider(clientId: googleClientId),
      EmailAuthProvider(),
    ]);

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
        debugShowCheckedModeBanner: false,
        routeInformationParser: _appRouter.defaultRouteParser(),
        routerDelegate: _appRouter.delegate());
  }
}

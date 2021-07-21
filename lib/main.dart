import 'package:crime_alert/provider/MapProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:crime_alert/router.dart' as router;
import 'package:flutter_config/flutter_config.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider.value(value: MapProvider())],
    child: CrimeAlert(),
  ));
}

class CrimeAlert extends StatelessWidget {
  const CrimeAlert({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Crime Alert App",
      onGenerateRoute: router.generateRoute,
      initialRoute: "login",
      debugShowCheckedModeBanner: false,
    );
  }
}

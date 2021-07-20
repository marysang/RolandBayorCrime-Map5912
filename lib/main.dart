import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:crime_alert/router.dart' as router;
import 'package:flutter_config/flutter_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  await Firebase.initializeApp();
  runApp(CrimeAlert());
}

class CrimeAlert extends StatelessWidget {
  // TODO:implement provider state management here
  @override
  Widget build(BuildContext context) {
    return App();
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

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

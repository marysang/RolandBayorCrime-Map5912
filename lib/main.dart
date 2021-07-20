import 'package:flutter/material.dart';
import 'package:crime_alert/router.dart' as router;
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CrimeAlert());
}

class CrimeAlert extends StatelessWidget {
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

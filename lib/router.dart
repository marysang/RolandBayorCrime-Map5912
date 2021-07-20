import 'package:crime_alert/screens/login.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case "login":
      return MaterialPageRoute(builder: (context) => Login());
    case "login":
      return MaterialPageRoute(builder: (context) => Login());
    default:
      return MaterialPageRoute(builder: (context) => Login());
  }
}

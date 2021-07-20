import 'package:crime_alert/screens/home.dart';
import 'package:crime_alert/screens/login.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  //route page to keep track and navigate to requested routes
  switch (settings.name) {
    case "login":
      return MaterialPageRoute(builder: (context) => Login());
    case "home":
      return MaterialPageRoute(builder: (context) => Home());
    default:
      return MaterialPageRoute(builder: (context) => Login());
  }
}

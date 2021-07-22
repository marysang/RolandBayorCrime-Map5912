import 'package:crime_alert/class/database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoggingIn = false;
  final _db = Database();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      Future.delayed(Duration(milliseconds: 50), () {
        if (FirebaseAuth.instance.currentUser != null) {
          Navigator.pushReplacementNamed(context, "home");
        }
      });
    });
    return _isLoggingIn
        ? Scaffold(
            body: Container(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              ),
            ),
          )
        : Scaffold(
            body: Container(
              color: Colors.orange[900],
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(top: 150),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 80,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Crime Alert",
                        style: TextStyle(
                          fontSize: 50,
                          fontFamily: "Zen Tokyo Zoo",
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green[600]),
                      ),
                      onPressed: _onSignin,
                      child: Text("Sign in With Google"),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Future<void> _onSignin() async {
    _isLoggingIn = true;
    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken);

    final res = await FirebaseAuth.instance.signInWithCredential(credential);

    if (res.user != null) {
      _db.createUser(res.user!.displayName.toString(),
          res.user!.email.toString(), res.user!.uid.toString());
      _isLoggingIn = false;
      _successfulSignIn(res.user!.displayName.toString());
      Navigator.popAndPushNamed(context, "home");
    }
  }

  _successfulSignIn(String name) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Welcome $name"),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.orange[900],
    ));
  }
}

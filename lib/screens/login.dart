import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Future<void> _onSignin() async {
    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken);

    final res = await FirebaseAuth.instance.signInWithCredential(credential);

    if (res.user != null) {
      Navigator.popAndPushNamed(context, "home");
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      Future.delayed(Duration(milliseconds: 50), () {
        if (FirebaseAuth.instance.currentUser != null) {
          Navigator.popAndPushNamed(context, "home");
        }
      });
    });
    return Scaffold(
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
                  backgroundColor: MaterialStateProperty.all(Colors.green[600]),
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
}

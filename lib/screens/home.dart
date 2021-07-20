import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late GoogleMapController _googleMapController;
  static const initialCameraPosition = CameraPosition(
    target: LatLng(9.432919, -0.848452),
    zoom: 12,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (controller) => _googleMapController,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),
          Positioned(
              bottom: 50,
              right: 20,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                ),
                onPressed: () {},
                child: Icon(Icons.add),
              ))
        ],
      ),
    );
  }
}

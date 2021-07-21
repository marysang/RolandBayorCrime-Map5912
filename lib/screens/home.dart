import 'package:crime_alert/provider/MapProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late MapProvider mapProvider;
  TextEditingController _crimeLocation = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    mapProvider.radius.close();
  }

  @override
  Widget build(BuildContext context) {
    mapProvider = Provider.of<MapProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: mapProvider.onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(9.432919, -0.848452),
              zoom: 11.0,
            ),
            markers: mapProvider.markers.toSet(),
            zoomControlsEnabled: false,
          ),
          Positioned(
            bottom: 50,
            right: 20,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green[600]),
              ),
              onPressed: () {
                _reportCrime();
              },
              child: Icon(Icons.add),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _reportCrime() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Crime'),
          content: Container(
            height: 50,
            child: Center(
              child: TextField(
                controller: _crimeLocation,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Upload Image'),
              onPressed: () {},
            ),
            TextButton(
              child: Text('Use Current Location'),
              onPressed: () async {
                mapProvider.addCurrentLocationToDB();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

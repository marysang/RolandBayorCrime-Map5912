import 'package:crime_alert/dialog.dart';
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

  @override
  void dispose() {
    super.dispose();
    mapProvider.radius.close();
  }

  Widget _crimeImage() {
    return mapProvider.imgPath == ""
        ? Container()
        : AnimatedPositioned(
            top: mapProvider.infoPosition,
            right: 0,
            left: 0,
            duration: Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                height: 200,
                child: Image.network(mapProvider.imgPath),
              ),
            ),
          );
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
              zoom: 13.0,
            ),
            markers: mapProvider.markers.toSet(),
            tiltGesturesEnabled: false,
            zoomControlsEnabled: false,
            onTap: (LatLng latLng) {
              setState(() {
                mapProvider.infoPosition = -300;
              });
            },
          ),
          _crimeImage(),
          Positioned(
            bottom: 50,
            right: 20,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green[600]),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => ReportDialog(),
                );
              },
              child: Icon(Icons.add),
            ),
          )
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _mapController = Completer();
  TextEditingController _crimeLocation = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  late Geoflutterfire geo;
  late Stream<List<DocumentSnapshot>> stream;
  var radius = BehaviorSubject.seeded(200.0);
  Location location = Location();

  //Map markers
  List<Marker> markers = [];

  @override
  void initState() {
    openStream();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    radius.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(9.432919, -0.848452),
              zoom: 12.0,
            ),
            markers: markers.toSet(),
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
                // _addMarker(lat, lng)();
                _reportCrime();
              },
              child: Icon(Icons.add),
            ),
          )
        ],
      ),
    );
  }

  Future<LocationData> getCurrentLocation() async {
    return location.getLocation();
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
                var pos = await getCurrentLocation();
                _addLocationToDB(double.parse("${pos.latitude}"),
                    double.parse("${pos.longitude}"));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void openStream() {
    geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: 9.432919, longitude: -0.848452);
    stream = radius.switchMap((rad) {
      var collectionReference = _firestore.collection('locations');
      return geo
          .collection(collectionRef: collectionReference)
          .within(center: center, radius: rad, field: 'position');
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    stream.listen((List<DocumentSnapshot> documentList) {
      _updateMarkers(documentList);
    });
  }

  void _showHome() async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      const CameraPosition(
        target: LatLng(12.960632, 77.641603),
        zoom: 15.0,
      ),
    ));
  }

  void _addLocationToDB(double lat, double lng) async {
    GeoFirePoint geoFirePoint = geo.point(latitude: lat, longitude: lng);
    var res =
        await _firestore.collection("locations").doc(geoFirePoint.hash).get();
    if (res.data() == null) {
      _firestore
          .collection('locations')
          .doc(geoFirePoint.hash)
          .set({"report_number": 1, 'position': geoFirePoint.data}).then((_) {
        print('added ${geoFirePoint.hash} successfully');
      });
    } else {
      _firestore.collection('locations').doc(geoFirePoint.hash).set({
        "report_number": res.data()!["report_number"] + 1,
        'position': geoFirePoint.data
      }).then((_) {
        print('added ${geoFirePoint.hash} successfully');
      });
    }
    setState(() {});
  }

  void _addMarker(double lat, double lng, int count) {
    var _marker;
    late BitmapDescriptor icon;

    if (count < 5) {
      icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    } else if (count >= 5 && count < 20) {
      icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    } else if (count >= 20) {
      icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }

    _marker = Marker(
      markerId: MarkerId(UniqueKey().toString()),
      position: LatLng(lat, lng),
      icon: icon,
    );
    setState(() {
      markers.add(_marker);
      print("ADDED");
    });
  }

  void _updateMarkers(List<DocumentSnapshot> snapshot) {
    snapshot.forEach((DocumentSnapshot doc) {
      GeoPoint point = doc['position']['geopoint'];
      int count = doc["report_number"];
      _addMarker(point.latitude, point.longitude, count);
    });
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //variables
  late GoogleMapController _googleMapController;
  TextEditingController _crimeLocation = TextEditingController();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  var uuid = Uuid();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  var location = Location();

  //initial camera location
  static const initialCameraPosition = CameraPosition(
    target: LatLng(9.432919, -0.848452),
    zoom: 12,
  );

  // Function adds marker on map
  _addMarker(LatLng pos) async {
    LatLng latLng = LatLng(pos.latitude, pos.longitude);
    var id = uuid.v4();
    Marker _marker = Marker(
      markerId: MarkerId(id.toString()),
      position: latLng,
      infoWindow: InfoWindow(title: "Some title"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    setState(() {
      markers[MarkerId(id.toString())] = _marker;
    });
    // _showMyDialog();
    // print(markers);
    await _addGeoPoint(id.toString(), latLng);
  }

  Future<DocumentReference> _addGeoPoint(String id, LatLng latLng) async {
    var pos = await location.getLocation();
    // await _showMyDialog();

    GeoFirePoint point = geo.point(
      latitude: double.parse("${latLng.latitude}"),
      longitude: double.parse("${latLng.longitude}"),
    );

    return firestore
        .collection("locations")
        .add({"position": point.data, "markerID": id});
  }

  Future<void> _showMyDialog() async {
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
              onPressed: () {
                // onSaveCrime();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _updateMarkers(MarkerId markerId, LatLng position) {
    // TODO: Let info window display image
    // print("placing maker $markerId");
    final Marker marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(title: "test"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    setState(() {
      markers[markerId] = marker;
    });
  }

  _getMakers() async {
    firestore.collection("locations").get().then((locations) {
      if (locations.docs.isNotEmpty) {
        locations.docs.forEach((doc) {
          print("fweuiheudhweidjwed!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

          print(doc.data()["markerID"]);
          _updateMarkers(
            MarkerId(doc.data()["markerID"]),
            LatLng(
              doc.data()["position"]["geopoint"].latitude,
              doc.data()["position"]["geopoint"].longitude,
            ),
          );
        });
      }
    });
  }

  @override
  void initState() {
    _getMakers();
    super.initState();
  }

  @override
  void dispose() {
    _crimeLocation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _googleMapController = controller;
            },
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            onLongPress: _addMarker,
            markers: Set.of(markers.values),
          ),
          // Positioned(
          //   bottom: 50,
          //   right: 20,
          //   child: ElevatedButton(
          //     style: ButtonStyle(
          //       backgroundColor: MaterialStateProperty.all(Colors.green[600]),
          //     ),
          //     onPressed: () {
          //       _addGeoPoint();
          //     },
          //     child: Icon(Icons.add),
          //   ),
          // )
        ],
      ),
    );
  }
}

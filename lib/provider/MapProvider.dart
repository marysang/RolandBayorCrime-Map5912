import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crime_alert/class/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

class MapProvider extends ChangeNotifier {
  Completer<GoogleMapController> _mapController = Completer();
  late Geoflutterfire geo;
  late Stream<List<DocumentSnapshot>> stream;
  var radius = BehaviorSubject.seeded(200.0);
  Location location = Location();
  final db = Database();
  String imgPath = "";
  double infoPosition = -200;

  //Map markers
  List<Marker> markers = [];
  MapProvider() {
    openStream();
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    stream.listen((List<DocumentSnapshot> documentList) {
      _updateMarkers(documentList);
    });
    notifyListeners();
  }

  void openStream() {
    geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: 9.3745, longitude: -0.8794);
    stream = radius.switchMap((rad) {
      var collectionReference = db.locationRef();

      return geo
          .collection(collectionRef: collectionReference)
          .within(center: center, radius: rad, field: 'position');
    });
  }

  void _updateMarkers(List<DocumentSnapshot> snapshot) {
    markers.clear();
    snapshot.forEach((DocumentSnapshot doc) {
      GeoPoint point = doc['position']['geopoint'];
      int count = doc["report_number"];
      String img = doc["imagePath"];
      imgPath = doc["imagePath"];
      _addMarker(point.latitude, point.longitude, count, img);
    });
  }

  void _addMarker(double lat, double lng, int count, String? img) {
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
        onTap: () {
          infoPosition = 50;
          imgPath = img!;
          notifyListeners();
        });

    markers.add(_marker);
    notifyListeners();
  }

  void addCurrentLocationToDB(String? fileUrl) async {
    LocationData pos = await getCurrentLocation();
    GeoFirePoint geoFirePoint = geo.point(
        latitude: double.parse("${pos.latitude}"),
        longitude: double.parse("${pos.longitude}"));

    var res = await db.verifyHashInDB(geoFirePoint.hash);

    if (res.data() == null) {
      //create a new crime report
      var data = {
        "report_number": 1,
        'position': geoFirePoint.data,
        "imagePath": fileUrl
      };
      await db.addNewLocation(geoFirePoint.hash, data);
    } else {
      //update report number if document already exist
      await db.updateReportNumber(
        geoFirePoint.hash,
        res.data()!["report_number"],
      );
    }
    notifyListeners();
  }

  Future<LocationData> getCurrentLocation() async {
    //get user's current location
    return location.getLocation();
  }
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crime_alert/class/FirestoreFunctions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapProvider extends ChangeNotifier {
  Completer<GoogleMapController> _mapController = Completer();
  late Geoflutterfire geo;
  late Stream<List<QueryDocumentSnapshot<Object?>>> stream;
  Location location = Location();
  final db = FirestoreFunctions();
  String imgPath = "";
  double infoPosition = -300;
  bool isUploadSuccess = false;
  final fireFunctions = FirestoreFunctions();

  //Map markers
  List<Marker> markers = [];
  MapProvider() {
    openStream();
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    stream.listen((List<QueryDocumentSnapshot<Object?>> documentList) {
      _updateMarkers(documentList);
      notifyListeners();
    });
    notifyListeners();
  }

  void openStream() {
    geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: 9.3745, longitude: -0.8794);
    fireFunctions.getStream();

    stream = fireFunctions.getStream();
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

    //switch marker colours based on number of reports
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

  Future<void> addReportToDB(String? fileUrl) async {
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
      await db
          .addNewReport(geoFirePoint.hash, data)
          .then((value) => isUploadSuccess = true);

      notifyListeners();
    } else {
      //update report number if document already exist
      await db
          .updateReportNumber(
            geoFirePoint.hash,
            res.data()!["report_number"],
          )
          .then((value) => isUploadSuccess = true);

      notifyListeners();
    }

    notifyListeners();
  }

  Future<LocationData> getCurrentLocation() async {
    //get user's current location
    return location.getLocation();
  }
}

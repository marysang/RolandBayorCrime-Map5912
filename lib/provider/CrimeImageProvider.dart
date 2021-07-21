import 'dart:io';
import 'package:crime_alert/class/database.dart';
import 'package:crime_alert/provider/MapProvider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';

class CrimeImageProvider extends ChangeNotifier {
  File? file;
  String fileName = "No Image";
  UploadTask? task;
  String? _fileUrl;
  MapProvider mapProvider = MapProvider();

  Future selectFile() async {
    final res = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (res == null) return "";

    file = File(res.files.single.path.toString());
    fileName = basename(file!.path);
    notifyListeners();
  }

  uploadImage() async {
    if (file == null) return;
    task = Database.uploadFile(file!, fileName);
    if (task == null) return;
    final snap = await task!;
    _fileUrl = await snap.ref.getDownloadURL();
    mapProvider.addCurrentLocationToDB(_fileUrl);
    _clearData();
    notifyListeners();
  }

  _clearData() {
    file = null;
    fileName = "No Image";
  }
}

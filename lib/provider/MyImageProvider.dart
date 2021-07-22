import 'dart:io';
import 'package:crime_alert/class/FirestoreFunctions.dart';
import 'package:crime_alert/provider/MapProvider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:mime/mime.dart';

class MyImageProvider extends ChangeNotifier {
  File? file;
  String fileName = "No Image";
  UploadTask? task;
  String? _fileUrl;
  MapProvider mapProvider = MapProvider();
  bool wrongType = false;

  Future<void> selectFile() async {
    //select file and check to make sure its an image file

    final res = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (res == null) return;

    file = File(res.files.single.path.toString());
    fileName = basename(file!.path);

    String? mimeStr = lookupMimeType(res.files.single.path.toString());
    var fileType = mimeStr!.split('/');

    if (fileType[0].toLowerCase().toString() != "image") {
      wrongType = true;
      _clearData();
      notifyListeners();
      return;
    }
    notifyListeners();
  }

  Future<void> uploadImage() async {
    //upload file to firebase storage and retrieve the url

    if (file == null) return;
    task = FirestoreFunctions.uploadFile(file!, fileName);
    if (task == null) return;
    final snap = await task!;
    _fileUrl = await snap.ref.getDownloadURL();
    mapProvider.addReportToDB(_fileUrl);
    _clearData();

    notifyListeners();
  }

  _clearData() {
    //set variables back to default
    file = null;
    fileName = "No Image";
  }
}

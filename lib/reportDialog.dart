import 'package:crime_alert/provider/MyImageProvider.dart';
import 'package:crime_alert/provider/MapProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({Key? key}) : super(key: key);

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  TextEditingController _crimeLocation = TextEditingController();
  late MyImageProvider _crimeImageProvider;

  _sendSnackMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      backgroundColor: color,
    ));
    _crimeImageProvider.wrongType = false;
  }

  @override
  Widget build(BuildContext context) {
    _crimeImageProvider = Provider.of<MyImageProvider>(context);

    return Consumer2<MapProvider, MyImageProvider>(
        builder: (context, mapProvider, imageProvider, child) {
      return AlertDialog(
        title: Text('Report Crime'),
        content: Container(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: _crimeLocation,
                decoration: InputDecoration(
                  hintText: "Leave Empty to use Current Location",
                  hintStyle: TextStyle(fontSize: 15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  imageProvider.fileName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Select Image'),
            onPressed: () async {
              await imageProvider.selectFile();
              if (imageProvider.wrongType) {
                _sendSnackMessage(
                  "File type not allowed. Please select an image file.",
                  Colors.red,
                );
              }
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () async {
              _sendSnackMessage("Sending Report Please Wait.", Colors.orange);
              imageProvider.file == null
                  ? await mapProvider.addReportToDB("")
                  : await imageProvider.uploadImage();
              if (mapProvider.isUploadSuccess) {
                _sendSnackMessage("Report Succefully sent!", Colors.green);
              } else {
                _sendSnackMessage("Error Sending Report!", Colors.red);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }
}

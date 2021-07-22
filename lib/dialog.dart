import 'package:crime_alert/provider/CrimeImageProvider.dart';
import 'package:crime_alert/provider/MapProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({Key? key}) : super(key: key);

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  late MapProvider mapProvider;
  TextEditingController _crimeLocation = TextEditingController();
  late CrimeImageProvider crimeImageProvider;

  _sendSnackMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      backgroundColor: color,
    ));
    crimeImageProvider.wrongType = false;
  }

  @override
  Widget build(BuildContext context) {
    mapProvider = Provider.of<MapProvider>(context);
    crimeImageProvider = Provider.of<CrimeImageProvider>(context);
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
                crimeImageProvider.fileName,
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
            await crimeImageProvider.selectFile();
            if (crimeImageProvider.wrongType) {
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
            crimeImageProvider.file == null
                ? mapProvider.addCurrentLocationToDB("")
                : await crimeImageProvider.uploadImage();
            _sendSnackMessage("Report Succefully sent!", Colors.green);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

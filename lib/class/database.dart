import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Database {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addNewLocation(String hash, data) async {
    return await firestore.collection("locations").doc(hash).set(data);
  }

  Future<void> updateReportNumber(String hash, int count) async {
    await firestore
        .collection("locations")
        .doc(hash)
        .set({"report_number": count + 1}, SetOptions(merge: true));
  }

  CollectionReference<Map<String, dynamic>> locationRef() {
    return firestore.collection("locations");
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> verifyHashInDB(
      String docHash) async {
    return await firestore.collection("locations").doc(docHash).get();
  }

  static UploadTask? uploadFile(File file, String fileName) {
    try {
      final ref = FirebaseStorage.instance.ref("CrimeImages/$fileName");
      return ref.putFile(file);
    } on FirebaseException catch (e) {
      print("error uploading $e");
      return null;
    }
  }
}

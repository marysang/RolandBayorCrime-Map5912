import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreFunctions {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addNewReport(String hash, data) async {
    //add new report to db
    return await firestore.collection("locations").doc(hash).set(data);
  }

  Future<void> updateReportNumber(String hash, int count) async {
    //update report number on existing report
    await firestore
        .collection("locations")
        .doc(hash)
        .set({"report_number": count + 1}, SetOptions(merge: true));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> verifyHashInDB(
      String docHash) async {
    //check if a particular doc already exists
    return await firestore.collection("locations").doc(docHash).get();
  }

  Future<void> createUser(String name, String email, String userHash) async {
    //add new user to db
    await firestore
        .collection("users")
        .doc(userHash)
        .set({"name": name, "email": email});
  }

  Stream<List<QueryDocumentSnapshot<Object?>>> getStream() {
    //stream locations
    Stream<QuerySnapshot> stream =
        firestore.collection('locations').snapshots();
    return stream.map((snap) => snap.docs.toList());
  }

  static UploadTask? uploadFile(File file, String fileName) {
    //upload image to firebase storage
    try {
      final ref = FirebaseStorage.instance.ref("CrimeImages/$fileName");
      return ref.putFile(file);
    } on FirebaseException catch (e) {
      print("error uploading $e");
      return null;
    }
  }
}

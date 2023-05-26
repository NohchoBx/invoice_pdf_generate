import 'dart:html' as html;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../model/devis_model.dart';


class FileHandleApi {

  static final HttpsCallable sendMailCallable = FirebaseFunctions.instanceFor(region: 'europe-central2').httpsCallable('sendMail');


  static Future<void> callSendMailFunction(String destEmail, String pdfDownloadUrl) async {
    print('email: '+ destEmail);
    try {
      final response = await sendMailCallable.call({
        'dest': destEmail,
        'pdfDownloadUrl': pdfDownloadUrl,
      });

      // Access the response data
      final result = response.data;

      // Handle the response data
      // Example: Check if the email was sent successfully
      if (result["success"] == true) {
        print('Email sent successfully');
      } else {
        print('Failed to send email');
      }
    } catch (e) {
      // Handle any errors
      print('Error calling sendMail function: $e');
    }
  }


  // save pdf file function
  static Future<File> saveDocumentMobile({
    required String name,
    required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();

    //final blob = pf.Blob([bytes], 'application/pdf');
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }




  static Future<void> saveDocumentWeb({
    required pw.Document pdf,
    required Devis devis,
    required bool isDevisOrFacture,
  }) async {
    try {
      // Convert the PDF to a Uint8List
      final Uint8List pdfBytes = await pdf.save();

      String devisOrFacture;

      if(isDevisOrFacture){
        devisOrFacture = "devis";
      } else {
        devisOrFacture = "factures";
      }

      print(devisOrFacture);

      // Upload the PDF to Cloud Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child(devisOrFacture)
          .child(devis.devisId  + ".pdf");
      final uploadTask = storageRef.putData(pdfBytes);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Add download link to Devis object
      devis.downloadLink = downloadUrl;

      callSendMailFunction(devis.emailAdress, devis.downloadLink!);


      if(isDevisOrFacture) {
        FirebaseFirestore.instance
            .collection('settings')
            .doc("lastId")
            .set({"lastDevisId": int.parse(devis.devisId)}, SetOptions(merge: true));
      } else {
        FirebaseFirestore.instance
            .collection('settings')
            .doc("lastId")
            .set({"lastFactureId": int.parse(devis.devisId)}, SetOptions(merge: true));
      }

      // Upload Devis object to Firestore
      final devisRef = FirebaseFirestore.instance.collection(devisOrFacture);
      await devisRef.doc(devis.devisId).set(devis.toJson());

      // Create a download link for the PDF blob
      final pdfBlob = html.Blob([pdfBytes], 'application/pdf');
      final downloadLink =
          html.AnchorElement(href: html.Url.createObjectUrlFromBlob(pdfBlob));
      downloadLink.text = 'Download PDF';
      downloadLink.download = devis.devisId + ' - ' + devis.clientName!;

      // Trigger the download programmatically
      downloadLink.click();
    } catch (error) {
      print('Error saving PDF: $error');
      rethrow;
    }
  }

  static Future<bool> deleteDevis(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('devis')
          .doc(documentId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting devis: $e');
      return false;
    }
  }

  static Future<bool> deleteFacture(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('factures')
          .doc(documentId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting devis: $e');
      return false;
    }
  }

  /*static Future<void> saveDocumentWeb({
    required String name,
    required pw.Document pdf,
  }) async {
    Future<html.Blob> pdfBlobFuture = pdf.save().then((List<int> pdfBytes) {
      return html.Blob([pdfBytes], 'application/pdf');
    });

    // Create a download link for the PDF blob
    Future<html.AnchorElement> downloadLinkFuture =
        pdfBlobFuture.then((html.Blob pdfBlob) {
      html.AnchorElement downloadLink =
          html.AnchorElement(href: html.Url.createObjectUrlFromBlob(pdfBlob))
            ..text = 'Download PDF'
            ..download = name + '.pdf';
      return downloadLink;
    });

    // Trigger the download programmatically
    downloadLinkFuture.then((html.AnchorElement downloadLink) {
      downloadLink.click();
    });
  }

  Future<void> uploadDevis(Devis devis, File file) async {
    try {
      // Upload file to Cloud Storage
      final storageRef =
          FirebaseStorage.instance.ref().child('devis').child(devis.devisId!);
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Add download link to Devis object
      devis.downloadLink = downloadUrl;

      // Upload Devis object to Firestore
      final devisRef = FirebaseFirestore.instance.collection('devis');
      await devisRef.doc(devis.devisId).set(devis.toJson());
    } catch (error) {
      print('Error uploading Devis: $error');
      rethrow;
    }
  }*/

  // open pdf file function
  static Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }
}

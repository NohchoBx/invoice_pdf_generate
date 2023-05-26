import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_pdf_generate/db/devis_controller.dart';

import '../devis_form/creation_devis.dart';
import '../model/devis_model.dart';
import '../utils/utils.dart';

class HomeFacturesList extends StatefulWidget {
  const HomeFacturesList({Key? key}) : super(key: key);

  @override
  State<HomeFacturesList> createState() => _HomeFacturesListState();
}

class _HomeFacturesListState extends State<HomeFacturesList> {
  late Future<List<Devis>>? _facturesListFuture;

  @override
  void initState() {
    _facturesListFuture = _getFactureList();

    super.initState();
  }


  Future<List<Devis>> _getFactureList() async {
    final snapshot = await FirebaseFirestore.instance.collection('factures').get();
    final facturesList = snapshot.docs
        .map((document) => Devis.fromJson(document.data()))
        .toList();
    return facturesList;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),),
        constraints: const BoxConstraints(maxWidth: 800.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Devis>>(
                future: _facturesListFuture,
                builder: (BuildContext context, AsyncSnapshot<List<Devis>> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final factureList = snapshot.data!;
                  return ListView.builder(
                    itemCount: factureList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Devis facture = factureList[index];
                      return ListTile(
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Facture N°" + facture.devisId),
                            Text("Client: ${facture.clientName}"),
                            Text("Adresse: ${facture.addressOfWork}")
                          ],
                        ),
                        subtitle:
                        Text(DateFormat("dd-MM-yyyy").format(facture.dateOfDevis)),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DevisForm(facture, false)));
                          // Handle onTap here
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () async {
                                  final result = await _deleteFactureFromFirestore(
                                      factureList[index].devisId);
                                  if (result) {
                                    setState(() {
                                      factureList.removeAt(index);
                                    });
                                  }
                                },
                                icon: const Icon(Icons.delete)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60.0, vertical: 8.0),
                  child: Text(
                    'Nouvelle facture',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white
                    ),
                  ),
                ),
                onPressed: () async {

                  final emptyFacture = Devis.empty();
                  final facture = emptyFacture.copyWith(devisId: (Utils.lastFactureId + 1).toString());

                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => DevisForm(facture, true)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _deleteFactureFromFirestore(String factureId) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this facture?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                final result = await FileHandleApi.deleteFacture(factureId);
                if (result) {
                  Navigator.of(context).pop(true);
                } else {
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        );
      },
    );

    return result;
  }
}

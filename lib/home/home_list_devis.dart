import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice_pdf_generate/db/devis_controller.dart';

import '../devis_form/creation_devis.dart';
import '../model/devis_model.dart';
import '../utils/utils.dart';

class HomeDevisList extends StatefulWidget {
  const HomeDevisList({Key? key}) : super(key: key);

  @override
  State<HomeDevisList> createState() => _HomeDevisListState();
}

class _HomeDevisListState extends State<HomeDevisList> {
  List<File>? _files;
  late Future<List<Devis>>? _devisListFuture;

  @override
  void initState() {
    _devisListFuture = _getDevisList();

    super.initState();
  }

  /*Future<void> _loadTempFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    setState(() {
      _files = directory
          .listSync()
          .where((file) => path.extension(file.path).toLowerCase() == '.pdf')
          .whereType<File>()
          .toList();
    });
  }*/

  Future<List<Devis>> _getDevisList() async {
    final snapshot = await FirebaseFirestore.instance.collection('devis').get();
    final devisList = snapshot.docs
        .map((document) => Devis.fromJson(document.data()))
        .toList();
    return devisList;
  }

  @override
  Widget build(BuildContext context) {
    /*if (!kIsWeb) {
      return _files == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _files!.length,
              itemBuilder: (context, index) {
                final file = _files![index];
                final stat = file.statSync();
                return ListTile(
                  onTap: () {
                    FileHandleApi.openFile(file);
                  },
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(
                    path.basename(file.path),
                    style: const TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(stat.type == FileSystemEntityType.file
                      ? DateFormat("dd-MM-yyyy").format(stat.changed)
                      : ''),
                  trailing: IconButton(
                      onPressed: () {
                        file.deleteSync();
                        setState(() {
                          _files!.removeAt(index);
                        });
                      },
                      icon: const Icon(Icons.delete_forever)),
                );
              },
            );
    } else {*/
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),),
        constraints: const BoxConstraints(maxWidth: 800.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Devis>>(
                future: _devisListFuture,
                builder: (BuildContext context, AsyncSnapshot<List<Devis>> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final devisList = snapshot.data!;
                  return ListView.builder(
                    itemCount: devisList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Devis devis = devisList[index];
                      return ListTile(
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Devis N°" + devis.devisId),
                            Text("Client: ${devis.clientName}"),
                            Text("Adresse: ${devis.addressOfWork}")
                          ],
                        ),
                        subtitle:
                            Text(DateFormat("dd-MM-yyyy").format(devis.dateOfDevis)),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DevisForm(devis, true)));
                          // Handle onTap here
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: (){
                              final devis1 = devis.copyWith(devisId: (Utils.lastFactureId + 1).toString());
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => DevisForm(devis1, false)));
                            }, icon: const Icon(Icons.note_add_outlined)),
                            IconButton(
                                onPressed: () async {
                                  final result = await _deleteDevisFromFirestore(
                                      devisList[index].devisId);
                                  if (result) {
                                    setState(() {
                                      devisList.removeAt(index);
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
                    'Nouveau devis',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                        color: Colors.white

                    ),
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => DevisForm(Devis.empty(), true)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _deleteDevisFromFirestore(String devisId) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this devis?'),
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
                final result = await FileHandleApi.deleteDevis(devisId);
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

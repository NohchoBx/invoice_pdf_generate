import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'db/devis_controller.dart';
import 'model/devis_model.dart';
import 'model/section_model.dart';
import 'model/task_model.dart';
import 'utils/utils.dart';

class PdfInvoiceApi {




  Future<void> generate(Devis devis, bool isDevisOrFacture) async {

    final font = await PdfGoogleFonts.robotoRegular();


    final pdf = pw.Document();

    final iconImage =
        (await rootBundle.load('assets/icon.png')).buffer.asUint8List();

    final tableHeaders = [
      'Description',
      'Quantité',
      'Prix Unit.' + String.fromCharCode(128),
      'TVA',
      'Unit',
      'Remise',
      'Total(' + String.fromCharCode(128) + ')',
    ];

    List<List<dynamic>> initTableData() {
      List<List<dynamic>> tableData = [];

      for (final item in devis.tasks) {
        if (item is Task) {
          tableData.add([
            {'title': item.title, 'description': item.description},
            item.quantity,
            Utils.formatter.format(item.unitPrice),
            '${item.tva}%',
            item.totalM2 ?? '/',
            item.promo ?? '/',
            Utils.formatter.format(item.totalSumWithoutTva),
          ]);
        } else if (item is Section) {
          tableData.add([
            {'title': item.title, 'description': '', 'isSectionTitle': true},
          ]);

          for (final task in item.tasks) {
            final isLastInSection = item.tasks.last == task;
            tableData.add([
              {'title': task.title, 'description': task.description, 'isSectionTitle': false},
              task.quantity.toStringAsFixed(2),
              Utils.formatter.format(task.unitPrice),
              '${task.tva}%',
              task.totalM2 != 0 ? task.totalM2 : '/',
              task.promo ?? '/',
              Utils.formatter.format(task.totalSumWithoutTva),
              // Set the "isLastInSection" flag
            ]);

            if(isLastInSection){
              tableData.add([
                {'isSectionTitle': false},
                '',
                '',
                '',
                '',
                'Sous-Total:',
               '${item.getTotalSum}${String.fromCharCode(128)}',
                // Set the "isLastInSection" flag
              ]);
            }
          }

        }
      }
      return tableData;
    }

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return [
            pw.Row(
              children: [
                pw.Image(
                  pw.MemoryImage(iconImage),
                  height: 120,
                  width: 120,
                ),
                pw.SizedBox(width: 0.5 * PdfPageFormat.mm),
                pw.Spacer(),
                pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Alpha Services Benelux',
                      style: pw.TextStyle(
                        fontSize: 13.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'TVA: 0541.320.178',
                    ),
                    pw.Text(
                      'www.alpha-service.be',
                    ),
                    pw.Text(
                      'services.benelux.be@gmail.com',
                    ),

                    pw.SizedBox(height: 30),
                    pw.Text(
                      devis.clientName,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      devis.addressOfWork,
                    ),
                    pw.Text(
                      devis.emailAdress,
                    ),
                    pw.Text(
                      devis.phoneNumber,
                    ),
                    pw.Text(
                      devis.clientTva != null ? "TVA: ${devis.clientTva}" : '',
                    ),

                  ],
                ),
              ],
            ),
            pw.Text("Date:" + DateFormat("dd/MM/yyyy").format(devis.dateOfDevis)),
            isDevisOrFacture ?  pw.Text("Devis n°: " + devis.devisId, style: const pw.TextStyle(fontSize: 18, color: PdfColors.red)) : pw.Text("Facture n°: " + devis.devisId, style: const pw.TextStyle(fontSize: 18, color: PdfColors.red)),
            pw.SizedBox(height: 4 * PdfPageFormat.mm),
            ///
            /// PDF Table Create
            ///
            _customTableFromTextArray(
              context: context,
              headers: tableHeaders,
              data: initTableData(),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.centerRight,
                6: pw.Alignment.centerRight,
              },
              //cellHeight: 200,
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
            ),
            pw.Divider(),

            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Row(
                children: [
                  pw.Spacer(flex: 6),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Montant HT',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              Utils.formatter.format(devis.totalSumWithoutTVA) +
                                  String.fromCharCode(128),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'TVA 6%',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              Utils.formatter.format(devis.totalSumWithTVA -
                                      devis.totalSumWithoutTVA) +
                                  String.fromCharCode(128),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.Divider(),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Total',
                                style: pw.TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              Utils.formatter.format(devis.totalSumWithTVA) +
                                  String.fromCharCode(128),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                        pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                alignment: pw.Alignment.centerLeft,
                child: pw.Paragraph(
                    text: replaceSpecialChars(devis.getDevisResume),
                    style: pw.TextStyle(fontSize: 11, font: font))),
            pw.SizedBox(height: 30),
          pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Row(children: [
                pw.Container(
                    child: pw.Text("DATE: ",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(width: 100),
                pw.Container(
                    child: pw.Text("SIGNATURE: ",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              ]),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                    "Nous restons à votre disposition pour toute information complémentaire.\nCordialement,\nAlpha Services Benelux.",
                    style: pw.TextStyle(font: font))),
          ];
        },
        footer: (context) {

          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Divider(),
              pw.SizedBox(height: 2 * PdfPageFormat.mm),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'You dream it we make it!',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      'Alpha Services Benelux',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      'Lt Graffplein 15, 1780 Wemmel',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ]),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Text(context.pageNumber.toString())
              )
            ],
          );
        },
      ),
    );

    if (!kIsWeb) {
      FileHandleApi.saveDocumentMobile(name: 'my_invoice.pdf', pdf: pdf)
          .then((value) => {FileHandleApi.openFile(value)});
    } else {
      devis.toString();
      FileHandleApi.saveDocumentWeb(pdf: pdf, devis: devis, isDevisOrFacture: isDevisOrFacture);
    }
  }

  String replaceSpecialChars(String text) {
    text = text.replaceAll("\u20AC", "€");
    text = text.replaceAll("\u2019", "'");
    text = text.replaceAll('\u201D', '"');
    text = text.replaceAll("–", "-");
    return text;
  }

  _customTableFromTextArray({
    required pw.Context context,
    required List<String> headers,
    required List<List<dynamic>> data,
    required Map<int, pw.Alignment> cellAlignments,
    pw.TextStyle? headerStyle,
    pw.BoxDecoration? headerDecoration,
    double? headerHeight,
  }) {
    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(250), // set width for first column
      },
      children: [
        // Headers
        pw.TableRow(
          children: headers.asMap().entries.map((entry) {
            final col = entry.key;
            final header = entry.value;
            return pw.Container(
              height: headerHeight,
              alignment: cellAlignments[col] ?? pw.Alignment.center,
              decoration: headerDecoration,
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Flexible(
                  flex: col == 0 ? 2 : 1,
                  child: pw.Text(
                    header,
                    textAlign: col == 0 ? pw.TextAlign.left : pw.TextAlign.right,
                    style: headerStyle ??
                        pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Data
        ...data.asMap().entries.map((entry) {
          final row = entry.key;
          final rowData = entry.value;
          final isSectionTitle = rowData.first['isSectionTitle'] ?? false;

          return pw.TableRow(
            decoration: isSectionTitle
                ? const pw.BoxDecoration(color: PdfColors.blue50)
                : null,
            children: rowData.asMap().entries.map((entry) {
              final col = entry.key;
              final cellData = entry.value;

              if (col == 0) {
                return pw.Container(
                  padding: isSectionTitle
                      ? const pw.EdgeInsets.all(6)
                      : const pw.EdgeInsets.all(1),
                  alignment: pw.Alignment.topLeft,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      if (cellData['title'] != null)
                        pw.Text(
                          replaceSpecialChars(cellData['title'] as String),
                          style: pw.TextStyle(
                            fontSize: isSectionTitle ? 12 : 10,
                            fontWeight:
                                pw.FontWeight.bold,
                          ),
                          softWrap: true,
                        ),
                      if (cellData['description'] != null &&
                          (cellData['description'] as String).isNotEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 5, bottom: 5),
                          child: pw.Text(
                            replaceSpecialChars(cellData['description'] as String),
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              } else {
                  return pw.Container(
                    padding: pw.EdgeInsets.symmetric(vertical: 6),
                    alignment: cellAlignments[col] ?? pw.Alignment.center,
                    child: pw.Text(
                      cellData.toString(),
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  );
              }
            }).toList(),
          );
        }).toList(),
      ],
    );
  }

  /*_customTableFromTextArray({
    required pw.Context context,
    required List<String> headers,
    required List<List<dynamic>> data,
    required Map<int, pw.Alignment> cellAlignments,
    pw.TextStyle? headerStyle,
    pw.BoxDecoration? headerDecoration,
    double? headerHeight,
  }) {
    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(250), // set width for first column
      },
      children: [
        // Headers
        pw.TableRow(
          children: headers.asMap().entries.map((entry) {
            final col = entry.key;
            final header = entry.value;
            return pw.Container(
              height: headerHeight,
              alignment: cellAlignments[col] ?? pw.Alignment.center,
              decoration: headerDecoration,
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Flexible(
                  flex: col == 0 ? 2 : 1,
                  child: pw.Text(
                    header,
                    textAlign: col == 0 ? pw.TextAlign.left : pw.TextAlign.right,
                    style: headerStyle ??
                        pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Data
        ...data.asMap().entries.map((entry) {
          final row = entry.key;
          final rowData = entry.value;
          final isSectionTitle = rowData.first['isSectionTitle'] ?? false;

          return pw.TableRow(
            decoration: isSectionTitle
                ? pw.BoxDecoration(color: PdfColors.lightBlue100)
                : null,
            children: rowData.asMap().entries.map((entry) {
              final col = entry.key;
              final cellData = entry.value;

              if (col == 0) {
                return pw.Container(
                  padding: isSectionTitle == true ? pw.EdgeInsets.all(6) : pw.EdgeInsets.all(1),
                  alignment: pw.Alignment.topLeft,
                  child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  if (cellData['title'] != null)
                    pw.Text(
                      cellData['title'] as String,
                      style: pw.TextStyle(
                        fontSize: isSectionTitle == true ? 12 : 10,
                        fontWeight: isSectionTitle == true ? pw.FontWeight.bold : pw.FontWeight.normal,
                      ),
                      softWrap: true,
                    ),
                  if (cellData['description'] != null &&
                      (cellData['description'] as String).isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 5, bottom: 5),
                      child: pw.Text(
                        cellData['description'] as String,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ),
                ],
                  ),
                );
              } else {
                return pw.Container(
                  alignment: cellAlignments[col] ?? pw.Alignment.center,
                  child: pw.Text(
                    cellData.toString(),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                );
              }
            }).toList(),
          );
        }).toList(),
      ],
    );
  }*/
}

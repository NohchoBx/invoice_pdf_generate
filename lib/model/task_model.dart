import 'package:flutter/material.dart';
import 'package:invoice_pdf_generate/model/task_controller.dart';
import 'package:invoice_pdf_generate/model/task_section_abstract.dart';



class Task implements SectionOrTask{
  String? documentReference;
  GlobalKey key;
  String title;
  String? description;
  double quantity;
  double unitPrice;
  double? totalM2;
  double tva;
  late TaskController controller;
  bool? isExpanded;
  double? promo;

  Task({
    this.documentReference,
    required this.title,
    this.description,
    required this.quantity,
    required this.unitPrice,
    this.totalM2,
    required this.tva,
    this.isExpanded,
    this.promo
  }) : key = GlobalKey() {
    controller = TaskController(
        titleController: TextEditingController(text: title),
        quantityController: TextEditingController(text: quantity.toString()),
        unitPriceController: TextEditingController(text: unitPrice.toString()),
        totalM2Controller:
        TextEditingController(text: totalM2?.toString() ?? ''),
        promoController:  TextEditingController(text: promo?.toString() ?? ''),
        descriptionController: TextEditingController(text: description ?? ''),
        tvaNotifier: ValueNotifier(tva),
        showM2Notifier:
        totalM2 != null && totalM2 != 0 ? ValueNotifier(true) : ValueNotifier(false));
  }

  double get totalSumWithTva {
    final totalNoTva = quantity *
        unitPrice *
        (totalM2 != null && totalM2! > 0 ? totalM2! : 1.0);
    final tvaAmount = totalNoTva * tva / 100.0;


    return double.parse(
        (totalNoTva + tvaAmount >= 0 ? totalNoTva + tvaAmount : 0.0)
            .toStringAsFixed(2));
  }

  double calculateTotalWithPromo(
      double totalNoTva, double tvaAmount, double promoAmount) {
    double total = totalNoTva + tvaAmount;
    total -= promoAmount;

    return total >= 0 ? double.parse(total.toStringAsFixed(2)) : 0.0;
  }



  double get getTotalWithPromo {
    if (promo != null) {
      return totalSumWithTva - (totalSumWithTva * promo! / 100);
    } else {
      return totalSumWithTva;
    }
  }



  double get getDifferenceOfPromo {
    if (promo != null) {
      double totalPriceWithPromo = getTotalWithPromo * (1 - promo! / 100);
      totalPriceWithPromo = getTotalWithPromo - totalPriceWithPromo;
      double difference = getTotalWithPromo - totalPriceWithPromo;
      return difference;
    } else {
      return 0;
    }
  }



  factory Task.empty(){
    return Task(title: "Titre de la tache", quantity: 1, unitPrice: 0, tva: 6,  isExpanded: true);
  }

  double get totalSumWithoutTva {
    final totalNoTva = quantity *
        unitPrice *
        (totalM2 != null && totalM2! > 0 ? totalM2! : 1.0);
    return totalNoTva >= 0 ? double.parse(totalNoTva.toStringAsFixed(2)) : 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalM2': totalM2,
      'tva': tva,
      'promo': promo,

    };
  }

  static Task fromJson(String? ref, Map<String, dynamic> json) {
    return Task(
      documentReference: ref,
      title: json['title'] as String,
      description: json['description'] as String?,
      quantity: json['quantity'] as double,
      unitPrice: json['unitPrice'] as double,
      totalM2: json['totalM2'] as double?,
      tva: json['tva'] as double,
      promo: json['promo'] as double?,
    );
  }

  @override
  String toString() {
    return 'Task{title: $title, description: $description, quantity: $quantity, unitPrice: $unitPrice, totalM2: $totalM2, tva: $tva}';
  }
}

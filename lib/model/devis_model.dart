import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:invoice_pdf_generate/model/task_model.dart';
import 'package:invoice_pdf_generate/model/task_section_abstract.dart';

import '../utils/utils.dart';
import 'section_model.dart';

class Devis {
   String devisId;
   String clientName;
   String? downloadLink;
   String emailAdress;
   String phoneNumber;
   String addressOfWork;
   DateTime dateOfDevis;
   DateTime endDateOfDevis;
   List<SectionOrTask> tasks;
   String resume;
   TextEditingController resumeController;
   String? clientTva;
   bool isClientPro;

  Devis({
    required this.devisId,
    required this.clientName,
    this.downloadLink,
    required this.emailAdress,
    required this.phoneNumber,
    required this.addressOfWork,
    required this.dateOfDevis,
    required this.tasks,
    required this.resume,
    required this.endDateOfDevis,
    this.clientTva,
    required this.isClientPro,
    required this.resumeController,
  });

  factory Devis.empty(){
   return Devis(devisId: (Utils.lastDevisId + 1).toString(), clientName: '', addressOfWork: '', dateOfDevis: DateTime.now(), downloadLink: '', phoneNumber: '', emailAdress: '', isClientPro: false, endDateOfDevis: DateTime.now().add(Duration(days: 30)), tasks: [], resume: '', resumeController: TextEditingController());
}

   Devis copyWith({
     String? devisId,
     String? clientName,
     String? downloadLink,
     String? emailAdress,
     String? phoneNumber,
     String? addressOfWork,
     DateTime? dateOfDevis,
     List<Task>? tasks,
     String? resume,
     DateTime? endDateOfDevis,
     String? clientTva,
     bool? isClientPro,
     TextEditingController? resumeController,
   }) {
     return Devis(
       devisId: devisId ?? this.devisId,
       clientName: clientName ?? this.clientName,
       downloadLink: downloadLink ?? this.downloadLink,
       emailAdress: emailAdress ?? this.emailAdress,
       phoneNumber: phoneNumber ?? this.phoneNumber,
       addressOfWork: addressOfWork ?? this.addressOfWork,
       dateOfDevis: dateOfDevis ?? this.dateOfDevis,
       tasks: tasks ?? this.tasks,
       resume: resume ?? this.resume,
       endDateOfDevis: endDateOfDevis ?? this.endDateOfDevis,
       clientTva: clientTva ?? this.clientTva,
       isClientPro: isClientPro ?? this.isClientPro,
       resumeController: resumeController ?? this.resumeController,
     );
   }
   double get totalSumWithoutTVA {
     double sum = 0.0;
     for (final item in tasks) {
       if (item is Task) {
         sum += item.totalSumWithoutTva;
       } else if (item is Section) {
         for (final task in item.tasks) {
           sum += task.totalSumWithoutTva;
         }
       }
     }
     return sum;
   }

   String get thirtyPercentOfTotalSum {
     double result = 0;
     for (final item in tasks) {
       if (item is Task) {
         result += item.getTotalWithPromo;
       } else if (item is Section) {
         for (final task in item.tasks) {
           result += task.getTotalWithPromo;
         }
       }
     }
     result = result * 30 / 100;
     return Utils.formatter.format(result);
   }

   double get totalSumWithTVA {
     double sum = 0.0;
     for (final item in tasks) {
       if (item is Task) {
         sum += item.getTotalWithPromo;
       } else if (item is Section) {
         for (final task in item.tasks) {
           sum += task.getTotalWithPromo;
         }
       }
     }
     return sum;
   }


  String get getDevisResume {
   return '''
    - Offre valable jusqu'au : ${DateFormat('dd/MM/yyyy').format(endDateOfDevis)}
    - Durée des travaux :
    - Début des travaux :
    - Tous les déchets sont ramassés par nos services et déposés dans un centre de recyclage.

    - Conditions de paiement : 30% au début des travaux, 50% en fonction de l’avancement du chantier, 20% lors de la remise de la clé

    - Si ce devis vous convient, veuillez verser un acompte de $thirtyPercentOfTotalSum EUR (soit 30% du montant total) avant le ${DateFormat('dd/MM/yyyy').format(endDateOfDevis)} sur le numéro de compte suivant : BE68 1030 7982 7634 avec le message structuré :$devisId et
    veuillez-nous le retourner signé précédé de la mention :
    "BON POUR ACCORD ET EXECUTION DU DEVIS”''';

  }



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'devisId': devisId,
      'clientName': clientName,
      'downloadLink': downloadLink,
      'emailAdress': emailAdress,
      'phoneNumber': phoneNumber,
      'addressOfWork': addressOfWork,
      'dateOfDevis': dateOfDevis.toIso8601String(),
      'endDateOfDevis': endDateOfDevis.toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'resume': resume,
      'isClientPro': isClientPro,
    };

    if (clientTva != null) {
      data['clientTva'] = clientTva;
    }

    return data;
  }


   factory Devis.fromJson(Map<String, dynamic> json) {
     final List<dynamic> tasksJson = json['tasks'];
     final List<SectionOrTask> tasks = tasksJson
         .map((taskJson) => parseSectionOrTask(taskJson))
         .toList();

     return Devis(
       devisId: json['devisId'],
       clientName: json['clientName'],
       downloadLink: json['downloadLink'],
       emailAdress: json['emailAdress'],
       phoneNumber: json['phoneNumber'],
       addressOfWork: json['addressOfWork'],
       dateOfDevis: DateTime.parse(json['dateOfDevis']),
       endDateOfDevis: DateTime.parse(json['endDateOfDevis']),
       isClientPro: json['isClientPro'] as bool,
       tasks: tasks,
       resume: json['resume'],
       clientTva: json.containsKey('clientTva') ? json['clientTva'] : null,
       resumeController: TextEditingController(),
     );
   }


   @override
  String toString() {
    return 'Devis{devisId: $devisId, clientName: $clientName, downloadLink: $downloadLink, emailAdress: $emailAdress, phoneNumber: $phoneNumber, addressOfWork: $addressOfWork, dateOfDevis: $dateOfDevis, tasks: $tasks, resume: $resume, clientTva: $clientTva}';
  }
}

SectionOrTask parseSectionOrTask(Map<String, dynamic> json) {
  if (json.containsKey('tasks')) {
    final dynamic tasksData = json['tasks'];
    final List<Task> tasks = [];

    if (tasksData is List) {
      tasksData.forEach((taskData) {
        if (taskData is Map<String, dynamic>) {
          final task = Task.fromJson(null, taskData);
          tasks.add(task);
        }
      });
    }

    return Section(json['title'], tasks);
  } else {
    return Task.fromJson(null, json);
  }
}

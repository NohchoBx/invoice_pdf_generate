import 'package:flutter/material.dart';
import 'package:invoice_pdf_generate/model/task_model.dart';
import 'package:invoice_pdf_generate/model/task_section_abstract.dart';

import '../utils/utils.dart';

class Section implements SectionOrTask {
  String title;
  List<Task> tasks;
  GlobalKey key;

  Section(this.title, this.tasks) : key = GlobalKey();

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  String get getTotalSum {
    double result = 0;
    for (final item in tasks) {
        result += item.getTotalWithPromo;
    }

    return Utils.formatter.format(result);
  }



}
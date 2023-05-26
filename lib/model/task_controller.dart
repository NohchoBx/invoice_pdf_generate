import 'package:flutter/material.dart';

class TaskController {
  TextEditingController titleController;
  TextEditingController quantityController;
  TextEditingController unitPriceController;
  TextEditingController totalM2Controller;
  TextEditingController promoController;
  TextEditingController descriptionController;
  ValueNotifier<double> tvaNotifier;
  ValueNotifier<bool> showM2Notifier;

  TaskController(
      {required this.titleController,
      required this.quantityController,
      required this.unitPriceController,
      required this.totalM2Controller,
      required this.descriptionController,
        required this.promoController,
      required this.tvaNotifier,
      required this.showM2Notifier});
}

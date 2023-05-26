import 'package:flutter/material.dart';
import 'package:invoice_pdf_generate/db/task_controller.dart';

import '../model/task_model.dart';
import '../utils/utils.dart';

class FavoritesTasks extends StatefulWidget {
  List<Task> suggestions;
  Task currentTask;
  FavoritesTasks(this.suggestions, this.currentTask, {Key? key})
      : super(key: key);

  @override
  State<FavoritesTasks> createState() => _FavoritesTasksState();
}

class _FavoritesTasksState extends State<FavoritesTasks> {


  String filterText = '';


  @override
  Widget build(BuildContext context) {
    final filteredTasks = widget.suggestions.where((task) {
      final title = task.title.toLowerCase();
      final filter = filterText.toLowerCase();
      return title.contains(filter);
    }).toList();

    return FocusScope(
      node: FocusScopeNode(),
      child: AlertDialog(
        title: const Text('Tâches enregistrées'),
        content: SizedBox(
          height: 500,
          width: 400,
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    filterText = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Chercher',
                ),
              ),
              SizedBox(
                height: 300,
                width: 400,
                child: ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, indexTasks) {
                    final task = filteredTasks[indexTasks];
                    return ExpansionTile(
                      children: [
                        Text(
                          task.description ?? '',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Text(
                                  'PrixUnit: ${Utils.formatter.format(task.unitPrice)} €',
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  'Quantité: ${Utils.formatter.format(task.quantity)}',
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  'TVA: ${task.tva}',
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  'Total: ${Utils.formatter.format(task.totalSumWithTva)}',
                                  textAlign: TextAlign.start,
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.start,
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              updateTaskControllersText(widget.currentTask, task);
                              widget.currentTask.controller.tvaNotifier.value =
                                  task.tva;
                              widget.currentTask.controller.showM2Notifier.value =
                                  task.controller.showM2Notifier.value;
                            },
                            child: const Text("Choisir"))
                      ],
                      title: Text(task.title),
                      trailing: SizedBox(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () async {
                                  final result = await _deleteTaskFromFirestore(task);
                                  if (result) {
                                    setState(() {
                                      widget.suggestions =
                                      List.from(widget.suggestions)
                                        ..removeAt(indexTasks);
                                    });
                                  }
                                },
                                icon: const Icon(Icons.delete))
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );

  }

  void updateTaskControllersText(Task currentTask, Task task) {
    currentTask.controller.titleController.text = task.title;

    currentTask.controller.quantityController.text = task.quantity.toString();

    currentTask.controller.unitPriceController.text = task.unitPrice.toString();

    currentTask.controller.descriptionController.text = task.description ?? "";

    currentTask.controller.tvaNotifier.value = task.tva;

    currentTask.controller.showM2Notifier.value = task.controller.showM2Notifier.value;

  }

  Future<bool> _deleteTaskFromFirestore(Task task) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                TaskManager()
                    .deleteTaskFromFirestore(task.documentReference!)
                    .then((value) {
                  if (value) {
                    Navigator.of(context).pop(true);
                  } else {
                    Navigator.of(context).pop(true);
                  }
                });
              },
            ),
          ],
        );
      },
    );

    return result;
  }
}

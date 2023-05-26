import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:invoice_pdf_generate/form/form_textfield.dart';
import 'package:reorderables/reorderables.dart';

import '../db/task_controller.dart';
import '../model/devis_model.dart';
import '../model/section_model.dart';
import '../model/task_model.dart';
import '../utils/utils.dart';
import 'bloc/devis_cubit.dart';
import 'favorites_tasks.dart';

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final manager = TaskManager();

  List<Task> suggestionTasks = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevisCubit, Devis>(
      builder: (context, devis) {
        return Column(
          children: _buildSectionAndTaskList(devis.tasks),
        );
      },
    );
  }

  List<Widget> _buildSectionAndTaskList(List<dynamic> sectionsAndTasks) {
    final List<Widget> widgets = [];
    for (final item in sectionsAndTasks) {
      if (item is Section) {
        widgets.add(_buildSection(item));
      } else if (item is Task) {
        widgets.add(_buildTaskItem(item, false));
      }
    }
    return widgets;
  }

  Widget _buildSection(Section section) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        ListTile(
          title: FormBuilderTextField(
            enableInteractiveSelection: true,
            name: section.title,
            initialValue: section.title,
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  section.title = value;
                });
              }
            },
            decoration: const InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              labelText: 'Titre de la section',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          trailing: IntrinsicWidth(
            child: Row(
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  onPressed: () {
                    context
                        .read<DevisCubit>()
                        .addTaskToSection(section, Task.empty());
                  },
                  child:
                      const Text('+'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    bool? result = await _deleteSection(section, context);
                    if (result == true) {
                      context.read<DevisCubit>().deleteSection(section);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        ..._buildSectionTasks(section.tasks),
      ],
    );
  }

  List<Widget> _buildSectionTasks(List<Task> tasks) {
    return tasks
        .map<Widget>((task) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildTaskItem(task, true),
            ))
        .toList();
  }

  Widget _buildTaskItem(Task currentTask, bool isParentSection) {
    return StatefulBuilder(
      key: ValueKey(currentTask.key),
      builder: (BuildContext context, StateSetter setState) {
        return Theme(
          data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent),
          child: ExpansionTile(
            title: isParentSection ? Text("• " + currentTask.title) : Text(currentTask.title),
            onExpansionChanged: (bool value) {
              currentTask.isExpanded = value;
            },
            initiallyExpanded: currentTask.isExpanded ?? false,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: FormBuilderTextField(
                              enableInteractiveSelection: true,
                              name: 'currentTask.title' + currentTask.hashCode.toString() ,
                              controller: currentTask.controller.titleController,
                              onChanged: (String? value) {
                                if (value != null) {
                                  setState(() {
                                    currentTask.title = value;
                                  });
                                }
                              },
                              decoration: inputDecoration("Titre"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: FormBuilderTextField(
                              enableInteractiveSelection: true,
                              name: 'currentTask.quantity' + currentTask.hashCode.toString(),
                              decoration: inputDecoration("Quantité"),
                              controller:
                                  currentTask.controller.quantityController,
                              onChanged: (value) {
                                if (value != null && value.isNotEmpty) {
                                  double? result = double.tryParse(value);
                                  if (result != null) {
                                    setState(() {
                                      currentTask.quantity = result;
                                      context.read<DevisCubit>().updateResume();
                                    });
                                  }
                                } else {
                                  setState(() {
                                    currentTask.quantity = 0;
                                    context.read<DevisCubit>().updateResume();
                                  });
                                }
                              },
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: FormBuilderTextField(
                              name: 'currentTask.unitPrice' + currentTask.hashCode.toString(),
                              decoration: inputDecoration("Prix Unit."),
                              controller:
                                  currentTask.controller.unitPriceController,
                              onChanged: (value) {
                                if (value != null && value.isNotEmpty) {
                                  double? result = double.tryParse(value);
                                  if (result != null) {
                                    setState(() {
                                      currentTask.unitPrice = result;
                                      context.read<DevisCubit>().updateResume();
                                    });
                                  }
                                } else {
                                  setState(() {
                                    currentTask.unitPrice = 0;
                                    context.read<DevisCubit>().updateResume();
                                  });
                                }
                              },
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: InputDecorator(
                            decoration: InputDecoration(
                                labelText: "TVA",
                                contentPadding:
                                    const EdgeInsets.fromLTRB(16, 20, 16, 12),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.blue.shade100),
                                  borderRadius: BorderRadius.circular(5),
                                )),
                            child: SizedBox(
                              height: 27,
                              child: DropdownButtonHideUnderline(
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                  ),
                                  child: ValueListenableBuilder<double>(
                                    valueListenable:
                                        currentTask.controller.tvaNotifier,
                                    builder: (BuildContext context,
                                        double value, Widget? child) {
                                      return DropdownButton<double>(
                                        isExpanded: true,
                                        focusColor: Colors.transparent,
                                        value: value,
                                        items: const [
                                          DropdownMenuItem(
                                            child: Text("6% TVA"),
                                            value: 6.0,
                                          ),
                                          DropdownMenuItem(
                                            child: Text("19% TVA"),
                                            value: 19.0,
                                          ),
                                          DropdownMenuItem(
                                            child: Text("0% Cocon"),
                                            value: 0.000001,
                                          ),
                                          DropdownMenuItem(
                                            child: Text("0% Intra"),
                                            value: 0.000002,
                                          ),
                                        ],
                                        onChanged: (double? newValue) {
                                          if (newValue != null) {
                                            currentTask.controller.tvaNotifier
                                                .value = newValue;
                                            setState(() {
                                              currentTask.tva = newValue;
                                              context
                                                  .read<DevisCubit>()
                                                  .updateResume();
                                            });
                                          }
                                        },
                                        selectedItemBuilder:
                                            (BuildContext context) {
                                          return const [
                                            Center(child: Text("6% TVA")),
                                            Center(child: Text("19% TVA")),
                                            Center(child: Text("0% Cocon")),
                                            Center(child: Text("0% Intra")),
                                          ];
                                        },
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable:
                              currentTask.controller.showM2Notifier,
                          builder: (BuildContext context, bool showTotalM2,
                              Widget? child) {
                            return currentTask.controller.showM2Notifier.value
                                ? Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: FormBuilderTextField(
                                        name: 'currentTask.totalM2' + currentTask.hashCode.toString(),
                                        controller: currentTask
                                            .controller.totalM2Controller,
                                        onChanged: (value) {
                                          if (value != null &&
                                              value.isNotEmpty) {
                                            double? result =
                                                double.tryParse(value);
                                            if (result != null) {
                                              setState(() {
                                                currentTask.totalM2 = result;
                                                context
                                                    .read<DevisCubit>()
                                                    .updateResume();
                                              });
                                            }
                                          } else {
                                            setState(() {
                                              currentTask.totalM2 = null;
                                              context
                                                  .read<DevisCubit>()
                                                  .updateResume();
                                            });
                                          }
                                        },
                                        decoration:
                                            inputDecoration("Total m2/m3/ml"),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  )
                                : Container();
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 1,
                          child: FormBuilderTextField(
                            name: 'currentTask.promo' + currentTask.hashCode.toString(),
                            decoration: inputDecoration("Remise(%)"),
                            controller: currentTask.controller.promoController,
                            onChanged: (value) {
                              if (value != null && value.isNotEmpty) {
                                double? result = double.tryParse(value);
                                if (result != null) {
                                  setState(() {
                                    currentTask.promo = result;
                                    context.read<DevisCubit>().updateResume();
                                  });
                                }
                              } else {
                                setState(() {
                                  currentTask.promo = null;
                                  context.read<DevisCubit>().updateResume();
                                });
                              }
                            },
                            keyboardType: TextInputType.number,
                            validator: (value) {},
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Switch(
                            value: currentTask.controller.showM2Notifier.value,
                            onChanged: (value) {
                              if (value == false) {
                                currentTask.totalM2 = null;
                                context.read<DevisCubit>().updateResume();
                              }
                              setState(() {
                                currentTask.controller.showM2Notifier.value =
                                    value;
                              });
                            },
                          ),
                        ),
                        const Text('Calcul par m2/m3/ml'),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    FormBuilderTextField(
                      name: 'currentTask.description' + currentTask.hashCode.toString(),
                      controller: currentTask.controller.descriptionController,
                      maxLines: 5,
                      onChanged: (String? value) {
                        if (value != null) {
                          currentTask.description = value;
                        }
                      },
                      decoration: inputDecoration("Description"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextButton(
                                  onPressed: () async {
                                    await _loadTasks();
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return FavoritesTasks(
                                              suggestionTasks, currentTask);
                                        });
                                  },
                                  child: const Text(
                                    "Montrer les tâches enregistrées",
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextButton.icon(
                                icon: Icon(
                                  Icons.save,
                                  color: Colors.green[700],
                                ),
                                label: Text(
                                  "Sauvegarder",
                                  style: TextStyle(color: Colors.green[700]),
                                ),
                                onPressed: () async {
                                  final result =
                                      await manager.addTask(currentTask);
                                  if (result) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Tache sauvergardée'),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        duration: Duration(seconds: 2),
                                        width: 300,
                                        backgroundColor: Colors.green,
                                        elevation: 3,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: const Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            "Une erreur s'est produite lors de la sauvegarde"),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      duration: Duration(seconds: 2),
                                      width: 300,
                                      backgroundColor: Colors.red,
                                      elevation: 3,
                                    ));
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextButton.icon(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red[700],
                                ),
                                label: Text(
                                  "Supprimer",
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                                onPressed: () async {
                                  bool? result = await _deleteTaskFromList(
                                      currentTask, context);
                                  if (result == true) {
                                    context
                                        .read<DevisCubit>()
                                        .deleteTask(currentTask.key);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Total: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          Utils.formatter.format(
                                                  currentTask.totalSumWithTva) +
                                              " € TVA",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          Utils.formatter.format(currentTask
                                                  .totalSumWithoutTva) +
                                              " € HTVA",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                              if (currentTask.promo != null)
                                Text(
                                    "Remise(" +
                                        currentTask.promo.toString() +
                                        "%): " +
                                        Utils.formatter.format(
                                            currentTask.getDifferenceOfPromo) +
                                        " €",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadTasks() async {
    List<Task> tasks = await manager.getTasks();
    setState(() {
      suggestionTasks = tasks;
    });
  }

  Future<bool?> _deleteTaskFromList(Task task, BuildContext context) async {
    final completer = Completer<bool?>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false when Cancel button is pressed
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true when Delete button is pressed
              },
            ),
          ],
        );
      },
    ).then((value) {
      completer.complete(
          value); // Complete the completer with the value returned from the dialog
    });

    return completer.future; // Return the future from the completer
  }

  Future<bool?> _deleteSection(Section section, BuildContext context) async {
    final completer = Completer<bool?>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false when Cancel button is pressed
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true when Delete button is pressed
              },
            ),
          ],
        );
      },
    ).then((value) {
      completer.complete(
          value); // Complete the completer with the value returned from the dialog
    });

    return completer.future; // Return the future from the completer
  }
}

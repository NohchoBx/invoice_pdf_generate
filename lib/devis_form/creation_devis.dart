import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:invoice_pdf_generate/db/task_controller.dart';
import 'package:invoice_pdf_generate/pdf_generation.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../form/form_general_info.dart';
import '../form/form_textfield.dart';
import '../model/devis_model.dart';
import '../model/section_model.dart';
import '../model/task_model.dart';
import '../utils/utils.dart';
import 'bloc/devis_cubit.dart';
import 'tasks_list.dart';


class DevisForm extends StatefulWidget{
  Devis devis;

  bool devisOrFacture;

  DevisForm(this.devis, this.devisOrFacture,{Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DevisFormState();

}

class _DevisFormState extends State<DevisForm>  {


  late DevisCubit devisCubit;

  @override
  void initState() {
    super.initState();
    devisCubit = DevisCubit(widget.devis);

  }

  @override
  void dispose() {
    super.dispose();
    devisCubit.close();
  }

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  final TextEditingController resumeTextEditingController =
      TextEditingController();


  final manager = TaskManager();

  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();


  @override
  Widget build(BuildContext context) {
    devisCubit.state.resumeController.text = devisCubit.state.getDevisResume;

    return BlocProvider<DevisCubit>.value(
      value: devisCubit,
      child: Scaffold(
          body: Theme(
            data: ThemeData(
                dividerColor: Colors.transparent, splashColor: Colors.transparent),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800.0),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      FormBuilder(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(widget.devisOrFacture ? 'Devis' : 'Facture', style: const TextStyle(fontSize: 40),),
                            const SizedBox(height: 50,),
                            Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: const FormGeneralInfo()),
                            const SizedBox(
                              height: 50,
                            ),
                            Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: TaskList()),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                  ),
                                  onPressed: () {
                                    devisCubit.addTask(Task.empty());
                                  },
                                  child:
                                  const Text('Ajouter une tâche'),
                                ),
                                const SizedBox(width: 20,),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                  ),
                                  onPressed: () {
                                    final List<Task> emptyTaskList = [];
                                    emptyTaskList.add(Task.empty());
                                    devisCubit.addSection(Section("Nouvelle section", emptyTaskList));
                                    },
                                  child:
                                 const  Row(
                                    children: [
                                      Icon(Icons.table_chart_outlined, size: 20,),
                                      Text('Ajouter une section'),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            ValueListenableBuilder(
                                valueListenable: devisCubit.state.resumeController,
                                builder: (context, value, _) {
                                return FormBuilderTextField(
                                  name: 'resume',
                                  maxLines: 8,
                                  controller: devisCubit.state.resumeController,
                                  decoration: inputDecoration("Résumé"),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                );
                              }
                            ),
                            const SizedBox(height: 10),

                            if(!widget.devisOrFacture)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                  ),
                                  onPressed: () {
                                    devisCubit.state.resumeController.text = "Merci de verser la somme de %invoiceremainingamount% avant le ${DateFormat('dd/MM/yyyy').format(devisCubit.state.endDateOfDevis)} sur le numéro de compte BE68 1030 7982 7634 avec comme communication : ${devisCubit.state.devisId}. Merci pour votre confiance";
                                  },
                                  child:const Text('Rafraichir resumer'),

                                ),
                              ),
                            const SizedBox(height: 10),

                            RoundedLoadingButton(
                              color: Colors.green,
                              child: const Text('Générer et envoyer',
                                  style: TextStyle(color: Colors.white)),
                              controller: _btnController,
                              onPressed: () async {
                                if (_formKey.currentState!.saveAndValidate()) {
                                  PdfInvoiceApi()
                                      .generate(devisCubit.state, widget.devisOrFacture)
                                      .then((value) => {
                                    _btnController.success(),
                                    reinitializeButton()
                                  });
                                } else {
                                  _btnController.error();
                                  reinitializeButton();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ))
    );
  }

  void reinitializeButton() {
     Timer(const Duration(seconds: 2), () {
      _btnController.reset();
    });
  }

}

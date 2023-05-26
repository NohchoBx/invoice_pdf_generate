import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../devis_form/bloc/devis_cubit.dart';
import '../model/devis_model.dart';
import 'form_textfield.dart';

class FormGeneralInfo extends StatelessWidget  {


  const FormGeneralInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevisCubit, Devis>(
      builder: (context, devis) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: BuildFormBuilderTextFieldInt(
                            "Numéro de devis/facture",
                            "devisNumber",
                            devis.devisId)),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                        child: BuildFormBuilderTextField(
                            "Nom Client", "clientName", devis.clientName ?? '')),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: BuildFormBuilderTextField("Adresse du chantier", "addressOfWork",
                            devis.addressOfWork)),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                        child: BuildFormBuilderTextField("Adresse Email", "addressOfEmail",
                            devis.emailAdress)),

                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BuildFormProClientTvaField(
                            "clientTVA",
                            devis.clientTva ?? '',
                            devis.isClientPro,
                          ),

                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: BuildFormBuilderTextField(
                          "Numéro de téléphone",
                          "phoneNumber",
                          devis.phoneNumber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Switch(
                    value: devis.isClientPro,
                    onChanged: (value) {
                      context.read<DevisCubit>().updateClientProValue(value);
                    },
                  ),
                  const Text('Client Pro'),
                ],
              ),
              const SizedBox(height: 30,),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: FormBuilderDateTimePicker(
                          name: 'dateOfDevis',
                          inputType: InputType.date,
                          initialValue: devis.dateOfDevis,
                          onChanged: (value) {
                            if(value != null) {
                              context.read<DevisCubit>().updateDateDevis(value);
                            }
                          },
                          decoration: inputDecoration("Date du début de la validité"),
                          validator: (value) {
                            if (value == null) {
                              return 'Please enter some text';
                            }
                            return null;
                          },

                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: FormBuilderDateTimePicker(
                          name: 'endDateOfDevis',
                          inputType: InputType.date,
                          initialValue: devis.endDateOfDevis,
                          onChanged: (value) {
                            if(value != null) {
                              context.read<DevisCubit>().updateEndDateDevis(value);
                            }
                          },
                          decoration: inputDecoration("Date de la fin de la validité"),
                          validator: (value) {
                            if (value == null) {
                              return 'Please enter some text';
                            }
                            return null;
                          },

                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        );
      }
    );
  }
}

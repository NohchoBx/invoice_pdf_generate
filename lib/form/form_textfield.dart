import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../devis_form/bloc/devis_cubit.dart';
//import 'package:form_builder_validators/form_builder_validators.dart';

class BuildFormBuilderTextField extends StatelessWidget {
  String label;
  String fieldKeyName;
  String fieldText;
  BuildFormBuilderTextField(this.label, this.fieldKeyName, this.fieldText,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: FormBuilderTextField(
        name: fieldKeyName,
        initialValue: fieldText,
        decoration: inputDecoration(label),
        onChanged: (value) {
          if(fieldKeyName == "addressOfEmail") {
            context.read<DevisCubit>().updateEmailAdress(value);
          } else if (fieldKeyName == "clientName") {
            context.read<DevisCubit>().updateClientname(value);
          } else if (fieldKeyName == "addressOfWork"){
            context.read<DevisCubit>().updateWorkAdress(value);
          } else if (fieldKeyName == "phoneNumber") {
            context.read<DevisCubit>().updatePhoneNumber(value);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },

      ),
    );
  }
}


class BuildFormProClientTvaField extends StatelessWidget {
  String fieldKeyName;
  String fieldText;
  bool isEnabled;
  BuildFormProClientTvaField(this.fieldKeyName, this.fieldText, this.isEnabled,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: FormBuilderTextField(
        name: fieldKeyName,
        initialValue: fieldText,
        onChanged: (value) {
          context.read<DevisCubit>().updateClientTva(value);
        },
        enabled: isEnabled,
        decoration: inputDecoration("TVA"),
      ),
    );
  }
}

class BuildFormBuilderTextFieldInt extends StatelessWidget {
  String label;
  String fieldKeyName;
  String fieldText;
  BuildFormBuilderTextFieldInt(this.label, this.fieldKeyName, this.fieldText,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: FormBuilderTextField(
        name: fieldKeyName,
        initialValue: fieldText,
        decoration: inputDecoration(label),
        keyboardType: TextInputType.number,
        onChanged: (value){
          if(value != null) {
            if(RegExp( r'^-?\d*\.?\d+$').hasMatch(value!)) {
            }
            context.read<DevisCubit>().updateDevisId(value);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },

      ),
    );
  }
}

InputDecoration inputDecoration(String label) {
  return InputDecoration(
      fillColor: Colors.transparent,
      label: Text(label),
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(5),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(5),
      ),
    disabledBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 1,color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(5),
    ),errorBorder: OutlineInputBorder(
    borderSide: BorderSide(width: 1,color: Colors.red[300]!),
    borderRadius: BorderRadius.circular(5),
  ), focusedErrorBorder: OutlineInputBorder(
  borderSide: BorderSide(width: 1,color: Colors.red[300]!),
  borderRadius: BorderRadius.circular(5)),

  );
}

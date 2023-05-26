import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/devis_model.dart';
import '../../model/section_model.dart';
import '../../model/task_model.dart';

class DevisCubit extends Cubit<Devis> {
  DevisCubit(Devis devis) : super(devis);

  void addTask(Task task) {
    state.tasks.add(task);
    emit(state.copyWith());
  }


  void addSection(Section section) {
    state.tasks.add(section);
    emit(state.copyWith());
  }


  void deleteSection(Section section) {
    state.tasks.remove(section);
    emit(state.copyWith());
  }


  void deleteTask(GlobalKey taskKey) {
    for (var item in state.tasks) {
      if (item is Section) {
        for (var task in item.tasks) {
          if (task.key == taskKey) {
            item.tasks.remove(task);
            break;
          }
        }
      } else if (item is Task && item.key == taskKey) {
        state.tasks.remove(item);
      }
    }
    emit(state.copyWith());
  }

  void addTaskToSection(Section section, Task task) {
    section.tasks.add(task);
    emit(state.copyWith());
  }




  void updateClientProValue(bool value) {
    state.isClientPro = value;
    emit(state.copyWith());
  }


  void updateDevisId(value) {
    state.devisId = value;
    updateResume();
  }


  void updateEmailAdress(value) {
    state.emailAdress = value;
  }

  void updateClientTva(tva){
    state.clientTva = tva;
  }

  void updateClientname(value) {
    state.clientName = value;
  }


  void updateWorkAdress(value){
    state.addressOfWork = value;
  }

  void updatePhoneNumber(value){
    state.phoneNumber = value;
  }

  void updateResume() {
    state.resumeController.text = state.getDevisResume;
    //refreshDevisResume();
  }

  void updateEndDateDevis(value) {
    state.endDateOfDevis = value;
    updateResume();
  }


  void updateDateDevis(value) {
    state.dateOfDevis = value;
    updateResume();
  }

  void refreshDevisResume() {
    emit(state.copyWith());
  }

}
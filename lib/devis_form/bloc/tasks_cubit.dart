import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/devis_model.dart';
import '../../model/task_model.dart';

class TasksCubit extends Cubit<List<Task>> {
  TasksCubit(List<Task> tasks) : super(tasks);

  void updateDevis(List<Task> updatedTasks) {
    emit(updatedTasks);
  }
}
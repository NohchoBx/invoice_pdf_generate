import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/task_model.dart';

class TaskManager {
  final CollectionReference<Map<String, dynamic>> _taskCollectionRef =
      FirebaseFirestore.instance.collection('tasks');

  Future<bool> addTask(Task task) async {
    try {
      final taskJson = task.toJson();
      await _taskCollectionRef.doc().set(taskJson, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<int>> getLastCreatedDevisId() async {
    final result = await FirebaseFirestore.instance
        .collection("settings")
        .doc("lastId")
        .get();
    final int devisId = result["lastDevisId"];
    final int anotherId = result["lastFactureId"];

    return [devisId, anotherId];
  }



  Future<List<Task>> getTasks() async {
    final snapshot = await _taskCollectionRef.get();
    final tasks = snapshot.docs
        .map((doc) => Task.fromJson(doc.id, doc.data()))
        .toList(growable: false);
    return tasks;
  }

  Future<bool> deleteTaskFromFirestore(String documentId) async {
    try {
      await _taskCollectionRef.doc(documentId).delete();
      return true;
    } catch (e) {
      print('Error deleting document: $e');
      return false;
    }
  }

  Future<List<Task>> searchTasks(String query) async {
    final snapshot = await _taskCollectionRef
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    final tasks = snapshot.docs
        .map((doc) => Task.fromJson(doc.id, doc.data()))
        .toList(growable: false);
    return tasks;
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/task_controller.dart';
import '../../utils/utils.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChange => _auth.authStateChanges();

  Future<void> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error Occured'),
          content: Text(e.toString()),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child:const Text("OK"))
          ],
        ),
      );
    }
  }


  void _getLastDevisId() async {
    final List<int> ids = await TaskManager().getLastCreatedDevisId();
    Utils.lastDevisId = ids[0];
    Utils.lastFactureId = ids[1];
  }

  //  SignOut the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

final authenticationProvider = Provider<Authentication>((ref) {
  return Authentication();
});

//  Here I have shared the example of a provider used within a provider.
// keep in mind I am reading a provider from a provider not watching it.
//  The docs mention not to use watch in a provider. This is bad for performance
//  if the data changes continuously your app will suck bad

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authenticationProvider).authStateChange;
});
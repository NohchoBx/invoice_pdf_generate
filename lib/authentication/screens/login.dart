import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../form/form_textfield.dart';
import '../providers/auth_provider.dart';


class LoginPage extends ConsumerWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authenticationProvider);
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 300.0,
                    maxHeight: 200.0,
                  ),
                  child: Image.asset(
                    'assets/icon1.png', // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 100,),
                FormBuilderTextField(
                  name: 'email',
                  controller: _emailController,
                  decoration: inputDecoration("Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
               const  SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'password',
                  controller: _passwordController,
                  decoration: inputDecoration("Password"),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Se connecter'),
                  onPressed: ()  {
                    final String email = _emailController.text.trim();
                    final String password = _passwordController.text.trim();
                    auth.signInWithEmailAndPassword(email, password, context).then((value) => {

                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

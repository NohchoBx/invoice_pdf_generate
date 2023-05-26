import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:invoice_pdf_generate/home/home_list_factures.dart';
import 'package:invoice_pdf_generate/utils/utils.dart';

import 'authentication/providers/auth_provider.dart';
import 'authentication/screens/login.dart';
import 'db/task_controller.dart';
import 'devis_form/creation_devis.dart';
import 'firebase_options.dart';
import 'home/home_list_devis.dart';
import 'model/devis_model.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _authState = ref.watch(authStateProvider);
    return MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.green,
          primarySwatch: Colors.green,
        ),
        home: _authState.when(
        data: (data)  {
          if (data != null) {
            return const HomePage();
          } else {
            return LoginPage();
          }
        },

        loading: () => const CircularProgressIndicator(),
        error: (e, trace) => const Text('error', textAlign: TextAlign.center,)));
  }

}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Devis'),
            Tab(text: 'Factures'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const  [
           HomeDevisList(),
           HomeFacturesList(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _getLastDevisId();

  }

  Future<void> _getLastDevisId() async {
    final List<int> ids = await TaskManager().getLastCreatedDevisId();
    setState(() {

      Utils.lastDevisId = ids[0];
      Utils.lastFactureId = ids[1];
    });
    print('rentre dans set state' + Utils.lastDevisId.toString());

  }
}

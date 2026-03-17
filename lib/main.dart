import 'package:flutter/material.dart';
import 'package:promoterapp/provider/DropdownProvider.dart';
import 'package:promoterapp/screen/Splashscreen.dart';
import 'package:promoterapp/util/Shared_pref.dart';
import 'package:promoterapp/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:async';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefClass.init();
  runApp(MyApp());

}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers:[

        ChangeNotifierProvider<DropdownProvider>(
            create: (_)=> DropdownProvider()
        ),

        ChangeNotifierProvider<AuthViewModel>(
            create: (_)=> AuthViewModel()
        ),

      ],
      child:MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }

}




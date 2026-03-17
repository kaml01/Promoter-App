import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:promoterapp/screen/HomeScreen.dart';
import 'package:promoterapp/screen/LoginScreen.dart';
import 'package:promoterapp/util/routes/routes_name.dart';

class Routes{

  static MaterialPageRoute generateRoute(RouteSettings routeSetting){

      switch(routeSetting.name){
        case  RoutesName.home:
          return MaterialPageRoute(builder:(BuildContext context) => HomeScreen());
        case RoutesName.login:
          return MaterialPageRoute(builder:(BuildContext context) => LoginScreen());
        default:
          return MaterialPageRoute(builder: (_){
            return const Scaffold(
              body: Center(
                child: Text('No route defined'),
              ),
            );
          });
      }

  }

}
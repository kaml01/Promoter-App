import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:promoterapp/repository/Auth_repository.dart';
import 'package:promoterapp/util/routes/routes_name.dart';

class AuthViewModel with ChangeNotifier{

  final _myrepo = AuthRepository();

  Future<void> loginApi(username,password,BuildContext context) async{

    _myrepo.loginApi(username,password).then((value){

      if(kDebugMode){

        Navigator.pushNamed(context, RoutesName.home);

      }

    }).onError((error,stackTrace){

      if(kDebugMode){
        print(error.toString());
      }

    });

  }

}
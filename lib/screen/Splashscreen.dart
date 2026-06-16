import 'dart:async';
import 'package:promoterapp/config/Common.dart';
import 'package:promoterapp/screen/HomeScreen.dart';
import 'package:promoterapp/screen/LoginScreen.dart';
import 'package:permission_handler/permission_handler.dart' as Permissionhandler;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../util/Shared_pref.dart';

class SplashScreen extends StatefulWidget{

  @override
  SplashScreenState createState() => new SplashScreenState();
  
}

class SplashScreenState extends State<SplashScreen>{

  @override
  void initState() {
    super.initState();
    print("userid value");
    _bootstrapApp();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [

          Expanded(
              flex: 2,
              child: Image.asset('assets/Images/jivo_logo.png')),
          const CircularProgressIndicator()

        ],
      ),
    );

  }

  Future<void> _bootstrapApp() async {
    try {
      await SharedPrefClass.init();
    } catch (e) {
      debugPrint("Shared preferences init failed: $e");
    }

    if (!mounted) {
      return;
    }

    checkisalreadyloggedin();
  }

  void checkisalreadyloggedin() async{

    try{

      int userid;
      String personName;

      personName = SharedPrefClass.getString(PERSON_NAME);
      userid = SharedPrefClass.getInt(USER_ID);

      if(userid!=0){

        Timer(const Duration(seconds: 3), () =>  Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            ));

      }else{

        Timer(const Duration(seconds: 3), () =>  Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
            ));

      }

    }catch(e){
      print("exceptionne $e");
    }

  }

  void calllocationfunction() async{

    var locationstatus = await Permissionhandler.Permission.locationAlways.status;

    if(locationstatus.isGranted == false){

    }else{
      await initializeService();
    }

  }

}


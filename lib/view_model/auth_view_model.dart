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

        // Logindetails details = Logindetails.fromJson(json.decode(value));
        // try {
        //
        //   if (response.statusCode == 200) {
        //
        //     if (details.personId != 0) {
        //
        //       try {
        //
        //         if(details.personType.toString().contains("PROMOTER")){
        //
        //           SharedPrefClass.setInt(USER_ID, details.personId);
        //           SharedPrefClass.setString(PERSON_TYPE, details.personType.toString());
        //           SharedPrefClass.setString(PERSON_NAME, details.personName.toString());
        //           SharedPrefClass.setString(GROUP, details.group.toString());
        //           SharedPrefClass.setString(DISTANCE_ALLOWED, details.distanceAllowed.toString());
        //
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) =>
        //                   HomeScreen(),
        //             ),
        //           );
        //
        //         }else{
        //
        //           Fluttertoast.showToast(
        //               msg: "Please check username and password !",
        //               toastLength: Toast.LENGTH_SHORT,
        //               gravity: ToastGravity.BOTTOM,
        //               timeInSecForIosWeb: 1,
        //               backgroundColor: Colors.black,
        //               textColor: Colors.white,
        //               fontSize: 16.0);
        //
        //         }
        //
        //       } catch (e) {
        //
        //         //print("distanceallowed$e");
        //
        //       }
        //
        //       Fluttertoast.showToast(
        //           msg: "Successfully logged in",
        //           toastLength: Toast.LENGTH_SHORT,
        //           gravity: ToastGravity.BOTTOM,
        //           timeInSecForIosWeb: 1,
        //           backgroundColor: Colors.black,
        //           textColor: Colors.white,
        //           fontSize: 16.0);
        //
        //     } else {
        //
        //       Fluttertoast.showToast(
        //         msg: "Please check your userid and password",
        //         toastLength: Toast.LENGTH_SHORT,
        //         gravity: ToastGravity.BOTTOM,
        //         timeInSecForIosWeb: 1,
        //         backgroundColor: Colors.black,
        //         textColor: Colors.white,
        //         fontSize: 16.0,
        //       );
        //
        //     }
        //
        //   } else {
        //
        //     Fluttertoast.showToast(
        //       msg: "Please check your credentials",
        //       toastLength: Toast.LENGTH_SHORT,
        //       gravity: ToastGravity.BOTTOM,
        //       timeInSecForIosWeb: 1,
        //       backgroundColor: Colors.black,
        //       textColor: Colors.white,
        //       fontSize: 16.0,
        //     );
        //
        //   }
        //
        // } catch (e) {
        //
        //   Fluttertoast.showToast(
        //     msg: "$e",
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: black,
        //     textColor: white,
        //     fontSize: 16.0,
        //   );

       // }
      }

    }).onError((error,stackTrace){

      if(kDebugMode){
        // FlutterToast.show("");
        print(error.toString());
      }

    });

  }

}
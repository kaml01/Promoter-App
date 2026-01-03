import 'package:flutter/material.dart';
import 'package:promoterapp/config/Common.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:promoterapp/util/Shared_pref.dart';
import 'package:permission_handler/permission_handler.dart' as Permissionhandler;
import 'dart:io';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart' as Geocoding;
import 'package:geolocator/geolocator.dart';

void getAttendanceStatus() async {

  String attStatus="";
  attStatus = SharedPrefClass.getString(ATT_STATUS);

  if(attStatus==""){

    penabled = true;
    woenabled = true;
    abenabled = true;
    present = true;
    wo = true;
    ab = true;

    eod = false;
    hd = false;
    eodenabled =false;
    hdenabled =false;

  }else if(attStatus=="P"){

    penabled = false;
    woenabled =false;
    abenabled = false;
    present = false;
    wo = false;
    ab = false;

    eod = true;
    hd = true;

    eodenabled =true;
    hdenabled =true;

  }else if(attStatus=="EOD"){

    penabled = false;
    woenabled =false;
    eodenabled =false;
    hdenabled =false;
    ab = false;
    abenabled = false;

    present = false;
    eod = false;
    wo = false;
    hd = false;

  }else if(attStatus=="NOON") {

    penabled = false;
    woenabled =false;
    hdenabled =false;
    ab = false;
    abenabled = false;

    eodenabled =true;
    present = false;
    eod = true;
    wo = false;
    hd = false;

  }else if(attStatus=="WO") {

    penabled = false;
    woenabled =false;
    eodenabled =false;
    hdenabled =false;
    ab = false;
    abenabled = false;

    present = false;
    eod = false;
    wo = false;
    hd = false;

  }else if(attStatus=="A") {

    penabled = false;
    woenabled =false;
    eodenabled =false;
    hdenabled =false;
    ab = false;
    abenabled = false;

    present = false;
    eod = false;
    wo = false;
    hd = false;

  }

}

Future<bool> checkNetwork() async {

  bool isConnected = false;

  try {

    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      isConnected = true;
    }

  } on SocketException catch (_) {
    isConnected = false;
  }

  return isConnected;
}

String getcurrentdatewithtime(){

  String date =DateFormat('MM-dd-yyyy HH:mm:ss').format(DateTime.now());
  return date;

}

// Future<void> showdialogg(String status,BuildContext context, List<Shops> listdata,progress) async {
//
//   progress.dismiss();
//   return showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder:(BuildContext context) {
//         return AlertDialog(
//           title: const Text('Attendance'),
//           content: const Text('Are you really present?'),
//           actions: <Widget>[
//
//             TextButton(
//               onPressed: () => {
//                 Navigator.pop(context, 'Cancel'),
//                 progress!.dismiss()
//               },
//               child: const Text('No'),
//             ),
//
//             TextButton(
//               onPressed: () =>{
//                 // Navigator.pop(context),
//                 gettodaysbeatt(status,context,listdata,progress),
//                },
//
//               child: const Text('Yes'),
//               ),
//
//            ],
//
//          );
//
//       }
//
//   );
//
// }
//
//
// Future<void> gettodaysbeatt(status,context,List<Shops> beatnamelist,progress) async {
//
//   int beatId = (SharedPrefClass.getInt(BEAT_ID)==0 ? -1 : SharedPrefClass.getInt(BEAT_ID));
//
//   if(beatId==0 || beatId ==-1){
//
//      //showbeat(status,context,beatnamelist,beatIdlist);
//      showbeatt(status,context,beatnamelist,progress);
//
//   }else{
//
//     markattendance(status,beatId.toString(),context,"" as File,progress);
//
//   }
//
// }
//
//
// Future<void> showbeatt(String status,BuildContext contextt, List<Shops> beatnamelist,progress) async {
//
//   if(beatnamelist.isEmpty){
//
//     Navigator.pop(contextt);
//
//     Fluttertoast.showToast(msg: "You don't have any beat! \n Please contact admin",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         backgroundColor: Colors.black,
//         textColor: Colors.white,
//         fontSize: 16.0);
//
//   }else{
//
//     Navigator.pop(contextt);
//   //  progress.dismiss();
//
//     return showDialog<void>(
//       context: contextt,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         contextt = context;
//         return AlertDialog(
//           title: const Text('Select Shop'),
//           content:ListView.builder(
//               shrinkWrap: true,
//               itemCount: beatnamelist.length,
//               itemBuilder: (context,i){
//                 return GestureDetector(
//
//                     onTap: (){
//
//                       Navigator.pop(contextt);
//                       if(SharedPrefClass.getDouble(latitude)==0.0){
//
//                         Fluttertoast.showToast(msg: "Please check your connection!",
//                             toastLength: Toast.LENGTH_SHORT,
//                             gravity: ToastGravity.BOTTOM,
//                             timeInSecForIosWeb: 1,
//                             backgroundColor: Colors.black,
//                             textColor: Colors.white,
//                             fontSize: 16.0);
//
//                       }else{
//
//                         if(getdistance(SharedPrefClass.getDouble(latitude),SharedPrefClass.getDouble(longitude),double.parse(beatnamelist[i].latitude!),double.parse(beatnamelist[i].longitude!))){
//
//                           SharedPrefClass.setInt(SHOP_ID,beatnamelist[i].retailerID!.toInt());
//                           selectFromCamera(status,beatnamelist[i].toString(),contextt,progress);
//
//                         }else{
//
//                           Fluttertoast.showToast(msg: "Too far from store!",
//                               toastLength: Toast.LENGTH_SHORT,
//                               gravity: ToastGravity.BOTTOM,
//                               timeInSecForIosWeb: 1,
//                               backgroundColor: Colors.black,
//                               textColor: Colors.white,
//                               fontSize: 16.0);
//
//                         }
//
//                       }
//
//                     },
//                     child: Container(
//                       padding:EdgeInsets.all(10),
//                       child: Text("${beatnamelist[i].retailerName}"),
//                     )
//                 );
//               }
//           ),
//         );
//       },
//     );
//
//   }
//
// }
//
//
// selectFromCamera(String status, String beatid,BuildContext contextt,progress) async {
//
//   var camerastatus = await Permissionhandler.Permission.camera.status;
//
//   if(camerastatus.isDenied == true){
//
//     Fluttertoast.showToast(msg: "Please allow camera permission!",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         backgroundColor: Colors.black,
//         textColor: Colors.white,
//         fontSize: 16.0);
//
//     Map<Permissionhandler.Permission, Permissionhandler.PermissionStatus> statuses = await [
//       Permissionhandler.Permission.camera
//     ].request();
//
//   }else{
//
//     try{
//
//         File? f;
//         int userid=0;
//         userid = SharedPrefClass.getInt(USER_ID);
//
//         final cameraFile= await ImagePicker().pickImage(source: ImageSource.camera,imageQuality: 50);
//
//         final now = new DateTime.now();
//         String dir = path.dirname(cameraFile!.path);
//         String newPath = path.join(dir,("$userid-${now.day}-${now.month}-${now.year}-${now.hour}${now.minute}${now.second}.jpg"));
//         f = await File(cameraFile.path).copy(newPath);
//
//         markattendance(status,beatid,contextt,f,progress);
//
//     }catch(e){
//
//       print('Failed to pick image: $e');
//
//     }
//
//   }
//
// }

Future<void> askpermission() async {

  var camerastatus = await Permissionhandler.Permission.camera.status;
  var locationstatus = await Permissionhandler.Permission.locationAlways.status;
  var readphonestate = await Permissionhandler.Permission.phone;

  if (camerastatus.isGranted == true && locationstatus.isGranted == false) {

    Geolocator.openAppSettings();

  } else if (camerastatus.isGranted == false && locationstatus.isGranted == false) {

    Map<Permissionhandler.Permission, Permissionhandler.PermissionStatus> statuses = await [
      Permissionhandler.Permission.location,
      Permissionhandler.Permission.camera,
      Permissionhandler.Permission.phone
    ].request();

  }

}

Future<void> checkdistance() async {

  var camerastatus = await Permissionhandler.Permission.camera.status;
  var locationstatus = await Permissionhandler.Permission.location.status;

  if (camerastatus.isGranted == false && locationstatus.isGranted == false) {

    Map<Permissionhandler.Permission, Permissionhandler.PermissionStatus> statuses = await [
      Permissionhandler.Permission.location,
      Permissionhandler.Permission.camera
    ].request();

  }else{

  }

}

/*get distance*/
bool getdistance(lat1 ,lng1, lat2, lng2){

  bool isallowed = false;
  var distance = Distance();

 // final totaldist = distance(LatLng(lat1,lng2), LatLng(lat2,lng2));
  final totaldist = Geolocator.distanceBetween(lat1,lng1,lat2,lng2);
  print("total distance $totaldist");
  int disallow = SharedPrefClass.getInt(DISTANCE_ALLOWED);
  print("DISTANCE ALLOWED $disallow");

  if(disallow > totaldist){

    print("$disallow");
    isallowed = true;

  }else{

    print("$totaldist");
    isallowed = false;

  }

  return isallowed;

}

Future<String> getdate(context) async{

  String dt= "";
  var date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now());

  if (date != null) {

    dt = DateFormat('MM/dd/yyyy').format(date);

  }

  return dt;
}

/*sales entry*/
Future<void> showskudialog(context, List SKUlist) async {

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      context = context;
      return AlertDialog(
        title: const Text('Select SKU'),
        content:ListView.builder(
            shrinkWrap: true,
            itemCount: SKUlist.length,
            itemBuilder: (context,i){
              return GestureDetector(

                  onTap: (){

                    Navigator.pop(context);
                   // addwidget(SKUlist[i]['itemName'],SKUlist[i]['itemID'],SKUlist[i]['imageurl'],num.parse(SKUlist[i]['quantity']));
                  },

                  child: Container(
                    padding:const EdgeInsets.all(10),
                    child: Text("${SKUlist[i]['itemName']}"),
                  )

              );
            }
        ),
      );
    },
  );

}

/*current date*/
String getcurrentdate(){

  String cdate = DateFormat("yyyy/MM/dd").format(DateTime.now());
  return cdate;

}

/*current location */
Position? currentPosition;

void getCurrentPosition(context) async {

  final hasPermission = await _handleLocationPermission(context);
  if (!hasPermission) return;

  await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
      .then((Position position) async {
    currentPosition = position;

    if(position.latitude==0.0){
      print("current location is null");
      currentPosition = await Geolocator.getLastKnownPosition();
      print("current location is null catch ${currentPosition!.latitude}");
    }

    SharedPrefClass.setDouble(latitude, currentPosition!.latitude);
    SharedPrefClass.setDouble(longitude, currentPosition!.longitude);
    // SharedPrefClass.setDouble(latitude, position.latitude);
    // SharedPrefClass.setDouble(longitude, position.longitude);

    //setState(() => currentPosition = position);
    _getAddressFromLatLng(currentPosition!);

  }).catchError((e) {
    debugPrint(e);
  });

}

Future<void> _getAddressFromLatLng(Position position) async {

  await Geocoding.placemarkFromCoordinates(
      currentPosition!.latitude, currentPosition!.longitude)
      .then((List<Geocoding.Placemark> placemarks) {

    if (placemarks != null && placemarks.isNotEmpty) {

      Geocoding.Placemark place = placemarks[0];
      // address = '${place.street}, ${place.subLocality}, ${place
      //     .subAdministrativeArea}, ${place.postalCode}';

    }else{
      print("unknown address");
    }

  }).catchError((e) {
    debugPrint(e);
  });

  //
  // await Geocoding.placemarkFromCoordinates(
  //     currentPosition!.latitude, currentPosition!.longitude)
  //     .then((List<Geocoding.Placemark> placemarks) {
  //   Geocoding.Placemark place = placemarks[0];
  //
  //   // setState(() {
  //   //
  //   //   _currentAddress = '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
  //   //
  //   // });
  //
  // }).catchError((e) {
  //   debugPrint(e);
  // });

}

Future<bool> _handleLocationPermission(context) async {

  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  print("serviceenabled $serviceEnabled");
  if (!serviceEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Location services are disabled. Please enable the services')));
    return false;
  }
  permission = await Geolocator.checkPermission();
  print("persmision latitude ${permission}");

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')));

      return false;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Location permissions are permanently denied, we cannot request permissions.')));
    return false;
  }
  return true;
}

Future<int> getBatteryLevel() async {

  Battery _battery = Battery();
  int level = await _battery.batteryLevel;

  return level;
}








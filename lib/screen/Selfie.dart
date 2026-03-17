import 'package:permission_handler/permission_handler.dart' as Permissionhandler;
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geocoding/geocoding.dart' as Geocoding;
import 'package:promoterapp/util/functionhelper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import '../models/Shops.dart';
import '../util/ApiHelper.dart';
import '../util/Shared_pref.dart';
import '../config/Common.dart';
import 'HomeScreen.dart';
import 'dart:convert';
import 'dart:io';

class Selfie extends StatefulWidget {

  const Selfie({super.key});

  @override
  State<Selfie> createState() => _SelfieState();

}

class _SelfieState extends State<Selfie> {

  File? f;
  bool _isLoading = false;
  String attstatus = "";
  List<Shops> shopdata = [];
  int userid = 0,shopid = 0;
  String _currentAddress="";

  @override
  void initState() {
    super.initState();
    getsharedprefdata();
    getallbeat('GetShopsDataver3').then((value) => allbeatlist(value));
    getCurrentPosition(context);
  }

  getsharedprefdata(){

    userid  = SharedPrefClass.getInt(USER_ID);
    attstatus = SharedPrefClass.getString(ATT_STATUS);
    shopid = SharedPrefClass.getInt(SHOP_ID);

  }

  Future<bool> _handleLocationPermission(context) async {
    bool serviceEnabled;
    geo.LocationPermission permission;

    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await geo.Geolocator.checkPermission();

    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));

        return false;
      }
    }
    if (permission == geo.LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  void getCurrentPosition(context) async {

    final hasPermission = await _handleLocationPermission(context);
    if (!hasPermission) return;

    await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.high)
        .then((geo.Position position) async {
      currentPosition = position;

      if(position.latitude==0.0){

        currentPosition = await geo.Geolocator.getLastKnownPosition();

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

  Future<void> _getAddressFromLatLng(geo.Position position) async {

    await Geocoding.placemarkFromCoordinates(
        currentPosition!.latitude, currentPosition!.longitude)
        .then((List<Geocoding.Placemark> placemarks) {

      if (placemarks != null && placemarks.isNotEmpty) {

        Geocoding.Placemark place = placemarks[0];
        _currentAddress = '${place.street}, ${place.subLocality}, ${place
            .subAdministrativeArea}, ${place.postalCode}';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ProgressHUD(
        child: Builder(
        builder: (ctx) =>
          InkWell(
          onTap: (){
            selectFromCamera(ctx);
          },
          child: Center(
            child: Image.asset('assets/Images/selfie.png',width: 100,height: 100,)
          ),
        )
         )
       )
    );
  }

  selectFromCamera(BuildContext contextt) async {

    var camerastatus = await Permissionhandler.Permission.camera.status;

    if(camerastatus.isDenied == true){

      Fluttertoast.showToast(msg: "Please allow camera permission!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);

      Map<Permissionhandler.Permission, Permissionhandler.PermissionStatus> statuses = await [
        Permissionhandler.Permission.camera
      ].request();

    }else{

      try{

        int userid=0;
        userid = SharedPrefClass.getInt(USER_ID);

        final cameraFile= await ImagePicker().pickImage(source: ImageSource.camera,imageQuality: 50);

        final now = new DateTime.now();
        String dir = path.dirname(cameraFile!.path);
        String newPath = path.join(dir,("$userid-${now.day}-${now.month}-${now.year}-${now.hour}${now.minute}${now.second}.jpg"));
        f = await File(cameraFile.path).copy(newPath);

        submitselfpie(contextt, f);

      }catch(e){

        print('Failed to pick image: $e');

      }

    }

  }

  void allbeatlist(value){
    print("value");
    setState(() {
      _isLoading = true;
    });

    if(value.length == 0){
      print("value1");
      Future.delayed(const Duration(seconds: 3), () {

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomeScreen()));

      });

      Fluttertoast.showToast(msg: "You don't have any beat! \n Please contact admin",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);

    }else{

      shopdata = value;
      print("value2"+attstatus);

      if(attstatus=="P"||attstatus=="NOON"){
        showbeatt(attstatus,context,shopdata);
      }

    }

  }

  Future<void> showbeatt(String status,BuildContext contextt, List<Shops> beatnamelist) async {

    if(beatnamelist.isEmpty){

      Navigator.pop(contextt);

      Fluttertoast.showToast(msg: "You don't have any beat! \n Please contact admin",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);

    }else{

      return showDialog<void>(
        context: contextt,
        barrierDismissible: false,
        builder: (BuildContext context) {
          contextt = context;
          return WillPopScope(
            child: AlertDialog(

                title: const Text('Select Shop'),
                content: SizedBox(
                  width: 400,
                  // height: 100,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: beatnamelist.length,
                      itemBuilder: (context,i){
                        return GestureDetector(

                            onTap: (){

                              Navigator.pop(contextt);

                              if(SharedPrefClass.getDouble(latitude)==0.0){

                                Fluttertoast.showToast(msg: "Please check your connection!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                    fontSize: 16.0);

                              }else{

                                if(getdistance(SharedPrefClass.getDouble(latitude),SharedPrefClass.getDouble(longitude),double.parse(beatnamelist[i].latitude!),double.parse(beatnamelist[i].longitude!))){

                                  print("beatlistid"+(beatnamelist[i].retailerID!.toInt()).toString());
                                  SharedPrefClass.setInt(SHOP_ID,beatnamelist[i].retailerID!.toInt());

                                }else{

                                  SharedPrefClass.setInt(SHOP_ID,beatnamelist[i].retailerID!.toInt());

                                  setState(() {
                                    _isLoading=false;
                                  });

                                  Fluttertoast.showToast(msg: "Too far from store!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (contextt) =>
                                              HomeScreen()
                                      )
                                  );

                                }

                              }

                            },
                            child: Container(
                              padding:EdgeInsets.all(10),
                              child: Text("${beatnamelist[i].retailerName}"),
                            )

                        );
                      }
                  ),
                )
            ),
            onWillPop: ()  {

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (contextt) =>
                          HomeScreen()
                  )
              );
              return new Future(() => true);

            },
          );

        },
      );

    }

  }

  Future<void> submitselfpie(BuildContext ctx,File? file) async {

    final progress = ProgressHUD.of(ctx);
    progress?.show();

    try{

      var salesentry = [{
        "personId":SharedPrefClass.getInt(USER_ID),
        "latitude": SharedPrefClass.getDouble(latitude),
        "longitude": SharedPrefClass.getDouble(longitude),
        "retailerId":SharedPrefClass.getInt(SHOP_ID),
        "address":_currentAddress
      }];
    //  print("address"+_currentAddress);
      var request = await http.MultipartRequest('POST', Uri.parse('${SharedPrefClass.getString(IP_URL)}SelfieData'));
      request.fields['data']= json.encode(salesentry);
      request.files.add(await http.MultipartFile.fromPath('image', file!.path.toString()));

      var response = await request.send();
      var responsed = await http.Response.fromStream(response);
      final responsedData = json.decode(responsed.body);

      if(response.statusCode == 200){

        Fluttertoast.showToast(msg: responsedData.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);

        if(responsedData.contains("DONE")){

          progress?.dismiss();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(),
            ),
          );

          Fluttertoast.showToast(msg: responsedData,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);

        }

      }else{

        Fluttertoast.showToast(msg: "Please contact admin!!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);

      }

    }catch(e){

      print("print image ${e.toString()}");

    }

  }

}

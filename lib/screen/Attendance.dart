import 'package:permission_handler/permission_handler.dart' as Permissionhandler;
import 'package:geocoding/geocoding.dart' as Geocoding;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:promoterapp/util/functionhelper.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:promoterapp/util/ApiHelper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:promoterapp/models/Shops.dart';
import 'package:location/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../util/Shared_pref.dart';
import '../config/Common.dart';
import 'HomeScreen.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';


class Attendance extends StatefulWidget{

    @override
    State<StatefulWidget> createState() {
      return AttendanceState();
    }

}

class AttendanceState extends State<Attendance>{

  double? lat ,lng;
  List beatnamelist = [];
  List<int> beatIdlist = [];
  int userid=0,beatId=0;
  String attStatus="";
  bool _isLoading = false;
  get progress => null;
  List<Shops> shopdata = [];
  bool cstatus = false ,lstatus =false,gpsstatus=false;
  Location location = Location();
  Timer? timer;
  File? f;
  String? serielno;
  String _currentAddress="";
  List<SimCard> _simCard = <SimCard>[];

  @override
  void initState() {
    super.initState();
    initMobileNumberState();
    askpermission();
    getCurrentPosition(context);
    getAttendanceStatus();
    setState(() {
      _isLoading = true;
    });

    getallbeat('GetShopsDataver3').then((value) => allbeatlist(value));

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

  Future<void> getCurrentPosition(context) async {
    final hasPermission = await _handleLocationPermission(context);
    if (!hasPermission) return;

    try {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high
      );

      if (position.latitude == 0.0) {
        position = (await geo.Geolocator.getLastKnownPosition())!;
      }

      currentPosition = position;
      await SharedPrefClass.setDouble(latitude, position.latitude);
      await SharedPrefClass.setDouble(longitude, position.longitude);

      print("latitude ${SharedPrefClass.getDouble(latitude)}");

      await _getAddressFromLatLng(position);
    } catch (e) {
      debugPrint('Location error: $e');
    }
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
  void dispose() {
    timer?.cancel();
    super.dispose();
  }


  Future<void> initMobileNumberState() async {

    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }

    try {
      _simCard = (await MobileNumber.getSimCards)!;
      print("simdata1 $_simCard");
    } on PlatformException catch (e) {
      debugPrint("Failed to get mobile number because of '${e.message}'");
    }

    fillCards();

    if (!mounted) return;

    setState(() {});
  }

  void fillCards() {

    for(int i=0;i<_simCard.length;i++){
      serielno = _simCard[i].number;
    }

  }

  void printSimCardsData() async {

    // try {
    //
    //   SimData simData = await SimDataPlugin.getSimData();
    //
    //   for (var s in simData.cards) {
    //      serielno = simData.cards[0].serialNumber;
    //      print('Serial number: ${s.slotIndex} ${s.serialNumber}');
    //
    //   }
    //
    // } catch (e) {
    //
    //   Fluttertoast.showToast(
    //       msg: "This is Toast",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.CENTER,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: Colors.red,
    //       textColor: Colors.white,
    //       fontSize: 16.0
    //   );
    //
    //   print('Serial number: ${e}');
    //   // debugPrint("error! code: ${e.code} - message: ${e.message}");
    // }

  }

  Future<void> askpermission() async {

    try{

      var camerastatus = await Permissionhandler.Permission.camera.status;
      var locationstatus = await Permissionhandler.Permission.locationWhenInUse.status;

      if (camerastatus.isGranted == false || locationstatus.isGranted == false) {

        Map<Permissionhandler.Permission, Permissionhandler.PermissionStatus> statuses = await [
          Permissionhandler.Permission.location,
          Permissionhandler.Permission.camera
        ].request();

      }

      print("camerastatusisgranted ${camerastatus.isGranted}");
      if(camerastatus.isGranted==true){
        cstatus = true;
      }

      if(locationstatus.isGranted == true){
        lstatus = true;

      }

      bool ison = await location.serviceEnabled();

      if (!ison) {

        bool isturnedon = await location.requestService();

        if (isturnedon) {
          gpsstatus = true;
          print("gpsstatus$gpsstatus");
        }else{
          print("gpsstatus$isturnedon");
        }

      }else{

        gpsstatus = true;

      }

    }catch(e){

      print("gpsstatus$e");

    }

  }

  void allbeatlist(value){

    if(value.length == 0){

      Future.delayed(Duration(seconds: 3), () {

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
      setState(() {
        _isLoading = false;
      });

    }

  }

  Future<void> showalltimepermissiondialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Disclosure'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This app collects location data to enable background location even when the app is closed or not in use'),

              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ok'),
              onPressed: () {

              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext ctx) {

    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.white,
                leading: GestureDetector(
                  onTap: (){

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomeScreen()));

                  },
                  child: const Icon(Icons.arrow_back,color:Color(0xFF063A06)),
                ),
                title: const Text("My Attendance",
                    style: TextStyle(color:Color(0xFF063A06),fontWeight: FontWeight.w400)
                )
            ),
            body:_isLoading?const Center(
                child:CircularProgressIndicator()
            ):
            Scaffold(
                body: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children:[

                            GestureDetector(
                              onTap: penabled? (){

                                if(cstatus==false){

                                  Fluttertoast.showToast(msg: "Please allow camera permission");

                                }else if(lstatus ==false){

                                  Fluttertoast.showToast(msg: "Please allow location permission");

                                }else{

                                  // setState(() {
                                  //   _isLoading=true;
                                  // });

                                  showdialogg("P",ctx,shopdata);

                                }

                              }:null,
                              child:Container(
                                height: 100,
                                width: 100,
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:  present ? const Color(0xff0e0e0e) : Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                    child:Text(
                                      "PRESENT",
                                      style: TextStyle(color:Colors.white),
                                    )
                                ),
                              ),
                            ),

                            GestureDetector(

                              onTap: eodenabled?(){

                                setState(() {
                                  _isLoading=true;
                                });

                                showdialogg("EOD",ctx, shopdata);

                              }:null,

                              child:Container(
                                height: 100,
                                width: 100,
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: eod ? const Color(0xff0e0e0e):Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                    child:Text("END OF DAY",style: TextStyle(color: Colors.white),)
                                ),
                              ),

                            ),

                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children:[

                            GestureDetector(
                              onTap: hdenabled?(){

                                if(cstatus==false){

                                  Fluttertoast.showToast(msg: "Please allow camera permission");

                                }else if(lstatus ==false){

                                  Fluttertoast.showToast(msg: "Please allow location permission");

                                }else{
                                  setState(() {
                                    _isLoading=true;
                                  });

                                  showdialogg("NOON",ctx,shopdata);

                                }

                              }:null,

                              child: Container(
                                height: 100,
                                width: 100,
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: hd ?  const Color(0xff0e0e0e) : Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                    child: Text("MID DAY",style: TextStyle(
                                        color: Colors.white
                                    ),
                                    )
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap:woenabled? (){

                                setState(() {
                                  _isLoading=true;
                                });
                                showdialogg("WO",context,shopdata);

                                // try{
                                //   Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //           builder: (ctx) =>
                                //               HomeScreen()));
                                // }catch(e){
                                //   print("print image $e");
                                // }
                              }:null,
                              child:Container(
                                height: 100,
                                width: 100,
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: wo ?  const Color(0xff0e0e0e):Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                    child: Text("WEEK OFF",style: TextStyle(
                                        color: Colors.white
                                    ),
                                    )
                                ),
                              ),
                            )

                          ],

                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            GestureDetector(
                              onTap:abenabled?(){

                                setState(() {
                                  _isLoading=true;
                                });

                                showdialogg("A",ctx,shopdata);

                              }:null,
                              child: Container(
                                height: 100,
                                width: 100,
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: ab ?  const Color(0xff0e0e0e) : Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                    child: Text("ABSENT",style: TextStyle(
                                        color: Colors.white
                                    ),
                                    )
                                ),
                              ),
                            )

                          ],
                        )

                     ]

                  ),
                )
            )
        ),
        onWillPop: () {

          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (contextt) =>
                      HomeScreen()
              )
          );

          return new Future(() => true);

        }
    );

  }

  Future<void> showdialogg(String status,BuildContext ctx, List<Shops> listdata) async {

    return showDialog(
      
        barrierDismissible: false,
        context: context,
        builder:(BuildContext context) {
          ctx = context;
          return AlertDialog(
            title: const Text('Attendance'),
            content:status=="P"||status=="NOON"?Text('Are you really present?'):Text('Are you sure?'),
            actions: <Widget>[

              TextButton(
                onPressed: () => {
                  Navigator.pop(context, 'Cancel'),
                  setState(() {
                    _isLoading = false;
                  })
                 // progress!.dismiss()
                },
                child: const Text('No'),
              ),

              TextButton(
                onPressed: () =>{

                  if(status=="P" || status=="NOON" ||status=="EOD"){

                    gettodaysbeatt(status,ctx,listdata),

                  }else{

                     markattendance(status,beatId.toString(),context,f)

                  }

                },
                child: const Text('Yes'),
              ),

            ],

          );

        }
      
    );

  }

  Future<void> gettodaysbeatt(status,context,List<Shops> beatnamelist) async {

    int beatId = (SharedPrefClass.getInt(BEAT_ID)==0 ? -1 : SharedPrefClass.getInt(BEAT_ID));

    if(beatId==0 || beatId ==-1 ){

      //showbeat(status,context,beatnamelist,beatIdlist);
      showbeatt(status,context,beatnamelist);

    }else{

      markattendance(status,beatId.toString(),context,"" as File);

    }

  }

  Future<void> showbeatt(String status,BuildContext contextt, List<Shops> beatnamelist) async {

    if(beatnamelist.isEmpty){

      Navigator.pop(contextt);

      Fluttertoast.showToast(msg: "No shop assigned",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);

    }else{

      Navigator.pop(contextt);

      return showDialog<void>(
        context: contextt,
        barrierDismissible: false,
        builder: (BuildContext context) {
          contextt = context;
          return WillPopScope(
              child: AlertDialog(
                title: const Text('Select Shop'),
                content: SizedBox(
                  width:400,
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

                                print("locationlatitude ${getdistance(SharedPrefClass.getDouble(latitude),SharedPrefClass.getDouble(longitude),double.parse(beatnamelist[i].latitude!),double.parse(beatnamelist[i].longitude!))}");

                                if(getdistance(SharedPrefClass.getDouble(latitude),SharedPrefClass.getDouble(longitude),double.parse(beatnamelist[i].latitude!),double.parse(beatnamelist[i].longitude!))){

                                  SharedPrefClass.setInt(SHOP_ID,beatnamelist[i].retailerID!.toInt());
                                  selectFromCamera(status,beatnamelist[i].toString(),contextt);

                                }else{

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
              onWillPop: () {

                setState(() {
                  _isLoading = false;
                });

                return new Future(() => true);

              });
        },
      );

    }

  }

  selectFromCamera(String status, String beatid,BuildContext contextt) async {

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

        markattendance(status,beatid,contextt,f!);
        setState(() {
          _isLoading=false;
        });
      }catch(e){

        print('Failed to pick image: $e');

      }

    }

  }

  Future<void> markattendance(String status, String beatid,BuildContext ctx,File? file) async {

    try{

      int userid=0;
      userid = SharedPrefClass.getInt(USER_ID);

      var request = await http.MultipartRequest('POST', Uri.parse('${SharedPrefClass.getString(IP_URL)}AddSalesPersonAttendance'));

      request.fields['personId']= userid.toString();
      request.fields['status']= status;
      request.fields['latitude']= SharedPrefClass.getDouble(latitude).toString();
      request.fields['longitude']= SharedPrefClass.getDouble(longitude).toString();
      request.fields['address']= _currentAddress;
      request.fields['retailerId']= SharedPrefClass.getInt(SHOP_ID).toString();
      request.fields['simNo']= serielno.toString();

      if(file != null){
        request.files.add(await http.MultipartFile.fromPath('image', file.path));
      }

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

          SharedPrefClass.setString(ATT_STATUS,status);

          setState(() {
            _isLoading=false;
          });

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen()));

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

      print("print image $e");

    }

  }

}


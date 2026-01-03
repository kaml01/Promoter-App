import 'package:permission_handler/permission_handler.dart' as Permissionhandler;
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:promoterapp/config/Common.dart';
import 'package:promoterapp/models/Item.dart';
import 'package:promoterapp/models/SalesItem.dart';
import 'package:promoterapp/models/Shops.dart';
import 'package:promoterapp/screen/Attendance.dart';
import 'package:promoterapp/screen/HomeScreen.dart';
import 'package:promoterapp/screen/MyWidget.dart';
import 'package:promoterapp/util/ApiHelper.dart';
import 'package:promoterapp/util/DatabaseHelper.dart';
import 'package:promoterapp/util/Networkconnectivity.dart';
import 'package:promoterapp/util/Shared_pref.dart';
import 'package:promoterapp/util/functionhelper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geocoding/geocoding.dart' as Geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:promoterapp/provider/DropdownProvider.dart';
import 'package:sim_data_plus/sim_data.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

List dynamicList = [];
class SalesEntry  extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return SalesEntryState();
  }

}

class SalesEntryState extends State<SalesEntry>{

  Position? currentPosition;
  String dt = "";
  List itemlist = [], itemid=[];
  final DatabaseHelper dbManager = DatabaseHelper();
  final connectivityResult = Connectivity().checkConnectivity();
  NetworkConnectivity networkConnectivity = NetworkConnectivity();
  int _batteryLevel = 0,userid = 0,shopid = 0;
  bool isturnedon = true;
  String attstatus = "";
  String _currentAddress="";
  List<Item> itemdata = [];
  List allitems = [];
  int _counter = 0,idx=0;
  File? cameraFile, cameraFile1, cameraFile2, f, f1, f2;
  List<Shops> shopdata = [];
  bool _isLoading = false;
  String? serielno;

  @override
  void initState() {
    super.initState();

    printSimCardsData();
    getuserdetails('Userdetails');
    getallbeat('GetShopsDataver3').then((value) => allbeatlist(value));

    getCurrentPosition();
    getsharedprefdata();
    getofflinedata();

    getBatteryLevel().then((value) => {
      _batteryLevel = value
    });

  }

  void allbeatlist(value) {

    setState(() {
      _isLoading = true;
    });

    if(value.length == 0){

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
        if(attstatus=="P"||attstatus=="NOON"){
          showbeatt(attstatus,context,shopdata);
        }

    }

  }

  void printSimCardsData() async {

    print('printSimCardsData');

    try {

      SimData simData = await SimDataPlugin.getSimData();
      print('printSimCardsData2');
      // for (var s in simData.cards) {
      serielno = simData.cards[0].serialNumber;

    } catch (e) {

      print('Serial number: ${e}');
      // debugPrint("error! code: ${e.code} - message: ${e.message}");
    }

  }

  getofflinedata() async{

    allitems.clear();
    allitems = await DatabaseHelper.getItems();

  }

  getsharedprefdata(){

    userid  = SharedPrefClass.getInt(USER_ID);
    attstatus = SharedPrefClass.getString(ATT_STATUS);
    shopid = SharedPrefClass.getInt(SHOP_ID);

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

  void getCurrentPosition() async {

    final hasPermission = await _handleLocationPermission(context);
    if (!hasPermission) return;

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      currentPosition = position;
      //print("current location is null${position.latitude}");

      if(position.latitude==0.0){
        //print("current location is null");
        currentPosition = await Geolocator.getLastKnownPosition();
        //print("current location is null catch ${currentPosition!.latitude}");
      }

      SharedPrefClass.setDouble(latitude, currentPosition!.latitude);
      SharedPrefClass.setDouble(longitude, currentPosition!.longitude);

      _getAddressFromLatLng(currentPosition!);

    }).catchError((e) async {
      //print("current location is null catch");
      currentPosition = await Geolocator.getLastKnownPosition();
      //print("current location is null catch ${currentPosition!.latitude}");
      debugPrint(e);
    });

  }

  Future<void> _getAddressFromLatLng(Position position) async {

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

  }

  Future<bool> _handleLocationPermission(context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();

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

  @override
  Widget build(BuildContext context)  {

    final dropdownOptionsProvider = Provider.of<DropdownProvider>(context);
    return WillPopScope(
        child: Scaffold(

            appBar: AppBar(
                backgroundColor: Colors.white,
                leading: GestureDetector(
                  onTap: (){

                    dynamicList.clear();

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomeScreen()));

                  },
                  child: const Icon(Icons.arrow_back,color:Color(0xFF063A06)),
                ),
                actions: [

                  AnimatedOpacity(
                    opacity: _counter != 0 ? 1 : 0,
                    duration: Duration(milliseconds: 500),
                    child: const Text(
                      '0',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ),

                ],
                title: const Text("Sales Entry", style: TextStyle(color:Color(0xFF063A06),fontWeight: FontWeight.w400))
            ),
            body: attstatus=="P" || attstatus=="NOON"? ProgressHUD(
                child:Builder(
                  builder:(ctx)=>

                      Scaffold(
                        body: Column(
                          children: [

                            Container(
                              height: 50,
                              color: Colors.black12,
                              child: Row(
                                children: [

                                  Expanded(
                                      flex: 1,
                                      child:GestureDetector(

                                          onTap: (){

                                            final progress = ProgressHUD.of(ctx);
                                            progress?.show();

                                            showskudialog(context,allitems,progress);

                                          },

                                          child:Container(
                                            child:  const Center(
                                              child:Text("+",style: TextStyle(
                                                  fontSize: 25
                                              ),
                                              ),
                                            ),
                                          )

                                      )
                                  ),

                                  Expanded(
                                      child:GestureDetector(

                                        onTap: (){
                                          getdate(context).then((value) => {
                                            setState((){
                                              dt =value;
                                            })
                                          });
                                        },

                                        child: Container(
                                          child: Center(
                                            child: Text(dt == ""?"Date" :dt,style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ),

                                      )
                                  ),

                                  Expanded(
                                      flex: 1,
                                      child: GestureDetector(

                                          onTap: (){

                                            final progress  = ProgressHUD.of(ctx);
                                           // if(currentPosition?.latitude==0.0 || currentPosition?.latitude == null){
                                              save(dropdownOptionsProvider,context,progress);

                                            // }else{
                                            //   Fluttertoast.showToast(msg: "Please turn on location");
                                            // }

                                          },

                                          child:const Center(
                                            child:Text("SAVE",style: TextStyle(
                                                fontSize: 16
                                            ),
                                            ),
                                          )
                                      )
                                  ),

                                ],
                              ),
                            ),

                            Row(
                              children: [

                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                      onTap: (){
                                        selectFromCamera("image");
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        height: 100,
                                        child:Center(
                                            child:cameraFile==null?Image.asset('assets/Images/plus.png',height: 15):Image.file(File(cameraFile!.path),width: MediaQuery.of(context).size.width)
                                        )
                                      )
                                  ),
                                ),

                                Expanded(
                                    flex: 1,
                                    child:InkWell(
                                      onTap: (){
                                        selectFromCamera("image1");
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        height: 100,
                                        child:Center(
                                            child:cameraFile1==null?Image.asset('assets/Images/plus.png',height: 15):Image.file(File(cameraFile1!.path))

                                        )
                                      ),
                                    )
                                ),

                                Expanded(
                                    flex: 1,
                                    child:InkWell(
                                      onTap: (){
                                        selectFromCamera("image2");
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        height: 100,
                                        child: Center(
                                            child:cameraFile1==null?Image.asset('assets/Images/plus.png',height: 15):Image.file(File(cameraFile1!.path))
                                        )
                                      ),
                                    )
                                ),

                              ],
                            ),

                            Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: dynamicList.length,
                                  itemBuilder: (_, index) =>
                                  dynamicList[index]
                              ),
                            ),

                         ],
                      ),
                   ),

                )
            ):AlertDialog(
              content:Wrap(
                children: [

                  Image.asset('assets/Images/complain.png',width: 40,height: 40,),
                  Container(
                    margin: EdgeInsets.all(10),
                    child:Text("First Mark Present"),
                  )

                ],
              ),
              actions: <Widget>[

                TextButton(
                  onPressed: () => {

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomeScreen()))

                  },
                  child: const Text('Cancel'),
                ),

                TextButton(
                  onPressed: () =>{

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Attendance()))

                  },
                  child: const Text('Ok'),
                ),

              ],

            )

        ),
        onWillPop:() async{
          dynamicList.clear();

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (contextt) =>
                      HomeScreen()));

          return new Future(() => true);

        }
    );

  }

  Future<void> SKUlist(value,context) async {

    itemdata = value.map<Item>((m) => Item.fromJson(Map<String, dynamic>.from(m))).toList();

  }

  Future<void> save(DropdownProvider dropdownOptionsProvider,context,progress) async {

    int userid = SharedPrefClass.getInt(USER_ID);
    List<SalesItem> items = [];

    int os = 0,cs=0,smpstk=0,sale=0 ;
    dynamicList.forEach((widget) {

      String op_stock = widget.op_stock.text;

      if (op_stock != "") {
        os++;
      }

      String cl_stock = widget.clo_stock.text;

      if (cl_stock != "") {
        cs++;
      }

      String samp_stock = widget.samp_stock.text;

      if (samp_stock != "") {
        smpstk++;
      }

      String sales = widget.sale.text;

      if (sales != "") {
        sale++;
      }

    });

    if(dynamicList.length==0){

      Fluttertoast.showToast(msg: "Please select SKU");

    }else if(smpstk!=dynamicList.length){

      Fluttertoast.showToast(msg: "Please enter sample stock");

    }else if(sale!=dynamicList.length){

      Fluttertoast.showToast(msg: "Please enter sales");

    }else if(cameraFile==null){

      Fluttertoast.showToast(msg: "Please select image");

    }else if(dt==""){

      Fluttertoast.showToast(msg: "Please select date");

    }else {

      progress?.show();

      for (int i = 0; i < dynamicList.length; i++) {

        items.add(
            SalesItem(
            int.parse(dropdownOptionsProvider.SKUid[i].toString()),
            // int.parse(dropdownOptionsProvider.open_stoc[i].toString()),
            // int.parse(dropdownOptionsProvider.clos_stoc[i].toString()),
            int.parse(dropdownOptionsProvider.sampl_stoc[i].toString()),
            dropdownOptionsProvider.selectedpieces[i],
            dropdownOptionsProvider.selectedquantity[i]
          )
        );

      }

      var salesentry = [{
           "location":_currentAddress,
           "personId": userid,
           "shopId": SharedPrefClass.getInt(SHOP_ID),
           "timeStamp": dt,
           "latitude": currentPosition?.latitude,
           "longitude": currentPosition?.longitude,
           "simNo":serielno,
           "address":"",
           "battery": _batteryLevel,
           "GpsEnabled": "GPS",
           "accuracy": currentPosition?.accuracy,
           "speed": currentPosition?.speed,
           "provider": "GPS",
           "altitude": currentPosition?.altitude,
           "items": json.encode(items),
      }];

      var body = json.encode(salesentry);
      print("body ${salesentry.toString()}");

      try{

        if(f1==null && f2==null){

          savepromotersale(body.toString(), f!.path.toString(), "", "", context, progress,dynamicList);

        }else if(f1==null){

          savepromotersale(body.toString(), f!.path.toString(), "", f2!.path.toString(), context, progress,dynamicList);

        }else if(f2==null){

          savepromotersale(body.toString(), f!.path.toString(), f1!.path.toString(),"", context, progress,dynamicList);

        }else{

          savepromotersale(body.toString(), f!.path.toString(), f1!.path.toString(),f2!.path.toString(), context, progress,dynamicList);

        }

      }catch(e){

        print("exception $e");

      }

    }

  }

  void addwidget(skUlist,itemid,imageurl,num quantity) async{

    setState(() {
      dynamicList.add(MyWidget(skUlist,itemid,imageurl,idx,quantity));
    });

    idx++;

  }

  Future<void> showskudialog(context, List SKUlist,progress) async {

    progress.dismiss();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        context = context;
        return StatefulBuilder(
          builder: (context,setState){
            return AlertDialog(
                title: const Text('Select SKU'),
                content: SizedBox(
                    width: 400, // Adjust the width as needed
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: SKUlist.length,
                      itemBuilder: (context,i){
                        return GestureDetector(
                            onTap: (){

                              Navigator.pop(context);
                              addwidget(SKUlist[i]['itemName'],SKUlist[i]['itemID'],SKUlist[i]['imageurl'],num.parse(SKUlist[i]['quantity']));

                            },

                            child: Container(
                              padding:const EdgeInsets.all(10),
                              child: Text("${SKUlist[i]['itemName']}"),
                            )

                        );
                      }
                  )
               )
            );
          },
        );
      },
    );

  }

  selectFromCamera(String s) async {

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

        if(s=="image"){

          f = await File(cameraFile.path).copy(newPath);
          setState(() {
            this.cameraFile = File(cameraFile.path);
          });

        }else if(s=="image1"){

          f1 = await File(cameraFile.path).copy(newPath);
          setState(() {
            this.cameraFile1 = File(cameraFile.path);

          });

        }else if(s=="image2"){

          f2 = await File(cameraFile.path).copy(newPath);
          setState(() {
            this.cameraFile2 = File(cameraFile.path);
          });

        }

      }catch(e){

        Fluttertoast.showToast(msg: "$e",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);

      }

    }

  }

}

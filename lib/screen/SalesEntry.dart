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
import 'package:sim_card_code/sim_card_code.dart';
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

class SalesEntryState extends State<SalesEntry> {

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
  int idx=0;
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
    try {
      final serialNumber = await SimCardManager.simSerialNumber;
      serielno = serialNumber;
      print('Serial number: $serialNumber');
    } catch (e) {
      print('Error: $e');
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
      currentPosition = await Geolocator.getLastKnownPosition();
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

  Widget _buildAttendanceWarning() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // A large, clear icon to show action is required
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_clock_outlined,
                size: 80,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Attendance Required",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF063A06),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "You haven't marked your attendance yet. Please mark 'Present' to start entering sales data.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Attendance()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF063A06),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Go to Attendance",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Back to Home",
                style: TextStyle(color: Colors.grey),
              ),
            ),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dropdownOptionsProvider = Provider.of<DropdownProvider>(context);    if (attstatus != "P" && attstatus != "NOON") {
      return _buildAttendanceWarning();
    }

    return ProgressHUD(
      child: Builder(
        builder: (hudContext) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color(0xFF063A06),
              foregroundColor: Colors.white,
              title: const Text(
                  "Sales Entry",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400)
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    dynamicList.clear();
                    idx = 0;
                  });
                  Navigator.pop(context);
                },
              ),
              actions: [
                // The Save Button
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton.icon(
                    onPressed: () {
                      final progress = ProgressHUD.of(hudContext);
                      save(dropdownOptionsProvider, context, progress);
                    },
                    icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 20),
                    label: const Text(
                      "SAVE",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                _buildInfoCard(),
                _buildImageSelectors(),
                _buildDateSelector(),
                const Divider(height: 1),
                Expanded(
                  child: dynamicList.isEmpty
                      ? _buildEmptyState(hudContext) // Pass hudContext here
                      : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: dynamicList.length,
                    itemBuilder: (_, index) => dynamicList[index],
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xFF063A06),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {

                final progress = ProgressHUD.of(hudContext);
                showskudialog(context, allitems, progress);

              },
            ),
          );
        },
      ),
    );

  }

  Widget _buildEmptyState(BuildContext ctx) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),

          const SizedBox(height: 10),

          const Text(
            "No SKUs added yet",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () {
              final progress = ProgressHUD.of(ctx);
              showskudialog(context, allitems, progress);
            },
            icon: const Icon(Icons.add),
            label: const Text("Add First Item"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF063A06),
              foregroundColor: Colors.white,
            ),
          )

        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell(
        onTap: () async {

          String? selectedDate = await getdate(context);
          if (selectedDate != null) {
            setState(() {
              dt = selectedDate;
            });
          }

        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: dt == "" ? Colors.red.withOpacity(0.5) : Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month, color: dt == "" ? Colors.red : const Color(0xFF063A06)),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sales Date",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    dt == "" ? "Select Transaction Date" : dt,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: dt == "" ? Colors.grey[400] : Colors.black87,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: const Color(0xFF063A06),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.store, color: Colors.white70),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _currentAddress.isEmpty ? "Detecting location..." : _currentAddress,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSelectors() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          _imageBox("Main", cameraFile, "image"),
          const SizedBox(width: 8),
          _imageBox("Shelf", cameraFile1, "image1"),
          const SizedBox(width: 8),
          _imageBox("Other", cameraFile2, "image2"),
        ],
      ),
    );
  }

  Widget _imageBox(String label, File? file, String type) {
    return Expanded(
      child: GestureDetector(
        onTap: () => selectFromCamera(type),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: file == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_a_photo, size: 20, color: Colors.grey),
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          )
              : ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(file, fit: BoxFit.cover),
          ),
        ),
      ),
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

  Future<void> showskudialog(BuildContext context, List skUlist, progress) async {

    progress.dismiss();
    List filteredList = List.from(skUlist);

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [

                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        const Text(
                          "Select Product",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),

                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>{
                            Navigator.pop(context)
                          },
                        )

                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: TextField(
                      onChanged: (value) {
                        setModalState(() {
                          filteredList = skUlist
                              .where((item) => item['itemName']
                              .toString()
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search SKU...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: filteredList.isEmpty
                        ? const Center(child: Text("No items found"))
                        : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: filteredList.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF063A06).withOpacity(0.1),
                            child: const Icon(Icons.inventory_2, color: Color(0xFF063A06)),
                          ),
                          title: Text(
                            filteredList[i]['itemName'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          // subtitle: Text("Price: ₹${filteredList[i]['quantity']}"),
                          trailing: const Icon(Icons.add_circle_outline, color: Colors.green),
                          onTap: () {
                            Navigator.pop(context);
                            addwidget(
                              filteredList[i]['itemName'],
                              filteredList[i]['itemID'],
                              filteredList[i]['imageurl'],
                              num.parse(filteredList[i]['quantity']),
                            );
                          },
                        );
                      },
                    ),
                  ),

                ],
              ),
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

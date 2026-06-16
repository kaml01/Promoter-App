import 'package:permission_handler/permission_handler.dart' as Permissionhandler;
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geocoding/geocoding.dart' as Geocoding;
import 'package:promoterapp/util/functionhelper.dart';
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
  static const Color _pageBackground = Color(0xFFFFFBF7);
  static const Color _primaryGreen = Color(0xFF3F7F4B);
  static const Color _primaryText = Color(0xFF203127);
  static const Color _softGreen = Color(0xFFEAF6EC);
  static const String _popupFontFamily = 'Georgia';

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

    }else{

      return showDialog<void>(
        context: contextt,
        barrierDismissible: false,
        builder: (BuildContext context) {
          contextt = context;
          return WillPopScope(
            child: AlertDialog(
              backgroundColor: _pageBackground,
              surfaceTintColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              titlePadding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              contentPadding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              title: Column(
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5DED4),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _softGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.store_mall_directory_outlined,
                          color: _primaryGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Shop',
                              style: TextStyle(
                                color: _primaryText,
                                fontWeight: FontWeight.w700,
                                fontFamily: _popupFontFamily,
                                fontSize: 20,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${beatnamelist.length} assigned shops',
                              style: const TextStyle(
                                color: Color(0xFF728077),
                                fontSize: 12.5,
                                fontFamily: _popupFontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            this.context,
                            MaterialPageRoute(
                              builder: (contextt) => HomeScreen(),
                            ),
                          );
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF728077),
                        ),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E9DF)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          color: _primaryGreen,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Choose the shop you are visiting to continue with your selfie.',
                            style: TextStyle(
                              color: Color(0xFF5E6A61),
                              fontSize: 12.5,
                              fontFamily: _popupFontFamily,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.48,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: beatnamelist.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final shop = beatnamelist[i];
                      final areaText = [
                        if ((shop.area ?? '').toString().trim().isNotEmpty)
                          shop.area.toString().trim(),
                        if ((shop.subArea ?? '').toString().trim().isNotEmpty)
                          shop.subArea.toString().trim(),
                      ].join(' • ');

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {

                            Navigator.pop(contextt);

                            if(SharedPrefClass.getDouble(latitude)==0.0){

                            }else{

                              if(getdistance(SharedPrefClass.getDouble(latitude),SharedPrefClass.getDouble(longitude),double.parse(beatnamelist[i].latitude!),double.parse(beatnamelist[i].longitude!))){

                                print("beatlistid"+(beatnamelist[i].retailerID!.toInt()).toString());
                                SharedPrefClass.setInt(SHOP_ID,beatnamelist[i].retailerID!.toInt());

                              }else{
                                setState(() {
                                  _isLoading=false;
                                });
                                showTooFarFromShopMessage(this.context);

                              }

                            }

                          },
                          child: Ink(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: const Color(0xFFE2E9DF)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0F223024),
                                  blurRadius: 14,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: _softGreen,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.storefront_rounded,
                                    color: _primaryGreen,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${shop.retailerName}",
                                        style: const TextStyle(
                                          color: _primaryText,
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: _popupFontFamily,
                                        ),
                                      ),
                                      if (areaText.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          areaText,
                                          style: const TextStyle(
                                            color: Color(0xFF728077),
                                            fontSize: 12.5,
                                            fontFamily: _popupFontFamily,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFF8A968E),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            onWillPop: ()  {
              Navigator.pop(context);

              Navigator.push(
                  this.context,
                  MaterialPageRoute(
                      builder: (contextt) =>
                          HomeScreen()
                  )
              );
              return Future.value(false);

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

        if(responsedData.contains("DONE")){

          progress?.dismiss();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(),
            ),
          );

        }

      }else{

      }

    }catch(e){

      print("print image ${e.toString()}");

    }

  }

}

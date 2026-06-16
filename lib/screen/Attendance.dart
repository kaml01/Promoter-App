import 'package:permission_handler/permission_handler.dart' as Permissionhandler;
import 'package:geocoding/geocoding.dart' as Geocoding;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:promoterapp/util/functionhelper.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:promoterapp/util/ApiHelper.dart';
import 'package:image_picker/image_picker.dart';
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
    
    const Attendance({super.key, this.showAppBar = false});

    final bool showAppBar;

    @override
    State<StatefulWidget> createState() {
      return AttendanceState();
    }

}

class AttendanceState extends State<Attendance>{
  
  static const Color _attendanceGreenDark = Color(0xFF3F7F4B);
  static const Color _attendanceGreenSoft = Color(0xFFE8F5E9);
  static const Color _attendanceSurface = Color(0xFFFFFBF7);
  static const String _popupFontFamily = 'Georgia';
    
  double? lat ,lng;
  List beatnamelist = [];
  List<int> beatIdlist = [];
  int userid=0,beatId=0;
  String attStatus="";
  bool _isBusy = false;
  bool _isFetchingLocation = true;
  bool _isFetchingBeats = true;
  bool _hasFetchedLocation = false;
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
    getallbeat('GetShopsDataver3').then((value) => allbeatlist(value));
  }
  
  bool get _canUseAttendanceActions =>
      !_isBusy && !_isFetchingLocation && !_isFetchingBeats && _hasFetchedLocation;

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
    if (mounted) {
      setState(() {
        _isFetchingLocation = true;
        _hasFetchedLocation = false;
        _currentAddress = "";
      });
    }

    final hasPermission = await _handleLocationPermission(context);
    if (!hasPermission) {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
      return;
    }

    try {
      geo.Position? position;

      // 1. Try to get the fresh location with a strict timeout (e.g., 6 seconds)
      try {
        position = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high,
          timeLimit: const Duration(seconds: 6),
        );
      } catch (e) {
        debugPrint("Fresh location timed out, trying last known...");
      }

      // 2. If fresh location failed or timed out, pick the last known location
      if (position == null) {
        position = await geo.Geolocator.getLastKnownPosition();
      }

      // 3. If we finally have a position (either fresh or last known)
      if (position != null) {
        currentPosition = position;
        await SharedPrefClass.setDouble(latitude, position.latitude);
        await SharedPrefClass.setDouble(longitude, position.longitude);
        _hasFetchedLocation = true;

        // Attempt address lookup, but don't let it stop the app
        await _getAddressFromLatLng(position);
      } else {
      }

    } catch (e) {
      debugPrint('General Location Error: $e');
    } finally {
      // 4. Crucial: Stop the loading spinner no matter what happened
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  Future<void> _getAddressFromLatLng(geo.Position position) async {
    try {
      // Set a timeout for the address lookup
      await Geocoding.placemarkFromCoordinates(
          position.latitude, position.longitude)
          .timeout(const Duration(seconds: 5)) // Give it only 5 seconds
          .then((List<Geocoding.Placemark> placemarks) {

        if (placemarks.isNotEmpty) {
          Geocoding.Placemark place = placemarks[0];
          _currentAddress = '${place.street}, ${place.subLocality}';
        }
      });
    } catch (e) {
      // If internet is too slow, just use coordinates as the address
      _currentAddress = "Address not available (Low Network)";
      debugPrint("Geocoding failed, but we have the Lat/Long!");
    }
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

    }else{

      shopdata = value;
      setState(() {
        _isFetchingBeats = false;
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
    return Scaffold(
      backgroundColor: _attendanceSurface,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: _attendanceSurface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              title: const Text(
                'Attendance',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF203127),
                ),
              ),
              iconTheme: const IconThemeData(color: _attendanceGreenDark),
            )
          : null,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildLocationHeader(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildActionCard(
                        "PRESENT",
                        Icons.fingerprint,
                        present ? _attendanceGreenDark : Colors.grey,
                        penabled,
                        "P",
                      ),
                      _buildActionCard(
                        "MID DAY",
                        Icons.wb_sunny,
                        hd ? Colors.orange[700]! : Colors.grey,
                        hdenabled,
                        "NOON",
                      ),
                      _buildActionCard(
                        "END OF DAY",
                        Icons.home_work,
                        eod ? Colors.redAccent : Colors.grey,
                        eodenabled,
                        "EOD",
                      ),
                      _buildActionCard(
                        "WEEK OFF",
                        Icons.calendar_today,
                        wo ? Colors.blue : Colors.grey,
                        woenabled,
                        "WO",
                      ),
                      _buildActionCard(
                        "ABSENT",
                        Icons.person_off,
                        ab ? Colors.black87 : Colors.grey,
                        abenabled,
                        "A",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isBusy)
            Container(
              color: Colors.white.withValues(alpha: 0.7),
              child: const Center(
                child: CircularProgressIndicator(color: _attendanceGreenDark),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEAF7EC),
            _attendanceGreenSoft,
          ],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.location_on, color: _attendanceGreenDark, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isFetchingLocation ? "Fetching current location" : "Current Location",
                  style: const TextStyle(
                    color: _attendanceGreenDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentAddress.isEmpty ? "Fetching location..." : _currentAddress,
                  style: const TextStyle(
                    color: Color(0xFF203127),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  _canUseAttendanceActions
                      ? "Attendance buttons are ready."
                      : "Attendance buttons will enable after location is fetched.",
                  style: const TextStyle(
                    color: Color(0xFF5E6D61),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _isFetchingLocation
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: _attendanceGreenDark,
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh, color: _attendanceGreenDark),
                  onPressed: _isBusy ? null : () => getCurrentPosition(context),
                )
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, bool enabled, String status) {
    final bool canTap = enabled && _canUseAttendanceActions;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: canTap ? () => showdialogg(status, context, shopdata) : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: canTap ? 1.0 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8EDE5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: canTap
                    ? color.withValues(alpha: 0.12)
                    : _attendanceGreenSoft,
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusAccent(String status) {
    switch (status) {
      case "P":
        return _attendanceGreenDark;
      case "NOON":
        return Colors.orange.shade700;
      case "EOD":
        return Colors.redAccent;
      case "WO":
        return Colors.blue;
      case "A":
        return Colors.black87;
      default:
        return _attendanceGreenDark;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "P":
        return Icons.fingerprint_rounded;
      case "NOON":
        return Icons.wb_sunny_rounded;
      case "EOD":
        return Icons.home_work_rounded;
      case "WO":
        return Icons.calendar_today_rounded;
      case "A":
        return Icons.person_off_rounded;
      default:
        return Icons.verified_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case "P":
        return "Present";
      case "NOON":
        return "Mid Day";
      case "EOD":
        return "End Of Day";
      case "WO":
        return "Week Off";
      case "A":
        return "Absent";
      default:
        return "Attendance";
    }
  }

  String _statusMessage(String status) {
    switch (status) {
      case "P":
        return "Confirm that you want to mark yourself present for today.";
      case "NOON":
        return "Confirm your mid day attendance update before continuing.";
      case "EOD":
        return "Confirm that you want to close the day with end of day attendance.";
      case "WO":
        return "Confirm that you want to mark today as week off.";
      case "A":
        return "Confirm that you want to mark yourself absent for today.";
      default:
        return "Please confirm this attendance action.";
    }
  }

  Future<void> showdialogg(String status,BuildContext ctx, List<Shops> listdata) async {

    return showDialog(

        barrierDismissible: false,
        context: context,
        builder:(BuildContext context) {
          ctx = context;
          final accent = _statusAccent(status);
          return AlertDialog(
            backgroundColor: const Color(0xFFFFFBF7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
            contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(_statusIcon(status), color: accent, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  _statusLabel(status),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF203127),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: _popupFontFamily,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            content: Text(
              _statusMessage(status),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF5E6D61),
                fontSize: 14,
                height: 1.5,
                fontFamily: _popupFontFamily,
              ),
            ),
            actions: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, 'Cancel');
                        setState(() {
                          _isBusy = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5E6D61),
                        side: const BorderSide(color: Color(0xFFE4EADF)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontFamily: _popupFontFamily),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        setState(() {
                          _isBusy = true;
                        });

                        if(status=="P" || status=="NOON" ||status=="EOD"){
                          await gettodaysbeatt(status,ctx,listdata);
                        }else{
                          await markattendance(status,beatId.toString(),context,f);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontFamily: _popupFontFamily),
                      ),
                    ),
                  ),
                ],
              ),

            ],
          );

        }
    );

  }

  Future<void> gettodaysbeatt(status,context,List<Shops> beatnamelist) async {

    int beatId = (SharedPrefClass.getInt(BEAT_ID)==0 ? -1 : SharedPrefClass.getInt(BEAT_ID));

    if(beatId==0 || beatId ==-1 ){

      await showbeatt(status,context,beatnamelist);

    }else{

      await markattendance(status,beatId.toString(),context,"" as File);

    }

  }

  Future<void> showbeatt(String status,BuildContext contextt, List<Shops> beatnamelist) async {

    if(beatnamelist.isEmpty){
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }

      Navigator.pop(contextt);

    }else{
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }

      Navigator.pop(contextt);

      return showDialog<void>(
        context: contextt,
        barrierDismissible: false,
        builder: (BuildContext context) {
          contextt = context;
          return WillPopScope(
              child: AlertDialog(
                backgroundColor: const Color(0xFFFFFBF7),
                surfaceTintColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                titlePadding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
                            color: _attendanceGreenSoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.store_mall_directory_outlined,
                            color: _attendanceGreenDark,
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
                                  color: Color(0xFF203127),
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
                            setState(() {
                              _isBusy = false;
                            });
                            Navigator.pop(context);
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
                            color: _attendanceGreenDark,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Choose the shop you are visiting to continue attendance.',
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

                                if (SharedPrefClass.getDouble(latitude) == 0.0) {

                                } else {

                                  print("locationlatitude ${getdistance(SharedPrefClass.getDouble(latitude),SharedPrefClass.getDouble(longitude),double.parse(beatnamelist[i].latitude!),double.parse(beatnamelist[i].longitude!))}");

                                  if (getdistance(SharedPrefClass.getDouble(latitude),SharedPrefClass.getDouble(longitude),double.parse(beatnamelist[i].latitude!),double.parse(beatnamelist[i].longitude!))) {

                                    SharedPrefClass.setInt(SHOP_ID, beatnamelist[i].retailerID!.toInt());
                                    selectFromCamera(status, beatnamelist[i].toString(), contextt);

                                  } else {

                                    setState(() {
                                      _isBusy = false;
                                    });
                                    showTooFarFromShopMessage(this.context);

                                  }

                                }

                              },
                              child: Ink(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: const Color(0xFFE3EADF)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x0D243127),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: _attendanceGreenSoft,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.storefront_rounded,
                                        color: _attendanceGreenDark,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${shop.retailerName}",
                                            style: const TextStyle(
                                              color: Color(0xFF203127),
                                              fontWeight: FontWeight.w700,
                                              fontFamily: _popupFontFamily,
                                              fontSize: 15.5,
                                            ),
                                          ),
                                          if (areaText.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF4F7F2),
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                areaText,
                                                style: const TextStyle(
                                                  color: Color(0xFF617066),
                                                  fontSize: 11.5,
                                                  fontFamily: _popupFontFamily,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F7F0),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.chevron_right_rounded,
                                        color: _attendanceGreenDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                  ),
                )
              ),
              onWillPop: () {

                setState(() {
                  _isBusy = false;
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
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }

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

        await markattendance(status,beatid,contextt,f!);
      }catch(e){
        if (mounted) {
          setState(() {
            _isBusy = false;
          });
        }

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

        if(responsedData.contains("DONE")){

          SharedPrefClass.setString(ATT_STATUS,status);

          setState(() {
            _isBusy=false;
          });

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen()));

        } else {
          if (mounted) {
            setState(() {
              _isBusy = false;
            });
          }
        }

      }else{
        if (mounted) {
          setState(() {
            _isBusy = false;
          });
        }

      }

    }catch(e){
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }

      print("print image $e");

    }

  }

}

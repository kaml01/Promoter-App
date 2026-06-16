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
  static const Color _pageBackground = Color(0xFFFFFBF7);
  static const Color _pageBackgroundSoft = Color(0xFFF4EFE6);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _surfaceSoft = Color(0xFFF8F4ED);
  static const Color _surfaceTint = Color(0xFFEAF6EC);
  static const Color _primaryGreen = Color(0xFF3F7F4B);
  static const Color _primaryText = Color(0xFF203127);
  static const Color _secondaryText = Color(0xFF6B766E);
  static const Color _border = Color(0xFFE6E0D7);
  static const String _popupFontFamily = 'Georgia';

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
  bool _isLocationLoading = true;
  bool _hasResolvedLocation = false;
  bool _isShopDialogOpen = false;
  String _selectedShopName = "";

  bool get _hasSelectedShop => _selectedShopName.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    printSimCardsData();
    getsharedprefdata();
    getuserdetails('Userdetails');
    getallbeat('GetShopsDataver3').then((value) => allbeatlist(value));
    getCurrentPosition();
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

    }else{

        shopdata = value;
        _maybeShowShopDialog();

    }

  }

  void _maybeShowShopDialog() {
    if (!mounted ||
        _isLocationLoading ||
        !_hasResolvedLocation ||
        _isShopDialogOpen ||
        shopdata.isEmpty ||
        (attstatus != "P" && attstatus != "NOON")) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted ||
          _isLocationLoading ||
          !_hasResolvedLocation ||
          _isShopDialogOpen ||
          shopdata.isEmpty ||
          (attstatus != "P" && attstatus != "NOON")) {
        return;
      }

      _isShopDialogOpen = true;
      try {
        await showbeatt(attstatus, context, shopdata);
      } finally {
        _isShopDialogOpen = false;
      }
    });
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
                            color: _surfaceTint,
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
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: _border),
                                ),
                                child: Text(
                                  '${beatnamelist.length} assigned shops',
                                  style: const TextStyle(
                                    color: _secondaryText,
                                    fontSize: 12.5,
                                    fontFamily: _popupFontFamily,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (contextt) =>
                                        HomeScreen()
                                )
                            );
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _secondaryText,
                          ),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF4F8F0),
                            Color(0xFFEAF6EC),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFDCE7DA)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose the shop you are visiting now.',
                            style: TextStyle(
                              color: _primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: _popupFontFamily,
                            ),
                          ),
                          SizedBox(height: 4),
                          // Text(
                          //   'Pick the nearest assigned shop to continue with sales entry.',
                          //   style: TextStyle(
                          //     color: _secondaryText,
                          //     fontSize: 12.5,
                          //     height: 1.4,
                          //     fontFamily: _popupFontFamily,
                          //   ),
                          // ),
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
                        itemBuilder: (context,i){
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
                              onTap: (){

                                Navigator.pop(contextt);

                                if(SharedPrefClass.getDouble(latitude)==0.0){

                                }else{

                                  if(getdistance(SharedPrefClass.getDouble(latitude),SharedPrefClass.getDouble(longitude),double.parse(beatnamelist[i].latitude!),double.parse(beatnamelist[i].longitude!))){

                                    print("beatlistid"+(beatnamelist[i].retailerID!.toInt()).toString());
                                    SharedPrefClass.setInt(SHOP_ID,beatnamelist[i].retailerID!.toInt());
                                    setState(() {
                                      shopid = beatnamelist[i].retailerID!.toInt();
                                      _selectedShopName = beatnamelist[i].retailerName ?? "";
                                    });
                                  }else{

                                    setState(() {
                                      _isLoading=false;
                                    });
                                    showTooFarFromShopMessage(this.context);

                                  }

                                }

                              },
                              child: Ink(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      Color(0xFFFFF9F0),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: const Color(0xFFE7E0D7)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x0D243127),
                                      blurRadius: 16,
                                      offset: Offset(0, 6),
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
                                        color: _surfaceTint,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.storefront_rounded,
                                        color: _primaryGreen,
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
                                              color: _primaryText,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: _popupFontFamily,
                                              fontSize: 15.5,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                         
                                          if (areaText.isNotEmpty) ...[
                                            const SizedBox(height: 10),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: _surfaceSoft,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                areaText,
                                                style: const TextStyle(
                                                  color: _secondaryText,
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
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE7E0D7)),
                                      ),
                                      child: const Icon(
                                        Icons.chevron_right_rounded,
                                        color: _primaryGreen,
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
  setState(() {
    _isLocationLoading = true;
    _hasResolvedLocation = false;
  });

  final hasPermission = await _handleLocationPermission(context);
  if (!hasPermission) {
    setState(() {
      _isLocationLoading = false;
    });
    return;
  }

  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentPosition = position;

    if (position.latitude == 0.0) {
      currentPosition = await Geolocator.getLastKnownPosition();
    }

    SharedPrefClass.setDouble(latitude, currentPosition!.latitude);
    SharedPrefClass.setDouble(longitude, currentPosition!.longitude);

    await _getAddressFromLatLng(currentPosition!);

    setState(() {
      _isLocationLoading = false;
      _hasResolvedLocation = true;
    });
    _maybeShowShopDialog();
  } catch (e) {
    currentPosition = await Geolocator.getLastKnownPosition();

    if (currentPosition != null) {
      SharedPrefClass.setDouble(latitude, currentPosition!.latitude);
      SharedPrefClass.setDouble(longitude, currentPosition!.longitude);
      await _getAddressFromLatLng(currentPosition!);
    }

    setState(() {
      _isLocationLoading = false;
      _hasResolvedLocation = currentPosition != null;
    });
    _maybeShowShopDialog();
  }
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
      backgroundColor: _pageBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _pageBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: _primaryGreen,
        title: const Text(
          "Sales Entry",
          style: TextStyle(
            color: _primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: _primaryGreen),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x142C302A),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
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
                    color: _primaryText,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "You haven't marked your attendance yet. Please mark 'Present' to start entering sales data.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: _secondaryText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Attendance(showAppBar: true),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
                    style: TextStyle(color: _secondaryText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dropdownOptionsProvider = Provider.of<DropdownProvider>(context);
    if (attstatus != "P" && attstatus != "NOON") {
      return _buildAttendanceWarning();
    }

    return ProgressHUD(
      child: Builder(
        builder: (hudContext) {
          return Scaffold(
            backgroundColor: _pageBackground,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: _pageBackground,
              surfaceTintColor: Colors.transparent,
              foregroundColor: _primaryGreen,
              title: const Text(
                  "Sales Entry",
                  style: TextStyle(color: _primaryText, fontWeight: FontWeight.w600)
              ),
              iconTheme: const IconThemeData(color: _primaryGreen),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  setState(() {
                    dynamicList.clear();
                    idx = 0;
                  });
                  Navigator.pop(context);
                },
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: TextButton.icon(
                    onPressed: _isLocationLoading
    ? null
    : () {
        final progress = ProgressHUD.of(hudContext);
        save(dropdownOptionsProvider, context, progress);
      },
//       onPressed: () {
//   final progress = ProgressHUD.of(hudContext);
//   save(dropdownOptionsProvider, context, progress);
// },
                    style: TextButton.styleFrom(
                      backgroundColor: _surfaceTint,
                      foregroundColor: _primaryGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                    label: const Text(
                      "Save",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _pageBackground,
                    _pageBackgroundSoft,
                  ],
                ),
              ),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildInfoCard(),
                        _buildImageSelectors(),
                        _buildDateSelector(),
                        //const Divider(height: 1, color: _border),
                      ],
                    ),
                  ),
                  if (dynamicList.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(hudContext),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(10),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, index) => dynamicList[index],
                          childCount: dynamicList.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // floatingActionButton: FloatingActionButton(
            //   backgroundColor: _primaryGreen,
            //   child: const Icon(Icons.add, color: Colors.white),
            //   onPressed: () {
            //     final progress = ProgressHUD.of(hudContext);
            //     showskudialog(context, allitems, progress);
            //   },
            // ),
            floatingActionButton: _hasSelectedShop
                ? FloatingActionButton(
                    backgroundColor:
                        _isLocationLoading ? Colors.grey : _primaryGreen,
                    child: _isLocationLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Icon(Icons.add, color: Colors.white),
                    onPressed: _isLocationLoading
                        ? null
                        : () {
                            final progress = ProgressHUD.of(hudContext);
                            showskudialog(context, allitems, progress);
                          },
                  )
                : null,
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

          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[350]),

          const SizedBox(height: 10),

          const Text(
            "No SKUs added yet",
            style: TextStyle(color: _primaryText, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),
          Text(
            _hasSelectedShop
                ? "Tap the plus button to start entering sales items."
                : "Select a shop first to enable the plus button.",
            style: const TextStyle(color: _secondaryText),
            textAlign: TextAlign.center,
          ),

        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: dt == "" ? Colors.red.withValues(alpha: 0.35) : _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x102C302A),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: dt == "" ? const Color(0xFFFCECEA) : _surfaceTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_month, color: dt == "" ? Colors.red : _primaryGreen),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sales Date",
                    style: const TextStyle(fontSize: 12, color: _secondaryText),
                  ),
                  Text(
                    dt == "" ? "Select Transaction Date" : dt,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: dt == "" ? Colors.grey[400] : _primaryText,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_drop_down, color: _secondaryText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEAF7EC),
              Color(0xFFF8F3E8),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.storefront_rounded, color: _primaryGreen),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLocationLoading
                        ? "Fetching location..."
                        : (_currentAddress.isEmpty
                            ? "Location not available"
                            : _currentAddress),
                    style: const TextStyle(color: _primaryText, fontSize: 12.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_selectedShopName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: _primaryGreen,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              _selectedShopName,
                              style: const TextStyle(
                                color: _primaryGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImageSelectors() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
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
        behavior: HitTestBehavior.opaque,
        onTap: () => selectFromCamera(type),
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x102C302A),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: file == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_a_photo, size: 22, color: _primaryGreen),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 11, color: _secondaryText, fontWeight: FontWeight.w600)),
            ],
          )
              : ClipRRect(
            borderRadius: BorderRadius.circular(18),
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

    }else if(smpstk!=dynamicList.length){

    }else if(sale!=dynamicList.length){

    }else if(cameraFile==null){

    }else if(dt==""){

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

        print("body ${body.toString()}");

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
                color: _pageBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [

                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 14),
                    height: 6,
                    width: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D8CD),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFEAF7EC),
                            Color(0xFFF7F0E4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFDDE6D9)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_rounded,
                              color: _primaryGreen,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Select Product",
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w700,
                                    color: _primaryText,
                                    fontFamily: _popupFontFamily,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${filteredList.length} items available",
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: _secondaryText,
                                    fontFamily: _popupFontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: _secondaryText),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _secondaryText,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _border),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.auto_awesome_rounded, color: _primaryGreen, size: 18),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
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
                      style: const TextStyle(
                        color: _primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: _popupFontFamily,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search product name",
                        hintStyle: const TextStyle(
                          color: _secondaryText,
                          fontFamily: _popupFontFamily,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _surfaceTint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.manage_search_rounded, color: _primaryGreen),
                        ),
                        filled: true,
                        fillColor: _surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: _border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: _border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: _primaryGreen),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: filteredList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 54,
                                  color: Color(0xFFB7BEB5),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "No products found",
                                  style: TextStyle(
                                    color: _primaryText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: _popupFontFamily,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Try a different product name.",
                                  style: TextStyle(
                                    color: _secondaryText,
                                    fontSize: 12.5,
                                    fontFamily: _popupFontFamily,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: filteredList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () {
                              Navigator.pop(context);
                              addwidget(
                                filteredList[i]['itemName'],
                                filteredList[i]['itemID'],
                                filteredList[i]['imageurl'],
                                num.parse(filteredList[i]['quantity']),
                              );
                            },
                            child: Ink(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Color(0xFFFFF9F1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: const Color(0xFFE6E0D7)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0D243127),
                                    blurRadius: 14,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: _surfaceTint,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.inventory_rounded,
                                      color: _primaryGreen,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          filteredList[i]['itemName'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: _primaryText,
                                            fontSize: 15,
                                            fontFamily: _popupFontFamily,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _surfaceSoft,
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            'Qty: ${filteredList[i]['quantity']}',
                                            style: const TextStyle(
                                              color: _secondaryText,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: _popupFontFamily,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFFE1DDD5)),
                                    ),
                                    child: const Icon(
                                      Icons.add_rounded,
                                      color: _primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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

      }

    }

  }

}

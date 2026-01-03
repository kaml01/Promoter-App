import 'package:promoterapp/screen/Selfie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:promoterapp/screen/Dashboard.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:promoterapp/config/Color.dart';
import 'package:flutter/material.dart';
import '../config/Common.dart';
import '../util/ApiHelper.dart';
import '../util/functionhelper.dart';
import 'Attendance.dart';
import 'LoginScreen.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'SalesReport.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class JivoColors {
  static const Color primary = Color(0xFFD4A017); // Golden Yellow
  static const Color primaryDark = Color(0xFFB8860B); // Dark Goldenrod
  static const Color secondary = Color(0xFF2E7D32); // Forest Green
  static const Color background = Color(0xFFFFFDF5); // Warm White
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color accent = Color(0xFFFF8F00); // Amber
}

bool isturnedon = false;
bool servicestatus = false;
bool haspermission = false;
late LocationPermission permission;
late Position position;

class HomeScreen extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }

}

class _HomeScreenState extends State<HomeScreen> {

  int _currentIndex = 0;

  final List<Widget> _screens = [
    Dashboard(),
    Attendance(),
    SalesReport(),
    Selfie(),
  ];

  void _logout() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            icon: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.red.shade400,
                size: 32,
              ),
            ),
            title: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: const Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () async {
                  SharedPreferences preferences =
                  await SharedPreferences.getInstance();
                  preferences.clear();
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Attendance';
      case 2:
        return 'Sales Report';
      case 3:
        return 'Selfie';
      default:
        return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _logout();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            _getTitle(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2,
          actions: [
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Logout',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _screens[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          elevation: 3,
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.fingerprint_outlined),
              selectedIcon: Icon(Icons.fingerprint_rounded),
              label: 'Attendance',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics_rounded),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon: Icon(Icons.camera_alt_rounded),
              label: 'Selfie',
            ),
          ],
        ),
      ),
    );
  }

}
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {

  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(minutes: 15), (timer) async {

    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        checkGps();
      }
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": "device",
      },
    );

  });

}

Future<void> initializeService() async {

  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(

      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Jivo Dsr',
      initialNotificationContent: 'Jivo Dsr',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();

}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

checkGps() async {
  servicestatus = await Geolocator.isLocationServiceEnabled();
  if(servicestatus){
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
      }else if(permission == LocationPermission.deniedForever){
        print("'Location permissions are permanently denied");
      }else{
        haspermission = true;
      }
    }else{
      haspermission = true;
    }

    if(haspermission){

      getLocation();
    }
  }else{
    print("GPS Service is not enabled, turn on GPS location");
  }

}

getLocation() async {

  position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  Battery _battery = Battery();
  var level = await _battery.batteryLevel;
  String? _currentAddress;

  SharedPreferences prefs = await SharedPreferences.getInstance();

  await geocoding.placemarkFromCoordinates(position.latitude, position.longitude)
      .then((List<geocoding.Placemark> placemarks) {

    geocoding.Placemark place = placemarks[0];

    _currentAddress = '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';

    try{

      var locationentry=[{
        "personId":prefs.getInt(USER_ID),
        "timeStamp":getcurrentdatewithtime(),
        "latitude":position.latitude,
        "longitude":position.latitude,
        "battery":level,
        "GpsEnabled":isturnedon,
        "accuracy":position.accuracy,
        "speed":position.speed,
        "provider":"GPS",
        "altitude":position.altitude,
        "address":_currentAddress}];

      var request = json.encode(locationentry);
       print("Request data ${request.toString()}");
      savelocation(request);

    }catch(e){

      print("low eexception $e");

    }

  }).catchError((e) {

    print("eexception $e");

  });

}


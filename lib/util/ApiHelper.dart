import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:promoterapp/config/Common.dart';
import 'package:promoterapp/models/Shops.dart';
import 'package:promoterapp/models/Logindetails.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:promoterapp/res/app_url.dart';
import 'package:promoterapp/screen/HomeScreen.dart';
import 'package:promoterapp/models/saalesreport.dart';
import 'package:promoterapp/util/Shared_pref.dart';
import '../models/proxydetails.dart';
import 'package:fluttertoast/fluttertoast.dart';

void _showLoginToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black87,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

Uri _buildLoginUri(String baseUrl, String endpoint, String user, String pass) {
  final uri = Uri.parse('$baseUrl$endpoint');
  return uri.replace(
    queryParameters: <String, String>{
      'user': user,
      'password': pass,
    },
  );
}

Future<Logindetails> login(BuildContext context, String user, String pass) async {

  final progress = ProgressHUD.of(context);
  progress?.show();
  final trimmedUser = user.trim();
  final trimmedPass = pass.trim();

  final fallbackDetails = Logindetails(
    personId: 0,
    personType: '',
    personName: '',
    userName: '',
    group: '',
    target: 0,
    targetBoxes: 0,
    distanceAllowed: 0,
    attStatus: '',
    canola: 0,
    olive: 0,
    gold: 0,
    mustard: 0,
    sunflower: 0,
    soyabean: 0,
    cottonseed: 0,
    wheatgrass: 0,
    naturalmineralwater: 0,
    plainsoda: 0,
    flavouredsoda: 0,
  );

  try {
    if (trimmedUser.isEmpty || trimmedPass.isEmpty) {
      _showLoginToast('Enter username and password.');
      return fallbackDetails;
    }

    final configuredBaseUrl = SharedPrefClass.getString(IP_URL).trim();
    final baseUrls = <String>[
      if (configuredBaseUrl.isNotEmpty) configuredBaseUrl,
      Appurl.baseurl,
    ].toSet().toList();

    if (baseUrls.isEmpty) {
      _showLoginToast('Server URL is missing. Please restart the app.');
      return fallbackDetails;
    }

    const endpoints = <String>[
      'LoginSalesPerson3',
      'LoginSalesPerson',
    ];

    http.Response? response;
    String? resolvedBaseUrl;
    Object? lastError;
    final attemptedUrls = <String>[];

    for (final baseUrl in baseUrls) {
      for (final endpoint in endpoints) {
        attemptedUrls.add('$baseUrl$endpoint');

        try {
          final currentResponse = await http
              .post(_buildLoginUri(baseUrl, endpoint, trimmedUser, trimmedPass))
              .timeout(const Duration(seconds: 15));

          if (currentResponse.statusCode == 200) {
            response = currentResponse;
            resolvedBaseUrl = baseUrl;
            break;
          }

          if (currentResponse.statusCode != 404) {
            response = currentResponse;
            resolvedBaseUrl = baseUrl;
            break;
          }
        } on TimeoutException catch (e) {
          lastError = e;
          break;
        } on SocketException catch (e) {
          lastError = e;
          break;
        }
      }

      if (response != null) {
        break;
      }
    }

    if (response == null) {
      if (lastError is TimeoutException || lastError is SocketException) {
        _showLoginToast('Cannot reach the login server. Please check your internet connection.');
      } else {
        _showLoginToast(
          'Login service was not found on the server.',
        );
        debugPrint('Attempted login URLs: ${attemptedUrls.join(', ')}');
      }
      return fallbackDetails;
    }

    if (resolvedBaseUrl != null && resolvedBaseUrl != configuredBaseUrl) {
      await SharedPrefClass.setString(IP_URL, resolvedBaseUrl);
    }

    if (response.statusCode != 200) {
      _showLoginToast(
        'Login failed with status ${response.statusCode}. Please try again.',
      );
      return fallbackDetails;
    }

    if (response.body.trim().isEmpty) {
      _showLoginToast('Server returned an empty login response.');
      return fallbackDetails;
    }

    final decoded = json.decode(response.body);
    if (decoded is! Map) {
      _showLoginToast('Unexpected login response from server.');
      return fallbackDetails;
    }

    final details = Logindetails.fromJson(
      Map<String, dynamic>.from(decoded),
    );

    if (details.personId != 0) {

      try {

        if(details.personType.toString().contains("PROMOTER")){

          await SharedPrefClass.setInt(USER_ID, details.personId);
          await SharedPrefClass.setString(PERSON_TYPE, details.personType.toString());
          await SharedPrefClass.setString(PERSON_NAME, details.personName.toString());
          await SharedPrefClass.setString(GROUP, details.group.toString());
          await SharedPrefClass.setInt(DISTANCE_ALLOWED, details.distanceAllowed ?? 0);

          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          }

        }else{
          _showLoginToast('You are not a promoter.');
        }

        } catch (e) {
          _showLoginToast('Login succeeded, but opening the app failed.');

        }

    } else {
      _showLoginToast('Invalid username or password.');
    }

    return details;

  } on TimeoutException {
    _showLoginToast('Login timed out. Please try again.');

    return fallbackDetails;

  } on SocketException catch (e) {
    _showLoginToast('Cannot reach the login server. Please check your internet connection.');
    debugPrint('Login socket exception: $e');

    return fallbackDetails;

  } on FormatException catch (e) {
    _showLoginToast('Login response could not be read.');
    debugPrint('Login format exception: $e');

    return fallbackDetails;

  } catch (e) {
    _showLoginToast('Unable to login right now. Please try again.');
    debugPrint('Login failed: $e');

    return fallbackDetails;

  } finally {
    progress?.dismiss();
  }

}

Future<dynamic> getallbeat(String endpoint) async{
  
  int userid=0;
  userid = SharedPrefClass.getInt(USER_ID);
  var response = await http.get(Uri.parse('${SharedPrefClass.getString(IP_URL)}$endpoint?id=$userid'));
  final list = jsonDecode(response.body);

  List<Shops> beatdata = [];
  beatdata = list.map<Shops>((m) => Shops.fromJson(Map<String, dynamic>.from(m))).toList();

  return beatdata;

}

Future<List<saalesreport>> getreports(String endpoint,String from,String to) async {

  int userid=0;

  userid = SharedPrefClass.getInt(USER_ID);

  var response = await http.get(Uri.parse('${SharedPrefClass.getString(IP_URL)}$endpoint?personId=$userid&startdate=$from&enddate=$to'));
  final list = jsonDecode(response.body);

  List<saalesreport> beatdata = [];

  try{

    beatdata = list.map<saalesreport>((m) => saalesreport.fromJson(Map<String, dynamic>.from(m))).toList();

  }catch(e){
    print("beatlist $e");
  }

  return beatdata;

}

Future<Logindetails> getuserdetails(String endpoint) async {

  int userid=0;

  Logindetails details;
  userid = SharedPrefClass.getInt(USER_ID);

  var response = await http.post(Uri.parse('${SharedPrefClass.getString(IP_URL)}$endpoint?userId=$userid'));
  final list = jsonDecode(response.body);

  if (response.statusCode == 200) {

    details = Logindetails.fromJson(json.decode(response.body));

  //  details = list.map<Logindetails>((m) => Logindetails.fromJson(Map<String, dynamic>.from(m))).toList();

    SharedPrefClass.setString(ATT_STATUS,details.attStatus.toString());
    SharedPrefClass.setInt(DISTANCE_ALLOWED,details.distanceAllowed!.toInt());
    SharedPrefClass.setInt(USER_ID, details.personId);
    SharedPrefClass.setString(PERSON_TYPE, details.personType.toString());
    SharedPrefClass.setString(PERSON_NAME, details.personName.toString());
    SharedPrefClass.setString(GROUP, details.group.toString());
    SharedPrefClass.setInt(TARGET, details.target!.toInt());
    SharedPrefClass.setString(ASSIGNED, details.assignedshops.toString());
    SharedPrefClass.setString(COVERED, details.coveredshops.toString());
    SharedPrefClass.setString(PRODUCTIVE, details.productiveshops.toString());
    SharedPrefClass.setString(CANOLA, details.canola.toString());
    SharedPrefClass.setString(OLIVE, details.olive.toString());
    SharedPrefClass.setString(GOLD, details.gold.toString());
    SharedPrefClass.setString(SUNFLOWER, details.sunflower.toString());
    SharedPrefClass.setString(SOYABEAN, details.soyabean.toString());
    SharedPrefClass.setString(COTTONSEED, details.cottonseed.toString());

  } else {

    throw Exception('Failed to load data');

  }

  return details;
}

Future<dynamic> checklatestversion(String endpoint,version,device) async{

  int userid=0;
  userid = SharedPrefClass.getInt(USER_ID);

  var response = await http.get(Uri.parse('${SharedPrefClass.getString(IP_URL)}$endpoint?id=$userid&appversion=$version&device=$device'));
  final list = jsonDecode(response.body);
  return list;

}

Future<dynamic> getSKU(String endpoint) async{

  int userid=0;
  userid = SharedPrefClass.getInt(USER_ID);

  var response = await http.get(Uri.parse('${SharedPrefClass.getString(IP_URL)}$endpoint?id=$userid'));
  final list = jsonDecode(response.body);
  return list;

}

Future<bool> proxylogin(context,username) async {

  Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  try {

    var response = await http.post(Uri.parse('http://proxy2.jivocanola.com:8080/gm/proxy.json'),headers: headers);
    List<proxydetails> proxy = [];
    final list = jsonDecode(response.body);
    proxy = list.map<proxydetails>((m) => proxydetails.fromJson(Map<String, dynamic>.from(m))).toList();
    proxyStatus = false;

    if (response.statusCode == 200) {

      for(int i=0;i<proxy.length;i++){

        if(proxy[i].proxy==username){

          proxyStatus = true;
        }

      }

    }

  } catch (e) {

    // ignore

  }

  return proxyStatus;
}

Future<void> savepromotersale(String salesEntry,String file,String file1,String file2,BuildContext context,progress,dynamiclist) async {

  try{

    var request = await http.MultipartRequest('POST', Uri.parse('${SharedPrefClass.getString(IP_URL)}SavePromoterSales2'));
    request.fields['salesEntry']= salesEntry.toString();
    request.files.add(await http.MultipartFile.fromPath('image', file));

    if(file1!=""){
      request.files.add(await http.MultipartFile.fromPath('image1', file1));
    }
    if(file2!=""){
      request.files.add(await http.MultipartFile.fromPath('image2', file2));
    }

    var response = await request.send();
    var responsed = await http.Response.fromStream(response);

    final responsedData = json.decode(responsed.body);

    if(responsedData.contains("DONE")){

      progress.dismiss();

      dynamiclist.clear();

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen()));

    }else{

      progress.dismiss();

    }

  }catch(e){

    progress.dismiss();
    print("response exception $e");

  }

}

Future<String> savelocation(jsondata) async {

  Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  var response = await http.post(Uri.parse('${SharedPrefClass.getString(IP_URL)}SaveLocationsV2?locations=$jsondata'),
      headers: headers);

  try {

    if (response.statusCode == 200) {

    } else {

    }

  }catch(e){

  }
  print("responsebody${response.body.toString()}");
  return response.body.toString();
}

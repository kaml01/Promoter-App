import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

class NetworkConnectivity  extends ChangeNotifier {

  String status = 'waiting...';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _streamSubscription;

  Future<String> checkConnectivity() async {

    var connectionResult = await _connectivity.checkConnectivity();

    if (connectionResult == ConnectivityResult.mobile) {

      status = "Online";
      notifyListeners();

    } else  if(connectionResult == ConnectivityResult.wifi) {

      status = "Online";
      notifyListeners();

    }else{
      status = "Offline";
      notifyListeners();
    }
    return status;
  }

  void checkRealtimeConnection() {

    _streamSubscription = _connectivity.onConnectivityChanged.listen((event) {
      switch (event) {

        case ConnectivityResult.mobile:
          {

            status = "Connected to MobileData";
            notifyListeners();

          }
          break;

        case ConnectivityResult.wifi:
          {

            status = "Connected to Wifi";
            notifyListeners();

          }
          break;

        default:
          {

            status = 'Offline';
            notifyListeners();

          }
          break;

      }
    });

  }

}



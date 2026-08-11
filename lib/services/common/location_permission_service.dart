// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

// class LocationPermissionService {
//   static Future<bool> _handlePermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();

//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();

//       if (permission == LocationPermission.denied) {
//         return false;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return false;
//     }

//     return true;
//   }

  // static Future<Stream<Position>> getLiveLocation() async {
  //   debugPrint('IN getLive Location 🚨');
  //   bool hasPermission = await _handlePermission();

  //   if (!hasPermission) {
  //     throw Exception("Location permission not granted");
  //   }

  //   return Geolocator.getPositionStream(
  //     locationSettings: const LocationSettings(
  //       accuracy: LocationAccuracy.high,
  //       distanceFilter: 5,
  //     ),
  //   );
  // }

  // static Future<bool> getCurrentLocationOnce() async {
  //   try {
  //     bool hasPermission = await _handlePermission();

  //     if (!hasPermission) {
  //       // throw Exception("Location permission not granted");
  //       debugPrint('🚨PERMISSION DENIED');
  //     }

  //     final pos = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );
  //     // SessionController()
  //     //     .updateCurrentLocation(lat: pos.latitude, lng: pos.longitude);
  //     return true;
  //   } catch (e) {
  //     debugPrint('ERROR: $e');
  //     debugPrint('Permission Denied');
  //     return false;
  //   }

    //Another way to handle permissions effectively
    //iOS does not allow to prompt for location if set to "Never" from iOS settings
    //    LocationPermission permission = await Geolocator.checkPermission();
    //     if (permission == LocationPermission.denied) {
    //   // Ask again
    //   permission = await Geolocator.requestPermission();
    // }

    // if (permission == LocationPermission.deniedForever) {
    //   // Cannot request again on iOS
    //   await showPermissionDialog();
    //   return;
    // }

    // if (permission == LocationPermission.whileInUse ||
    //     permission == LocationPermission.always) {
    //   // Permission granted
    // }
//   }
// }

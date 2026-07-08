import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mygate_coepd/app.dart';
import 'package:mygate_coepd/config/app_config.dart';
import 'package:mygate_coepd/firebase_options.dart';
import 'package:mygate_coepd/models/user.dart';
import 'package:mygate_coepd/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  bool hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!hasShownError) {
      hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        hasShownError = false;
      });

      return Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'An error has occurred',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              Text(
                details.exceptionAsString(),
                style: TextStyle(fontSize: 16.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                'Please restart the app and try again.',
                style: TextStyle(fontSize: 16.sp),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox.shrink();
  };

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(FamilyMemberAdapter());
  Hive.registerAdapter(ResidentVehicleAdapter());
  Hive.registerAdapter(ResidentPetAdapter());

  // Initialize app configuration
  await AppConfig.init();

  // Initialize FCM
  try {
    await FcmService().init();
  } catch (e) {
    log('Failed to initialize FCM: $e');
    log('Failed to initialize FCM: ${e.toString()}');
  }

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]).then((value) {
    runApp(const App());
  });
}

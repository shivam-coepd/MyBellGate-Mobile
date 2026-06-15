import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';

enum InternetStatus { online, offline }

class AppInternetCheck {
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  static void checkInternet({required BuildContext context}) async {
    Future<bool> hasInternetConnection() async {
      try {
        final result = await InternetAddress.lookup('google.com');

        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException {
        return false;
      }
    }

    bool isConnected = await hasInternetConnection();

    if (isConnected) {
    } else {
      AppSnackbar.show(
        context: context,
        message: 'No Internet Connection',
        type: SnackBarType.error,
        position: SnackBarPosition.top,
      );
    }
  }
}

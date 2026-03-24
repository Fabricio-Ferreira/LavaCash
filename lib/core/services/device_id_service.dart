import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

abstract class DeviceIdService {
  static Future<String> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo android = await deviceInfo.androidInfo;
      return android.id;
    }
    if (Platform.isIOS) {
      final IosDeviceInfo ios = await deviceInfo.iosInfo;
      return ios.identifierForVendor ?? 'unknown-ios';
    }
    return 'unknown-platform';
  }
}

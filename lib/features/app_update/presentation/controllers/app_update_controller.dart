import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/update_check_result.dart';
import '../../domain/usecases/check_for_update.dart';
import '../../domain/usecases/get_apk_download_url.dart';
import '../widgets/update_dialog.dart';

class AppUpdateController extends GetxController {
  AppUpdateController({
    required CheckForUpdate checkForUpdate,
    required GetApkDownloadUrl getApkDownloadUrl,
  }) : _checkForUpdate = checkForUpdate,
       _getApkDownloadUrl = getApkDownloadUrl;

  final CheckForUpdate _checkForUpdate;
  final GetApkDownloadUrl _getApkDownloadUrl;

  @override
  void onReady() {
    super.onReady();
    executeCheckForUpdate();
  }

  Future<void> executeCheckForUpdate() async {
    final Either<Failure, UpdateCheckResult> result = await _checkForUpdate();
    await result.fold<Future<void>>(
      (Failure failure) async {
        log('AppUpdate | check failed: ${failure.message}');
      },
      (UpdateCheckResult data) async {
        if (!data.hasUpdate) {
          return;
        }
        await _showUpdateDialog(data);
      },
    );
  }

  Future<void> _showUpdateDialog(UpdateCheckResult data) async {
    await Get.dialog<void>(
      UpdateDialog(
        info: data.updateInfo,
        onUpdatePressed: () async {
          Get.back<void>();
          final Either<Failure, String> urlResult =
              await _getApkDownloadUrl();
          await urlResult.fold<Future<void>>(
            (Failure failure) async {
              log('AppUpdate | could not get download URL: ${failure.message}');
            },
            (String signedUrl) async {
              await openApkUrl(signedUrl);
            },
          );
        },
      ),
      barrierDismissible: !data.updateInfo.isMandatory,
    );
  }

  Future<void> openApkUrl(String apkUrl) async {
    final Uri uri = Uri.parse(apkUrl.trim());
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      log('AppUpdate | could not launch URL: $apkUrl');
    }
  }
}

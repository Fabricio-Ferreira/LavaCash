import 'package:dartz/dartz.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/update_check_result.dart';
import '../../domain/entities/update_info.dart';
import '../../domain/repositories/app_update_repository.dart';
import '../datasources/app_update_remote_datasource.dart';

class AppUpdateRepositoryImpl implements AppUpdateRepository {
  AppUpdateRepositoryImpl({required AppUpdateRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AppUpdateRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, UpdateCheckResult>> checkForUpdate() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      final int currentBuildNumber =
          int.tryParse(packageInfo.buildNumber) ?? 0;
      final model = await _remoteDataSource.fetchLatestVersion();
      final UpdateInfo remote = model.toDomain();
      final String trimmedApk = remote.apkStoragePath.trim();
      if (trimmedApk.isEmpty) {
        return Right<Failure, UpdateCheckResult>(
          UpdateCheckResult(
            hasUpdate: false,
            currentVersion: currentVersion,
            currentBuildNumber: currentBuildNumber,
            updateInfo: remote,
          ),
        );
      }
      final bool hasUpdate = _isRemoteNewer(
        currentVersion: currentVersion,
        currentBuild: currentBuildNumber,
        remoteVersion: remote.latestVersion,
        remoteBuild: remote.latestBuildNumber,
      );
      return Right<Failure, UpdateCheckResult>(
        UpdateCheckResult(
          hasUpdate: hasUpdate,
          currentVersion: currentVersion,
          currentBuildNumber: currentBuildNumber,
          updateInfo: remote,
        ),
      );
    } on UpdateFailure catch (e) {
      return Left<Failure, UpdateCheckResult>(e);
    } on Exception catch (e) {
      return Left<Failure, UpdateCheckResult>(UpdateFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getApkDownloadUrl() async {
    try {
      final String url = await _remoteDataSource.getApkSignedUrl();
      return Right<Failure, String>(url);
    } on UpdateFailure catch (e) {
      return Left<Failure, String>(e);
    } on Exception catch (e) {
      return Left<Failure, String>(UpdateFailure(e.toString()));
    }
  }

  bool _isRemoteNewer({
    required String currentVersion,
    required int currentBuild,
    required String remoteVersion,
    required int remoteBuild,
  }) {
    final int versionCompare = _compareSemVer(remoteVersion, currentVersion);
    if (versionCompare > 0) {
      return true;
    }
    if (versionCompare < 0) {
      return false;
    }
    return remoteBuild > currentBuild;
  }

  int _compareSemVer(String a, String b) {
    final List<int> aParts = a.split('.').map((String e) => int.tryParse(e) ?? 0).toList();
    final List<int> bParts = b.split('.').map((String e) => int.tryParse(e) ?? 0).toList();
    final int maxLength = aParts.length > bParts.length ? aParts.length : bParts.length;
    while (aParts.length < maxLength) {
      aParts.add(0);
    }
    while (bParts.length < maxLength) {
      bParts.add(0);
    }
    for (int i = 0; i < maxLength; i++) {
      if (aParts[i] > bParts[i]) {
        return 1;
      }
      if (aParts[i] < bParts[i]) {
        return -1;
      }
    }
    return 0;
  }
}

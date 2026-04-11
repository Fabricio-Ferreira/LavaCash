import 'package:equatable/equatable.dart';

import 'update_info.dart';

class UpdateCheckResult extends Equatable {
  const UpdateCheckResult({
    required this.hasUpdate,
    required this.currentVersion,
    required this.currentBuildNumber,
    required this.updateInfo,
  });

  final bool hasUpdate;
  final String currentVersion;
  final int currentBuildNumber;
  final UpdateInfo updateInfo;

  @override
  List<Object?> get props => <Object?>[
    hasUpdate,
    currentVersion,
    currentBuildNumber,
    updateInfo,
  ];
}

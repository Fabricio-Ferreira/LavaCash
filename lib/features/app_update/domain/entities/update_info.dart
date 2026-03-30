import 'package:equatable/equatable.dart';

class UpdateInfo extends Equatable {
  const UpdateInfo({
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.apkUrl,
    required this.isMandatory,
    required this.title,
    required this.message,
    required this.releaseNotes,
    this.publishedAt,
  });

  final String latestVersion;
  final int latestBuildNumber;
  final String apkUrl;
  final bool isMandatory;
  final String title;
  final String message;
  final List<String> releaseNotes;
  final DateTime? publishedAt;

  @override
  List<Object?> get props => <Object?>[
    latestVersion,
    latestBuildNumber,
    apkUrl,
    isMandatory,
    title,
    message,
    releaseNotes,
    publishedAt,
  ];
}

import '../../domain/entities/update_info.dart';

class UpdateInfoModel {
  UpdateInfoModel({
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.apkStoragePath,
    required this.isMandatory,
    required this.title,
    required this.message,
    required this.releaseNotes,
    this.publishedAt,
  });

  final String latestVersion;
  final int latestBuildNumber;
  final String apkStoragePath;
  final bool isMandatory;
  final String title;
  final String message;
  final List<String> releaseNotes;
  final DateTime? publishedAt;

  factory UpdateInfoModel.fromJson(Map<String, dynamic> json) {
    final Object? rawNotes = json['release_notes'];
    final List<String> notes = <String>[];
    if (rawNotes is List<dynamic>) {
      for (final Object? e in rawNotes) {
        notes.add(e?.toString() ?? '');
      }
    }
    final Object? published = json['published_at'];
    DateTime? publishedAt;
    if (published is String) {
      publishedAt = DateTime.tryParse(published);
    }
    return UpdateInfoModel(
      latestVersion: json['latest_version'] as String? ?? '',
      latestBuildNumber: _parseInt(json['latest_build_number']),
      apkStoragePath: json['apk_storage_path'] as String? ?? '',
      isMandatory: json['is_mandatory'] as bool? ?? false,
      title: json['title'] as String? ?? 'Atualizacao disponivel',
      message: json['message'] as String? ?? '',
      releaseNotes: notes,
      publishedAt: publishedAt,
    );
  }

  UpdateInfo toDomain() {
    return UpdateInfo(
      latestVersion: latestVersion,
      latestBuildNumber: latestBuildNumber,
      apkStoragePath: apkStoragePath,
      isMandatory: isMandatory,
      title: title,
      message: message,
      releaseNotes: releaseNotes,
      publishedAt: publishedAt,
    );
  }

  static int _parseInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

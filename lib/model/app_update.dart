// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AppUpdate {
  final String? appName;
  final int? versionNumber;
  final String? versionCode;
  final String? downloadUrl;
  final String? description;

  AppUpdate({
    this.appName,
    this.versionNumber,
    this.versionCode,
    this.downloadUrl,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'appName': appName,
      'versionNumber': versionNumber,
      'versionCode': versionCode,
      'downloadUrl': downloadUrl,
      'description': description,
    };
  }

  factory AppUpdate.fromMap(Map<String, dynamic> map) {
    return AppUpdate(
      appName: map['appName'],
      versionNumber: map['versionNumber']?.toInt() ?? 0,
      versionCode: map['versionCode'],
      downloadUrl: map['downloadUrl'],
      description: map['description'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AppUpdate.fromJson(String source) =>
      AppUpdate.fromMap(json.decode(source) as Map<String, dynamic>);
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UploadFile {
  final String token;
  final String filename;
  final String downloadUrl;

  UploadFile({
    required this.token,
    required this.filename,
    required this.downloadUrl,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token': token,
      'filename': filename,
      'downloadUrl': downloadUrl,
    };
  }

  factory UploadFile.fromMap(Map<String, dynamic> map) {
    return UploadFile(
      token: map['token'],
      filename: map['filename'],
      downloadUrl: map['downloadUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UploadFile.fromJson(String source) =>
      UploadFile.fromMap(json.decode(source) as Map<String, dynamic>);
}

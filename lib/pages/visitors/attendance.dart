import 'dart:convert';
import 'package:marina_bay_cell_building_visitors/pages/visitors/employee.dart';

class Attendance {
  final String? id;
  final Employee? userId;
  final int day;
  final int month;
  final int year;
  final String status;
  final String? wlStatus;
  final DateTime? date;
  final DateTime? checkInTime;
  final double? checkInLatitude;
  final String? checkInAddress;
  final double? checkInLongitude;
  final String? checkInPhoto;
  final DateTime? checkOutTime;
  final double? checkOutLatitude;
  final String? checkOutAddress;
  final double? checkOutLongitude;
  final String? checkOutPhoto;
  final int totalActiveSeconds;
  final int totalBreakSeconds;
  final int overtimeSeconds;
  final DateTime? breakStartTime;
  final DateTime? breakEndTime;
  final List<AttendanceTimeline> timeline;
  final DateTime? lastUpdatedTime; // New Field

  Attendance({
    this.id,
    this.userId,
    required this.day,
    required this.month,
    required this.year,
    required this.status,
    this.wlStatus,
    this.date,
    this.checkInTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInAddress,
    this.checkInPhoto,
    this.checkOutTime,
    this.checkOutLatitude,
    this.checkOutAddress,
    this.checkOutLongitude,
    this.checkOutPhoto,
    this.totalActiveSeconds = 0,
    this.totalBreakSeconds = 0,
    this.overtimeSeconds = 0,
    this.breakStartTime,
    this.breakEndTime,
    this.timeline = const [],
    this.lastUpdatedTime, // Initialize the new field
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['_id'],
      userId: (json['userId'] != null && json['userId'] is Map<String, dynamic>)
          ? Employee.fromMap(json['userId'] as Map<String, dynamic>)
          : null,
      day: json['day'],
      month: json['month'],
      year: json['year'],
      status: json['status'],
      wlStatus: json['wlStatus'],
      checkInTime: json['checkInTime'] != null
          ? DateTime.parse(json['checkInTime'])
          : null,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,

      checkInLatitude: json['checkInLatitude']?.toDouble(),
      checkInLongitude: json['checkInLongitude']?.toDouble(),
      checkInPhoto: json['checkInPhoto'],
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'])
          : null,
      checkOutLatitude: json['checkOutLatitude']?.toDouble(),
      checkOutLongitude: json['checkOutLongitude']?.toDouble(),
      checkOutPhoto: json['checkOutPhoto'],
      checkOutAddress: json['checkOutAddress'],
      checkInAddress: json['checkInAddress'],
      totalActiveSeconds: json['totalActiveSeconds'] ?? 0,
      totalBreakSeconds: json['totalBreakSeconds'] ?? 0,
      overtimeSeconds: json['overtimeSeconds'] ?? 0,
      breakStartTime: json['breakStartTime'] != null
          ? DateTime.parse(json['breakStartTime'])
          : null,
      breakEndTime: json['breakEndTime'] != null
          ? DateTime.parse(json['breakEndTime'])
          : null,
      timeline:
          (json['timeline'] as List<dynamic>?)
              ?.map((e) => AttendanceTimeline.fromJson(e))
              .toList() ??
          [],
      lastUpdatedTime: json['lastUpdatedTime'] != null
          ? DateTime.parse(json['lastUpdatedTime'])
          : DateTime.now(), // Parse new field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'day': day,
      'month': month,
      'year': year,
      'status': status,
      'wlStatus': wlStatus,
      'date': date?.toIso8601String(),
      'checkInTime': checkInTime?.toIso8601String(),
      'checkInLatitude': checkInLatitude,
      'checkInLongitude': checkInLongitude,
      'checkInAddress': checkInAddress,
      'checkOutAddress': checkOutAddress,
      'checkInPhoto': checkInPhoto,
      'checkOutTime': checkOutTime?.toIso8601String(),
      'checkOutLatitude': checkOutLatitude,
      'checkOutLongitude': checkOutLongitude,
      'checkOutPhoto': checkOutPhoto,
      'totalActiveSeconds': totalActiveSeconds,
      'totalBreakSeconds': totalBreakSeconds,
      'overtimeSeconds': overtimeSeconds,
      'breakStartTime': breakStartTime?.toIso8601String(),
      'breakEndTime': breakEndTime?.toIso8601String(),
      'timeline': timeline.map((e) => e.toJson()).toList(),
      'lastUpdatedTime': lastUpdatedTime?.toIso8601String(), // Include in JSON
    };
  }
}

class AttendanceTimeline {
  String event;
  DateTime? timestamp;
  DateTime? timestampEnd;
  int? durationSeconds;
  String? remark;
  String? photo;
  double? latitude;
  double? longitude;

  AttendanceTimeline({
    required this.event,
    this.timestamp,
    this.timestampEnd,
    this.durationSeconds,
    this.remark,
    this.photo,
    this.latitude,
    this.longitude,
  });

  factory AttendanceTimeline.fromJson(Map<String, dynamic> json) {
    return AttendanceTimeline(
      event: json['event'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
      timestampEnd: json['timestampEnd'] != null
          ? DateTime.parse(json['timestampEnd'])
          : null,
      durationSeconds: json['durationSeconds'],
      remark: json['remark'],
      photo: json['photo'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'timestamp': timestamp?.toIso8601String(),
      'timestampEnd': timestampEnd?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'remark': remark,
      'photo': photo,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class AttendanceSeparated {
  final List<Attendance> data;
  final List<Attendance> approvedList;
  final List<Attendance> rejectedList;
  final List<Attendance> pendingList;

  AttendanceSeparated({
    this.data = const [],
    this.approvedList = const [],
    this.rejectedList = const [],
    this.pendingList = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'data': data.map((x) => x.toJson()).toList(),
      'approvedList': approvedList.map((x) => x.toJson()).toList(),
      'rejectedList': rejectedList.map((x) => x.toJson()).toList(),
      'pendingList': pendingList.map((x) => x.toJson()).toList(),
    };
  }

  factory AttendanceSeparated.fromJson(Map<String, dynamic> json) {
    return AttendanceSeparated(
      data: json['data'] != null
          ? List<Attendance>.from(
              (json['data'] as List<dynamic>).map<Attendance>(
                (x) => Attendance.fromJson(x as Map<String, dynamic>),
              ),
            )
          : [],
      approvedList: json['approvedList'] != null
          ? List<Attendance>.from(
              (json['approvedList'] as List<dynamic>).map<Attendance>(
                (x) => Attendance.fromJson(x as Map<String, dynamic>),
              ),
            )
          : [],
      rejectedList: json['rejectedList'] != null
          ? List<Attendance>.from(
              (json['rejectedList'] as List<dynamic>).map<Attendance>(
                (x) => Attendance.fromJson(x as Map<String, dynamic>),
              ),
            )
          : [],
      pendingList: json['pendingList'] != null
          ? List<Attendance>.from(
              (json['pendingList'] as List<dynamic>).map<Attendance>(
                (x) => Attendance.fromJson(x as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  // Update this method to accept a Map<String, dynamic>
  factory AttendanceSeparated.f(Map<String, dynamic> source) =>
      AttendanceSeparated.fromJson(source);
}

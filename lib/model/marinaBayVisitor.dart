class MarinaBayVisitor {
  final String? id;
  final String? name;
  final int? phoneNumber;
  final String? purpose;
  final DateTime? checkInTime;
  final String? checkInPhoto;
  final DateTime? checkOutTime;
  final String? checkOutPhoto;
  final int? unitNo;
  final DateTime? date;
  final String? type;
  final int? peopleCount;
  final String? wing;

  MarinaBayVisitor({
    this.id,
    this.name,
    this.phoneNumber,
    this.purpose,
    this.checkInTime,
    this.checkInPhoto,
    this.checkOutTime,
    this.checkOutPhoto,
    this.unitNo,
    this.date,
    this.type,
    this.peopleCount,
    this.wing,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "phoneNumber": phoneNumber,
      "purpose": purpose,
      "checkInTime": checkInTime?.toIso8601String(),
      "checkInPhoto": checkInPhoto,
      "checkOutTime": checkOutTime?.toIso8601String(),
      "checkOutPhoto": checkOutPhoto,
      "unitNo": unitNo,
      "date": date?.toIso8601String(),
      "type": type,
      "peopleCount": peopleCount,
      "wing": wing,
    };
  }

  factory MarinaBayVisitor.fromJson(Map<String, dynamic> json) {
    return MarinaBayVisitor(
      id: json['_id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      purpose: json['purpose'],
      checkInTime: json['checkInTime'] != null
          ? DateTime.parse(json['checkInTime'])
          : null,
      checkInPhoto: json['checkInPhoto'],
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'])
          : null,
      checkOutPhoto: json['checkOutPhoto'],
      unitNo: json['unitNo'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      type: json['type'],
      peopleCount: json['peopleCount'],
      wing: json['wing'],
    );
  }
}

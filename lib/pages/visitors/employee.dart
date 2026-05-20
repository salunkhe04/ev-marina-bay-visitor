class Employee {
  final String? id;
  final String? profilePic;
  final String? employeeId;
  final String? prefix;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? email;
  final int? phoneNumber;
  final DateTime? dateOfBirth;
  final DateTime? joiningDate;
  final String? gender;
  final String? address;
  final String? status;
  final String? role;

  final bool? isVerified;
  final bool? isVerifiedPhone;
  final bool? isVerifiedEmail;

  final Employee? reportingTo;
  final String? maritalStatus;
  final String? bloodGroup;
  final List<String> permissions;
  final DateTime? mpinChangeDate;
  final String? experienceStatus;
  final List<PersonalDocument> personalDocument;

  Employee({
    this.id,
    this.employeeId,
    this.prefix,
    this.firstName,
    this.middleName,
    this.lastName,
    this.email,
    this.status,
    this.phoneNumber,
    this.dateOfBirth,
    this.joiningDate,
    this.gender,
    this.address,
    this.role,
    this.profilePic,
    this.isVerified,
    this.isVerifiedPhone,
    this.isVerifiedEmail,
    this.reportingTo,
    this.maritalStatus,
    this.bloodGroup,
    this.mpinChangeDate,
    this.experienceStatus,
    this.permissions = const [],
    this.personalDocument = const [],
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['_id'],
      email: map['email'],
      prefix: map['prefix'],
      employeeId: map['employeeId'],
      profilePic: map['profilePic'],
      firstName: map['firstName'],
      middleName: map['middleName'],
      lastName: map['lastName'],
      phoneNumber: map['phoneNumber'],
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.tryParse(map["dateOfBirth"])
          : null,
      joiningDate: map['joiningDate'] != null
          ? DateTime.tryParse(map["joiningDate"])
          : null,
      gender: map['gender'],
      status: map['status'],
      address: map['address'],
      role: map['role'],
      isVerified: map['isVerified'],
      isVerifiedPhone: map['isVerifiedPhone'],
      isVerifiedEmail: map['isVerifiedEmail'],
      reportingTo:
          (map['reportingTo'] != null &&
              map['reportingTo'] is Map<String, dynamic>)
          ? Employee.fromMap(map['reportingTo'] as Map<String, dynamic>)
          : null,
      maritalStatus: map['maritalStatus'],
      bloodGroup: map['bloodGroup'],
      experienceStatus: map['experienceStatus'],
      permissions: map['permissions'] != null
          ? List<String>.from(map['permissions'])
          : [],
      mpinChangeDate: map['mpinChangeDate'] != null
          ? DateTime.tryParse(map['mpinChangeDate'])
          : null,
      personalDocument: map['personalDocument'] != null
          ? (map["personalDocument"] as List<dynamic>?)
                    ?.map((ele) => PersonalDocument.fromJson(ele))
                    .toList() ??
                []
          : [],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "prefix": prefix,
      "employeeId": employeeId,
      "profilePic": profilePic,
      "firstName": firstName,
      "middleName": middleName,
      "lastName": lastName,
      "phoneNumber": phoneNumber,
      "dateOfBirth": dateOfBirth?.toIso8601String(),
      "joiningDate": joiningDate?.toIso8601String(),
      "gender": gender,
      "status": status,
      "address": address,
      "role": role ?? "employee",
      "isVerified": isVerified,
      "isVerifiedPhone": isVerifiedPhone,
      "isVerifiedEmail": isVerifiedEmail,
      "reportingTo": reportingTo?.id,
      "maritalStatus": maritalStatus,
      "bloodGroup": bloodGroup,
      "permissions": permissions,
      'mpinChangeDate': mpinChangeDate?.toIso8601String(),
      'experienceStatus': experienceStatus,
      "personalDocument": personalDocument.map((e) => e.toJson()).toList(),
    };
  }

  Map<String, dynamic> toMapForUpdate() {
    return {
      ...(id != null ? {'id': id} : {}),
      ...(profilePic != null ? {'profilePic': profilePic} : {}),
      ...(employeeId != null ? {'employeeId': employeeId} : {}),
      ...(prefix != null ? {'prefix': prefix} : {}),
      ...(firstName != null ? {'firstName': firstName} : {}),
      ...(middleName != null ? {'middleName': middleName} : {}),
      ...(lastName != null ? {'lastName': lastName} : {}),
      ...(email != null ? {'email': email} : {}),
      ...(phoneNumber != null ? {'phoneNumber': phoneNumber} : {}),
      ...(dateOfBirth != null ? {'dateOfBirth': dateOfBirth} : {}),
      ...(joiningDate != null
          ? {'joiningDate': joiningDate?.toIso8601String()}
          : {}),
      ...(gender != null ? {'gender': gender} : {}),
      ...(address != null ? {'address': address} : {}),
      ...(status != null ? {'status': status} : {}),
      ...(role != null ? {'role': role} : {}),
      ...(isVerified != null ? {'isVerified': isVerified} : {}),
      ...(isVerifiedPhone != null ? {'isVerifiedPhone': isVerifiedPhone} : {}),
      ...(isVerifiedEmail != null ? {'isVerifiedEmail': isVerifiedEmail} : {}),
      ...(phoneNumber != null ? {'phoneNumber': phoneNumber} : {}),
      ...(reportingTo != null ? {'reportingTo': reportingTo?.id} : {}),
      ...(maritalStatus != null ? {'maritalStatus': maritalStatus} : {}),
      ...(bloodGroup != null ? {'bloodGroup': bloodGroup} : {}),
      ...(permissions.isNotEmpty ? {'permissions': permissions} : {}),
      ...(mpinChangeDate != null
          ? {'mpinChangeDate': mpinChangeDate?.toIso8601String()}
          : {}),
      ...(experienceStatus != null
          ? {'experienceStatus': experienceStatus}
          : {}),
      ...(personalDocument.isNotEmpty
          ? {
              'personalDocument': personalDocument
                  .map((e) => e.toJson())
                  .toList(),
            }
          : {}),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Employee && other.id == id;
  }

  @override
  int get hashCode => employeeId.hashCode;
}

class PersonalDocument {
  final String? typeOfDocument;
  final String? documentNumber;
  final String? name;
  final String? file;
  final String? frontSide;
  final String? backSide;

  PersonalDocument({
    this.typeOfDocument,
    this.documentNumber,
    this.name,
    this.file,
    this.frontSide,
    this.backSide,
  });

  factory PersonalDocument.fromJson(Map<String, dynamic> json) {
    return PersonalDocument(
      typeOfDocument: json['typeOfDocument'],
      documentNumber: json['documentNumber'],
      name: json['name'],
      file: json['file'],
      frontSide: json['frontSide'] ?? '',
      backSide: json['backSide'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "typeOfDocument": typeOfDocument,
      "documentNumber": documentNumber,
      "name": name,
      "file": file,
      "frontSide": frontSide,
      "backSide": backSide,
    };
  }
}

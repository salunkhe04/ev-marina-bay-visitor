// import 'dart:async';
// import 'dart:io';
// // import 'package:ev_homes/components/appColors.dart';
// // import 'package:ev_homes/core/helper/helper.dart';
// // import 'package:ev_homes/core/models/attendance/attendance_log.dart';
// // import 'package:ev_homes/core/providers/attendance_provider.dart';
// // import 'package:ev_homes/core/providers/geolocation_provider.dart';
// // import 'package:ev_homes/core/providers/setting_provider.dart';
// // import 'package:ev_homes/core/services/api_service.dart';
// // import 'package:ev_homes/core/services/hive_service.dart';
// // import 'package:ev_homes/core/services/shared_pref_service.dart';
// // import 'package:ev_homes/pages/attendance_pages/attendance_log.dart';
// // import 'package:ev_homes/pages/attendance_pages/face_recog_pages/face_register_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:lottie/lottie.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:convert';
// import 'package:provider/provider.dart';

// class TimeInOutScreenFaceRecogV2 extends StatefulWidget {
//   final String? type;
//   final String? id;
//   const TimeInOutScreenFaceRecogV2({super.key, this.type, this.id});

//   @override
//   State<TimeInOutScreenFaceRecogV2> createState() =>
//       _TimeInOutScreenFaceRecogV2State();
// }

// class _TimeInOutScreenFaceRecogV2State extends State<TimeInOutScreenFaceRecogV2>
//     with WidgetsBindingObserver {
//   final FaceDetector _faceDetector = FaceDetector(
//     options: FaceDetectorOptions(
//       enableClassification: false,
//       enableTracking: true,
//       enableLandmarks: false,
//       performanceMode: FaceDetectorMode.fast,
//     ),
//   );

//   Timer? _periodicTimer;
//   bool _isProcessing = false;
//   bool isUploadingImage = false;
//   bool _faceMatched = false;
//   bool isError = false;
//   File? selectedImage;
//   String _statusMessage = "Face Recognition Status";
//   double similarity = 0;

//   Future<void> onRefresh() async {
//     // final settingProvider = Provider.of<SettingProvider>(
//     //   context,
//     //   listen: false,
//     // );
//     // await settingProvider.getFaceIdByUserId(
//     //   settingProvider.loggedAdmin?.id ?? "",
//     // );
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     onRefresh();
//   }

//   // Expects a pre-captured photo File from an external camera source
//   void _startFaceVerificationPipeline(File file) async {
//     final attendanceProvider = Provider.of<AttendanceProvider>(
//       context,
//       listen: false,
//     );

//     setState(() {
//       _isProcessing = true;
//     });

//     try {
//       final inputImage = InputImage.fromFilePath(file.path);
//       final faces = await _faceDetector.processImage(inputImage);

//       if (faces.isEmpty) {
//         setState(() => _statusMessage = "No face detected");
//       } else if (faces.length > 1) {
//         setState(() => _statusMessage = "Multiple faces detected");
//       } else {
//         setState(() => _statusMessage = "Face detected - Matching...");
//         selectedImage = file;
//         try {
//           final dir = await getApplicationDocumentsDirectory();
//           final savedPath =
//               "${dir.path}/checkin_${DateTime.now().millisecondsSinceEpoch}.jpg";
//           final savedFile = await file.copy(savedPath);

//           bool isCheckedIn = attendanceProvider.attendance?.checkInTime != null;
//           // await SharedPrefService.storeData("check-in", {
//           //   "type": isCheckedIn == true ? "check-out" : "check-in",
//           //   "checkInPhoto": savedFile.path,
//           //   "checkInTime": DateTime.now().toIso8601String(),
//           // });
//         } catch (e) {
//           // Caching error fallback
//         }

//         Uint8List imageBytes = await file.readAsBytes();
//         await _setImage(imageBytes);
//         await _matchFaces();
//       }
//     } catch (e) {
//       print("Face processing error: $e");
//     } finally {
//       setState(() => _isProcessing = false);
//     }
//   }

//   Future<void> _setImage(Uint8List imageToAuthenticate) async {
//     // Custom byte registration configurations if needed
//   }

//   void _showFaceIdNotRegisteredDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           title: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(
//                 Icons.face_retouching_off,
//                 color: Colors.redAccent,
//                 size: 30.0,
//               ),
//               const SizedBox(width: 10.0),
//               Expanded(
//                 child: Text(
//                   'Face ID Not Registered',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20.0,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//           content: const Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'It looks like your Face ID isn\'t set up for check-in/out yet.',
//                 style: TextStyle(fontSize: 16.0),
//               ),
//               SizedBox(height: 10.0),
//               Text(
//                 'Please register your Face ID to use this feature.',
//                 style: TextStyle(fontSize: 16.0),
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(dialogContext).pop();
//                 Navigator.of(context).pop();
//                 // Navigator.of(context).push(
//                 //   MaterialPageRoute(
//                 //     builder: (context) => const FaceRegisterPage(),
//                 //   ),
//                 // );
//               },
//               child: Text(
//                 'Continue',
//                 style: TextStyle(
//                   color: Theme.of(context).primaryColor,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18.0,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _matchFaces() async {
//     bool faceMatched = false;

//     // final settingProvider = Provider.of<SettingProvider>(
//     //   context,
//     //   listen: false,
//     // );
//     // final geolocationProvider = Provider.of<GeolocationProvider>(
//     //   context,
//     //   listen: false,
//     // );
//     // final attendanceProvider = Provider.of<AttendanceProvider>(
//     //   context,
//     //   listen: false,
//     // );

//     // bool isCheckedIn = attendanceProvider.attendance?.checkInTime != null;

//     // String address =
//     //     geolocationProvider.address.isNotEmpty &&
//     //         geolocationProvider.address != "Fetching address..."
//     //     ? geolocationProvider.address
//     //     : "${geolocationProvider.latitude} ${geolocationProvider.longitude}";

//     // final cFace = settingProvider.currentFaceId;
//     // final loadedImage = cFace?.preLoadedFace;

//     // if (loadedImage == null) {
//     //   setState(() {
//     //     _statusMessage = "Face is not registered";
//     //   });
//     //   _periodicTimer?.cancel();
//     //   _faceDetector.close();
//     //   if (selectedImage != null) {
//     //     selectedImage = await Helper.drawOverlayCheckOutImage(
//     //       imageFile: selectedImage!,
//     //       time: Helper.formatDate(DateTime.now().toIso8601String()),
//     //       address: address,
//     //       percent: similarity.toStringAsFixed(0),
//     //     );

//     //     try {
//     //       final dir = await getApplicationDocumentsDirectory();
//     //       final savedPath =
//     //           "${dir.path}/checkin_${DateTime.now().millisecondsSinceEpoch}.jpg";
//     //       final savedFile = await File(selectedImage!.path).copy(savedPath);

//     //       await SharedPrefService.storeData("check-in", {
//     //         "type": isCheckedIn == true ? "check-out" : "check-in",
//     //         "checkInPhoto": savedFile.path,
//     //         "checkInTime": DateTime.now().toIso8601String(),
//     //       });
//     //     } catch (e) {
//     //       // Caching layout exceptions
//     //     }
//     //   }

//     //   _completeProcess(false);
//     //   _showFaceIdNotRegisteredDialog(context);
//     //   return;
//     // }

//     // if (selectedImage != null) {
//     //   selectedImage = await Helper.drawOverlayCheckOutImage(
//     //     imageFile: selectedImage!,
//     //     time: Helper.formatDate(DateTime.now().toIso8601String()),
//     //     address: address,
//     //     percent: similarity.toStringAsFixed(0),
//     //   );
//     //   try {
//     //     final dir = await getApplicationDocumentsDirectory();
//     //     final savedPath =
//     //         "${dir.path}/checkin_${DateTime.now().millisecondsSinceEpoch}.jpg";
//     //     final savedFile = await File(selectedImage!.path).copy(savedPath);

//     //     await SharedPrefService.storeData("check-in", {
//     //       "type": isCheckedIn == true ? "check-out" : "check-in",
//     //       "checkInPhoto": savedFile.path,
//     //       "checkInTime": DateTime.now().toIso8601String(),
//     //     });
//     //   } catch (e) {
//     //     // Caching fallback configuration rules
//     //   }
//     // }

//     setState(() {
//       _statusMessage = "OK";
//     });
//     _completeProcess(false);
//   }

//   void _completeProcess(bool matched) {
//     _periodicTimer?.cancel();
//     _submitResult(matched);
//   }

//   void _submitResult(bool matched) async {
//     try {
//       // final attendanceProvider = Provider.of<AttendanceProvider>(
//       //   context,
//       //   listen: false,
//       // );
//       // final settingProvider = Provider.of<SettingProvider>(
//       //   context,
//       //   listen: false,
//       // );
//       // final geolocationProvider = Provider.of<GeolocationProvider>(
//       //   context,
//       //   listen: false,
//       // );

//       // bool isCheckedIn = attendanceProvider.attendance?.checkInTime != null;
//       // final bool isCheckedOut =
//       //     attendanceProvider.attendance?.checkOutTime != null;

//       if (selectedImage != null) {
//         setState(() {
//           isUploadingImage = true;
//         });

//         final uploadedResp = await ApiService().uploadFile(selectedImage!);
//         if (uploadedResp == null) {
//           Helper.showCustomSnackBar("Failed to Upload Photo");
//           return;
//         }
//         try {
//           final now = DateTime.now();
//           final attLog = AttendanceLogModel(
//             accuracy: 0,
//             id: now.millisecondsSinceEpoch.toString(),
//             userId: settingProvider.loggedAdmin?.id ?? "",
//             action: widget.type ?? "IN",
//             status: geolocationProvider.isWithinRadius ? "SUCCESS" : "FAILED",
//             reason: geolocationProvider.isWithinRadius
//                 ? "NONE"
//                 : "OUT_OF_GEOFENCE",
//             message: geolocationProvider.isWithinRadius
//                 ? "Attendance marked"
//                 : "Attempted ${isCheckedOut
//                       ? "(OUT)"
//                       : isCheckedIn
//                       ? "(OUT)"
//                       : "(IN)"} outside geofence at ${geolocationProvider.address}",
//             latitude: geolocationProvider.latitude,
//             longitude: geolocationProvider.longitude,
//             insideGeofence: geolocationProvider.isWithinRadius,
//             timestamp: now,
//             day: now.day,
//             month: now.month,
//             year: now.year,
//             synced: false,
//             photoPath: selectedImage?.path,
//           );
//           HiveService.addAttendanceLog(attLog);
//         } catch (e) {
//           // Metric calculation log exceptions
//         }

//         if (widget.type == "OUT") {
//           Map<String, dynamic> data2 = {
//             "userId": settingProvider.loggedAdmin?.id,
//             "checkOutLatitude": geolocationProvider.latitude,
//             "checkOutLongitude": geolocationProvider.longitude,
//             "checkOutAddress": geolocationProvider.address,
//             "checkOutPhoto": uploadedResp.downloadUrl,
//             "similarity": similarity,
//           };
//           await attendanceProvider.checkOut(data2);
//         } else if (widget.type == "IN") {
//           Map<String, dynamic> data4 = {
//             "userId": settingProvider.loggedAdmin?.id,
//             "checkInLatitude": geolocationProvider.latitude,
//             "checkInLongitude": geolocationProvider.longitude,
//             "checkInAddress": geolocationProvider.address,
//             "checkInPhoto": uploadedResp.downloadUrl,
//             "similarity": similarity,
//           };
//           await attendanceProvider.checkIn(data4);
//         } else {
//           Helper.showCustomSnackBar("please go back and try again.");
//         }
//       }
//     } catch (e) {
//       // Stream exception validation tracking mapping
//     } finally {
//       if (mounted) {
//         Navigator.of(context).pop();
//         Navigator.of(
//           context,
//         ).push(MaterialPageRoute(builder: (context) => const AttendanceLog()));
//       }
//     }
//     setState(() {
//       isUploadingImage = false;
//     });
//   }

//   @override
//   void dispose() {
//     _faceDetector.close();
//     _periodicTimer?.cancel();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text(
//           widget.type == "OUT"
//               ? "Punch OUT"
//               : widget.type == "IN"
//               ? "Punch IN"
//               : "Face Recognition",
//           style: const TextStyle(
//             color: AppColors.text,
//             fontWeight: FontWeight.w600,
//             fontSize: 20,
//           ),
//         ),
//         backgroundColor: AppColors.primary,
//         elevation: 0,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: AppColors.text),
//       ),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Container(
//                 width: double.infinity,
//                 margin: const EdgeInsets.all(16),
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 20,
//                   horizontal: 24,
//                 ),
//                 decoration: BoxDecoration(
//                   color: _getStatusBackgroundColor(),
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: _getStatusIconColor().withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         _getStatusIcon(),
//                         color: _getStatusIconColor(),
//                         size: 24,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Text(
//                         _statusMessage,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: _getStatusTextColor(),
//                           height: 1.3,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (_isProcessing) ...[
//                 Expanded(
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Lottie.asset(
//                           "assets/animations/face_verification_anim.json",
//                           width: 200,
//                           height: 200,
//                         ),
//                         const SizedBox(height: 16),
//                         const Text(
//                           "Verifying face, please wait...",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ] else if (selectedImage != null && _isProcessing == false) ...[
//                 Image.file(
//                   selectedImage!,
//                   width: MediaQuery.sizeOf(context).width * 0.9,
//                   height: MediaQuery.sizeOf(context).height * 0.5,
//                 ),
//               ] else ...[
//                 Expanded(
//                   child: Center(
//                     child: Container(
//                       width: 320,
//                       height: 420,
//                       decoration: BoxDecoration(
//                         color: AppColors.cardBackground,
//                         borderRadius: BorderRadius.circular(24),
//                         border: Border.all(color: AppColors.primary, width: 2),
//                       ),
//                       child: const Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.face_retouching_natural,
//                             size: 64,
//                             color: AppColors.textLight,
//                           ),
//                           SizedBox(height: 16),
//                           Text(
//                             'Ready for Biometric Input...',
//                             style: TextStyle(
//                               color: AppColors.textLight,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//               const SizedBox(height: 16),
//               SafeArea(child: const SizedBox(height: 16)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusBackgroundColor() {
//     if (isError) return AppColors.error.withOpacity(0.1);
//     if (_faceMatched) return AppColors.success.withOpacity(0.1);
//     return AppColors.primary.withOpacity(0.3);
//   }

//   Color _getStatusTextColor() {
//     if (isError) return AppColors.error;
//     if (_faceMatched) return AppColors.success;
//     return AppColors.text;
//   }

//   Color _getStatusIconColor() {
//     if (isError) return AppColors.error;
//     if (_faceMatched) return AppColors.success;
//     return AppColors.secondary;
//   }

//   IconData _getStatusIcon() {
//     if (isError) return Icons.error_outline;
//     if (_faceMatched) return Icons.check_circle_outline;
//     return Icons.face;
//   }
// }

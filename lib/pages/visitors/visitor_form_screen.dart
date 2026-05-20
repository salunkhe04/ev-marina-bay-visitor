import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marina_bay_cell_building_visitors/core/helper/helper.dart';
import 'package:marina_bay_cell_building_visitors/model/marinaBayVisitor.dart';
import 'package:marina_bay_cell_building_visitors/providers/settingProvider.dart';
import 'package:marina_bay_cell_building_visitors/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img; // Import the image package

// Your EV Homes feature components and state engines
// import 'package:ev_homes/core/providers/attendance_provider.dart';
// import 'package:ev_homes/core/providers/geolocation_provider.dart';
// import 'package:ev_homes/core/providers/setting_provider.dart';
// import 'time_in_out_screen_face_recog_v2.dart';

class VisitorFormScreen extends StatefulWidget {
  const VisitorFormScreen({super.key});

  @override
  State<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _flatNoController = TextEditingController();

  File? capturedImageFile;
  String? capturedImageUrl;
  final ImagePicker _picker = ImagePicker();

  bool isError = false;
  bool _faceMatched = false;
  CameraController? _cameraController;
  List<CameraDescription>? cameras;

  bool isLoading = false;
  TimeOfDay? _selectedTimeIn;
  String _selectedType = 'Visitor';
  bool _photoError = false;
  bool _timeInError = false;

  Future<void> _selectTime(BuildContext context, bool isTimeIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isTimeIn) {
          _selectedTimeIn = picked;
        }
      });
    }
  }

  Future<void> capturePhoto() async {
    await initializeCamera();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.blueGrey,
          body: SafeArea(
            child: Stack(
              children: [
                // Camera Preview
                Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    height: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: _getCameraBorderColor(),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getCameraBorderColor().withOpacity(0.4),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: _cameraController!.value.aspectRatio,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  ),
                ),

                // Top Bar
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const Text(
                        "Capture Visitor Photo",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Bottom Capture Button
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          final file = await _cameraController!.takePicture();

                          setState(() {
                            capturedImageFile = File(file.path);
                            // photoError = null;
                          });

                          if (mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          setState(() {
                            isError = true;
                          });
                        }
                      },
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 5),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();

    final frontCamera = cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    setState(() {});
  }

  Future<void> onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final settingProvider = Provider.of<SettingProvider>(
      context,
      listen: false,
    );

    try {
      setState(() {
        isLoading = true;
      });

      if (capturedImageFile != null) {
        final imageBytes = await capturedImageFile!.readAsBytes();

        img.Image? capturedImage = img.decodeImage(imageBytes);

        if (capturedImage != null) {
          final compressedImageBytes = img.encodeJpg(
            capturedImage,
            quality: 40,
          );
          final compressedFile = File(
            '${capturedImageFile!.parent.path}/marinaVisitorApp${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          await compressedFile.writeAsBytes(compressedImageBytes);
          final uploadedFile = await ApiService().uploadFile(compressedFile);
          // print(uploadedFile);
          capturedImageUrl = uploadedFile?.downloadUrl;
        }
      }

      print(capturedImageUrl);

      final dta = MarinaBayVisitor(
        name: _nameController.text,
        phoneNumber: int.parse(_contactController.text),
        checkInTime: DateTime.now(),
        checkInPhoto: capturedImageUrl,
        unitNo: int.tryParse(_flatNoController.text),
        date: DateTime.now(),
        type: _selectedType,
        purpose: Helper.getTextOrNull(_commentController),
      );

      final newMap = dta.toJson();

      await settingProvider.addMarinaVisitor(newMap);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Visitor added successfully")),
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      // Clear fields
      setState(() {
        _nameController.clear();
        _contactController.clear();
        _commentController.clear();
        _flatNoController.clear();

        capturedImageFile = null;
        capturedImageUrl = null;

        _selectedTimeIn = null;

        _selectedType = "Visitor";
      });
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Marina Bay Visitors'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registration Form',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Text(
                'Fill out building entry credentials below',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFF8FAFC)],
                  ),
                  border: Border.all(color: const Color(0xFFEDF2F7)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.badge_outlined, size: 22),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Contact
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        prefixIcon: Icon(Icons.phone_iphone_outlined, size: 22),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) =>
                          value!.isEmpty ? 'Contact info required' : null,
                    ),

                    const SizedBox(height: 18),

                    // Purpose Dropdown
                    const Text(
                      'Authority',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedType,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: const [
                            DropdownMenuItem(
                              value: 'Visitor',
                              child: Text('Visitor'),
                            ),
                            DropdownMenuItem(
                              value: 'Owner',
                              child: Text('Owner'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                        ),
                      ),
                    ),

                    // Flat No field only for Owner
                    if (_selectedType == 'Owner') ...[
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _flatNoController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: 'Flat No.',
                          prefixIcon: Icon(Icons.apartment_rounded, size: 22),
                        ),
                        validator: (value) {
                          if (_selectedType == 'Owner' &&
                              (value == null || value.isEmpty)) {
                            return 'Flat number required';
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 24),

                    // NEW: Dynamic Biometric Face Verification Field
                    const Text(
                      'Check in photo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: capturePhoto,
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade100,
                        ),
                        child: capturedImageFile == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tap to Capture Photo',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  capturedImageFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Schedule Timings
                    const Text(
                      'Time In',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimePickerField(
                            title: 'Time In',
                            time: _selectedTimeIn,
                            onTap: () => _selectTime(context, true),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Comment
                    TextFormField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        labelText: 'Purpose',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Center(
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSubmit,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(240, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Entry',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerField({
    required String title,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 6),
                Text(
                  time != null ? time.format(context) : '--:--',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCameraBorderColor() {
    if (isError) return Colors.red;
    if (_faceMatched) return Colors.green;
    return Colors.orange;
  }
}

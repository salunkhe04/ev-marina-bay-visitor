import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:marina_bay_cell_building_visitors/model/marinaBayVisitor.dart';
import 'package:marina_bay_cell_building_visitors/providers/settingProvider.dart';
import 'package:marina_bay_cell_building_visitors/services/api_service.dart';
import 'package:provider/provider.dart';

class VisitorFormEditScreen extends StatefulWidget {
  final MarinaBayVisitor visitor;

  const VisitorFormEditScreen({super.key, required this.visitor});

  @override
  State<VisitorFormEditScreen> createState() => _VisitorFormEditScreenState();
}

class _VisitorFormEditScreenState extends State<VisitorFormEditScreen> {
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

  @override
  void initState() {
    super.initState();

    final visitor = widget.visitor;

    _nameController.text = visitor.name ?? '';

    _contactController.text = visitor.phoneNumber?.toString() ?? '';

    _commentController.text = visitor.purpose ?? '';

    _flatNoController.text = visitor.unitNo?.toString() ?? '';

    _selectedType = visitor.type ?? 'Visitor';

    capturedImageUrl = visitor.checkInPhoto;

    if (visitor.checkInTime != null) {
      _selectedTimeIn = TimeOfDay.fromDateTime(visitor.checkInTime!);
    }
  }

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

  Future<void> onUpdate() async {
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
            '${capturedImageFile!.parent.path}/visitor_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );

          await compressedFile.writeAsBytes(compressedImageBytes);

          final uploadedFile = await ApiService().uploadFile(compressedFile);

          capturedImageUrl = uploadedFile?.downloadUrl;
        }
      }

      final updatedVisitor = MarinaBayVisitor(
        // id: widget.visitor.id,
        name: _nameController.text,
        phoneNumber: int.tryParse(_contactController.text),
        checkInPhoto: capturedImageUrl,
        unitNo: int.tryParse(_flatNoController.text),
        purpose: _commentController.text,
        type: _selectedType,
        checkInTime: widget.visitor.checkInTime,
        checkOutTime: widget.visitor.checkOutTime,
        checkOutPhoto: widget.visitor.checkOutPhoto,
        date: widget.visitor.date,
      );

      // await settingProvider.updateMarinaVisitor(
      //   widget.visitor.id!,
      //   updatedVisitor.toJson(),
      // );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Visitor updated successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());
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
        title: const Text('Edit Visitor'),
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
                'Edit Visitor',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFEDF2F7)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      readOnly: true,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _contactController,
                      readOnly: true,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        prefixIcon: Icon(Icons.phone_iphone_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Authority',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedType,
                          isExpanded: true,
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
                          // onChanged: (value) {
                          //   setState(() {
                          //     _selectedType = value!;
                          //   });
                          // },
                          onChanged: null,
                        ),
                      ),
                    ),

                    if (_selectedType == 'Owner') ...[
                      const SizedBox(height: 18),

                      TextFormField(
                        controller: _flatNoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Flat No.',
                          prefixIcon: Icon(Icons.apartment_rounded),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    const Text(
                      'Check-In',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    GestureDetector(
                      // onTap: capturePhoto,
                      onTap: null,
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade100,
                        ),
                        child:
                            capturedImageFile == null &&
                                capturedImageUrl == null
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
                                child: capturedImageFile != null
                                    ? Image.file(
                                        capturedImageFile!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                    : Image.network(
                                        capturedImageUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Schedule Timings',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    InkWell(
                      // onTap: () => _selectTime(context, true),
                      onTap: null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedTimeIn != null
                                  ? _selectedTimeIn!.format(context)
                                  : '--:--',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Check-Out',
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

                    const Text(
                      'Schedule Timings',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    InkWell(
                      // onTap: () => _selectTime(context, true),
                      onTap: null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedTimeIn != null
                                  ? _selectedTimeIn!.format(context)
                                  : '--:--',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      readOnly: true,
                      enabled: false,
                      controller: _commentController,
                      decoration: const InputDecoration(labelText: 'Comment'),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Center(
                child: ElevatedButton(
                  onPressed: isLoading ? null : onUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(240, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
                          'Update Entry',
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

  Color _getCameraBorderColor() {
    if (isError) return Colors.red;

    if (_faceMatched) return Colors.green;

    return Colors.orange;
  }
}

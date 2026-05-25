import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:marina_bay_cell_building_visitors/core/helper/helper.dart';
import 'package:marina_bay_cell_building_visitors/model/marinaBayVisitor.dart';
import 'package:marina_bay_cell_building_visitors/providers/settingProvider.dart';
import 'package:marina_bay_cell_building_visitors/services/api_service.dart';
import 'package:provider/provider.dart';

class VisitorFormEditScreen extends StatefulWidget {
  final MarinaBayVisitor? visitor;

  const VisitorFormEditScreen({super.key, this.visitor});

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

  bool _checkOutPhotoError = false;

  bool _timeOutError = false;

  File? checkOutImageFile;

  String? checkOutImageUrl;

  TimeOfDay? _selectedTimeOut;
  int _numberOfPeople = 1;

  @override
  void initState() {
    super.initState();
    final visitor = widget.visitor;
    _nameController.text = visitor?.name ?? '';
    _contactController.text = visitor?.phoneNumber?.toString() ?? '';
    _commentController.text = visitor?.purpose ?? '';
    _flatNoController.text = visitor?.unitNo?.toString() ?? '';
    _selectedType = visitor?.type ?? 'Visitor';
    capturedImageUrl = visitor?.checkInPhoto;
    _numberOfPeople = int.parse(visitor?.peopleCount.toString() ?? "");
    if (visitor?.checkInTime != null) {
      _selectedTimeIn = TimeOfDay.fromDateTime(visitor!.checkInTime!);
    }
    checkOutImageUrl = visitor?.checkOutPhoto;
    if (visitor?.checkOutTime != null) {
      _selectedTimeOut = TimeOfDay.fromDateTime(visitor!.checkOutTime!);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isTimeIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTimeOut = picked;
        _timeOutError = false;
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
                            checkOutImageFile = File(file.path);
                            _checkOutPhotoError = false;
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
    if (checkOutImageFile == null && checkOutImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Checkout photo is required"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTimeOut == null && widget.visitor?.checkOutTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Time out is required"),
          backgroundColor: Colors.red,
        ),
      );
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

      if (checkOutImageFile != null) {
        final imageBytes = await checkOutImageFile!.readAsBytes();

        img.Image? capturedImage = img.decodeImage(imageBytes);

        if (capturedImage != null) {
          final compressedImageBytes = img.encodeJpg(
            capturedImage,
            quality: 40,
          );

          final compressedFile = File(
            '${checkOutImageFile!.parent.path}/checkout-${DateTime.now().millisecondsSinceEpoch}.jpg',
          );

          await compressedFile.writeAsBytes(compressedImageBytes);

          final uploadedFile = await ApiService().uploadFile(compressedFile);

          checkOutImageUrl = uploadedFile?.downloadUrl;
        }
      }

      DateTime? checkoutDateTime;

      if (_selectedTimeOut != null && widget.visitor?.checkInTime != null) {
        final checkInDate = widget.visitor!.checkInTime!;

        checkoutDateTime = DateTime(
          checkInDate.year,
          checkInDate.month,
          checkInDate.day,
          _selectedTimeOut!.hour,
          _selectedTimeOut!.minute,
        );
      }

      final updatedVisitor = MarinaBayVisitor(
        name: widget?.visitor?.name,
        phoneNumber: widget?.visitor?.phoneNumber,
        type: widget?.visitor?.type,
        purpose: widget?.visitor?.purpose,
        date: widget?.visitor?.date,
        checkInPhoto: widget.visitor?.checkInPhoto,
        checkInTime: widget.visitor?.checkInTime,
        checkOutPhoto: checkOutImageUrl,
        checkOutTime: checkoutDateTime,
        peopleCount: widget?.visitor?.peopleCount,
      );

      await settingProvider.updateVisitor(
        widget.visitor?.id ?? "",
        updatedVisitor.toJson(),
      );

      if (!mounted) return;
      setState(() {
        _checkOutPhotoError =
            checkOutImageFile == null && checkOutImageUrl == null;

        _timeOutError =
            _selectedTimeOut == null && widget.visitor?.checkOutTime == null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Visitor checked out successfully")),
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

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Number of People',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          Row(
                            children: [
                              // IconButton(
                              //   onPressed: () {
                              //     // if (_numberOfPeople > 1) {
                              //     setState(() {
                              //       _numberOfPeople;
                              //     });
                              //     // }
                              //   },
                              //   icon: const Icon(Icons.remove_circle_outline),
                              // ),
                              Text(
                                '$_numberOfPeople',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              // IconButton(
                              //   onPressed: () {
                              //     setState(() {
                              //       _numberOfPeople++;
                              //     });
                              //   },
                              //   icon: const Icon(Icons.add_circle_outline),
                              // ),
                            ],
                          ),
                        ],
                      ),
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
                          border: Border.all(
                            color: _checkOutPhotoError
                                ? Colors.red
                                : Colors.grey.shade300,
                            width: _checkOutPhotoError ? 2 : 1,
                          ),
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
                      'Time In',
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
                          border: Border.all(
                            color: _timeOutError
                                ? Colors.red
                                : const Color(0xFFE2E8F0),
                            width: _timeOutError ? 2 : 1,
                          ),
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
                              Helper.formatDateOnly(
                                widget.visitor?.checkInTime
                                        ?.toIso8601String() ??
                                    "",
                              ),
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
                        child:
                            checkOutImageFile == null &&
                                checkOutImageUrl == null
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
                                child: checkOutImageFile != null
                                    ? Image.file(
                                        checkOutImageFile!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                    : Image.network(
                                        checkOutImageUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      'Time Out',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    InkWell(
                      onTap: () => _selectTime(context, false),
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
                              _selectedTimeOut != null
                                  ? _selectedTimeOut!.format(context)
                                  : Helper.formatDateOnly(
                                      widget.visitor?.checkOutTime
                                              ?.toIso8601String() ??
                                          "",
                                    ),
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

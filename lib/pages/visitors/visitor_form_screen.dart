import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class VisitorFormScreen extends StatefulWidget {
  const VisitorFormScreen({super.key});

  @override
  State<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  String? _attachedFileName;
  TimeOfDay? _selectedTimeIn;
  TimeOfDay? _selectedTimeOut;

  Future<void> _pickPhotoAllowance() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );
    if (result != null) {
      setState(() {
        _attachedFileName = result.files.single.name;
      });
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
        } else {
          _selectedTimeOut = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Marina Bay Visitors')),
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

              // IMPROVISED: Single unified container wrapper with an elegant light gradient
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
                    colors: [
                      Colors.white,
                      Color(
                        0xFFF8FAFC,
                      ), // Fades beautifully into a soft metallic sheen
                    ],
                  ),
                  border: Border.all(color: const Color(0xFFEDF2F7)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field 1: Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.badge_outlined, size: 22),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Name required' : null,
                    ),
                    const SizedBox(height: 18),

                    // Field 2: Contact
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        prefixIcon: Icon(Icons.phone_iphone_outlined, size: 22),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) =>
                          value!.isEmpty ? 'Contact info required' : null,
                    ),
                    const SizedBox(height: 18),

                    // Field 3: Photo Document Component Link
                    const Text(
                      'Verification Documents',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickPhotoAllowance,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add_a_photo_outlined,
                              color: Color(0xFF2563EB),
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Photo Allowance Attachment',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _attachedFileName ??
                                        'Tap to select system image source',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _attachedFileName != null
                                          ? Colors.green.shade700
                                          : const Color(0xFF94A3B8),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Field 4 & 5: Unified Time Range
                    const Text(
                      'Schedule Timings',
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimePickerField(
                            title: 'Time Out',
                            time: _selectedTimeOut,
                            onTap: () => _selectTime(context, false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Field 6: Purpose Paragraph Area
                    TextFormField(
                      controller: _purposeController,
                      decoration: const InputDecoration(
                        labelText: 'Purpose of Visit',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      validator: (value) =>
                          value!.isEmpty ? 'Purpose statement required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Submit Layout Row
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Visitor registration complete'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(240, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit Entry',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}

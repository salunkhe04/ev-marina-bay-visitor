import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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

  TimeOfDay? _selectedTimeIn;
  String _selectedPurpose = 'Visitor';

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
                      validator: (value) =>
                          value!.isEmpty ? 'Name required' : null,
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) =>
                          value!.isEmpty ? 'Contact info required' : null,
                    ),

                    const SizedBox(height: 18),

                    // Purpose Dropdown
                    const Text(
                      'Purpose',
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
                          value: _selectedPurpose,
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
                              _selectedPurpose = value!;
                            });
                          },
                        ),
                      ),
                    ),

                    // Flat No field only for Owner
                    if (_selectedPurpose == 'Owner') ...[
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _flatNoController,
                        decoration: const InputDecoration(
                          labelText: 'Flat No.',
                          prefixIcon: Icon(Icons.apartment_rounded, size: 22),
                        ),
                        validator: (value) {
                          if (_selectedPurpose == 'Owner' &&
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
                      'Security Verification',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Consumer2<AttendanceProvider, GeolocationProvider>(
                    //   builder: (context, attendanceProvider, geolocationProvider, child) {
                    //     final bool isCheckedIn =
                    //         attendanceProvider.attendance?.checkInTime != null;
                    //     final bool isCheckedOut =
                    //         attendanceProvider.attendance?.checkOutTime != null;

                    //     String cardTitle = "Biometric Verification";
                    //     String actionButtonText = "Punch IN";
                    //     Color statusColor = const Color(
                    //       0xFF2563EB,
                    //     ); // Premium Blue
                    //     IconData statusIcon = Icons.fingerprint_rounded;

                    //     if (isCheckedIn && !isCheckedOut) {
                    //       cardTitle = "Active Session: Clocked In";
                    //       actionButtonText = "Punch OUT";
                    //       statusColor = const Color(
                    //         0xFF10B981,
                    //       ); // Emerald Green
                    //       statusIcon = Icons.gpp_good_rounded;
                    //     } else if (isCheckedOut) {
                    //       cardTitle = "Verification Completed";
                    //       actionButtonText = "Completed";
                    //       statusColor = const Color(0xFF64748B); // Slate Gray
                    //       statusIcon = Icons.lock_clock_rounded;
                    //     }

                    //     return Container(
                    //       width: double.infinity,
                    //       padding: const EdgeInsets.all(14),
                    //       decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         borderRadius: BorderRadius.circular(16),
                    //         border: Border.all(color: const Color(0xFFE2E8F0)),
                    //         backgroundColor: const Color(0xFFF8FAFC),
                    //       ),
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Row(
                    //             children: [
                    //               Container(
                    //                 padding: const EdgeInsets.all(8),
                    //                 decoration: BoxDecoration(
                    //                   color: statusColor.withOpacity(0.1),
                    //                   shape: BoxShape.circle,
                    //                 ),
                    //                 child: Icon(
                    //                   statusIcon,
                    //                   color: statusColor,
                    //                   size: 20,
                    //                 ),
                    //               ),
                    //               const SizedBox(width: 12),
                    //               Expanded(
                    //                 child: Column(
                    //                   crossAxisAlignment:
                    //                       CrossAxisAlignment.start,
                    //                   children: [
                    //                     Text(
                    //                       cardTitle,
                    //                       style: const TextStyle(
                    //                         fontSize: 14,
                    //                         fontWeight: FontWeight.bold,
                    //                         color: Color(0xFF1E293B),
                    //                       ),
                    //                     ),
                    //                     const SizedBox(height: 1),
                    //                     Text(
                    //                       geolocationProvider.isWithinRadius
                    //                           ? "Inside verified parameter boundaries"
                    //                           : "Checking operational parameters...",
                    //                       style: TextStyle(
                    //                         fontSize: 11,
                    //                         color:
                    //                             geolocationProvider
                    //                                 .isWithinRadius
                    //                             ? const Color(0xFF64748B)
                    //                             : const Color(0xFF64748B),
                    //                       ),
                    //                     ),
                    //                   ],
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //           const SizedBox(height: 12),
                    //           SizedBox(
                    //             width: double.infinity,
                    //             height: 44,
                    //             child: ElevatedButton(
                    //               onPressed: isCheckedOut
                    //                   ? null
                    //                   : () {
                    //                       final String type = isCheckedIn
                    //                           ? "OUT"
                    //                           : "IN";
                    //                       // final settingProvider =
                    //                       //     Provider.of<SettingProvider>(
                    //                       //       context,
                    //                       //       listen: false,
                    //                       //     );

                    //                       Navigator.of(context).push(
                    //                         MaterialPageRoute(
                    //                           builder: (context) =>
                    //                               TimeInOutScreenFaceRecog(
                    //                                 type: type,
                    //                                 id: settingProvider
                    //                                     .loggedAdmin
                    //                                     ?.id,
                    //                               ),
                    //                         ),
                    //                       );
                    //                     },
                    //               style: ElevatedButton.styleFrom(
                    //                 backgroundColor: isCheckedIn
                    //                     ? const Color(0xFFEF4444)
                    //                     : const Color(0xFF2563EB),
                    //                 foregroundColor: Colors.white,
                    //                 elevation: 0,
                    //                 disabledBackgroundColor: const Color(
                    //                   0xFFE2E8F0,
                    //                 ),
                    //                 shape: RoundedRectangleBorder(
                    //                   borderRadius: BorderRadius.circular(10),
                    //                 ),
                    //               ),
                    //               child: Text(
                    //                 actionButtonText,
                    //                 style: const TextStyle(
                    //                   fontSize: 13,
                    //                   fontWeight: FontWeight.bold,
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     );
                    //   },
                    // ),
                    const SizedBox(height: 18),

                    // Schedule Timings
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
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Comment
                    TextFormField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        labelText: 'Comment',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      validator: (value) =>
                          value!.isEmpty ? 'Comment required' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

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

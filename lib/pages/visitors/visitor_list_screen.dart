import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_month_year_picker/simple_month_year_picker.dart';

class VisitorListScreen extends StatelessWidget {
  const VisitorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const VisitorListScreenMobile();
  }
}

class VisitorListScreenMobile extends StatefulWidget {
  const VisitorListScreenMobile({super.key});

  @override
  State<VisitorListScreenMobile> createState() =>
      _VisitorListScreenMobileState();
}

class _VisitorListScreenMobileState extends State<VisitorListScreenMobile> {
  String searchQuery = '';
  DateTime selectedDate = DateTime.now();

  /// Dummy Data
  final List<Map<String, dynamic>> dummyAttendance = [
    {
      "date": "20 May 2026",
      "checkInTime": "11:46:30",
      "checkOutTime": "NA",
      "checkInAddress": "JN2-57/B, Navi Mumbai",
      "checkOutAddress": "NA",
      "status": "present",
      "checkInPhoto": "https://i.pravatar.cc/300?img=12",
      "checkOutPhoto": "",
    },
    {
      "date": "19 May 2026",
      "checkInTime": "NA",
      "checkOutTime": "NA",
      "checkInAddress": "NA",
      "checkOutAddress": "NA",
      "status": "absent",
      "checkInPhoto": "",
      "checkOutPhoto": "",
    },
    {
      "date": "18 May 2026",
      "checkInTime": "11:23:56",
      "checkOutTime": "15:33:15",
      "checkInAddress": "JN/3-38, Navi Mumbai",
      "checkOutAddress": "JN2-57/B, Navi Mumbai",
      "status": "present",
      "checkInPhoto": "https://i.pravatar.cc/300?img=15",
      "checkOutPhoto": "https://i.pravatar.cc/300?img=16",
    },
    {
      "date": "17 May 2026",
      "checkInTime": "NA",
      "checkOutTime": "NA",
      "checkInAddress": "NA",
      "checkOutAddress": "NA",
      "status": "absent",
      "checkInPhoto": "",
      "checkOutPhoto": "",
    },
  ];

  Future<void> _selectDate(BuildContext context) async {
    final picked = await SimpleMonthYearPicker.showMonthYearPickerDialog(
      context: context,
      selectionColor: const Color(0xFF1565C0), // BLUE
      // buttonsColor: const Color(0xFF1565C0),
      titleTextStyle: const TextStyle(
        color: Color(0xFF1565C0),
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      monthTextStyle: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      yearTextStyle: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: Colors.white,
      disableFuture: true,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAttendance = dummyAttendance.where((employee) {
      final status = employee["status"].toString().toLowerCase();
      final search = searchQuery.toLowerCase();

      return status.contains(search);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1565C0)),
        title: const Text(
          'Attendance List',
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 18),

          /// Date Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.grey,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 12),

                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Text(
                    DateFormat("MMMM yyyy").format(selectedDate),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Spacer(),

                const Icon(Icons.history, color: Colors.grey, size: 32),
              ],
            ),
          ),

          const SizedBox(height: 14),

          /// Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SizedBox(
              height: 48,
              child: TextField(
                onChanged: (query) {
                  setState(() {
                    searchQuery = query;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search Status',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF1565C0),
                    size: 24,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// Empty State
          if (filteredAttendance.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assignment_ind_outlined,
                        size: 48,
                        color: Colors.blueGrey.shade300,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'No Active Visitors',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'New check-ins will display here',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            )
          /// List
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredAttendance.length,
                itemBuilder: (context, index) {
                  final attendee = filteredAttendance[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// LEFT
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  attendee["date"],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                infoTile("Time In", attendee["checkInAddress"]),

                                const SizedBox(height: 8),

                                infoTile(
                                  "Time Out",
                                  attendee["checkOutAddress"],
                                ),

                                const SizedBox(height: 10),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: attendee["status"] == "absent"
                                        ? Colors.red.shade50
                                        : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    attendee["status"].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: attendee["status"] == "absent"
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          /// CHECK IN
                          Column(
                            children: [
                              Text(
                                attendee["checkInTime"],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 8),

                              photoWidget(attendee["checkInPhoto"]),
                            ],
                          ),

                          const SizedBox(width: 10),

                          /// CHECK OUT
                          Column(
                            children: [
                              Text(
                                attendee["checkOutTime"],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 8),

                              photoWidget(attendee["checkOutPhoto"]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget infoTile(String heading, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget photoWidget(String image) {
    final bool hasImage = image.toString().isNotEmpty;

    return GestureDetector(
      onTap: hasImage
          ? () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: InteractiveViewer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(image),
                      ),
                    ),
                  );
                },
              );
            }
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: hasImage
            ? Image.network(image, width: 54, height: 70, fit: BoxFit.cover)
            : Container(
                width: 54,
                height: 70,
                color: Colors.grey.shade100,
                child: Icon(
                  Icons.person,
                  color: Colors.grey.shade400,
                  size: 34,
                ),
              ),
      ),
    );
  }
}

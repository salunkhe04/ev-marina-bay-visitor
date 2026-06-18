import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marina_bay_cell_building_visitors/core/helper/helper.dart';
import 'package:marina_bay_cell_building_visitors/model/marinaBayVisitor.dart';
import 'package:marina_bay_cell_building_visitors/pages/visitors/visitor_form_edit_screen.dart';
import 'package:provider/provider.dart';
import 'package:simple_month_year_picker/simple_month_year_picker.dart';

import '../../providers/settingProvider.dart';

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
  bool isLoading = false;

  DateTime selectedDate = DateTime.now();

  Future<void> onRefresh() async {
    try {
      final settingProvider = Provider.of<SettingProvider>(
        context,
        listen: false,
      );

      setState(() {
        isLoading = true;
      });

      await settingProvider.getMarinaBayVisitor("Marina Bay");
    } catch (e) {
      // Handle exception cleanly
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await SimpleMonthYearPicker.showMonthYearPickerDialog(
      context: context,
      selectionColor: const Color(0xFF1565C0),
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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingProvider = Provider.of<SettingProvider>(context);

    // UPDATED: Filter sequence parsing text queries and project selections concurrently
    final List<MarinaBayVisitor> filteredAttendance = settingProvider.visitors
        .where((visitor) {
          final name = visitor.name?.toLowerCase() ?? '';
          final purpose = visitor.purpose?.toLowerCase() ?? '';
          final search = searchQuery.toLowerCase();

          // Match the text search first
          final matchesSearch =
              name.contains(search) || purpose.contains(search);

          return matchesSearch;
        })
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1565C0)),
        title: const Text(
          'Visitor List',
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1565C0)),
            onPressed: () {
              onRefresh(); // Example
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: Column(
          children: [
            const SizedBox(height: 18),

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
                    hintText: 'Search Visitor',
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

            const SizedBox(height: 12),

            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (filteredAttendance.isEmpty)
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
                        'No Matching Visitors',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: filteredAttendance.length,
                  itemBuilder: (context, index) {
                    final MarinaBayVisitor attendee = filteredAttendance[index];

                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                VisitorFormEditScreen(visitor: attendee),
                          ),
                        );

                        onRefresh();
                      },
                      child: Container(
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            attendee.name ?? "Unknown Visitor",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1565C0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Project: ${attendee.project ?? 'N/A'}",
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1565C0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),

                                    Text(
                                      Helper.formatDate(
                                        attendee.checkInTime != null
                                            ? attendee.checkInTime
                                                      ?.toIso8601String() ??
                                                  ""
                                            : "NA",
                                      ),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    infoTile(
                                      "No of People",
                                      attendee.peopleCount.toString(),
                                    ),

                                    const SizedBox(height: 10),

                                    infoTile(
                                      "Purpose",
                                      attendee.purpose ?? "No Purpose",
                                    ),

                                    const SizedBox(height: 8),

                                    if (attendee.unitNo != null) ...[
                                      infoTile(
                                        "Unit / Wing",
                                        "${attendee.unitNo}${attendee.wing != null ? ' - ${attendee.wing}' : ''}",
                                      ),
                                    ],

                                    const SizedBox(height: 10),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: attendee.checkOutTime == null
                                            ? Colors.green.shade50
                                            : Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        attendee.checkOutTime == null
                                            ? "CHECKED IN"
                                            : "CHECKED OUT",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: attendee.checkOutTime == null
                                              ? Colors.green
                                              : Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),

                              /// CHECK IN IMAGE TARGET
                              Column(
                                children: [
                                  Text(
                                    Helper.formatTimeOnly(
                                      attendee.checkInTime != null
                                          ? attendee.checkInTime
                                                    ?.toIso8601String() ??
                                                ""
                                          : "NA",
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  photoWidget(attendee.checkInPhoto ?? ""),
                                ],
                              ),

                              const SizedBox(width: 10),

                              /// CHECK OUT IMAGE TARGET
                              Column(
                                children: [
                                  Text(
                                    Helper.formatTimeOnly(
                                      attendee.checkOutTime != null
                                          ? attendee.checkOutTime
                                                    ?.toIso8601String() ??
                                                ""
                                          : "NA",
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  photoWidget(attendee.checkOutPhoto ?? ""),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
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

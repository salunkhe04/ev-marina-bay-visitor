import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marina_bay_cell_building_visitors/main.dart';

class Helper {
  static void showCustomSnackBar(
    String message, [
    Color bgColor = Colors.red,
    Color textColor = Colors.white,
  ]) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: textColor)),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      backgroundColor: bgColor,
    );

    if (scaffoldMessengerKey.currentState != null) {
      // Show SnackBar if ScaffoldMessenger is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scaffoldMessengerKey.currentState?.clearSnackBars();
        scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
      });
    } else {
      // Show fallback dialog if no Scaffold is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorKey.currentContext != null) {
          showDialog(
            context: navigatorKey.currentContext!,
            builder: (context) {
              return AlertDialog(
                backgroundColor: bgColor,
                content: Text(message, style: TextStyle(color: textColor)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK', style: TextStyle(color: textColor)),
                  ),
                ],
              );
            },
          );
        } else {
          // print("no context avail");
          // Log or handle the case where neither context is available
        }
      });
    }
  }

  static String? getTextOrNull(TextEditingController controller) {
    final text = controller.text.trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  static String formatDateOnly(String dateString) {
    // List of possible date formats
    final List<String> formats = [
      'dd MMM yyyy',
      'yyyy-MM-dd',
      'yyyy-MM-dd hh:mm',
      'dd MMMM yyyy',
      'dd/MM/yyyy',
      // Include ISO 8601 format
      'yyyy-MM-ddTHH:mm:ss.SSSZ', // ISO format with timezone
      'yyyy-MM-ddTHH:mm:ss.SSSZ', // ISO format with Z
    ];

    for (String format in formats) {
      try {
        // Parse the date string
        final DateFormat dateFormat = DateFormat(format);

        // Check for ISO 8601 format separately
        DateTime dateTime;
        if (format == 'yyyy-MM-ddTHH:mm:ss.SSSZ' ||
            format == 'yyyy-MM-ddTHH:mm:ss.SSSZ') {
          dateTime = DateTime.parse(dateString); // Parse ISO format
        } else {
          dateTime = dateFormat.parseStrict(dateString);
        }
        dateTime = dateTime.toLocal();

        // Define the desired output format
        final DateFormat outputFormatter = DateFormat('d MMMM yyyy HH:mm');

        // Format the DateTime object into the desired string format
        return outputFormatter.format(dateTime);
      } catch (e) {
        // Continue to the next format if parsing fails
        continue;
      }
    }

    // If no format matched, return "NA"
    return "NA";
  }
}

import 'package:flutter/material.dart';
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
}

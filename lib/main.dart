import 'package:flutter/material.dart';
import 'package:marina_bay_cell_building_visitors/features/visitors/video_splash_screen.dart';

void main() {
  runApp(const MarinaBayVisitorApp());
}

class MarinaBayVisitorApp extends StatelessWidget {
  const MarinaBayVisitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marina Bay Visitors',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          primary: const Color(0xFF2563EB),
          background: const Color(0xFFF8FAFC),
        ),
      ),
      // App kicks off here, loads video, then navigates to Home Wrapper automatically
      home: const VisitorSplashScreen(),
    );
  }
}

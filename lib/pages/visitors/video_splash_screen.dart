import 'package:flutter/material.dart';

import 'dart:async';

import 'package:marina_bay_cell_building_visitors/main.dart';

import 'dart:async';

import 'package:marina_bay_cell_building_visitors/navigation_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup fade-in animation for a premium feel
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NavigationWrapper()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // MODIFICATION 1: Set the Scaffold background color directly to white
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Content Layer
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40), // Top spacing
                  // Center Branding Block
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/logo.png', // Main 10 Marina Bay Logo
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'RESIDENT PORTAL',
                        style: TextStyle(
                          // Gold text still looks stunning and sharp against pure white
                          color: const Color(0xFFD4AF37),
                          fontSize: 22,
                          fontWeight: FontWeight
                              .w500, // Slightly bumped weight for white background crispness
                          letterSpacing: 4.0,
                        ),
                      ),
                    ],
                  ),

                  // Footer Branding Block
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 20.0,
                      left: 40.0,
                      right: 40.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 1.5,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.amber,
                                Colors.purple,
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.4, 0.6, 1.0],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Image.asset(
                          'assets/ev_logo.webp', // EV Homes logo at the bottom
                          height: 32,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

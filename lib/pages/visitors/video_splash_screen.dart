import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../navigation_wrapper.dart';

class VisitorSplashScreen extends StatefulWidget {
  const VisitorSplashScreen({super.key});

  @override
  State<VisitorSplashScreen> createState() => _VisitorSplashScreenState();
}

class _VisitorSplashScreenState extends State<VisitorSplashScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize your video file stream
    _videoController = VideoPlayerController.asset("assets/video/home_bg.mp4")
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
        _videoController.setLooping(false); // Play once
        _videoController.play();

        // Listen for the exact moment the video ends
        _videoController.addListener(_videoListener);
      });
  }

  void _videoListener() {
    // If the video reaches the final millisecond, transition forward
    if (_videoController.value.position >= _videoController.value.duration) {
      _videoController.removeListener(_videoListener);
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (mounted) {
      // Replaces the splash screen on the stack so users can't press "back" into it
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NavigationWrapper()),
      );
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_videoListener);
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF0F172A,
      ), // Premium dark background while loading
      body: Stack(
        fit: StackFit.expand,
        children: [
          _isVideoInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                ),

          // Clean text overlay at the center top
          const Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'MARINA BAY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // IMPORTANT: Needed for SystemNavigator.pop()
import 'package:marina_bay_cell_building_visitors/pages/visitors/profile_screen.dart';
import 'package:marina_bay_cell_building_visitors/pages/visitors/visitor_form_screen.dart';
import 'package:marina_bay_cell_building_visitors/pages/visitors/visitor_list_screen.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    VisitorListScreen(),
    VisitorFormScreen(),
    ProfileScreen(),
  ];

  /// Function to show a modern, beautiful exit confirmation dialog
  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent, 
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wraps content perfectly
            children: [
              // Icon Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF), // Very light blue background
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFF2563EB), // Matches your primary blue
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Exit Application?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B), // Slate 800
                ),
              ),
              const SizedBox(height: 12),
              
              // Description
              const Text(
                'Are you sure you want to leave? ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B), // Slate 500
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              
              // Side-by-side Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE2E8F0)), // Light border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Exit Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB), // Primary Blue
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Exit App',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ?? false; 
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isShortScreen = mediaQuery.size.height < 650;

    /// Wrap Scaffold with PopScope to intercept the device back button
    return PopScope(
      canPop: false, // Prevents the default pop action
      onPopInvoked: (bool didPop) async {
        if (didPop) return;

        // Show the dialog and wait for the user's choice
        final bool shouldExit = await _showExitDialog(context);
        
        if (shouldExit) {
          // Closes the application completely
          SystemNavigator.pop(); 
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5F7),

        /// IMPORTANT FIX
        resizeToAvoidBottomInset: true,

        body: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: IndexedStack(index: _currentIndex, children: _screens),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        floatingActionButton: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isShortScreen ? 56 : 64,
          width: isShortScreen ? 56 : 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x4D2563EB),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            heroTag: "fab",
            onPressed: () {
              setState(() {
                _currentIndex = 1;
              });
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            shape: const CircleBorder(),
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: isShortScreen ? 28 : 32,
            ),
          ),
        ),

        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomAppBar(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              elevation: 0,
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: isShortScreen ? 58 : 66,
                child: Row(
                  children: [
                    /// PROFILE
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _currentIndex = 2;
                          });
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              color: _currentIndex == 2
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF94A3B8),
                              size: isShortScreen ? 22 : 24,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _currentIndex == 2
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// FAB SPACE
                    SizedBox(width: isShortScreen ? 60 : 72),

                    /// LIST
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _currentIndex = 0;
                          });
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              color: _currentIndex == 0
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF94A3B8),
                              size: isShortScreen ? 22 : 24,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'List',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _currentIndex == 0
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
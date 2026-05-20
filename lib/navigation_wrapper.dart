import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final isShortScreen = mediaQuery.size.height < 650;

    return Scaffold(
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  VisitorFormScreen(), 
  VisitorListScreen(), 
];

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout_rounded, color: Color(0xFF2563EB), size: 32),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Exit Application?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Are you sure you want to leave?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Exit App',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        final bool shouldExit = await _showExitDialog(context);
        if (shouldExit) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5F7),
        resizeToAvoidBottomInset: true,
        body: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: IndexedStack(index: _currentIndex, children: _screens),
        ),
        bottomNavigationBar: _ElegantBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}

class _ElegantBottomNav extends StatelessWidget {
  const _ElegantBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

static const _items = [
  (icon: Icons.edit_document, label: 'Form'), 
  (icon: Icons.receipt_long_rounded, label: 'List'),
];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final isSelected = currentIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated pill indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEFF6FF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        item.icon,
                        size: 22,
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF94A3B8),
                      ),
                      child: Text(item.label),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
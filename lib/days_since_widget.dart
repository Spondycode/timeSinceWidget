import 'dart:async';
import 'dart:ui'; // Required for ImageFilter (frosted glass blur effect)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'date_counter.dart';

/// An ultra-compact, premium floating widget that displays the weeks and days
/// since a user-configured start date. On hover, a settings gear appears.
class DaysSinceWidget extends StatefulWidget {
  const DaysSinceWidget({Key? key}) : super(key: key);

  @override
  State<DaysSinceWidget> createState() => _DaysSinceWidgetState();
}

class _DaysSinceWidgetState extends State<DaysSinceWidget> {
  DateTime _startDate = DateTime(2024, 1, 1); // Default fallback
  DateTime _currentDate = DateTime.now();
  Timer? _updateTimer;
  bool _isHovered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedDate();

    // Periodic timer to refresh values every 60 minutes
    _updateTimer = Timer.periodic(const Duration(minutes: 60), (timer) {
      if (mounted) {
        setState(() {
          _currentDate = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  // Load date from SharedPreferences
  Future<void> _loadSavedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getString('start_date');
    if (savedTime != null) {
      final parsed = DateTime.tryParse(savedTime);
      if (parsed != null) {
        setState(() {
          _startDate = parsed;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Save date to SharedPreferences
  Future<void> _saveDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('start_date', date.toIso8601String());
    setState(() {
      _startDate = date;
    });
  }

  // Show premium date picker dialog with dynamic window resizing
  Future<void> _selectStartDate() async {
    // Get current window bounds to restore later
    final originalSize = await windowManager.getSize();
    final originalPosition = await windowManager.getPosition();
    
    // Target size for date picker
    final targetSize = const Size(380, 520);
    
    // Shift position left and up to keep the widget's corner anchored on screen
    final double dx = targetSize.width - originalSize.width;
    final double dy = targetSize.height - originalSize.height;
    
    final newPosition = Offset(originalPosition.dx - dx, originalPosition.dy - dy);

    // Expand window first to accommodate the full date picker dialog
    await windowManager.setBounds(
      Rect.fromLTWH(newPosition.dx, newPosition.dy, targetSize.width, targetSize.height),
    );

    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _startDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2036),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.cyanAccent,
                onPrimary: Colors.black,
                surface: Color(0xFF1E1E2C),
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: const Color(0xFF1E1E2C),
            ),
            child: child!,
          );
        },
      );
      if (picked != null && picked != _startDate) {
        await _saveDate(picked);
      }
    } finally {
      // Shrink window back to original size and position
      await windowManager.setBounds(
        Rect.fromLTWH(originalPosition.dx, originalPosition.dy, originalSize.width, originalSize.height),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
          ),
        ),
      );
    }

    final diff = DateCounter.differenceInWeeksAndDays(_startDate, _currentDate);
    final weeks = diff['weeks'] ?? 0;
    final days = diff['days'] ?? 0;

    final weekLabel = weeks == 1 ? "wk" : "wks";
    final dayLabel = days == 1 ? "day" : "days";
    final displayText = "$weeks $weekLabel, $days $dayLabel";

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0), // Frosted glass blur effect
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: const Color(0xAA1E1E2C), // Translucent backing (Y)
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subtle calendar indicator icon
                  Icon(
                    Icons.event_note_rounded,
                    color: Colors.cyanAccent.withOpacity(0.8),
                    size: 12,
                  ),
                  const SizedBox(width: 6),
                  
                  // Prominent but compact countdown text
                  Text(
                    displayText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                  
                  // Smoothly animated/revealed settings button on hover
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: _isHovered
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: _selectStartDate,
                                child: Icon(
                                  Icons.settings_rounded,
                                  color: Colors.white.withOpacity(0.6),
                                  size: 12,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
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

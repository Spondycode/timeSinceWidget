import 'dart:async';
import 'package:flutter/material';
import 'date_counter.dart';

/// A premium, stateful Flutter widget that displays the time elapsed since a fixed start date.
/// It automatically updates every 60 minutes using a periodic timer.
class DaysSinceWidget extends StatefulWidget {
  /// The fixed start date to count from. Defaults to January 1, 2024.
  final DateTime startDate;

  const DaysSinceWidget({
    Key? key,
    DateTime? startDate,
  })  : this.startDate = startDate ?? const _DefaultDate(),
        super(key: key);

  @override
  State<DaysSinceWidget> createState() => _DaysSinceWidgetState();
}

/// Constant fallback for default constructor value
class _DefaultDate extends DateTime {
  const _DefaultDate() : super(2024, 1, 1);
}

class _DaysSinceWidgetState extends State<DaysSinceWidget> with SingleTickerProviderStateMixin {
  late DateTime _currentDate;
  Timer? _updateTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    
    // Animation for rich entrance transition
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

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
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diff = DateCounter.differenceInWeeksAndDays(widget.startDate, _currentDate);
    final weeks = diff['weeks'] ?? 0;
    final days = diff['days'] ?? 0;

    // Formatting string for start date
    final startFormatted = "${widget.startDate.year}-${widget.startDate.month.toString().padLeft(2, '0')}-${widget.startDate.day.toString().padLeft(2, '0')}";

    // Theme values (harmonious dark theme or container overlay)
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28.0),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1E2C), Color(0xFF2C2C3E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
                ),
                child: const Text(
                  'TIME SINCE START',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Main Counter display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$weeks',
                    style: const TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'w',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$days',
                    style: const TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'd',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Text(
                '${weeks == 1 ? "1 Week" : "$weeks Weeks"} and ${days == 1 ? "1 Day" : "$days Days"}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Divider
              Divider(
                color: Colors.white.withOpacity(0.1),
                thickness: 1,
              ),
              const SizedBox(height: 16),

              // Info Section showing the Start Date and Last Checked Date
              _buildInfoRow(
                label: 'Counting From',
                value: startFormatted,
                icon: Icons.calendar_today_rounded,
                color: Colors.amberAccent,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                label: 'Last Synced',
                value: "${_currentDate.hour.toString().padLeft(2, '0')}:${_currentDate.minute.toString().padLeft(2, '0')}",
                icon: Icons.sync_rounded,
                color: Colors.greenAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color.withOpacity(0.8)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Courier', // monospaced style for values
          ),
        ),
      ],
    );
  }
}

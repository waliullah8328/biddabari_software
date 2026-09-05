import 'dart:async';
import 'package:flutter/material.dart';

/// Live, ticking "offer ends in HH:MM:SS" chip. Updates every second and
/// hides itself once the offer expires. Shared by the course card and the
/// course details page so both always show the exact same countdown.
class OfferCountdownChip extends StatefulWidget {
  final DateTime endTime;
  const OfferCountdownChip({super.key, required this.endTime});

  @override
  State<OfferCountdownChip> createState() => _OfferCountdownChipState();
}

class _OfferCountdownChipState extends State<OfferCountdownChip> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.endTime.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = widget.endTime.difference(DateTime.now());
      if (next.isNegative) {
        _timer?.cancel();
        if (mounted) setState(() => _remaining = Duration.zero);
        return;
      }
      if (mounted) setState(() => _remaining = next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    if (d <= Duration.zero) return 'Offer ended';
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    if (days > 0) {
      return '${days}d ${two(hours)}:${two(minutes)}:${two(seconds)}';
    }
    return '${two(hours)}:${two(minutes)}:${two(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining <= Duration.zero) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department,
              size: 14, color: Colors.orangeAccent),
          const SizedBox(width: 4),
          Text(
            _format(_remaining),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
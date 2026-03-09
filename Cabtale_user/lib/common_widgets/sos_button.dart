import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSButton extends StatefulWidget {
  const SOSButton({super.key});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> {
  bool _counting = false;
  int _seconds = 5;
  Timer? _timer;

  void _startCountdown() {
    setState(() {
      _counting = true;
      _seconds = 5;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 1) {
        setState(() {
          _seconds--;
        });
      } else {
        _makeEmergencyCall();
        _stopCountdown();
      }
    });
  }

  void _stopCountdown() {
    _timer?.cancel();
    setState(() {
      _counting = false;
    });
  }

  Future<void> _makeEmergencyCall() async {
    const phoneNumber = 'tel:911'; // Canada police
    if (await canLaunchUrl(Uri.parse(phoneNumber))) {
      await launchUrl(Uri.parse(phoneNumber));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch dialer')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _counting
        ? Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Calling in $_seconds',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.white),
            onPressed: _stopCountdown,
          ),
        ],
      ),
    )
        : ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      icon: const Icon(Icons.warning, color: Colors.white),
      label: const Text("SOS", style: TextStyle(color: Colors.white)),
      onPressed: _startCountdown,
    );
  }
}

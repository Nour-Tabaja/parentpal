import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart';

class SleepPage extends StatefulWidget {
  final int babyId;
  const SleepPage(this.babyId, {super.key});
  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  int? _sessionId;
  bool _running = false;
  DateTime? _startTime;
  DateTime? _endTime;

  final _notes = TextEditingController();

  Uri _uri(String p) => buildUri(p);

  Future<void> _start() async {
    final url = _uri('startSleep.php');
    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (Globals.token != null) 'Authorization': 'Bearer ${Globals.token}',
      },
      body: jsonEncode({'baby_id': widget.babyId}),
    );

    debugPrint('startSleep status: ${res.statusCode}');
    debugPrint('startSleep body: ${res.body}');

    if (res.statusCode == 200) {
      final j = jsonDecode(res.body);
      if (j['success'] == true) {
        setState(() {
          _sessionId = j['session_id'];
          _running = true;
          _startTime = DateTime.parse(j['started_at']);
          _endTime = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(j['message'] ?? 'Failed to start')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server error: ${res.statusCode}')));
    }
  }

  /// Stop a running session. Returns true if stop succeeded.
  Future<bool> _stop({DateTime? endedAt}) async {
    if (_sessionId == null) return false;
    final url = _uri('stopSleep.php');
    final ended = (endedAt ?? DateTime.now());
    final endedStr = ended.toIso8601String().replaceFirst('T', ' ').split('.').first;

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (Globals.token != null) 'Authorization': 'Bearer ${Globals.token}',
      },
      body: jsonEncode({
        'session_id': _sessionId,
        'ended_at': endedStr,
        'notes': _notes.text,
      }),
    );

    debugPrint('stopSleep status: ${res.statusCode}');
    debugPrint('stopSleep body: ${res.body}');

    if (res.statusCode == 200) {
      final j = jsonDecode(res.body);
      if (j['success'] == true) {
        setState(() {
          _running = false;
          _startTime = null;
          _endTime = ended;
          _sessionId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sleep saved')));
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(j['message'] ?? 'Failed to stop')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server error: ${res.statusCode}')));
    }
    return false;
  }

  /// Save manual sleep:
  /// - If a session is running, stop it now.
  /// - If no session is running, create a short manual session (start then stop).
  Future<void> _saveManual() async {
    if (Globals.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not authenticated')));
      return;
    }

    // If there's a running session, end it now
    if (_sessionId != null) {
      debugPrint('Saving manual: stopping existing session $_sessionId');
      final stopped = await _stop(endedAt: DateTime.now());
      if (stopped) {
        Navigator.of(context).pop(true); // notify caller to refresh logs
      }
      return;
    }

    // No running session: create a manual session (start then stop)
    final now = DateTime.now();
    final defaultDuration = const Duration(hours: 1);
    final start = now.subtract(defaultDuration);
    final end = now;

    // Start a session (source manual) and provide started_at so server records correct start
    final startUrl = _uri('startSleep.php');
    final startRes = await http.post(
      startUrl,
      headers: {
        'Content-Type': 'application/json',
        if (Globals.token != null) 'Authorization': 'Bearer ${Globals.token}',
      },
      body: jsonEncode({
        'baby_id': widget.babyId,
        'source': 'manual',
        'started_at': start.toIso8601String().replaceFirst('T', ' ').split('.').first
      }),
    );

    debugPrint('manual start status: ${startRes.statusCode}');
    debugPrint('manual start body: ${startRes.body}');

    if (startRes.statusCode == 200) {
      final j = jsonDecode(startRes.body);
      if (j['success'] == true) {
        setState(() {
          _sessionId = j['session_id'];
          _running = true;
          _startTime = DateTime.parse(j['started_at']);
        });

        final stopped = await _stop(endedAt: end);
        if (stopped) {
          Navigator.of(context).pop(true); // notify caller to refresh logs
        }
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(j['message'] ?? 'Failed to create manual session')));
        return;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server error: ${startRes.statusCode}')));
      return;
    }
  }

  @override
Widget build(BuildContext context) {
  final runningText = _running
      ? (_startTime != null ? 'Running since ${_startTime.toString()}' : 'Running')
      : (_startTime != null && _endTime != null
          ? 'From ${_startTime.toString()} to ${_endTime.toString()}'
          : 'No active session');

  return Scaffold(
    backgroundColor: const Color(0xFFF8F9FC),
    appBar: AppBar(
      backgroundColor: const Color(0xFF8194BE),
      title: const Text('Add Sleep', style: TextStyle(color: Colors.white)),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              children: [
                Text(
                  runningText,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                if (!_running)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCE6180),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _start,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('START'),
                  ),
                if (_running)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final stopped = await _stop();
                      if (stopped) Navigator.of(context).pop(true);
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('STOP'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _notes,
            decoration: InputDecoration(
              labelText: 'Notes (optional)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8194BE),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _saveManual,
            child: const Text('Save manual sleep as log'),
          ),
        ],
      ),
    ),
  );
}

}

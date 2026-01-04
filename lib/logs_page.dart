import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart';

class LogsPage extends StatefulWidget {
  final int babyId;
  final String type;
  const LogsPage(this.babyId, this.type, {super.key});
  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List logs = [];
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  Uri _uri(String p) => buildUri(p);

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (Globals.token == null) {
        setState(() {
          logs = [];
          _error = 'Not authenticated. Please log in.';
          _loading = false;
        });
        return;
      }

      Uri url;
      if (widget.type == 'sleep') {
        url = _uri('getSleepSessions.php')
            .replace(queryParameters: {'baby_id': widget.babyId.toString()});
      } else if (widget.type == 'diaper') {
        url = _uri('getDiapers.php')
            .replace(queryParameters: {'baby_id': widget.babyId.toString()});
      } else if (widget.type == 'feeding') {
        url = _uri('getFeedings.php')
            .replace(queryParameters: {'baby_id': widget.babyId.toString()});
      } else {
        url = _uri('getAllLogs.php')
            .replace(queryParameters: {'baby_id': widget.babyId.toString()});
      }

      debugPrint('fetchLogs URL: $url');
      final res = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${Globals.token}'},
      );
      debugPrint('fetchLogs status: ${res.statusCode}');
      debugPrint('fetchLogs body: ${res.body}');

      if (res.statusCode == 200) {
        final parsed = jsonDecode(res.body);
        if (parsed is List) {
          setState(() => logs = parsed);
        } else if (parsed is Map && parsed.containsKey('data')) {
          setState(() => logs = parsed['data'] ?? []);
        } else {
          setState(() {
            logs = [];
            _error = 'Unexpected response format from server';
          });
        }
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        setState(() {
          logs = [];
          _error = 'Unauthorized. Please log in again.';
        });
      } else {
        setState(() {
          logs = [];
          _error = 'Server error: ${res.statusCode}';
        });
      }
    } catch (e, st) {
      debugPrint('fetchLogs exception: $e\n$st');
      setState(() {
        logs = [];
        _error = 'Network or parsing error';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> addLog() async {
    if (widget.type != 'activity') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Use the specific screen to add this type (Sleep/Feeding/Diaper).'),
        ),
      );
      return;
    }

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (Globals.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated.')),
      );
      return;
    }

    final url = _uri('saveLog.php');
    final body = jsonEncode({
      'baby_id': widget.babyId,
      'type': widget.type,
      'details': text,
      'value': '',
      'recorded_at': DateTime.now().toIso8601String(),
    });

    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Globals.token}',
        },
        body: body,
      );

      debugPrint('addLog status: ${res.statusCode}');
      debugPrint('addLog body: ${res.body}');

      if (res.statusCode == 200) {
        final j = jsonDecode(res.body);
        if (j is Map && j['success'] == true) {
          _controller.clear();
          await fetchLogs();
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(j['message'] ?? 'Failed to add log')),
          );
        }
      } else if (res.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unauthorized. Please log in again.')),
        );
      } else if (res.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saving notes is not supported on this server.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${res.statusCode}')),
        );
      }
    } catch (e, st) {
      debugPrint('addLog exception: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error')),
      );
    }
  }

  Map<String, String?>? _parseSleepDetails(String? details) {
    if (details == null) return null;
    final lower = details.toLowerCase();
    if (!lower.startsWith('sleep from')) return null;
    final regex = RegExp(
      r'from\s+([0-9:\- ]+)\s+to\s+([0-9:\- ]+)',
      caseSensitive: false,
    );
    final m = regex.firstMatch(details);
    if (m != null && m.groupCount >= 2) {
      final s = m.group(1)?.trim();
      final e = m.group(2)?.trim();
      return {'started': s, 'ended': e};
    }
    return null;
  }

  String _formatItem(Map item) {
    final kind = (item['kind'] ?? item['type'] ?? '').toString().toLowerCase();

    // Sleep
    if (kind == 'sleep') {
      final startField = item['started_at'];
      final endField = item['ended_at'];
      final notes = (item['notes'] ?? '').toString();

      if (startField != null &&
          startField.toString().isNotEmpty &&
          endField != null &&
          endField.toString().isNotEmpty) {
        return 'Sleep: ${startField.toString()} → ${endField.toString()}'
            '${notes.isNotEmpty ? "\nNotes: $notes" : ""}';
      }

      final details = item['details'];
      final parsed = _parseSleepDetails(details?.toString());
      if (parsed != null) {
        final s = parsed['started'] ?? '?';
        final e = parsed['ended'] ?? 'running';
        return 'Sleep: $s → $e${notes.isNotEmpty ? "\nNotes: $notes" : ""}';
      }

      if (details != null && details.toString().isNotEmpty) {
        return details.toString() + (notes.isNotEmpty ? "\nNotes: $notes" : "");
      }

      return 'Sleep: running' + (notes.isNotEmpty ? "\nNotes: $notes" : "");
    }

    // Feeding (bottle/nursing/solids)
    if (kind == 'feeding' || kind == 'bottle' || kind == 'nursing' || kind == 'solids') {
      final type = (item['type'] ?? kind).toString().toLowerCase();
      final notes = (item['notes'] ?? item['details'] ?? '').toString();

      if (type == 'solids') {
        final food = (item['food_name'] ?? 'Unknown food').toString();
        final amt = (item['solid_amount'] ?? item['amount'] ?? '').toString();
        final amtText = amt.isNotEmpty ? '$amt tbsp' : '';
        return 'Solids: $food ${amtText.isNotEmpty ? amtText : ""}'
            '${notes.isNotEmpty ? "\nNotes: $notes" : ""}';
      } else {
        final amount = item['amount'];
        final unit = (item['unit'] ?? '').toString();
        final side = (item['side'] ?? '').toString();

        final amountText = (amount != null && amount.toString().isNotEmpty)
            ? '${amount.toString()} ${unit}'
            : '';
        final sideText = side.isNotEmpty ? ' ($side)' : '';

        return 'Feeding: ${amountText}${sideText}'
            '${notes.isNotEmpty ? "\nNotes: $notes" : ""}';
      }
    }

    // Diaper
    if (kind == 'diaper' ||
        (item['details'] == 'pee' ||
            item['details'] == 'poo' ||
            item['details'] == 'mixed')) {
      final d = (item['details'] ?? item['kind'] ?? '').toString();
      final notes = (item['notes'] ?? '').toString();
      return 'Diaper: $d${notes.isNotEmpty ? "\nNotes: $notes" : ""}';
    }

    // Fallback: show details if present
    if (item.containsKey('details') && (item['details'] ?? '').toString().isNotEmpty) {
      final notes = (item['notes'] ?? '').toString();
      final details = item['details'].toString();
      return details + (notes.isNotEmpty ? "\nNotes: $notes" : "");
    }

    return item.toString();
  }

  Widget _section(Widget title, List logs) {
    if (logs.isEmpty) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFCE6180),
            ),
            child: title,
          ),
          const SizedBox(height: 12),
          ...logs.map((log) {
            final map = log is Map ? log : Map<String, dynamic>.from(log);
            final time = (map['recorded_at'] ??
                    map['started_at'] ??
                    map['created_at'])
                ?.toString() ??
                '';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text('${_formatItem(map)}\n$time'),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8194BE),
        title: const Text('Logs', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: fetchLogs,
        child: Column(
          children: [
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: logs.isEmpty && !_loading
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('No entries yet. Pull to refresh.')),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _section(
                          Row(
                            children: const [
                              Icon(Icons.restaurant, color: Color(0xFFCE6180)),
                              SizedBox(width: 8),
                              Text('Feeding'),
                            ],
                          ),
                          logs.where((l) {
                            final t = (l['type'] ?? l['kind'])?.toString().toLowerCase();
                            return t != null &&
                                ['feeding', 'bottle', 'nursing', 'solids'].contains(t);
                          }).toList(),
                        ),
                        _section(
                          Row(
                            children: const [
                              Icon(Icons.bedtime, color: Color(0xFFCE6180)),
                              SizedBox(width: 8),
                              Text('Sleep'),
                            ],
                          ),
                          logs.where((l) => (l['type'] ?? l['kind']) == 'sleep').toList(),
                        ),
                        _section(
                          Row(
                            children: const [
                              Icon(Icons.wc, color: Color(0xFFCE6180)),
                              SizedBox(width: 8),
                              Text('Diaper'),
                            ],
                          ),
                          logs.where((l) => (l['type'] ?? l['kind']) == 'diaper').toList(),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Add note'),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: addLog),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

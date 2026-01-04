import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart';

class DiaperPage extends StatefulWidget {
  final int babyId;
  const DiaperPage(this.babyId, {super.key});
  @override
  State<DiaperPage> createState() => _DiaperPageState();
}

class _DiaperPageState extends State<DiaperPage> {
  String _kind = 'pee';
  final _notes = TextEditingController();

  Uri _uri(String p) => buildUri(p);

  Future<void> _save() async {
    final url = _uri('saveDiaper.php');
    final body = jsonEncode({'baby_id': widget.babyId, 'kind': _kind, 'notes': _notes.text});
    final res = await http.post(url, headers: {'Content-Type':'application/json', if (Globals.token!=null) 'Authorization':'Bearer ${Globals.token}'}, body: body);
    if (res.statusCode == 200) {
      final j = jsonDecode(res.body);
      if (j['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diaper saved')));
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save failed')));
    }
  }

  Widget _styledIconButton(String kind, IconData icon) {
  final selected = _kind == kind;
  return GestureDetector(
    onTap: () => setState(() => _kind = kind),
    child: Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: selected ? const Color(0xFFCE6180) : Colors.grey[300],
          child: Icon(icon, color: selected ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 6),
        Text(
          kind.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selected ? const Color(0xFFCE6180) : Colors.black87,
          ),
        ),
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
      title: const Text('Add Diaper', style: TextStyle(color: Colors.white)),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _styledIconButton('pee', Icons.opacity),
                _styledIconButton('poo', Icons.bubble_chart),
                _styledIconButton('mixed', Icons.merge_type),
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
            onPressed: _save,
            child: const Text('Save Diaper'),
          ),
        ],
      ),
    ),
  );
}

}

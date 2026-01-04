import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart';

// if (_type == 'solids' && _selectedFoodId == null) {
//   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a food')));
//   return;
// }

class FeedingPage extends StatefulWidget {
  final int babyId;
  const FeedingPage(this.babyId, {super.key});
  @override
  State<FeedingPage> createState() => _FeedingPageState();
}

class _FeedingPageState extends State<FeedingPage> {
  String _type = 'bottle';
  String _unit = 'oz';
  double _amount = 4.0;
  String _side = 'left';
  final _notes = TextEditingController();

  List<Map<String, dynamic>> _foods = [];
  int? _selectedFoodId;
  double _solidAmount = 1.0;

  Uri _uri(String p) => buildUri(p);

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  Future<void> _fetchFoods() async {
    final url = _uri('getFoods.php');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final j = jsonDecode(res.body);
      if (j is List) {
        setState(() => _foods = List<Map<String, dynamic>>.from(j));
      }
    }
  }

  Future<void> _save() async {
    final url = _uri('saveFeeding.php');
    /////
    if (_type == 'solids' && _selectedFoodId == null) {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a food')));
  return;
}
//////
    final body = jsonEncode({
      'baby_id': widget.babyId,
      'type': _type,
      'unit': (_type == 'bottle' || _type == 'nursing') ? _unit : null,
'amount': (_type == 'bottle' || _type == 'nursing') ? _amount.toString() : (_type == 'solids' ? _solidAmount.toString() : null),
'side': _type == 'nursing' ? _side : null,

      'notes': _notes.text,
      'food_id': _type == 'solids' && _selectedFoodId != null ? _selectedFoodId : null
    });
//_selectedFoodId : null
    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (Globals.token != null) 'Authorization': 'Bearer ${Globals.token}'
      },
      body: body,
    );

    if (res.statusCode == 200) {
      final j = jsonDecode(res.body);
      if (j['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feeding saved')));
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save failed')));
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F9FC),
    appBar: AppBar(
      backgroundColor: const Color(0xFF8194BE),
      title: const Text('Add Feeding', style: TextStyle(color: Colors.white)),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              children: [
                ToggleButtons(
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: Colors.white,
                  fillColor: const Color(0xFFCE6180),
                  color: Colors.black87,
                  isSelected: [_type == 'nursing', _type == 'bottle', _type == 'solids'],
                  onPressed: (i) {
                    setState(() {
                      _type = i == 0 ? 'nursing' : i == 1 ? 'bottle' : 'solids';
                    });
                  },
                  children: const [
                    Padding(padding: EdgeInsets.all(8), child: Text('Nursing')),
                    Padding(padding: EdgeInsets.all(8), child: Text('Bottle')),
                    Padding(padding: EdgeInsets.all(8), child: Text('Solids')),
                  ],
                ),
                const SizedBox(height: 16),
                if (_type == 'nursing') ...[
  Row(
    children: [
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _side == 'left' ? const Color(0xFFCE6180) : Colors.grey[300],
            foregroundColor: _side == 'left' ? Colors.white : Colors.black,
          ),
          onPressed: () => setState(() => _side = 'left'),
          child: const Text('LEFT'),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _side == 'right' ? const Color(0xFFCE6180) : Colors.grey[300],
            foregroundColor: _side == 'right' ? Colors.white : Colors.black,
          ),
          onPressed: () => setState(() => _side = 'right'),
          child: const Text('RIGHT'),
        ),
      ),
    ],
  ),
  const SizedBox(height: 12),
  Row(
    children: [
      const Text('Unit:'),
      const SizedBox(width: 8),
      ChoiceChip(
        label: const Text('oz'),
        selected: _unit == 'oz',
        onSelected: (_) => setState(() => _unit = 'oz'),
        selectedColor: const Color(0xFF8194BE),
      ),
      const SizedBox(width: 8),
      ChoiceChip(
        label: const Text('mL'),
        selected: _unit == 'ml',
        onSelected: (_) => setState(() => _unit = 'ml'),
        selectedColor: const Color(0xFF8194BE),
      ),
    ],
  ),
  const SizedBox(height: 12),
  Text('Amount: ${_amount.toStringAsFixed(1)} $_unit'),
  Slider(
    value: _amount,
    min: 0,
    max: _unit == 'oz' ? 12 : 360,
    divisions: _unit == 'oz' ? 24 : 36,
    activeColor: const Color(0xFFCE6180),
    onChanged: (v) => setState(() => _amount = v),
  ),
],

                if (_type == 'bottle') ...[
                  Row(
                    children: [
                      const Text('Unit:'),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('oz'),
                        selected: _unit == 'oz',
                        onSelected: (_) => setState(() => _unit = 'oz'),
                        selectedColor: const Color(0xFF8194BE),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('mL'),
                        selected: _unit == 'ml',
                        onSelected: (_) => setState(() => _unit = 'ml'),
                        selectedColor: const Color(0xFF8194BE),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Amount: ${_amount.toStringAsFixed(1)} $_unit'),
                  Slider(
                    value: _amount,
                    min: 0,
                    max: _unit == 'oz' ? 12 : 360,
                    divisions: _unit == 'oz' ? 24 : 36,
                    activeColor: const Color(0xFFCE6180),
                    onChanged: (v) => setState(() => _amount = v),
                  ),
                ],
                if (_type == 'solids') ...[
                  const Text('Select food:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _foods.map((food) {
                      final id = int.tryParse(food['id'].toString());
                      final name = food['name'] ?? '';
                      final imageUrl = food['image_url'] ?? '';
                      final selected = _selectedFoodId == id;

                      return InkWell(
                        onTap: () => setState(() => _selectedFoodId = id),
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                           boxShadow: selected
    ? [BoxShadow(color: const Color(0xFFCE6180).withOpacity(0.5), blurRadius: 8)]
    : [],

                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                                child: imageUrl.isEmpty ? Text(name[0]) : null,
                              ),
                              const SizedBox(height: 4),
                              Text(name, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text('Amount: ${_solidAmount.toStringAsFixed(1)} tbsp'),
                  Slider(
                    value: _solidAmount,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    activeColor: const Color(0xFFCE6180),
                    onChanged: (v) => setState(() => _solidAmount = v),
                  ),
                ],
                const SizedBox(height: 12),
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
                  child: const Text('Save Feeding'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

}

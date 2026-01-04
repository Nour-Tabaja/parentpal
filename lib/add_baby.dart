import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart';

class AddBaby extends StatefulWidget {
  const AddBaby({super.key});
  @override
  State<AddBaby> createState() => _AddBabyState();
}

class _AddBabyState extends State<AddBaby> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  int age = 0;
  double weight = 0;
  double length = 0;
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _saving = true);
    final url = buildUri('saveBaby.php');
    final res = await http.post(url, headers: {
      'Content-Type':'application/json',
      if (Globals.token != null) 'Authorization':'Bearer ${Globals.token}'
    }, body: jsonEncode({
      'name': name,
      'age_months': age,
      'weight_kg': weight,
      'length_cm': length
    }));
    setState(() => _saving = false);
    if (res.statusCode == 200) {
      final j = jsonDecode(res.body);
      if (j['success'] == true) { Navigator.pop(context, true); return; }
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save failed')));
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F9FC),
    appBar: AppBar(
      backgroundColor: const Color(0xFF8194BE),
      title: Row( children: const [Text( 'Add Your Little Love', style: TextStyle(color: Colors.white, fontSize: 18), ),  SizedBox(width: 8),  Icon(Icons.favorite, color: Colors.white, size: 20),], ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Banner
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(),
                      child: Image.asset(
                        'assets/baby_banner.jpg',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFCE6180).withOpacity(0.2), // soft crimson
                            Color(0xFF8194BE).withOpacity(0.2), // soft gray-blue
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _styledField(
              label: 'Name',
              keyboardType: TextInputType.text,
              onSaved: (v) => name = v ?? '',
              validator: (v) => (v == null || v.isEmpty) ? 'Enter name' : null,
            ),
            _styledField(
              label: 'Age (months)',
              keyboardType: TextInputType.number,
              onSaved: (v) => age = int.tryParse(v ?? '0') ?? 0,
            ),
            _styledField(
              label: 'Weight (kg)',
              keyboardType: TextInputType.number,
              onSaved: (v) => weight = double.tryParse(v ?? '0') ?? 0,
            ),
            _styledField(
              label: 'Length (cm)',
              keyboardType: TextInputType.number,
              onSaved: (v) => length = double.tryParse(v ?? '0') ?? 0,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCE6180),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    ),
  );
}
Widget _styledField({
  required String label,
  required TextInputType keyboardType,
  FormFieldSetter<String>? onSaved,
  FormFieldValidator<String>? validator,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF8194BE), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: validator,
    ),
  );
}

}

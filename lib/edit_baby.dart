import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'baby.dart';

class EditBabyPage extends StatefulWidget {
  final Baby baby;
  const EditBabyPage(this.baby, {super.key});

  @override
  State<EditBabyPage> createState() => _EditBabyPageState();
}

class _EditBabyPageState extends State<EditBabyPage> {
  final _formKey = GlobalKey<FormState>();
  late int age;
  late double weight;
  late double length;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    age = widget.baby.ageMonths;
    weight = widget.baby.weightKg;
    length = widget.baby.lengthCm;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _saving = true);

    try {
      final url = buildUri('updateBaby.php');
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (Globals.token != null)
            'Authorization': 'Bearer ${Globals.token}',
        },
        body: jsonEncode({
          'baby_id': widget.baby.id,
          'age_months': age,
          'weight_kg': weight,
          'length_cm': length,
        }),
      );

      setState(() => _saving = false);

      if (res.statusCode == 200) {
        final j = jsonDecode(res.body);
        print("Response JSON: $j");
        if (j['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Baby info updated successfully')),
          );
          Navigator.pop(context, true);
          return;
        }
      } else {
        print("HTTP Error: ${res.statusCode}");
        print("Response Body: ${res.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Update failed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8194BE),
        title: const Text('Edit Baby', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: age.toString(),
                decoration: const InputDecoration(labelText: 'Age (months)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => age = int.tryParse(v ?? '0') ?? 0,
              ),
              TextFormField(
                initialValue: weight.toString(),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => weight = double.tryParse(v ?? '0') ?? 0,
              ),
              TextFormField(
                initialValue: length.toString(),
                decoration: const InputDecoration(labelText: 'Length (cm)'),
                keyboardType: TextInputType.number,
                onSaved: (v) => length = double.tryParse(v ?? '0') ?? 0,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCE6180),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

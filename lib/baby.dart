import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'globals.dart';

class Baby {
  final int id;
  final String name;
  final int ageMonths;
  final double weightKg;
  final double lengthCm;

  Baby(this.id, this.name, this.ageMonths, this.weightKg, this.lengthCm);

  @override
  String toString() {
    return 'Name: $name\nAge (months): $ageMonths\nWeight: ${weightKg}kg\nLength: ${lengthCm}cm';
  }
}

List<Baby> babies = [];

Future<List<Baby>> fetchBabies() async {
  final url = buildUri('getBabies.php');
  final res = await http.get(url, headers: Globals.token != null ? {'Authorization':'Bearer ${Globals.token}'} : {});
  if (res.statusCode != 200) throw Exception('Failed to load');
  final List data = convert.jsonDecode(res.body);
  return data.map((row) => Baby(
    int.tryParse(row['id'].toString()) ?? 0,
    row['name'] ?? '',
    int.tryParse(row['age_months'].toString()) ?? 0,
    double.tryParse(row['weight_kg'].toString()) ?? 0.0,
    double.tryParse(row['length_cm'].toString()) ?? 0.0,
  )).toList();
}

void updateBabies(Function(bool success) update) async {
  try {
    final list = await fetchBabies();
    babies.clear();
    babies.addAll(list);
    update(true);
  } catch (e) {
    update(false);
  }
}

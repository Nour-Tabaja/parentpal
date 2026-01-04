import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'baby.dart';
import 'baby_detail.dart';

class ShowBabies extends StatelessWidget {
  const ShowBabies({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: babies.length,
      itemBuilder: (context, index) {
        final b = babies[index];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BabyDetail(b))),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8194BE).withOpacity(0.1), // soft gray-blue background
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF8194BE), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.baby, color: const Color(0xFFCE6180), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        b.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFCE6180), // crimson
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Age: ${b.ageMonths} months • ${b.weightKg}kg',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

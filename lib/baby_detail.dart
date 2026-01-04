import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'baby.dart';
import 'logs_page.dart';
import 'sleep_page.dart';
import 'feeding_page.dart';
import 'diaper_page.dart';
import 'support_page.dart';
import 'edit_baby.dart'; // <-- new file

class BabyDetail extends StatelessWidget {
  final Baby baby;
  const BabyDetail(this.baby, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8194BE),
        title: Row(
          children: [
            FaIcon(FontAwesomeIcons.baby, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                baby.name,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
        Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: const Color(0xFFCE6180).withOpacity(0.6),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Stack(
    children: [
      // Details column
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Age: ${baby.ageMonths} months',
              style: const TextStyle(fontSize: 16, color: Colors.white)),
          Text('Weight: ${baby.weightKg} kg',
              style: const TextStyle(fontSize: 16, color: Colors.white)),
          if (baby.lengthCm != null)
            Text('Length: ${baby.lengthCm} cm',
                style: const TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),

      // Positioned edit icon in top-right
      Positioned(
        top: 0,
        right: 0,
        child: IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () async {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditBabyPage(baby)),
            );
            if (updated == true) {
              // Refresh or reload baby data if needed
            }
          },
        ),
      ),
    ],
  ),
)
,
          const SizedBox(height: 24),
          _navCard(context, Icons.bedtime, 'Sleep', () => SleepPage(baby.id)),
          _navCard(context, Icons.restaurant, 'Feeding', () => FeedingPage(baby.id)),
          _navCard(context, Icons.wc, 'Diaper', () => DiaperPage(baby.id)),
          _navCard(context, Icons.child_care, 'Logs', () => LogsPage(baby.id, 'activity')),
          _navCard(context, Icons.forum, 'Tips', () => const SupportPage()),
        ],
      ),
    );
  }

  Widget _navCard(BuildContext context, IconData icon, String label, Widget Function() pageBuilder) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => pageBuilder())),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF8194BE).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8194BE), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFCE6180)),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

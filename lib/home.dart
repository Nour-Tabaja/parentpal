import 'package:flutter/material.dart';
import 'baby.dart';
import 'show_babies.dart';
import 'add_baby.dart';
import 'login.dart';
import 'globals.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loaded = false;

  void update(bool success) {
    setState(() {
      _loaded = true;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load data')),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    updateBabies(update);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // white background
      appBar: AppBar(
        backgroundColor: const Color(0xFF8194BE), // gray-blue
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            // Image.asset(
            //   'assets/ParentPal_Logo.png',
            //   height: 60,
            //   width: 80,
            // ),
            // const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundImage: const AssetImage('assets/prof2.png'),
            ),
            const SizedBox(width: 8),
            Text(
              Globals.username ?? 'User',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Globals.token = null;
              Globals.userId = null;
              Globals.username = null;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _loaded
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCE6180), // crimson
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddBaby(),
                            ),
                          );
                          if (res == true) {
                            setState(() {
                              _loaded = false;
                              updateBabies(update);
                            });
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Your Little Love'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8194BE), // gray-blue
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _loaded = false;
                            updateBabies(update);
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
       

                const Expanded(child: ShowBabies()),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

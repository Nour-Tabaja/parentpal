import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _user = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    setState(() => _loading = true);
    final url = buildUri('register.php');
    final res = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _user.text.trim(),
          'email': _email.text.trim(),
          'password': _pass.text
        }));
    setState(() => _loading = false);
    if (res.statusCode == 200) {
      final j = jsonDecode(res.body);
     if (j['success'] == true) {
  Globals.token = j['token'];
  Globals.userId = j['id'];
  Globals.username = j['username']; // store username
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (_) => const Home()));
  return;
}

    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Register failed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.asset(
                'assets/ParentPal_Logo.png',
                height: 120,
                width: 150,
                errorBuilder: (context, error, stackTrace) =>
                    const Text('ParentPal',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
            Text('Create Your ParentPal Account !',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8194BE))),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Join our caring family and start nurturing moments', style: TextStyle(fontSize: 16, color: Color(0xFFCE6180).withOpacity(0.7))),
                const SizedBox(width: 6),
                Icon(Icons.favorite, color: Color(0xFFCE6180).withOpacity(0.7), size: 18),
              ],
            ),
            const SizedBox(height: 32),
            _styledField(
                controller: _user,
                label: 'Full Name',
                obscure: false,
                icon: Icons.person_outline),
            _styledField(
                controller: _email,
                label: 'Email',
                obscure: false,
                icon: Icons.email_outlined),
            _styledField(
                controller: _pass,
                label: 'Password',
                obscure: true,
                icon: Icons.lock_outline),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCE6180),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _loading ? null : _register,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create Account',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // back to login
                },
                child: const Text('Already have an account? Login',
                    style: TextStyle(color: Color(0xFF8194BE))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _styledField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: const Color(0xFF8194BE)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

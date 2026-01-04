import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});
  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  List posts = [];

  Future<void> fetchPosts() async {
    final url = buildUri('getSupport.php');
    final res = await http.get(url);
    if (res.statusCode == 200) setState(() => posts = jsonDecode(res.body));
  }

  @override
  void initState() { super.initState(); fetchPosts(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8194BE),
        title: const Text('Tips', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: fetchPosts,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, i) {
            final p = posts[i] is Map ? Map<String, dynamic>.from(posts[i]) : (posts[i] as Map<String, dynamic>);
            final title = p['title'] ?? '';
            final body = p['body'] ?? '';
            final author = p['author'] ?? p['user'] ?? '';
            final time = p['created_at'] ?? p['recorded_at'] ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFCE6180).withOpacity( 0.6),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(body.toString()),
                if ((author ?? '').toString().isNotEmpty || (time ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(children: [Text(author.toString(), style: const TextStyle(color: Colors.black54, fontSize: 12)), const Spacer(), Text(time.toString(), style: const TextStyle(color: Colors.black54, fontSize: 12))])
                ]
              ]),
            );
          },
        ),
      ),
    );
  }
}

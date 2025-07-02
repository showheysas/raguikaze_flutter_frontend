import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const RaguiKazeApp());

class RaguiKazeApp extends StatelessWidget {
  const RaguiKazeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ラグい風 フラッタver.',
      theme: ThemeData(
        fontFamily: 'NotoSansJP',
        primarySwatch: Colors.blue,
      ),
      home: const RaguiKazeHomePage(),
    );
  }
}

class RaguiKazeHomePage extends StatefulWidget {
  const RaguiKazeHomePage({super.key});

  @override
  _RaguiKazeHomePageState createState() => _RaguiKazeHomePageState();
}

class _RaguiKazeHomePageState extends State<RaguiKazeHomePage> {
  final TextEditingController _queryController = TextEditingController();
  bool _kazemode = false;

  String _answer = '';
  List<Map<String, dynamic>> _references = [];

  Future<void> _sendQuery() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    final apiUrl = 'http://10.0.2.2:8000/ask';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query, 'kazemode': _kazemode}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _answer = data['answer'];
          _references = List<Map<String, dynamic>>.from(data['references']);
        });
      } else {
        throw Exception('サーバーエラー: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _answer = '通信に失敗しました：$e';
        _references = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _kazemode ? const Color(0xFFEAFBF1) : const Color(0xFFEAF6FB);
    final buttonColor = _kazemode ? const Color(0xFF70B77E) : const Color(0xFF0077C2);
    final buttonTextColor = Colors.white;
    final titleFont = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      fontFamily: 'NotoSerifJP',
      color: Colors.white,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('ラグい風　フラッタver.', style: titleFont),
        backgroundColor: buttonColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌿 風さん画像
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/images/kaze_top.png'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _queryController,
              decoration: const InputDecoration(
                labelText: '質問を入力してください',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 16),
              minLines: 2,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('風モード'),
                Switch(
                  value: _kazemode,
                  onChanged: (value) {
                    setState(() {
                      _kazemode = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendQuery,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: buttonTextColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                '教えて！',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            if (_answer.isNotEmpty) ...[
              Text(
                _kazemode ? 'ラグい風さんの回答:' : 'RAGの回答:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(_answer),
              const SizedBox(height: 24),
            ],
            if (_references.isNotEmpty) ...[
              const Text(
                '参照条文:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              for (var ref in _references)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref['prefLabel'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(ref['text'] ?? ''),
                    ],
                  ),
                )
            ],
          ],
        ),
      ),
    );
  }
}

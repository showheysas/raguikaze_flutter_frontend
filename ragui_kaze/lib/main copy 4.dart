import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const RaguiKazeApp());

class RaguiKazeApp extends StatelessWidget {
  const RaguiKazeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ラグい風',
      debugShowCheckedModeBanner: false,
      home: RaguiKazeHomePage(),
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

    final apiUrl = 'http://10.0.2.2:8000/ask'; // ← Androidエミュレータ用。Chromeなら127.0.0.1に変更。

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
    final bgColor = _kazemode ? Colors.green[50] : Colors.white;
    final appBarColor = _kazemode ? Colors.green[200] : Colors.blue;
    final buttonColor = _kazemode ? Colors.teal : Colors.blue;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('ラグい風　フラッタVer.'),
        backgroundColor: appBarColor,
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

            // 入力欄
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                labelText: '質問を入力してください',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: _kazemode ? Colors.green[100] : null,
              ),
              minLines: 2,
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            // 風モードスイッチ
            Row(
              children: [
                const Text('風さんモード'),
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

            // 送信ボタン
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: _sendQuery,
              child: const Text('教えて！'),
            ),
            const SizedBox(height: 24),

            // 回答表示
            if (_answer.isNotEmpty) ...[
              const Text(
                'RAGの回答:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(_answer),
              const SizedBox(height: 24),
            ],

            // 参照条文表示
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
                      Text(ref['prefLabel'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
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

import 'package:flutter/material.dart';
import 'dart:convert'; // ← 上部に追加
import 'package:http/http.dart' as http; // ← 上部に追加

void main() {
  runApp(const RaguiKazeApp());
}

class RaguiKazeApp extends StatelessWidget {
  const RaguiKazeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ラグい風',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RaguiKazeHomePage(),
    );
  }
}

class RaguiKazeHomePage extends StatefulWidget {
  const RaguiKazeHomePage({super.key});

  @override
  State<RaguiKazeHomePage> createState() => _RaguiKazeHomePageState();
}

class _RaguiKazeHomePageState extends State<RaguiKazeHomePage> {
  final TextEditingController _queryController = TextEditingController();
  bool _kazemode = false;

  // 送信処理
  void _sendQuery() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    final apiUrl = 'http://127.0.0.1:8000/ask'; // ← 適宜変更（実機など）

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query, 'kazemode': _kazemode}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['answer'];
        final references = data['references'] as List<dynamic>;

        // ダイアログで表示（あとで画面にちゃんと出す）
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('AIの回答'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(answer),
                const SizedBox(height: 8),
                const Text('参照条文:', style: TextStyle(fontWeight: FontWeight.bold)),
                for (var ref in references)
                  Text('- ${ref['prefLabel']}：${ref['text']}'),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
          ),
        );
      } else {
        throw Exception('サーバーエラー: ${response.statusCode}');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('エラー'),
          content: Text('通信に失敗しました：\n$e'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ラグい風')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _queryController,
              decoration: const InputDecoration(
                labelText: '質問を入力してください',
                border: OutlineInputBorder(),
              ),
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
              child: const Text('送信'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ラグい風',
      home: Scaffold(
        appBar: AppBar(title: const Text('ラグい風')),
        body: const Center(child: Text('Flutter 初起動 成功！')),
      ),
    );
  }
}

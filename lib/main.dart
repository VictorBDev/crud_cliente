import 'package:flutter/material.dart';
import 'package:multi_sem13/note_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData.dark(),
      home: const NotesView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

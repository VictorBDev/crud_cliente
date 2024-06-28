import 'package:flutter/material.dart';
import 'package:crud_cliente/page/student_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicación de Estudiantes',
      theme: ThemeData.dark(),
      home: const StudentsView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

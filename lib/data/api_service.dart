import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crud_cliente/model/student.dart';

class ApiService {
  final String baseUrl;

  ApiService(
      {this.baseUrl =
          'http://192.168.1.11:3000'}); //usa la ip de servidor local

  Future<List<StudentModel>> getStudents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/students'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body)['data'];
        return body.map((dynamic item) => StudentModel.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load students. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener estudiantes: $e');
      rethrow;
    }
  }

  Future<StudentModel> createStudent(StudentModel student) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(student.toJson()),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body)['data'];
      return StudentModel(
        id: data['id'],
        nombre: student.nombre,
        carrera: student.carrera,
        edad: student.edad,
        fechaIngreso: student.fechaIngreso,
      );
    } else {
      throw Exception('Failed to create student');
    }
  }

  Future<StudentModel> updateStudent(StudentModel student) async {
    final response = await http.put(
      Uri.parse('$baseUrl/students/${student.id}'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(student.toJson()),
    );
    if (response.statusCode == 200) {
      return student;
    } else {
      throw Exception('Failed to update student');
    }
  }

  Future<void> deleteStudent(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/students/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete student');
    }
  }
}

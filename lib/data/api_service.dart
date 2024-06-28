import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:multi_sem13/model/student.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<StudentModel>> getStudents() async {
    final response = await http.get(Uri.parse('$baseUrl/students'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['data'];
      return body.map((dynamic item) => StudentModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load students');
    }
  }

  Future<StudentModel> createStudent(StudentModel student) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(student.toJson()),
    );
    if (response.statusCode == 200) {
      return StudentModel.fromJson(jsonDecode(response.body)['data']);
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

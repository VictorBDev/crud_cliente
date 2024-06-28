import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:multi_sem13/model/student.dart';

class StorageService {
  Future<List<StudentModel>> getStudents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? studentsJson = prefs.getString('students');
    if (studentsJson == null) {
      return [];
    }
    List<dynamic> studentsList = json.decode(studentsJson);
    return studentsList.map((json) => StudentModel.fromJson(json)).toList();
  }

  Future<void> saveStudents(List<StudentModel> students) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String studentsJson = json.encode(students.map((e) => e.toJson()).toList());
    await prefs.setString('students', studentsJson);
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_sem13/model/student.dart';

class StorageService {
  static const String _key = 'students';

  Future<List<StudentModel>> getStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? studentsJson = prefs.getString(_key);
    if (studentsJson == null) return [];
    final List<dynamic> decoded = jsonDecode(studentsJson);
    return decoded.map((e) => StudentModel.fromJson(e)).toList();
  }

  Future<void> saveStudents(List<StudentModel> students) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(students.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}

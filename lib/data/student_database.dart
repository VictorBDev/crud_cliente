import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:multi_sem13/model/student.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:multi_sem13/data/api_service.dart';
import 'package:multi_sem13/data/storage_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class StudentDatabase {
  static final StudentDatabase instance = StudentDatabase._internal();
  static Database? _database;
  late final ApiService _apiService;
  late final StorageService _storageService;

  StudentDatabase._internal() {
    _apiService = ApiService(baseUrl: 'http://10.0.2.2:3000');
    _storageService = StorageService();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'students.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${StudentFields.tableName} (
        ${StudentFields.id} ${StudentFields.idType},
        ${StudentFields.nombre} ${StudentFields.textType},
        ${StudentFields.carrera} ${StudentFields.textType},
        ${StudentFields.edad} ${StudentFields.intType},
        ${StudentFields.fechaIngreso} ${StudentFields.textType}
      )
    ''');
  }

  Future<List<StudentModel>> readAll() async {
    if (kIsWeb) {
      return _storageService.getStudents();
    } else {
      final db = await database;
      const orderBy = '${StudentFields.fechaIngreso} DESC';
      final result = await db.query(StudentFields.tableName, orderBy: orderBy);
      return result.map((json) => StudentModel.fromJson(json)).toList();
    }
  }

  Future<StudentModel> create(StudentModel student) async {
    if (kIsWeb) {
      final students = await _storageService.getStudents();
      student = student.copy(id: students.length + 1);
      students.add(student);
      await _storageService.saveStudents(students);
      return student;
    } else {
      final db = await database;
      final id = await db.insert(StudentFields.tableName, student.toJson());
      return student.copy(id: id);
    }
  }

  Future<StudentModel> update(StudentModel student) async {
    if (kIsWeb) {
      final students = await _storageService.getStudents();
      final index = students.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        students[index] = student;
        await _storageService.saveStudents(students);
      }
      return student;
    } else {
      final db = await database;
      await db.update(
        StudentFields.tableName,
        student.toJson(),
        where: '${StudentFields.id} = ?',
        whereArgs: [student.id],
      );
      return student;
    }
  }

  Future<void> delete(int id) async {
    if (kIsWeb) {
      final students = await _storageService.getStudents();
      students.removeWhere((s) => s.id == id);
      await _storageService.saveStudents(students);
    } else {
      final db = await database;
      await db.delete(
        StudentFields.tableName,
        where: '${StudentFields.id} = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> syncWithServer() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print('No internet connection');
      return;
    }

    try {
      List<StudentModel> serverStudents = await _apiService.getStudents();
      List<StudentModel> localStudents = await readAll();

      for (var serverStudent in serverStudents) {
        var localStudent = localStudents.firstWhere(
          (local) => local.id == serverStudent.id,
          orElse: () => StudentModel(
              id: -1,
              nombre: '',
              carrera: '',
              edad: 0,
              fechaIngreso: DateTime.now()),
        );

        if (localStudent.id == -1) {
          await create(serverStudent);
        } else if (serverStudent != localStudent) {
          await update(serverStudent);
        }
      }

      for (var localStudent in localStudents) {
        if (!serverStudents.any((server) => server.id == localStudent.id)) {
          await _apiService.createStudent(localStudent);
        }
      }
    } catch (e) {
      print('Error syncing with server: $e');
    }
  }
}

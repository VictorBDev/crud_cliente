import 'package:multi_sem13/student.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//Student database crea las tablas además de realizar las operaciones CRUD
//El Json ayuda a serializar y deserializar los datos, de modelo JSON a objeto Dart
class StudentDatabase {
  static final StudentDatabase instance = StudentDatabase._internal();

  static Database? _database;

  StudentDatabase._internal();

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

  Future<StudentModel> create(StudentModel student) async {
    final db = await instance.database;
    final id = await db.insert(StudentFields.tableName, student.toJson());
    return student.copy(id: id);
  }

  Future<StudentModel> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      StudentFields.tableName,
      columns: StudentFields.values,
      where: '${StudentFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return StudentModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<StudentModel>> readAll() async {
    final db = await instance.database;
    const orderBy = '${StudentFields.fechaIngreso} DESC';
    final result = await db.query(StudentFields.tableName, orderBy: orderBy);
    return result.map((json) => StudentModel.fromJson(json)).toList();
  }

  Future<int> update(StudentModel student) async {
    final db = await instance.database;
    return db.update(
      StudentFields.tableName,
      student.toJson(),
      where: '${StudentFields.id} = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      StudentFields.tableName,
      where: '${StudentFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

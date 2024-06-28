class StudentFields {
  static const List<String> values = [
    id,
    nombre,
    carrera,
    edad,
    fechaIngreso,
  ];

  static const String tableName = 'estudiantes';
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String intType = 'INTEGER NOT NULL';
  static const String id = '_id';
  static const String nombre = 'nombre';
  static const String carrera = 'carrera';
  static const String edad = 'edad';
  static const String fechaIngreso = 'fecha_ingreso';
}

class StudentModel {
  int? id;
  final String nombre;
  final String carrera;
  final int? edad;
  final DateTime? fechaIngreso;

  StudentModel({
    this.id,
    required this.nombre,
    required this.carrera,
    this.edad,
    required this.fechaIngreso,
  });

  Map<String, Object?> toJson() => {
        StudentFields.id: id,
        StudentFields.nombre: nombre,
        StudentFields.carrera: carrera,
        StudentFields.edad: edad,
        StudentFields.fechaIngreso: fechaIngreso?.toIso8601String(),
      };

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: json[StudentFields.id] as int?,
        nombre: json[StudentFields.nombre] as String,
        carrera: json[StudentFields.carrera] as String,
        edad: json[StudentFields.edad] as int?,
        fechaIngreso: json[StudentFields.fechaIngreso] != null
            ? DateTime.parse(json[StudentFields.fechaIngreso] as String)
            : null,
      );

  StudentModel copy({
    int? id,
    String? nombre,
    String? carrera,
    int? edad,
    DateTime? fechaIngreso,
  }) =>
      StudentModel(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        carrera: carrera ?? this.carrera,
        edad: edad ?? this.edad,
        fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nombre == other.nombre &&
          carrera == other.carrera &&
          edad == other.edad &&
          fechaIngreso == other.fechaIngreso;

  @override
  int get hashCode =>
      id.hashCode ^
      nombre.hashCode ^
      carrera.hashCode ^
      edad.hashCode ^
      fechaIngreso.hashCode;
}

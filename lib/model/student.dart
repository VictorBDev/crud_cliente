class StudentModel {
  final int? id;
  final String nombre;
  final String carrera;
  final int edad;
  final DateTime fechaIngreso;

  StudentModel({
    this.id,
    required this.nombre,
    required this.carrera,
    required this.edad,
    required this.fechaIngreso,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: json['_id'] as int?,
        nombre: json['nombre'] as String,
        carrera: json['carrera'] as String,
        edad: json['edad'] as int,
        fechaIngreso: DateTime.parse(json['fecha_ingreso'] as String),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'nombre': nombre,
        'carrera': carrera,
        'edad': edad,
        'fecha_ingreso': fechaIngreso.toIso8601String(),
      };

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
}

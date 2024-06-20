import 'package:flutter/material.dart';
import 'package:multi_sem13/student.dart';
import 'package:multi_sem13/student_database.dart';

class StudentDetailsView extends StatefulWidget {
  const StudentDetailsView({Key? key, this.studentId}) : super(key: key);
  final int? studentId;

  @override
  State<StudentDetailsView> createState() => _StudentDetailsViewState();
}

class _StudentDetailsViewState extends State<StudentDetailsView> {
  StudentDatabase studentDatabase = StudentDatabase.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController majorController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  late StudentModel student;
  bool isLoading = false;
  bool isNewStudent = false;

  @override
  void initState() {
    refreshStudent();
    super.initState();
  }

  refreshStudent() {
    if (widget.studentId == null) {
      setState(() {
        isNewStudent = true;
        student = StudentModel(
          nombre: '',
          carrera: '',
          edad: 0,
          fechaIngreso: DateTime.now(),
        );
      });
      return;
    }
    studentDatabase.read(widget.studentId!).then((value) {
      setState(() {
        student = value;
        nameController.text = student.nombre;
        majorController.text = student.carrera;
        ageController.text = student.edad?.toString() ?? '';
      });
    });
  }

  saveStudent() async {
    setState(() {
      isLoading = true;
    });
    final model = StudentModel(
      id: isNewStudent ? null : student.id,
      nombre: nameController.text,
      carrera: majorController.text,
      edad: int.tryParse(ageController.text) ?? 0,
      fechaIngreso: DateTime.now(),
    );
    if (isNewStudent) {
      await studentDatabase.create(model);
    } else {
      await studentDatabase.update(model);
    }
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
  }

  deleteStudent() async {
    await studentDatabase.delete(student.id!);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(isNewStudent ? 'Añadir Estudiante' : 'Editar Estudiante'),
        actions: [
          if (!isNewStudent)
            IconButton(
              onPressed: deleteStudent,
              icon: const Icon(Icons.delete),
            ),
          IconButton(
            onPressed: saveStudent,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(children: [
                  TextField(
                    controller: nameController,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Nombre',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextField(
                    controller: majorController,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Carrera',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  TextField(
                    controller: ageController,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Ingrese su edad',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      int? age = int.tryParse(value);
                      if (age != null && (age < 0 || age > 100)) {
                        ageController.text = 'Error';
                        ageController.selection = TextSelection.fromPosition(
                          TextPosition(offset: ageController.text.length),
                        );
                      }
                    },
                  ),
                ]),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:multi_sem13/model/student.dart';
import 'package:multi_sem13/data/student_database.dart';

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

  refreshStudent() async {
    setState(() => isLoading = true);
    if (widget.studentId == null) {
      setState(() {
        isNewStudent = true;
        student = StudentModel(
          nombre: '',
          carrera: '',
          edad: 0,
          fechaIngreso: DateTime.now(),
        );
        isLoading = false;
      });
      return;
    }
    try {
      student = await studentDatabase.read(widget.studentId!);
      nameController.text = student.nombre;
      majorController.text = student.carrera;
      ageController.text = student.edad?.toString() ?? '';
    } catch (e) {
      print('Error loading student: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading student: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  saveStudent() async {
    setState(() => isLoading = true);
    try {
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
      await studentDatabase.syncWithServer();
      Navigator.pop(context, true);
    } catch (e) {
      print('Error saving student: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving student: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  deleteStudent() async {
    setState(() => isLoading = true);
    try {
      await studentDatabase.delete(student.id!);
      await studentDatabase.syncWithServer();
      Navigator.pop(context, true);
    } catch (e) {
      print('Error deleting student: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting student: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
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
                    decoration: InputDecoration(
                      hintText: 'Ingrese su nombre',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.2),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: majorController,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ingrese su carrera',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.2),
                        fontSize: 20,
                      ),
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: ageController,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ingrese su edad',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.2),
                        fontSize: 20,
                      ),
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
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

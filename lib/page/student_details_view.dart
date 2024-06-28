import 'package:flutter/material.dart';
import 'package:multi_sem13/model/student.dart';
import 'package:multi_sem13/data/student_database.dart';

class StudentDetailsView extends StatefulWidget {
  final int? studentId;

  const StudentDetailsView({Key? key, this.studentId}) : super(key: key);

  @override
  _StudentDetailsViewState createState() => _StudentDetailsViewState();
}

class _StudentDetailsViewState extends State<StudentDetailsView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _majorController;
  late TextEditingController _ageController;

  StudentDatabase studentDatabase = StudentDatabase.instance;
  bool isLoading = false;
  bool isNewStudent = false;
  late StudentModel student;

  @override
  void initState() {
    super.initState();
    isNewStudent = widget.studentId == null;
    _nameController = TextEditingController();
    _majorController = TextEditingController();
    _ageController = TextEditingController();
    if (!isNewStudent) {
      loadStudent();
    }
  }

  void loadStudent() async {
    setState(() => isLoading = true);
    try {
      student = await studentDatabase.readAll().then(
            (students) => students.firstWhere((s) => s.id == widget.studentId),
          );
      _nameController.text = student.nombre;
      _majorController.text = student.carrera;
      _ageController.text = student.edad.toString();
    } catch (e) {
      print('Error loading student: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        final studentModel = StudentModel(
          id: isNewStudent ? null : student.id,
          nombre: _nameController.text,
          carrera: _majorController.text,
          edad: int.parse(_ageController.text),
          fechaIngreso: DateTime.now(),
        );

        if (isNewStudent) {
          await studentDatabase.create(studentModel);
        } else {
          await studentDatabase.update(studentModel);
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
  }

  Future<void> deleteStudent() async {
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
                        //Hint text opacity
                        color: Colors.white.withOpacity(0.2),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      //Background opacity
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                  ),
                  SizedBox(height: 10), // Add this line
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

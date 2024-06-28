import 'package:flutter/material.dart';
import 'package:multi_sem13/model/student.dart';
import 'package:multi_sem13/data/student_database.dart';
import 'package:multi_sem13/page/student_details_view.dart';

class StudentsView extends StatefulWidget {
  const StudentsView({Key? key}) : super(key: key);

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  StudentDatabase studentDatabase = StudentDatabase.instance;

  List<StudentModel> students = [];

  @override
  void initState() {
    refreshStudents();
    super.initState();
  }

  @override
  dispose() {
    studentDatabase.close();
    super.dispose();
  }

  refreshStudents() {
    studentDatabase.readAll().then((value) {
      setState(() {
        students = value;
      });
    });
  }

  goToStudentDetailsView({int? id}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => StudentDetailsView(studentId: id)),
    );
    refreshStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text('Lista de Estudiantes'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Center(
        child: students.isEmpty
            ? const Text(
                'No hay estudiantes aún',
                style: TextStyle(color: Colors.white),
              )
            : ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return GestureDetector(
                    onTap: () => goToStudentDetailsView(id: student.id),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                student.fechaIngreso.toString().split(' ')[0],
                              ),
                              Text(
                                'Nombre: ${student.nombre}',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              Text(
                                'Carrera: ${student.carrera}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'Edad: ${student.edad}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => goToStudentDetailsView(),
        tooltip: 'Añadir Estudiante',
        child: const Icon(Icons.add),
      ),
    );
  }
}

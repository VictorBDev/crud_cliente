import 'package:flutter/material.dart';
import 'package:multi_sem13/model/student.dart';
import 'package:multi_sem13/data/api_service.dart';
import 'package:multi_sem13/page/student_details_view.dart';

class StudentsView extends StatefulWidget {
  const StudentsView({Key? key}) : super(key: key);

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  final ApiService apiService = ApiService();
  List<StudentModel> students = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshStudents();
  }

  Future<void> refreshStudents() async {
    setState(() => isLoading = true);
    try {
      students = await apiService.getStudents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading students: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> goToStudentDetailsView({int? id}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            StudentDetailsView(studentId: id, apiService: apiService),
      ),
    );
    if (result != null) {
      await refreshStudents();
    }
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
            onPressed: refreshStudents,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? const Center(
                  child: Text(
                    'No hay estudiantes aún',
                    style: TextStyle(color: Colors.white),
                  ),
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
                                  'Nombre: ${student.nombre}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  'Carrera: ${student.carrera}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  'Edad: ${student.edad}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => goToStudentDetailsView(),
        tooltip: 'Añadir Estudiante',
        child: const Icon(Icons.add),
      ),
    );
  }
}

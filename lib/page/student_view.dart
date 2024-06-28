import 'package:flutter/material.dart';
import 'package:multi_sem13/data/student_database.dart';
import 'package:multi_sem13/model/student.dart';
import 'package:multi_sem13/page/student_details_view.dart';

class StudentsView extends StatefulWidget {
  const StudentsView({Key? key}) : super(key: key);

  @override
  _StudentsViewState createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  StudentDatabase studentDatabase = StudentDatabase.instance;
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
      await studentDatabase.syncWithServer();
      students = await studentDatabase.readAll();
    } catch (e) {
      print('Error refreshing students: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refreshing students: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _navigateToAddStudentPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetailsView(),
      ),
    );

    if (result == true) {
      await refreshStudents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Estudiantes'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return ListTile(
                  title: Text(student.nombre),
                  subtitle: Text(student.carrera),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StudentDetailsView(studentId: student.id),
                      ),
                    );
                    if (result == true) {
                      await refreshStudents();
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddStudentPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}

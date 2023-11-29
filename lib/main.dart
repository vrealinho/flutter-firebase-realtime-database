import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mi_database/list_students.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alunos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  Future<FirebaseApp> _initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    FirebaseApp firebaseApp = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Student'),
      ),
      body: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Text('Register Student',
                            style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontSize: 30,
                                fontFamily: 'Roboto',
                                fontStyle: FontStyle.italic)),
                        RegisterStudent(),
                      ]),
                )
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class RegisterStudent extends StatefulWidget {
  const RegisterStudent({Key? key}) : super(key: key);

  @override
  RegisterStudentState createState() => RegisterStudentState();
}

class RegisterStudentState extends State<RegisterStudent> {
  final _formKey = GlobalKey<FormState>();
  final listOfCourses = ['Master in Informatics', 'PG Data Science and Digital Transformation', 'Master in GPME', 'Master in Design'];
  String? dropdownCourseValue = 'Master in Informatics';
  final listOfYears = ['1º year', '2º year'];
  String? dropdownYearValue = '1º year';
  final nameController = TextEditingController();
  final dbRef = FirebaseDatabase.instance.ref('students');

  @override
  Widget build(BuildContext context) {

    return Form(
        key: _formKey,
        child: SingleChildScrollView(
            child: Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Name of student?',
                    labelText: 'Name',
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Name';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: DropdownButtonFormField(
                  value: dropdownCourseValue,
                  icon: const Icon(Icons.arrow_downward),
                  decoration: const InputDecoration(
                    labelText: 'Course of student?',
                  ),
                  items: listOfCourses.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownCourseValue = newValue;
                    });
                  },
                  validator: (dynamic value) {
                    if (value.isEmpty) {
                      return 'Select the course';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: DropdownButtonFormField(
                  value: dropdownYearValue,
                  icon: const Icon(Icons.arrow_downward),
                  decoration: const InputDecoration(
                    labelText: 'Curricular year?',
                  ),
                  items: listOfYears.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownYearValue = newValue;
                    });
                  },
                  validator: (dynamic value) {
                    if (value.isEmpty) {
                      return 'Select the curricular year';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            dbRef.push().set({
                              'name': nameController.text,
                              'year': dropdownYearValue,
                              'course': dropdownCourseValue
                            }).then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Student registered')));
                              nameController.clear();
                            }).catchError((onError) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(onError)));
                            });
                          }
                        },
                        child: const Text('Register'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ListStudents(title: 'List of students')),
                          );
                        },
                        child: const Text('List'),
                      ),
                    ],
                  )),
            ])));
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }
}

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mi_database/list_students.dart';
import 'package:flutter/material.dart';

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
    Future<FirebaseApp> firebaseApp = Firebase.initializeApp();
    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registar aluno'),
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
                          Text('Registar aluno',
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
  final listOfCourses = ['Mestrado em Informática', 'PG Data Science and Digital Transformation', 'Mestrado em Gestão de PME', 'Mestrado em Design de Identidade Digital'];
  String? dropdownCourseValue = 'Mestrado em Informática';
  final listOfYears = ['1º ano', '2º ano'];
  String? dropdownYearValue = '1º ano';
  final nameController = TextEditingController();
  final dbRef = FirebaseDatabase.instance.ref('alunos');

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
                    hintText: 'Qual nome do aluno?',
                    labelText: 'Nome',
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Nome';
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
                    labelText: 'Qual o curso do aluno?',
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
                      return 'Selecione o curso';
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
                    labelText: 'Qual o ano curricular?',
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
                      return 'Selecione o ano curricular';
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
                              'nome': nameController.text,
                              'ano': dropdownYearValue,
                              'curso': dropdownCourseValue
                            }).then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Aluno adicionado')));
                              nameController.clear();
                            }).catchError((onError) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(onError)));
                            });
                          }
                        },
                        child: const Text('Registar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ListStudents(title: 'Listagem de alunos')),
                          );
                        },
                        child: const Text('Listar'),
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

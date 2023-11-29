import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ListStudents extends StatefulWidget {
  const ListStudents({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  ListStudentsState createState() => ListStudentsState();
}

class ListStudentsState extends State<ListStudents> {
  final dbRef = FirebaseDatabase.instance.ref('students');
  List<Map<dynamic, dynamic>> lists = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title!),
        ),
        body: FutureBuilder(
            future: dbRef.once(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                lists.clear();
                Map<dynamic, dynamic> values = snapshot.data.snapshot.value;
                values.forEach((key, values) {
                  lists.add(values);
                });
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: lists.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Name: ${lists[index]['name']}'),
                            Text('Course: ${lists[index]['course']}'),
                            Text('Curricular year: ${lists[index]['year']}'),
                          ],
                        ),
                      );
                    });
              }
              return const CircularProgressIndicator();
            }));
  }
}
